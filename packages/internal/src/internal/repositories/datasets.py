from internal.database.models.datasets import (
    DatasetModel,
    DatasetCreateModel,
    DatasetUploadModel,
)
import os
import boto3


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

    def update_batch_keys(self, dataset_id, batch_keys) -> DatasetModel:
        dataset = self.get_dataset(dataset_id)
        dataset.batch_keys = batch_keys
        self.datasets_table.put_item(Item=dataset.model_dump(mode="json"))
        return dataset
