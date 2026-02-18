from datetime import datetime
import random
from database.models.assets import DatasetModel, AssetModel
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
