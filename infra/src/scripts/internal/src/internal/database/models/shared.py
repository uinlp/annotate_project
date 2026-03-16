from enum import Enum
from pydantic import BaseModel


class ModalityTypeEnum(str, Enum):
    TEXT = "text"
    AUDIO = "audio"
    IMAGE = "image"
    VIDEO = "video"


class TaskTypeEnum(str, Enum):
    IMAGE_TO_TEXT = "image_to_text"
    TEXT_TO_TEXT = "text_to_text"


class S3UrlModel(BaseModel):
    url: str
    expires_in: int | None = None
