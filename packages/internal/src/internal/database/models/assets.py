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


class AssetCreateModel(BaseModel):
    dataset_id: str
    task_type: TaskTypeEnum
    name: str
    description: str
    annotate_fields: list[AnnotateFieldModel]
    tags: list[str] = []
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

    @computed_field
    @property
    def id(self) -> str:
        return self.name.lower().replace(" ", "-")
