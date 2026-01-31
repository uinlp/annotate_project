from datetime import datetime
import random
from src.database.models.assets import AnnotateAssetModel, AnnotateFieldModel, TaskTypeEnum, AnnotateFieldTypeEnum

class AssetsRepository:
    def __init__(self):
        pass

    def list_assets(self) -> list[AnnotateAssetModel]:
        assets: list[AnnotateAssetModel] = []
        id_ = 1
        for i in range(1, 30):
            assets.append(AnnotateAssetModel(
                id=str(id_),
                data_id=f"nllb_en_{i}",
                type=TaskTypeEnum.TEXT_TO_TEXT,
                title=f"NLLB English-Yoruba Text Collection {i}",
                description=f"You're to translate the text from English to Yoruba.",
                created_at=datetime.now(),
                updated_at=datetime.now(),
                annotate_fields=[
                    AnnotateFieldModel(
                        name="translation",
                        type=AnnotateFieldTypeEnum.TEXT,
                        description="Translate text to Yoruba.",
                    ),
                ],
                tags=["english", "translation", "yoruba"],
            ))
            id_ += 1
            assets.append(AnnotateAssetModel(
                id=str(id_),
                data_id=f"nllb_en_{i}",
                type=TaskTypeEnum.TEXT_TO_TEXT,
                title=f"NLLB English-Igbo Text Collection {i}",
                description=f"You're to translate the text from English to Igbo.",
                created_at=datetime.now(),
                updated_at=datetime.now(),
                annotate_fields=[
                    AnnotateFieldModel(
                        name="translation",
                        type=AnnotateFieldTypeEnum.TEXT,
                        description="Translate text to Igbo.",
                    ),
                ],
                tags=["english", "translation", "igbo"],
            ))
            id_ += 1
        # shuffle the assets list
        random.shuffle(assets)
        return assets