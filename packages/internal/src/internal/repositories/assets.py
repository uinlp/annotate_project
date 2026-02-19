from internal.database.models.assets import (
    AssetModel,
    AssetCreateModel,
    AssetPublishModel,
)
from .datasets import DatasetsRepository
import os
import boto3


class AssetsRepository:
    def __init__(self):
        assets_table_name = os.environ["ASSETS_TABLE_NAME"]
        self.dynamodb = boto3.resource("dynamodb")
        aws_region = os.getenv("AWS_DEFAULT_REGION") or os.getenv("AWS_REGION")
        self.s3_client = boto3.client(
            "s3", endpoint_url=f"https://s3.{aws_region}.amazonaws.com"
        )
        self.assets_table = self.dynamodb.Table(assets_table_name)

    def list_assets(self) -> list[AssetModel]:
        response = self.assets_table.scan()
        items = response["Items"]
        return [AssetModel(**item) for item in items]

    def get_asset(self, asset_id: str) -> AssetModel:
        response = self.assets_table.get_item(Key={"id": asset_id})
        return AssetModel(**response["Item"])

    def create_asset(self, asset: AssetCreateModel) -> None:
        dr = DatasetsRepository()
        dataset = dr.get_dataset(asset.dataset_id)
        # Create one asset for each dataset batch
        for batch_key in dataset.batch_keys:
            key_num = batch_key.split("#")[1].split(".")[0]
            self.assets_table.put_item(
                Item=AssetModel(
                    **{
                        **asset.model_dump(mode="json"),
                        "dataset_batch_key": batch_key,
                        "id": f"{asset.id}#{key_num}",
                        "name": f"{asset.name} #{key_num}",
                    }
                ).model_dump(mode="json")
            )

    def get_publish_url(self, asset_id, publisher_id):
        bucket = os.environ["ASSETS_PUBLISHES_BUCKET_NAME"]
        url = self.s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": bucket,
                "Key": f"{asset_id}@{publisher_id}.zip",
            },
            ExpiresIn=3600,
        )
        return AssetPublishModel(url=url)

    def published(self, asset_id, publisher_id):
        asset = self.get_asset(asset_id)
        asset.publishers.append(publisher_id)
        self.assets_table.put_item(Item=asset.model_dump(mode="json"))
        # Update publisher's publish_count
