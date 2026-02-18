from internal.database.models.assets import AssetModel, AssetCreateModel
from .datasets import DatasetsRepository
import os
import boto3


class AssetsRepository:
    def __init__(self):
        assets_table_name = os.environ["ASSETS_TABLE_NAME"]
        self.dynamodb = boto3.resource("dynamodb")

        self.assets_table = self.dynamodb.Table(assets_table_name)

    def list_assets(self) -> list[AssetModel]:
        response = self.assets_table.scan()
        items = response["Items"]
        return [AssetModel(**item) for item in items]

    def get_asset(self, asset_id: str) -> AssetModel:
        response = self.assets_table.get_item(Key={"id": asset_id})
        return AssetModel(**response["Item"])

    def create_asset(self, asset: AssetCreateModel) -> AssetModel:
        dr = DatasetsRepository()
        dataset = dr.get_dataset(asset.dataset_id)
        # Create one asset for each dataset batch
        for batch_key in dataset.batch_keys:
            self.assets_table.put_item(
                Item=AssetModel.model_validate(
                    {
                        **asset.model_dump(),
                        "dataset_batch_key": batch_key,
                        "id": f"{asset.id}#{batch_key}",
                        "name": f"{asset.name} #{batch_key}",
                    }
                ).model_dump()
            )
        return asset
