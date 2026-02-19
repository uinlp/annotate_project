from internal.database.models.datasets import (
    DatasetModel,
    DatasetCreateModel,
    DatasetUploadModel,
    ModalityTypeEnum,
)
import os
import boto3
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

    def list_datasets(self) -> list[DatasetModel]:
        response = self.datasets_table.scan()
        items = response["Items"]
        return [DatasetModel(**item) for item in items]

    def get_dataset(self, dataset_id: str) -> DatasetModel:
        response = self.datasets_table.get_item(Key={"id": dataset_id})
        return DatasetModel(**response["Item"])

    def create_dataset(self, dataset: DatasetCreateModel) -> DatasetUploadModel:
        self.datasets_table.put_item(
            Item=DatasetModel.model_validate(
                dataset.model_dump(mode="json")
            ).model_dump(mode="json")
        )
        upload_url = self.s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": os.environ["DATASETS_TEMP_BUCKET_NAME"],
                "Key": f"{dataset.id}.zip",
            },
            ExpiresIn=3600,
        )
        return DatasetUploadModel(url=upload_url)

    def make_batches(self, bucket_name, object_key):
        logger.info(f"Making batches for {bucket_name} {object_key}")
        obj = self.s3_client.get_object(Bucket=bucket_name, Key=object_key)
        data = io.BytesIO(obj["Body"].read())
        with zipfile.ZipFile(data, "r") as zip_ref:
            zip_ref.extractall("tmp")
        del data
        dataset = self.get_dataset(object_key.split(".")[0])
        batch_size = dataset.batch_size
        dest_bucket = os.environ["DATASETS_OBJECTS_BUCKET_NAME"]
        # Parse the dataset according to its modality
        if dataset.modality == ModalityTypeEnum.TEXT:
            logger.info(f"Modality: {dataset.modality}")
            batch_count = 0
            # Read each file in the extracted folder and process in batches
            for filename in os.listdir("tmp"):
                file_path = f"tmp/{filename}"
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
            shutil.rmtree("tmp")

            # Update the dataset in database with all batch keys
            self.datasets_table.put_item(Item=dataset.model_dump(mode="json"))
            logger.info("Dataset batched successfully")
        elif dataset.modality in (
            ModalityTypeEnum.IMAGE,
            ModalityTypeEnum.AUDIO,
            ModalityTypeEnum.VIDEO,
        ):
            # TODO: Split the files into batches of batch_size
            pass
        else:
            raise ValueError(f"Unknown modality: {dataset.modality}")

    def _upload_batch(self, batch, batch_idx, dest_bucket, dataset):
        """Helper to package and upload a single batch to S3."""
        with io.BytesIO() as output:
            with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as zipf:
                for line_idx, line in enumerate(batch):
                    # Each line is stored as a separate file in the zip
                    zipf.writestr(f"data/{line_idx}.txt", line)

            output.seek(0)
            batch_key = f"{dataset.id}#{batch_idx}.zip"
            self.s3_client.put_object(Bucket=dest_bucket, Key=batch_key, Body=output)
            logger.info(f"Uploaded batch: {batch_key}")
            dataset.batch_keys.append(batch_key)
