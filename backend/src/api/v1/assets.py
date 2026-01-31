from fastapi.responses import FileResponse
from fastapi.routing import APIRouter
from fastapi import Path
from typing import Annotated

from src.database.models.assets import AnnotateAssetModel
from src.repositories.assets import AssetsRepository


router = APIRouter()

assets_repository = AssetsRepository()


@router.get("/")
def get_assets() -> list[AnnotateAssetModel]:
    return assets_repository.list_assets()


@router.get("/{data_id}")
def get_asset(data_id: Annotated[str, Path()]) -> AnnotateAssetModel:
    assets = assets_repository.list_assets()
    for asset in assets:
        if asset.data_id == data_id:
            return asset
    raise ValueError(f"Asset with data_id {data_id} not found")


@router.get("/{data_id}/download")
def download_asset(data_id: Annotated[str, Path()]):
    """
    Download asset in zip format
    """
    return FileResponse(f"src/repositories/assets_data/{data_id}.zip", media_type='application/zip')

