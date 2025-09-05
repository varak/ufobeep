from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from app.config.environment import settings
import logging

logger = logging.getLogger(__name__)

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
    """Create JWT refresh token with longer expiration"""
    to_encode = data.copy()
    to_encode.update({"type": "refresh"})  # Mark as refresh token
    
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(days=7)  # 7 days for refresh tokens
    
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
        # Debug logging to see what token we're getting
        logger.info(f"DEBUG: Received token for verification: '{token}' (length: {len(token)})")
        logger.info(f"DEBUG: Token segments count: {len(token.split('.')) if token else 0}")
        
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