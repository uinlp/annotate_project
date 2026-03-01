from fastapi import FastAPI, Request
from api.v1 import router as v1_router
from mangum import Mangum
from aws_lambda_powertools.logging import Logger
from starlette.middleware.sessions import SessionMiddleware
from .settings import SECRET_KEY, CLIENT_ID

logger = Logger()

app = FastAPI(
    swagger_ui_init_oauth={
        "clientId": CLIENT_ID,
        "appName": "UINLP",
        "usePkceWithAuthorizationCodeGrant": True,
    }
)

# Include API routers
app.include_router(router=v1_router, prefix="/v1")

# Session middleware for OAuth2
app.add_middleware(SessionMiddleware, secret_key=SECRET_KEY)


@app.get("/")
async def read_root(request: Request):
    logger.info(f"Hello: {request.scope.get('aws.event')}")
    return {"Hello": request.scope.get("aws.event")}


handler = Mangum(app)
