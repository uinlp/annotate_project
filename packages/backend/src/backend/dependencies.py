from fastapi import Depends
from fastapi.security import OAuth2AuthorizationCodeBearer
from .settings import AUTHORIZATION_URL, TOKEN_URL

oauth2_scheme = OAuth2AuthorizationCodeBearer(
    authorizationUrl=AUTHORIZATION_URL,
    tokenUrl=TOKEN_URL,
    scopes={
        "openid": "OpenID Connect",
        "profile": "Profile",
        "email": "Email",
    },
)

is_authenticated = Depends(oauth2_scheme)
