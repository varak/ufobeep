from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from app.config.environment import settings
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional
import logging

logger = logging.getLogger(__name__)
security = HTTPBearer(auto_error=False)

def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(hours=settings.jwt_expiration_hours)
    
    to_encode.update({"exp": expire})
    
    try:
        encoded_jwt = jwt.encode(
            to_encode, 
            settings.jwt_secret, 
            algorithm=settings.jwt_algorithm
        )
        return encoded_jwt
    except Exception as e:
        logger.error(f"Error creating access token: {e}")
        raise


def create_refresh_token(data: dict, expires_delta: timedelta = None) -> str:
    """Create JWT refresh token with effectively infinite expiration (10 years)"""
    to_encode = data.copy()
    to_encode.update({"type": "refresh"})  # Mark as refresh token

    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(days=3650)  # 10 years - effectively infinite
    
    to_encode.update({"exp": expire})
    
    try:
        encoded_jwt = jwt.encode(
            to_encode, 
            settings.jwt_secret, 
            algorithm=settings.jwt_algorithm
        )
        return encoded_jwt
    except Exception as e:
        logger.error(f"Error creating refresh token: {e}")
        raise


def verify_access_token(token: str) -> dict:
    """Verify and decode JWT access token with clock skew tolerance"""
    try:
        payload = jwt.decode(
            token, 
            settings.jwt_secret, 
            algorithms=[settings.jwt_algorithm],
            options={"verify_exp": True, "leeway": timedelta(seconds=300)}  # ±5 minute clock skew tolerance
        )
        return payload
    except JWTError as e:
        logger.warning(f"JWT verification failed: {e}")
        raise
    except Exception as e:
        logger.error(f"Error verifying access token: {e}")
        raise


async def get_current_user_id(token: Optional[HTTPAuthorizationCredentials] = Depends(security)) -> Optional[str]:
    """Extract user ID from JWT token"""
    if not token:
        return None

    try:
        payload = verify_access_token(token.credentials)
        user_id = payload.get("sub") or payload.get("user_id")
        return user_id
    except Exception:
        return None


async def require_current_user_id(token: Optional[HTTPAuthorizationCredentials] = Depends(security)) -> str:
    """Require authenticated user and return user ID"""
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required"
        )

    user_id = await get_current_user_id(token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token"
        )

    return user_id