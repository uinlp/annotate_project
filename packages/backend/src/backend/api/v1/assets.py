from fastapi.responses import FileResponse
from fastapi.routing import APIRouter
from fastapi import Path
from typing import Annotated

from internal.database.models.assets import (
    AssetModel,
    AssetCreateModel,
    AssetPublishModel,
    AssetPublishCreateModel,
    AssetPublishBodyModel,
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


@router.post("/publish-url")
def create_publish_url(body: AssetPublishBodyModel) -> AssetPublishModel:
    model = AssetPublishCreateModel(
        asset_id=body.asset_id,
        publisher_id="",  # Will be replaced with the publisher id from the token
    )
    return assets_repository.create_publish_url(model)


@router.post("/publish")
def publish_asset(body: AssetPublishBodyModel) -> None:
    model = AssetPublishCreateModel(
        asset_id=body.asset_id,
        publisher_id="",  # Will be replaced with the publisher id from the token
    )
    return assets_repository.published(model)


@router.get("/{asset_id}")
def get_asset(asset_id: Annotated[str, Path()]) -> AssetModel:
    return assets_repository.get_asset(asset_id)
