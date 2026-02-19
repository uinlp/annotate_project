from fastapi.responses import FileResponse
from fastapi.routing import APIRouter
from fastapi import Path
from typing import Annotated

from internal.database.models.assets import (
    AssetModel,
    AssetCreateModel,
    AssetPublishModel,
)
from internal.repositories.assets import AssetsRepository


router = APIRouter()

assets_repository = AssetsRepository()


@router.get("/")
def list_assets() -> list[AssetModel]:
    return assets_repository.list_assets()


@router.post("/")
def create_asset(asset: AssetCreateModel) -> None:
    assets_repository.create_asset(asset)


@router.get("/{asset_id}")
def get_asset(asset_id: Annotated[str, Path()]) -> AssetModel:
    return assets_repository.get_asset(asset_id)


@router.get("/{asset_id}/publish-url")
def get_publish_url(asset_id: Annotated[str, Path()]) -> AssetPublishModel:
    publisher_id = "test"  # Will be replaced with the publisher id from the token
    return assets_repository.get_publish_url(asset_id, publisher_id)


@router.post("/{asset_id}/publish")
def publish_asset(asset_id: Annotated[str, Path()]) -> None:
    publisher_id = "test"  # Will be replaced with the publisher id from the token
    return assets_repository.published(asset_id, publisher_id)
