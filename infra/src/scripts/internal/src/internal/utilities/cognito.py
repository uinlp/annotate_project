import boto3
from fastapi import HTTPException
from jose import jwt, JWTError
import os
from typing import Any


cognito_client = boto3.client("cognito-idp")


def get_current_user(
    token: str,
    jwks: list[dict],
    user_pool_client_id: str | None = os.getenv("COGNITO_CLIENT_ID"),
    user_pool_id: str | None = os.getenv("COGNITO_USER_POOL_ID"),
    region: str | None = os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION"),
) -> dict[str, Any]:
    try:
        # 2. Decode the token header to find the correct public key (kid)
        header = jwt.get_unverified_header(token)
        kid = header["kid"]
        key = next((k for k in jwks if k["kid"] == kid), None)

        if not key:
            raise HTTPException(status_code=401, detail="Public key not found")

        # 3. Verify the token signature and claims (exp, iss, aud)
        payload = jwt.decode(
            token,
            key,
            algorithms=["RS256"],
            audience=user_pool_client_id,
            issuer=f"https://cognito-idp.{region}://{user_pool_id}",
        )

        # 4. (Optional) Use Boto3 to get extra user info not in the token
        # This requires the 'aws.cognito.signin.user.admin' scope in the token
        user_info = cognito_client.get_user(AccessToken=token)

        return {
            "username": payload.get("username"),
            "sub": payload.get("sub"),
            "attributes": user_info.get("UserAttributes"),
        }

    except (JWTError, Exception) as e:
        raise HTTPException(
            status_code=401,
            detail=f"Could not validate credentials: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )
