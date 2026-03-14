from pydantic import BaseModel, computed_field, Field
from datetime import datetime

from .shared import ModalityTypeEnum


class DatasetModel(BaseModel):
    id: str
    name: str
    description: str
    modality: ModalityTypeEnum
    batch_size: int
    batch_keys: list[str] = []
    created_at: datetime
    updated_at: datetime

    @property
    def has_batches(self) -> bool:
        return len(self.batch_keys) != 0


class DatasetCreateModel(BaseModel):
    name: str
    description: str
    modality: ModalityTypeEnum
    batch_size: int

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


class DatasetUploadModel(BaseModel):
    url: str


class DatasetBatchDownloadModel(BaseModel):
    url: str


class DatasetBatchDownloadCreateModel(BaseModel):
    batch_key: str
