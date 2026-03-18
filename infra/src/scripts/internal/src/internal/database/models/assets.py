from internal.utilities.parser import make_id
from pydantic import BaseModel, computed_field, Field
from datetime import datetime

from .shared import ModalityTypeEnum


class AnnotateFieldModel(BaseModel):
    name: str
    modality: ModalityTypeEnum
    description: str


class AssetModel(BaseModel):
    id: str
    dataset_id: str
    dataset_batch_key: str
    modality: ModalityTypeEnum
    name: str
    description: str
    created_at: datetime
    updated_at: datetime
    annotate_fields: list[AnnotateFieldModel]
    tags: list[str] = []
    total_publishes: int = 0


class AssetCreateModel(BaseModel):
    dataset_id: str
    name: str
    description: str
    annotate_fields: list[AnnotateFieldModel]
    tags: list[str] = []

    @computed_field
    @property
    def id(self) -> str:
        return make_id(self.name)

    @computed_field
    @property
    def created_at(self) -> datetime:
        return datetime.now()

    @computed_field
    @property
    def updated_at(self) -> datetime:
        return datetime.now()


class AssetPublishCreateModel(BaseModel):
    asset_id: str
    publisher_id: str

    @computed_field
    @property
    def created_at(self) -> datetime:
        return datetime.now()

    @computed_field
    @property
    def updated_at(self) -> datetime:
        return datetime.now()


class AssetPublishModel(BaseModel):
    asset_id: str
    publisher_id: str
    is_verified: bool = False
    is_published: bool = False
    publish_key: str
    created_at: datetime
    updated_at: datetime


class AssetPublishBodyModel(BaseModel):
    asset_id: str
