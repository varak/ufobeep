from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel
from datetime import datetime, timezone
from typing import Optional, Dict, Any
import logging
from app.core.auth import verify_access_token
from app.services.database_service import get_database_pool
from app.services.notify import notify_users

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/alerts", tags=["comments"])

class CommentIn(BaseModel):
    body: str
    media_url: Optional[str] = None

def _uid(authorization: str = Header(None)) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Authorization header required")
    
    token = authorization.replace("Bearer ", "")
    try:
        payload = verify_access_token(token)
        sub = payload.get("sub")
        if not sub:
            raise HTTPException(status_code=401, detail="Invalid token payload")
        return str(sub)
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Token verification failed: {str(e)}")

@router.get("/{sighting_id}/comments")
async def list_comments(sighting_id: str, limit: int = 30) -> Dict[str, Any]:
    pool = await get_database_pool()
    async with pool.acquire() as conn:
        # Fetch regular comments (newest first for current UI compatibility)
        rows = await conn.fetch(
            "SELECT c.id, c.user_id, u.username, c.body, c.media_url, c.created_at FROM comments c JOIN users u ON c.user_id = u.id WHERE c.sighting_id=$1::uuid ORDER BY c.created_at DESC LIMIT $2",
            sighting_id, limit
        )
        
        # Also fetch the original sighting description to show as first "comment"
        sighting = await conn.fetchrow(
            "SELECT s.description, s.reporter_id, s.created_at, u.username FROM sightings s LEFT JOIN users u ON s.reporter_id = u.id WHERE s.id = $1::uuid",
            sighting_id
        )
        
        comments = [dict(r) for r in rows]
        
        # If there's a description, add it as the first pseudo-comment (provides context for the conversation)
        if sighting and sighting['description'] and sighting['description'].strip() and sighting['reporter_id'] and sighting['username']:
            description_comment = {
                'id': 0,  # Special ID for original description
                'user_id': sighting['reporter_id'],
                'username': sighting['username'],
                'body': sighting['description'],
                'media_url': None,
                'created_at': sighting['created_at'].isoformat()
            }
            # Add description at the top for context, even though it's chronologically first
            comments.insert(0, description_comment)
        
    return {"items": comments, "next_cursor": None}

@router.post("/{sighting_id}/comments", status_code=201)
async def create_comment(
    sighting_id: str, 
    body: CommentIn, 
    user_id: str = Depends(_uid)
) -> Dict[str, Any]:
    now = datetime.now(timezone.utc)
    pool = await get_database_pool()
    
    async with pool.acquire() as conn:
        # Insert the comment
        row = await conn.fetchrow(
            "INSERT INTO comments(sighting_id,user_id,body,media_url,created_at) VALUES ($1,$2,$3,$4,$5) RETURNING id",
            sighting_id, user_id, body.body, body.media_url, now
        )
        
        # Auto-follow the sighting when commenting
        await conn.execute(
            "INSERT INTO follows(sighting_id,user_id) VALUES ($1,$2) ON CONFLICT (sighting_id,user_id) DO NOTHING",
            sighting_id, user_id
        )
        
        # Get commenter's username and followers for notifications
        user_row = await conn.fetchrow(
            "SELECT username FROM users WHERE id = $1",
            user_id
        )
        
        # Get all followers of this sighting (excluding the commenter)
        follower_rows = await conn.fetch(
            "SELECT user_id FROM follows WHERE sighting_id = $1 AND user_id != $2",
            sighting_id, user_id
        )
    
    # Send notifications using unified system (SAME as proximity alerts)
    print(f"DEBUG: user_row={user_row}, follower_rows={follower_rows}")
    if user_row and follower_rows:
        try:
            follower_user_ids = [row["user_id"] for row in follower_rows]
            print(f"DEBUG: Calling notify_users with {len(follower_user_ids)} followers")
            sent = await notify_users(
                pool,
                follower_user_ids,
                title=f"💬 {user_row['username']} commented",
                body=body.body[:100] + ("..." if len(body.body) > 100 else ""),
                data={
                    "type": "comment",
                    "comment_id": str(row["id"]),
                    "sighting_id": sighting_id,
                },
            )
            print(f"DEBUG: notify_users returned {sent}")
            logger.info(f"Comment notification sent: {sent} notifications for sighting {sighting_id}")
        except Exception as e:
            print(f"DEBUG: Exception in notify_users: {e}")
            logger.error(f"Failed to send comment notifications: {e}")
    
    return {"id": row["id"]}

@router.post("/{sighting_id}/follow", status_code=201)
async def follow_sighting(sighting_id: str, user_id: str = Depends(_uid)) -> Dict[str, Any]:
    pool = await get_database_pool()
    async with pool.acquire() as conn:
        await conn.execute(
            "INSERT INTO follows(sighting_id,user_id) VALUES ($1,$2) ON CONFLICT (sighting_id,user_id) DO NOTHING",
            sighting_id, user_id
        )
    return {"message": "Following sighting for notifications"}
