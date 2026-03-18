from fastapi.routing import APIRouter
from fastapi import Path, Query
from typing import Annotated

from internal.database.models.datasets import (
    DatasetModel,
    DatasetCreateModel,
    DatasetBatchDownloadCreateModel,
)
from internal.database.models.shared import S3UrlModel
from internal.repositories.datasets import DatasetsRepository


router = APIRouter()

datasets_repository = DatasetsRepository()


@router.get("/")
def list_datasets(
    admin_all: Annotated[bool, Query()] = False,
) -> list[DatasetModel]:
    return datasets_repository.list_datasets(admin_all)


@router.post("/")
def create_dataset(dataset: DatasetCreateModel) -> S3UrlModel:
    return datasets_repository.create_dataset(dataset)


@router.put("/{dataset_id}")
def update_dataset(dataset_id: Annotated[str, Path()], dataset: DatasetModel) -> None:
    if dataset_id != dataset.id:
        raise ValueError("Dataset id does not match")
    datasets_repository.update_dataset(dataset)


@router.delete("/{dataset_id}")
def delete_dataset(dataset_id: Annotated[str, Path()]) -> None:
    datasets_repository.delete_dataset(dataset_id)


@router.get("/{dataset_id}")
def get_dataset(dataset_id: Annotated[str, Path()]) -> DatasetModel:
    return datasets_repository.get_dataset(dataset_id)


@router.post("/batch-download-url")
def create_batch_download_url(
    body: DatasetBatchDownloadCreateModel,
) -> S3UrlModel:
    return datasets_repository.create_batch_download_url(body)
