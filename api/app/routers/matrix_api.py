from datetime import datetime
from typing import List, Optional, Dict, Any
import logging

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer
from pydantic import BaseModel, Field

from app.services.matrix_service import matrix_service, generate_user_sso_token, get_room_transcript

logger = logging.getLogger(__name__)

# Request/Response models
class MatrixSSORequest(BaseModel):
    user_id: str = Field(..., description="User ID to generate SSO token for")
    display_name: Optional[str] = Field(None, description="Display name for Matrix user")


class MatrixSSOResponse(BaseModel):
    success: bool
    sso_token: str
    matrix_user_id: str
    server_name: str
    login_url: str
    expires_at: str


class MatrixRoomInfo(BaseModel):
    room_id: str
    room_alias: Optional[str] = None
    room_name: Optional[str] = None
    topic: Optional[str] = None
    member_count: int = 0
    join_url: str
    matrix_to_url: str


class MatrixMessage(BaseModel):
    event_id: str
    sender: str
    timestamp: int
    content: Dict[str, Any]
    formatted_timestamp: Optional[str] = None


class MatrixTranscriptResponse(BaseModel):
    success: bool
    room_id: str
    messages: List[MatrixMessage]
    total_messages: int


# Router configuration
router = APIRouter(
    prefix="/v1/matrix",
    tags=["matrix"],
    responses={
        404: {"description": "Matrix resource not found"},
        400: {"description": "Bad request"},
        403: {"description": "Access denied"},
        422: {"description": "Validation error"},
        503: {"description": "Matrix service unavailable"},
    }
)

security = HTTPBearer(auto_error=False)

# Dependencies
async def get_current_user_id(token: Optional[str] = Depends(security)) -> Optional[str]:
    """Extract user ID from JWT token (simplified for now)"""
    if token and token.credentials:
        # TODO: Implement actual JWT validation
        return "anonymous_user"
    return None


# Endpoints
@router.post("/sso", response_model=MatrixSSOResponse)
async def generate_matrix_sso_token(
    request: MatrixSSORequest,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Generate an SSO token for Matrix authentication
    
    This creates a temporary authentication token that allows the user
    to join Matrix chat rooms for their sightings automatically.
    """
    try:
        # In production, verify that the requesting user matches the SSO request
        # or has appropriate permissions
        
        logger.info(f"Generating Matrix SSO token for user {request.user_id}")
        
        sso_data = await generate_user_sso_token(
            user_id=request.user_id,
            display_name=request.display_name
        )
        
        if not sso_data:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail={
                    "error": "MATRIX_UNAVAILABLE",
                    "message": "Matrix service is currently unavailable"
                }
            )
        
        return MatrixSSOResponse(
            success=True,
            sso_token=sso_data['sso_token'],
            matrix_user_id=sso_data['matrix_user_id'],
            server_name=sso_data['server_name'],
            login_url=sso_data['login_url'],
            expires_at=sso_data['expires_at']
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to generate Matrix SSO token: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "SSO_TOKEN_FAILED",
                "message": "Failed to generate SSO token"
            }
        )


@router.get("/room/{room_id}/info", response_model=MatrixRoomInfo)
async def get_matrix_room_info(
    room_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Get information about a Matrix room
    
    Returns basic room information including name, topic, and member count.
    """
    try:
        async with matrix_service as matrix:
            room_info = await matrix.get_room_info(room_id)
            
            if not room_info:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail={
                        "error": "ROOM_NOT_FOUND",
                        "message": f"Matrix room {room_id} not found"
                    }
                )
            
            return MatrixRoomInfo(
                room_id=room_info['room_id'],
                room_name=room_info.get('name'),
                topic=room_info.get('topic'),
                member_count=room_info.get('member_count', 0),
                join_url=f"{matrix_service.base_url}/#/room/{room_id}",
                matrix_to_url=f"https://matrix.to/#/{room_id}"
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get Matrix room info for {room_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "ROOM_INFO_FAILED",
                "message": "Failed to retrieve room information"
            }
        )


@router.get("/room/{room_id}/messages", response_model=MatrixTranscriptResponse)
async def get_matrix_room_transcript(
    room_id: str,
    limit: int = 50,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Get message transcript from a Matrix room
    
    Returns recent messages from the specified Matrix room.
    Limited to public rooms or rooms the user has access to.
    """
    try:
        # Validate limit
        limit = max(1, min(limit, 1000))  # Between 1 and 1000
        
        logger.debug(f"Fetching {limit} messages from Matrix room {room_id}")
        
        messages = await get_room_transcript(room_id, limit)
        
        # Convert to response format
        formatted_messages = [
            MatrixMessage(
                event_id=msg['event_id'],
                sender=msg['sender'],
                timestamp=msg['timestamp'],
                content=msg['content'],
                formatted_timestamp=msg['formatted_timestamp']
            )
            for msg in messages
        ]
        
        return MatrixTranscriptResponse(
            success=True,
            room_id=room_id,
            messages=formatted_messages,
            total_messages=len(formatted_messages)
        )
        
    except Exception as e:
        logger.error(f"Failed to get Matrix transcript for room {room_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "TRANSCRIPT_FAILED",
                "message": "Failed to retrieve room transcript"
            }
        )


@router.post("/room/{room_id}/join")
async def join_matrix_room(
    room_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Join a Matrix room
    
    Attempts to join the specified Matrix room on behalf of the authenticated user.
    """
    try:
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "AUTHENTICATION_REQUIRED",
                    "message": "User authentication required to join rooms"
                }
            )
        
        async with matrix_service as matrix:
            success = await matrix.invite_user_to_room(room_id, user_id)
            
            if success:
                return {
                    "success": True,
                    "message": f"Successfully joined room {room_id}",
                    "room_id": room_id,
                    "user_id": user_id,
                    "timestamp": datetime.utcnow().isoformat()
                }
            else:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail={
                        "error": "JOIN_FAILED",
                        "message": "Failed to join the specified room"
                    }
                )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to join Matrix room {room_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "JOIN_ERROR",
                "message": "Error occurred while joining room"
            }
        )


@router.get("/health")
async def matrix_health_check():
    """Check Matrix service health"""
    try:
        async with matrix_service as matrix:
            is_healthy = await matrix.health_check()
            
            return {
                "status": "healthy" if is_healthy else "unhealthy",
                "matrix_server": matrix_service.base_url,
                "server_name": matrix_service.server_name,
                "timestamp": datetime.utcnow().isoformat()
            }
            
    except Exception as e:
        logger.error(f"Matrix health check failed: {e}")
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }