from pydantic import BaseModel, computed_field, Field
from datetime import datetime

from .shared import ModalityTypeEnum, TaskTypeEnum


class AnnotateFieldModel(BaseModel):
    name: str
    modality: ModalityTypeEnum
    description: str


class AssetModel(BaseModel):
    id: str
    dataset_id: str
    dataset_batch_key: str
    task_type: TaskTypeEnum
    name: str
    description: str
    created_at: datetime
    updated_at: datetime
    annotate_fields: list[AnnotateFieldModel]
    tags: list[str] = []
    publishers: list[str] = []


class AssetCreateModel(BaseModel):
    dataset_id: str
    task_type: TaskTypeEnum
    name: str
    description: str
    annotate_fields: list[AnnotateFieldModel]
    tags: list[str] = []

    @computed_field
    @property
    def id(self) -> str:
        return self.name.lower().replace(" ", "-")

    @computed_field
    @property
    def created_at(self) -> datetime:
        return datetime.now()

    @computed_field
    @property
    def updated_at(self) -> datetime:
        return datetime.now()


class AssetPublishModel(BaseModel):
    url: str
