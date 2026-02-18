import unittest
from unittest.mock import MagicMock, patch
import os
from datetime import datetime

# Set environment variables before importing the repository
os.environ["ASSETS_TABLE_NAME"] = "test-assets-table"
os.environ["DATASETS_TABLE_NAME"] = "test-datasets-table"
os.environ["DATASETS_OBJECTS_BUCKET_NAME"] = "test-bucket"

from internal.repositories.assets import AssetsRepository
from internal.database.models.assets import AssetModel, AssetCreateModel
from internal.database.models.datasets import DatasetModel
from internal.database.models.shared import TaskTypeEnum, ModalityTypeEnum


class TestAssetsRepository(unittest.TestCase):
    def setUp(self):
        # Patch boto3 resource
        self.mock_boto3_res = patch("boto3.resource").start()
        self.mock_dynamodb = MagicMock()
        self.mock_boto3_res.return_value = self.mock_dynamodb

        # Mock the assets table
        self.mock_assets_table = MagicMock()
        self.mock_dynamodb.Table.return_value = self.mock_assets_table

        # Initialize repository
        self.repository = AssetsRepository()

    def tearDown(self):
        patch.stopall()

    def test_list_assets(self):
        # Mock scan response
        self.mock_assets_table.scan.return_value = {
            "Items": [
                {
                    "id": "asset-1",
                    "dataset_id": "ds-1",
                    "dataset_batch_key": "batch-1",
                    "task_type": "image_to_text",
                    "name": "Asset 1",
                    "description": "Desc 1",
                    "created_at": "2024-02-18T10:00:00",
                    "updated_at": "2024-02-18T10:00:00",
                    "annotate_fields": [],
                    "tags": [],
                }
            ]
        }

        assets = self.repository.list_assets()

        self.assertEqual(len(assets), 1)
        self.assertIsInstance(assets[0], AssetModel)
        self.assertEqual(assets[0].id, "asset-1")
        self.mock_assets_table.scan.assert_called_once()

    def test_get_asset(self):
        # Mock get_item response
        self.mock_assets_table.get_item.return_value = {
            "Item": {
                "id": "asset-1",
                "dataset_id": "ds-1",
                "dataset_batch_key": "batch-1",
                "task_type": "image_to_text",
                "name": "Asset 1",
                "description": "Desc 1",
                "created_at": "2024-02-18T10:00:00",
                "updated_at": "2024-02-18T10:00:00",
                "annotate_fields": [],
                "tags": [],
            }
        }

        asset = self.repository.get_asset("asset-1")

        self.assertIsInstance(asset, AssetModel)
        self.assertEqual(asset.id, "asset-1")
        self.mock_assets_table.get_item.assert_called_once_with(Key={"id": "asset-1"})

    @patch("internal.repositories.assets.DatasetsRepository")
    def test_create_asset(self, MockDatasetsRepository):
        # Mock DatasetsRepository and the dataset it returns
        mock_dr = MockDatasetsRepository.return_value
        mock_dataset = DatasetModel(
            id="ds-1",
            name="DS 1",
            description="Desc",
            modality=ModalityTypeEnum.TEXT,
            batch_size=10,
            batch_keys=["batch-1", "batch-2"],
            created_at=datetime.now(),
            updated_at=datetime.now(),
        )
        mock_dr.get_dataset.return_value = mock_dataset

        # Create asset input
        asset_create = AssetCreateModel(
            dataset_id="ds-1",
            task_type=TaskTypeEnum.IMAGE_TO_TEXT,
            name="New Asset",
            description="New Desc",
            annotate_fields=[],
            tags=["tag1"],
        )

        result = self.repository.create_asset(asset_create)

        # Verify that put_item was called for each batch key
        self.assertEqual(self.mock_assets_table.put_item.call_count, 2)

        # Check first call arguments
        first_call_item = self.mock_assets_table.put_item.call_args_list[0][1]["Item"]
        self.assertEqual(first_call_item["dataset_batch_key"], "batch-1")
        self.assertTrue(first_call_item["id"].endswith("#batch-1"))

        self.assertEqual(result, asset_create)


if __name__ == "__main__":
    unittest.main()
