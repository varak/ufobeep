"""
Firebase Authentication Middleware for UFOBeep API
Validates Firebase ID tokens and provides user context
Replaces device ID authentication with Firebase UID
"""

from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin
from firebase_admin import auth, credentials
import asyncpg
import os
import logging
from typing import Optional

logger = logging.getLogger(__name__)

# Initialize Firebase Admin SDK
def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        if not firebase_admin._apps:
            # Try to use service account key file first
            cred_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_KEY')
            if cred_path and os.path.exists(cred_path):
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase Admin initialized with service account")
            else:
                # Use default credentials (works on Cloud Run, GCE, etc.)
                firebase_admin.initialize_app()
                logger.info("Firebase Admin initialized with default credentials")
        else:
            logger.info("Firebase Admin already initialized")
    except Exception as e:
        logger.error(f"Failed to initialize Firebase Admin: {e}")
        # Don't raise error - allow app to start without Firebase
        # We'll handle auth failures gracefully in the middleware

# Initialize on import
initialize_firebase()

# HTTP Bearer token scheme
security = HTTPBearer(auto_error=False)

class FirebaseUser:
    """Represents an authenticated Firebase user"""
    def __init__(self, uid: str, email: Optional[str] = None, phone: Optional[str] = None, 
                 username: Optional[str] = None):
        self.uid = uid
        self.email = email
        self.phone = phone
        self.username = username

async def verify_firebase_token(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security)
) -> Optional[FirebaseUser]:
    """
    Verify Firebase ID token from Authorization header
    Returns None for anonymous/public endpoints
    """
    if not credentials:
        return None
        
    try:
        # Verify the token
        decoded_token = auth.verify_id_token(credentials.credentials)
        uid = decoded_token['uid']
        email = decoded_token.get('email')
        phone = decoded_token.get('phone_number')
        
        logger.info(f"Token verified for UID: {uid}")
        
        # Create Firebase user object
        firebase_user = FirebaseUser(
            uid=uid,
            email=email, 
            phone=phone
        )
        
        return firebase_user
        
    except auth.InvalidIdTokenError:
        logger.warning("Invalid Firebase ID token")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token"
        )
    except auth.ExpiredIdTokenError:
        logger.warning("Expired Firebase ID token") 
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token expired"
        )
    except Exception as e:
        logger.error(f"Token verification failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed"
        )

async def require_auth(
    firebase_user: Optional[FirebaseUser] = Depends(verify_firebase_token)
) -> FirebaseUser:
    """
    Require authenticated user for protected endpoints
    """
    if not firebase_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required"
        )
    return firebase_user

async def get_user_with_username(
    firebase_user: FirebaseUser = Depends(require_auth),
    db: asyncpg.Pool = Depends(lambda: None)  # Will be injected by endpoint
) -> FirebaseUser:
    """
    Get Firebase user with username from database
    """
    if not db:
        # Username lookup not available without database
        return firebase_user
        
    try:
        # Look up username by Firebase UID
        query = "SELECT username FROM users WHERE firebase_uid = $1"
        result = await db.fetchval(query, firebase_user.uid)
        
        if result:
            firebase_user.username = result
            logger.debug(f"Found username '{result}' for UID {firebase_user.uid}")
        else:
            logger.warning(f"No username found for UID {firebase_user.uid}")
            
        return firebase_user
        
    except Exception as e:
        logger.error(f"Error looking up username: {e}")
        return firebase_user

# Backwards compatibility helpers for migration

async def get_current_user_id(
    firebase_user: Optional[FirebaseUser] = Depends(verify_firebase_token)
) -> Optional[str]:
    """
    Get current user's Firebase UID
    Returns None for anonymous users
    """
    return firebase_user.uid if firebase_user else None

async def require_user_id(
    firebase_user: FirebaseUser = Depends(require_auth)  
) -> str:
    """
    Require authenticated user and return UID
    """
    return firebase_user.uid

# Optional auth - allows both authenticated and anonymous access
OptionalAuth = Depends(verify_firebase_token)

# Required auth - must be authenticated 
RequiredAuth = Depends(require_auth)

# Auth with username lookup
AuthWithUsername = Depends(get_user_with_username)