from internal.database.models.assets import (
    AssetModel,
    AssetCreateModel,
    AssetPublishCreateModel,
    AssetPublishModel,
)
from internal.database.models.shared import ModalityTypeEnum, S3UrlModel
from .datasets import DatasetsRepository
import os
import boto3
from boto3.dynamodb.conditions import Key


class AssetsRepository:
    def __init__(self):
        assets_table_name = os.environ["ASSETS_TABLE_NAME"]
        publishes_table_name = os.environ["PUBLISHES_TABLE_NAME"]
        self.dynamodb = boto3.resource("dynamodb")
        aws_region = os.getenv("AWS_DEFAULT_REGION") or os.getenv("AWS_REGION")
        self.s3_client = boto3.client(
            "s3", endpoint_url=f"https://s3.{aws_region}.amazonaws.com"
        )
        self.assets_table = self.dynamodb.Table(assets_table_name)
        self.publishes_table = self.dynamodb.Table(publishes_table_name)

    def list_assets(self, modality: ModalityTypeEnum | None = None) -> list[AssetModel]:
        if modality:
            response = self.assets_table.query(
                IndexName="modality-index",
                KeyConditionExpression=Key("modality").eq(modality.value),
            )
        else:
            response = self.assets_table.scan()
        items = response["Items"]
        return [AssetModel(**item) for item in items]

    def get_asset(self, asset_id: str) -> AssetModel:
        response = self.assets_table.get_item(Key={"id": asset_id})
        if "Item" not in response:
            raise ValueError(f"Asset with id {asset_id} not found")
        return AssetModel(**response["Item"])

    def update_asset(self, asset: AssetModel) -> None:
        self.assets_table.put_item(Item=asset.model_dump(mode="json"))

    def delete_asset(self, asset_id: str) -> None:
        self.assets_table.delete_item(Key={"id": asset_id})

    def create_asset(self, asset: AssetCreateModel) -> None:
        dr = DatasetsRepository()
        dataset = dr.get_dataset(asset.dataset_id)
        # Create one asset for each dataset batch
        for batch_key in dataset.batch_keys:
            key_num = batch_key.split("/")[1].split(".")[0]
            self.assets_table.put_item(
                Item=AssetModel(
                    **{
                        **asset.model_dump(mode="json"),
                        "modality": dataset.modality,
                        "dataset_batch_key": batch_key,
                        "id": f"{asset.id}-{key_num}",
                        "name": f"{asset.name} #{key_num}",
                    }
                ).model_dump(mode="json")
            )

    def create_publish_url(self, model: AssetPublishCreateModel):
        bucket = os.environ["PUBLISHES_BUCKET_NAME"]
        key = f"{model.asset_id}/{model.publisher_id}.zip"
        self.publishes_table.put_item(
            Item=AssetPublishModel(
                **{
                    **model.model_dump(mode="json"),
                    "publish_key": key,
                    "is_published": False,
                }
            ).model_dump(mode="json")
        )
        url = self.s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": bucket,
                "Key": key,
            },
            ExpiresIn=3600,
        )
        return S3UrlModel(url=url, expires_in=3600)

    def publish_asset(self, model: AssetPublishCreateModel):
        # asset = self.get_asset(model.asset_id)
        # asset.publishers.append(model.publisher_id)
        # self.assets_table.put_item(Item=asset.model_dump(mode="json"))
        # self.publishes_table.put_item(
        #     Item=AssetPublishModel(
        #         **{
        #             **model.model_dump(mode="json"),
        #             "publish_key": f"{model.asset_id}/{model.publisher_id}.zip",
        #         }
        #     ).model_dump(mode="json")
        # )
        self.publishes_table.update_item(
            Key={"asset_id": model.asset_id, "publisher_id": model.publisher_id},
            UpdateExpression="SET is_published = :val",
            ExpressionAttributeValues={":val": True},
        )
        self.assets_table.update_item(
            Key={"id": model.asset_id},
            # UpdateExpression="SET total_publishes = total_publishes + :inc",
            # ExpressionAttributeValues={":inc": 1},
            UpdateExpression="SET total_publishes = if_not_exists(total_publishes, :zero) + :inc",
            ExpressionAttributeValues={":inc": 1, ":zero": 0},
        )

    def verify_publish(self, model: AssetPublishCreateModel):
        self.publishes_table.update_item(
            Key={"asset_id": model.asset_id, "publisher_id": model.publisher_id},
            UpdateExpression="SET is_verified = :val",
            ExpressionAttributeValues={":val": True},
        )

    def list_publishes(
        self, asset_id: str | None = None, publisher_id: str | None = None
    ) -> list[AssetPublishModel]:
        if asset_id:
            response = self.publishes_table.query(
                KeyConditionExpression=Key("asset_id").eq(asset_id),
            )
        elif publisher_id:
            response = self.publishes_table.query(
                IndexName="publisher-id-index",
                KeyConditionExpression=Key("publisher_id").eq(publisher_id),
            )
        else:
            response = self.publishes_table.scan()
        return [AssetPublishModel(**item) for item in response["Items"]]
