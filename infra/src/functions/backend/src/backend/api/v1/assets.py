from fastapi.responses import FileResponse
from fastapi.routing import APIRouter
from fastapi import Path, Query, Depends
from typing import Annotated

from internal.database.models.assets import (
    AssetModel,
    AssetCreateModel,
    AssetPublishCreateModel,
    AssetPublishBodyModel,
    AssetPublishModel,
)
from internal.database.models.shared import ModalityTypeEnum, S3UrlModel
from internal.repositories.assets import AssetsRepository
from backend.dependencies import get_current_user_me


router = APIRouter()

assets_repository = AssetsRepository()


@router.post("/publish-upload-url")
def create_publish_upload_url(
    body: AssetPublishBodyModel, user: dict = Depends(get_current_user_me)
) -> S3UrlModel:
    model = AssetPublishCreateModel(
        asset_id=body.asset_id,
        publisher_id=user["sub"],
    )
    return assets_repository.create_publish_url(model)


@router.post("/acknowledge-publish")
def acknowledge_publish(
    body: AssetPublishBodyModel, user: dict = Depends(get_current_user_me)
) -> None:
    model = AssetPublishCreateModel(
        asset_id=body.asset_id,
        publisher_id=user["sub"],
    )
    return assets_repository.publish_asset(model)


@router.post("/publishes/verify")
def verify_publish(create_model: AssetPublishCreateModel) -> None:
    return assets_repository.verify_publish(create_model)


@router.get("/publishes")
def list_publishes(
    asset_id: Annotated[str, Query()] | None = None,
    publisher_id: Annotated[str, Query()] | None = None,
) -> list[AssetPublishModel]:
    return assets_repository.list_publishes(asset_id, publisher_id)


@router.get("/publishes/me")
def list_my_publishes(
    user: dict = Depends(get_current_user_me),
) -> list[AssetPublishModel]:
    return assets_repository.list_publishes(publisher_id=user["sub"])


@router.get("/")
def list_assets(
    modality: Annotated[ModalityTypeEnum, Query()] | None = None,
    admin_all: bool = False,
) -> list[AssetModel]:
    return assets_repository.list_assets(modality, admin_all)


@router.post("/")
def create_asset(asset: AssetCreateModel) -> None:
    assets_repository.create_asset(asset)


@router.put("/{asset_id}")
def update_asset(asset_id: Annotated[str, Path()], asset: AssetModel) -> None:
    if asset_id != asset.id:
        raise ValueError("Asset id does not match")
    assets_repository.update_asset(asset)


@router.delete("/{asset_id}")
def delete_asset(asset_id: Annotated[str, Path()]) -> None:
    assets_repository.delete_asset(asset_id)


@router.get("/{asset_id}")
def get_asset(asset_id: Annotated[str, Path()]) -> AssetModel:
    return assets_repository.get_asset(asset_id)
