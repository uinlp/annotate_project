from fastapi.routing import APIRouter
from fastapi import Path
from typing import Annotated

from internal.database.models.datasets import (
    DatasetModel,
    DatasetCreateModel,
    DatasetUploadModel,
    DatasetBatchDownloadModel,
    DatasetBatchDownloadCreateModel,
)
from internal.repositories.datasets import DatasetsRepository


router = APIRouter()

datasets_repository = DatasetsRepository()


@router.get("/")
def list_datasets() -> list[DatasetModel]:
    return datasets_repository.list_datasets()


@router.post("/")
def create_dataset(dataset: DatasetCreateModel) -> DatasetUploadModel:
    return datasets_repository.create_dataset(dataset)


@router.get("/{dataset_id}")
def get_dataset(dataset_id: Annotated[str, Path()]) -> DatasetModel:
    return datasets_repository.get_dataset(dataset_id)


@router.get("/batch-download-url")
def get_batch_download_url(
    body: DatasetBatchDownloadCreateModel,
) -> DatasetBatchDownloadModel:
    return datasets_repository.get_batch_download_url(body)
