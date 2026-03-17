from internal.utilities.parser import make_id
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
        return make_id(self.name)

    @computed_field
    @property
    def created_at(self) -> datetime:
        return datetime.now()

    @computed_field
    @property
    def updated_at(self) -> datetime:
        return datetime.now()


class DatasetBatchDownloadCreateModel(BaseModel):
    batch_key: str
