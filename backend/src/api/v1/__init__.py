from fastapi import APIRouter

from .assets import router as assets_router


router = APIRouter()
router.include_router(assets_router, prefix="/assets", tags=["assets"])
