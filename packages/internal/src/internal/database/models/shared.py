from enum import Enum


class ModalityTypeEnum(str, Enum):
    TEXT = "text"
    AUDIO = "audio"


class TaskTypeEnum(str, Enum):
    IMAGE_TO_TEXT = "image_to_text"
    TEXT_TO_TEXT = "text_to_text"
