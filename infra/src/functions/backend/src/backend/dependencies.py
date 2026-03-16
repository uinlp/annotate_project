from fastapi import Depends
import requests
from fastapi.security import OAuth2AuthorizationCodeBearer
from backend.settings import (
    COGNITO_AUTHORIZATION_URL,
    COGNITO_TOKEN_URL,
    COGNITO_USER_POOL_ID,
    AWS_REGION,
    COGNITO_CLIENT_ID,
)
from internal.utilities.cognito import get_current_user

# Cache JWKS to avoid frequent network calls
JWKS_URL = (
    f"https://cognito-idp.{AWS_REGION}://{COGNITO_USER_POOL_ID}/.well-known/jwks.json"
)
jwks = requests.get(JWKS_URL).json()["keys"]

oauth2_scheme = OAuth2AuthorizationCodeBearer(
    authorizationUrl=COGNITO_AUTHORIZATION_URL,
    tokenUrl=COGNITO_TOKEN_URL,
    scopes={
        "openid": "OpenID Connect",
        "profile": "Profile",
        "email": "Email",
    },
)

is_authenticated = Depends(oauth2_scheme)


# Get current user from token
async def get_current_user_me(token: str = Depends(oauth2_scheme)):
    return get_current_user(
        token=token,
        jwks=jwks,
        user_pool_client_id=COGNITO_CLIENT_ID,
        user_pool_id=COGNITO_USER_POOL_ID,
        region=AWS_REGION,
    )
