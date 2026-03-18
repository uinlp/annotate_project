from internal.database.models.datasets import (
    DatasetModel,
    DatasetCreateModel,
    ModalityTypeEnum,
    DatasetBatchDownloadCreateModel,
)
from internal.database.models.shared import S3UrlModel
import os
import boto3
from boto3.dynamodb.conditions import Attr
import io
import zipfile
import itertools
import shutil
from aws_lambda_powertools.logging import Logger

logger = Logger()


class DatasetsRepository:
    def __init__(self):
        datasets_table_name = os.environ["DATASETS_TABLE_NAME"]
        self.dynamodb = boto3.resource("dynamodb")
        aws_region = os.getenv("AWS_DEFAULT_REGION") or os.getenv("AWS_REGION")
        self.s3_client = boto3.client(
            "s3", endpoint_url=f"https://s3.{aws_region}.amazonaws.com"
        )

        self.datasets_table = self.dynamodb.Table(datasets_table_name)

    def list_datasets(self, admin_all: bool = False) -> list[DatasetModel]:
        filter_expression = None
        if not admin_all:
            filter_expression = Attr("is_completed").eq(True) & Attr("is_deleted").eq(
                False
            )

        kwargs = {}
        if filter_expression is not None:
            kwargs["FilterExpression"] = filter_expression
        response = self.datasets_table.scan(**kwargs)
        items = response["Items"]
        return [DatasetModel(**item) for item in items]

    def get_dataset(self, dataset_id: str) -> DatasetModel:
        response = self.datasets_table.get_item(Key={"id": dataset_id})
        if "Item" not in response:
            raise ValueError(f"Dataset with id {dataset_id} not found")
        return DatasetModel(**response["Item"])

    def update_dataset(self, dataset: DatasetModel) -> None:
        self.datasets_table.put_item(Item=dataset.model_dump(mode="json"))

    def delete_dataset(self, dataset_id: str) -> None:
        # self.datasets_table.delete_item(Key={"id": dataset_id})
        self.datasets_table.update_item(
            Key={"id": dataset_id},
            UpdateExpression="SET is_deleted = :is_deleted",
            ExpressionAttributeValues={":is_deleted": True},
        )

    def create_dataset(self, dataset: DatasetCreateModel) -> S3UrlModel:
        self.datasets_table.put_item(
            Item=DatasetModel(**dataset.model_dump(mode="json")).model_dump(mode="json")
        )
        upload_url = self.s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": os.environ["DATASETS_TEMP_BUCKET_NAME"],
                "Key": f"{dataset.id}.zip",
            },
            ExpiresIn=3600,
        )
        return S3UrlModel(url=upload_url, expires_in=3600)

    def make_batches(self, bucket_name, object_key):
        logger.info(f"Making batches for {bucket_name} {object_key}")
        obj = self.s3_client.get_object(Bucket=bucket_name, Key=object_key)
        data = io.BytesIO(obj["Body"].read())
        with zipfile.ZipFile(data, "r") as zip_ref:
            zip_ref.extractall("/tmp/datasets")
        del data
        dataset = self.get_dataset(object_key.split(".")[0])
        dataset.batch_keys = []  # Reset the list to avoid duplication
        batch_size = dataset.batch_size
        dest_bucket = os.environ["DATASETS_OBJECTS_BUCKET_NAME"]
        # Parse the dataset according to its modality
        if dataset.modality == ModalityTypeEnum.TEXT:
            logger.info(f"Modality: {dataset.modality}")
            batch_count = 1  # Start from 1
            # Read each file in the extracted folder and process in batches
            for filename in os.listdir("/tmp/datasets"):
                file_path = f"/tmp/datasets/{filename}"
                if not os.path.isfile(file_path) or not filename.endswith(
                    (".txt", ".md")
                ):
                    continue

                logger.info(f"Processing filename: {filename}")
                with open(file_path, "r") as f:
                    if filename.endswith(".txt"):
                        # Read batch-sized lines at a time to optimize memory usage
                        while True:
                            batch = list(itertools.islice(f, batch_size))
                            if not batch:
                                break

                            self._upload_batch(batch, batch_count, dest_bucket, dataset)
                            batch_count += 1
                    else:
                        # For other text formats (like .md), treat the entire file as one item
                        batch = [f.read()]
                        self._upload_batch(batch, batch_count, dest_bucket, dataset)
                        batch_count += 1

            # Clean up extracted files
            shutil.rmtree("/tmp/datasets")

            # Update the dataset in database with all batch keys
            self.datasets_table.put_item(Item=dataset.model_dump(mode="json"))
            logger.info("Dataset batched successfully")
            # Remove the dataset from temp bucket
            self.s3_client.delete_object(
                Bucket=bucket_name,
                Key=object_key,
            )
        elif dataset.modality in (
            ModalityTypeEnum.IMAGE,
            ModalityTypeEnum.AUDIO,
            ModalityTypeEnum.VIDEO,
        ):
            logger.info(f"Modality: {dataset.modality}")
            batch_count = 1

            valid_extensions = {
                ModalityTypeEnum.IMAGE: (".jpg", ".jpeg", ".png", ".gif", ".webp"),
                ModalityTypeEnum.AUDIO: (".mp3", ".wav", ".ogg", ".flac", ".m4a"),
                ModalityTypeEnum.VIDEO: (".mp4", ".avi", ".mov", ".mkv", ".webm"),
            }[dataset.modality]

            all_files = []
            for root, _, files in os.walk("/tmp/datasets"):
                for filename in files:
                    if filename.lower().endswith(valid_extensions):
                        all_files.append(os.path.join(root, filename))

            all_files.sort()

            for i in range(0, len(all_files), batch_size):
                batch_files = all_files[i : i + batch_size]
                self._upload_media_batch(batch_files, batch_count, dest_bucket, dataset)
                batch_count += 1

            shutil.rmtree("/tmp/datasets")

            self.datasets_table.put_item(Item=dataset.model_dump(mode="json"))
            logger.info("Dataset batched successfully")

            self.s3_client.delete_object(
                Bucket=bucket_name,
                Key=object_key,
            )
        else:
            raise ValueError(f"Unknown modality: {dataset.modality}")
        dataset.is_completed = True
        self.datasets_table.put_item(Item=dataset.model_dump(mode="json"))

    def _upload_batch(self, batch, batch_idx, dest_bucket, dataset):
        """Helper to package and upload a single batch to S3."""
        with io.BytesIO() as output:
            with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as zipf:
                for line_idx, line in enumerate(batch):
                    # Each line is stored as a separate file in the zip
                    zipf.writestr(f"data/{line_idx + 1}.txt", line)

            output.seek(0)
            batch_key = f"{dataset.id}/{batch_idx}.zip"
            self.s3_client.put_object(Bucket=dest_bucket, Key=batch_key, Body=output)
            logger.info(f"Uploaded batch: {batch_key}")
            dataset.batch_keys.append(batch_key)

    def _upload_media_batch(self, file_paths, batch_idx, dest_bucket, dataset):
        """Helper to package and upload a batch of media files to S3."""
        with io.BytesIO() as output:
            with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as zipf:
                for idx, file_path in enumerate(file_paths):
                    ext = os.path.splitext(file_path)[1]
                    zipf.write(file_path, arcname=f"data/{idx + 1}{ext}")

            output.seek(0)
            batch_key = f"{dataset.id}/{batch_idx}.zip"
            self.s3_client.put_object(Bucket=dest_bucket, Key=batch_key, Body=output)
            logger.info(f"Uploaded media batch: {batch_key}")
            dataset.batch_keys.append(batch_key)

    def create_batch_download_url(self, model: DatasetBatchDownloadCreateModel):
        dataset_objects_bucket = os.environ["DATASETS_OBJECTS_BUCKET_NAME"]
        url = self.s3_client.generate_presigned_url(
            "get_object",
            Params={
                "Bucket": dataset_objects_bucket,
                "Key": model.batch_key,
            },
            ExpiresIn=3600,
        )
        return S3UrlModel(url=url, expires_in=3600)
