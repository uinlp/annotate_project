from pydantic import BaseModel
from enum import Enum
from datetime import datetime


class AnnotateFieldTypeEnum(str, Enum):
    TEXT = "text"
    AUDIO = "audio"


class TaskTypeEnum(str, Enum):
    IMAGE_TO_TEXT = "image_to_text"
    TEXT_TO_TEXT = "text_to_text"


class AnnotateFieldModel(BaseModel):
    name: str
    type: AnnotateFieldTypeEnum
    description: str


class AnnotateAssetModel(BaseModel):
    id: str
    data_id: str
    type: TaskTypeEnum
    title: str
    description: str
    created_at: datetime
    updated_at: datetime
    annotate_fields: list[AnnotateFieldModel]
    tags: list[str] = []
