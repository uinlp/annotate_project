from fastapi import FastAPI, Request
from src.api.v1 import router as v1_router
from mangum import Mangum
from aws_lambda_powertools.logging import Logger

logger = Logger()

app = FastAPI()

app.include_router(router=v1_router, prefix="/v1")


@app.get("/")
async def read_root(request: Request):
    logger.info(f"Hello: {request.scope.get('aws.event')}")
    return {"Hello": request.scope.get("aws.event")}


handler = Mangum(app)
