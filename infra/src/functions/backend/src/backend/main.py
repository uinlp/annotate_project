from fastapi import FastAPI, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from backend.api.v1 import router as v1_router
from mangum import Mangum
from aws_lambda_powertools.logging import Logger
from starlette.middleware.sessions import SessionMiddleware
from backend.settings import (
    SECRET_KEY,
    COGNITO_CLIENT_ID,
    COGNITO_REDIRECT_URI,
)
from backend.dependencies import is_authenticated, get_current_user_me

logger = Logger()

app = FastAPI(
    swagger_ui_init_oauth={
        "clientId": COGNITO_CLIENT_ID,
        "appName": "UINLP",
        "usePkceWithAuthorizationCodeGrant": True,
        "scopes": ["openid", "profile", "email"],
    },
    swagger_ui_oauth2_redirect_url=COGNITO_REDIRECT_URI,
)

# Include API routers
app.include_router(router=v1_router, prefix="/v1", dependencies=[is_authenticated])

# Session middleware for OAuth2
app.add_middleware(SessionMiddleware, secret_key=SECRET_KEY or "")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/", dependencies=[is_authenticated])
async def read_root(request: Request):
    logger.info(f"Hello: {request.scope.get('aws.event')}")
    return {"Hello": request.scope.get("aws.event")}


@app.get("/user")
async def get_user(request: Request, user: dict = Depends(get_current_user_me)):
    print(request.scope)
    return {"user": user}


handler = Mangum(app)
