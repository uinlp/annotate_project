from fastapi import FastAPI, Request
from api.v1 import router as v1_router
from mangum import Mangum
from aws_lambda_powertools.logging import Logger
from starlette.middleware.sessions import SessionMiddleware
from settings import SECRET_KEY, COGNITO_CLIENT_ID, COGNITO_REDIRECT_URI
from dependencies import is_authenticated

logger = Logger()

app = FastAPI(
    swagger_ui_init_oauth={
        "clientId": COGNITO_CLIENT_ID,
        "appName": "UINLP",
        "usePkceWithAuthorizationCodeGrant": True,
        "scopes": ["openid", "profile", "email"],
        "additionalQueryStringParams": {
            "redirect_uri": COGNITO_REDIRECT_URI,
        },
    }
)

# Include API routers
app.include_router(router=v1_router, prefix="/v1", dependencies=[is_authenticated])

# Session middleware for OAuth2
app.add_middleware(SessionMiddleware, secret_key=SECRET_KEY)


@app.get("/", dependencies=[is_authenticated])
async def read_root(request: Request):
    logger.info(f"Hello: {request.scope.get('aws.event')}")
    return {"Hello": request.scope.get("aws.event")}


handler = Mangum(app)
