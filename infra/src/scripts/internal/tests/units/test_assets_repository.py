import unittest
from unittest.mock import MagicMock, patch
import os
from datetime import datetime

# Set environment variables before importing the repository
os.environ["ASSETS_TABLE_NAME"] = "test-assets-table"
os.environ["DATASETS_TABLE_NAME"] = "test-datasets-table"
os.environ["DATASETS_OBJECTS_BUCKET_NAME"] = "test-bucket"

from internal.repositories.assets import AssetsRepository
from internal.database.models.assets import (
    AssetModel,
    AssetCreateModel,
    AssetPublishCreateModel,
)
from internal.database.models.datasets import DatasetModel
from internal.database.models.shared import TaskTypeEnum, ModalityTypeEnum


class TestAssetsRepository(unittest.TestCase):
    def setUp(self):
        self.repository = AssetsRepository()

    def test_publish_asset(self):
        self.repository.publish_asset(
            AssetPublishCreateModel(
                asset_id="english-to-yoruba-translation-10",
                publisher_id="210c3218-00c1-70b1-24cd-68afe07c71cf",
            )
        )


if __name__ == "__main__":
    unittest.main()
