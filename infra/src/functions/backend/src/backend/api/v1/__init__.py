from fastapi import APIRouter

from .assets import router as assets_router
from .datasets import router as datasets_router


router = APIRouter()
router.include_router(assets_router, prefix="/assets", tags=["assets"])
router.include_router(datasets_router, prefix="/datasets", tags=["datasets"])
