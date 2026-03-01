from fastapi import Depends
from fastapi.security import OAuth2AuthorizationCodeBearer
from settings import COGNITO_AUTHORIZATION_URL, COGNITO_TOKEN_URL

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
