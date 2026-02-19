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
        dataset_id = object_key.split(".")[0]
        dataset = self.get_dataset(dataset_id)
        batch_size = dataset.batch_size
        dest_bucket = os.environ["DATASETS_OBJECTS_BUCKET_NAME"]
        # Parse the dataset according to its modality
        if dataset.modality == ModalityTypeEnum.TEXT:
            logger.info(f"Modality: {dataset.modality}")
            # Read each file in the extracted folder line by line
            for filename in os.listdir("tmp"):
                logger.info(f"Filename: {filename}")
                if filename.endswith((".txt", ".md")):
                    with open(f"tmp/{filename}", "r") as f:
                        lines = (
                            f.readlines() if filename.endswith(".txt") else [f.read()]
                        )
                    # Create batches of batch_size lines
                    batches = [
                        lines[i : i + batch_size]
                        for i in range(0, len(lines), batch_size)
                    ]
                    # Save each batch as a zip file into dest bucket
                    for i, batch in enumerate(batches):
                        with io.BytesIO() as output:
                            with zipfile.ZipFile(
                                output, "w", zipfile.ZIP_DEFLATED
                            ) as zipf:
                                for line in batch:
                                    zipf.writestr(f"data/{i}.txt", line)
                            output.seek(0)
                            batch_key = f"{dataset_id}#{i}.zip"
                            self.s3_client.put_object(
                                Bucket=dest_bucket, Key=batch_key, Body=output.read()
                            )
                            logger.info(f"Batch key: {batch_key}")
                            dataset.batch_keys.append(batch_key)
            # Update the dataset in database
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
