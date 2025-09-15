from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel
from datetime import datetime, timezone
from typing import Optional, Dict, Any
import logging
import httpx
from app.core.auth import verify_access_token
from app.services.database_service import get_database_pool
from app.services.notify import notify_users_excluding_device

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/beep", tags=["comments"])

class CommentIn(BaseModel):
    body: str
    media_url: Optional[str] = None
    device_id: Optional[str] = None

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
        # Fetch regular comments (oldest first for chronological conversation flow)
        rows = await conn.fetch(
            "SELECT c.id, c.user_id, u.username, c.body, c.media_url, c.created_at FROM comments c JOIN users u ON c.user_id = u.id WHERE c.sighting_id=$1::uuid ORDER BY c.created_at ASC LIMIT $2",
            sighting_id, limit
        )
        
        # Also fetch the original sighting description to show as first "comment"
        # Skip for MUFON cases to prevent first description from being added as a comment
        sighting = await conn.fetchrow(
            "SELECT s.description, s.reporter_id, s.created_at, s.source, u.username FROM sightings s LEFT JOIN users u ON s.reporter_id::uuid = u.id WHERE s.id = $1::uuid",
            sighting_id
        )
        
        comments = [dict(r) for r in rows]

        # If there's a description, add it as the first pseudo-comment (chronologically first in ASC order)
        # Skip for MUFON cases as requested by user
        is_mufon_case = sighting and (sighting.get('source') == 'mufon' or sighting.get('username') == 'MUFON_Database')

        if (sighting and sighting['description'] and sighting['description'].strip()
            and sighting['reporter_id'] and sighting['username']
            and not is_mufon_case):
            description_comment = {
                'id': 0,  # Special ID for original description
                'user_id': sighting['reporter_id'],
                'username': sighting['username'],
                'body': sighting['description'],
                'media_url': None,
                'created_at': sighting['created_at'].isoformat()
            }
            # Add description at the beginning (chronologically first in ASC order for proper conversation flow)
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
        # Insert the comment with device_id
        row = await conn.fetchrow(
            "INSERT INTO comments(sighting_id,user_id,body,media_url,device_id,created_at) VALUES ($1,$2,$3,$4,$5,$6) RETURNING id",
            sighting_id, user_id, body.body, body.media_url, body.device_id, now
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
        
        # Get all followers of this sighting (including the commenter - we'll exclude by device instead)
        follower_rows = await conn.fetch(
            "SELECT user_id FROM follows WHERE sighting_id = $1",
            sighting_id
        )
    
    # Send notifications using device-exclusion system 
    print(f"DEBUG: user_row={user_row}, follower_rows={follower_rows}")
    if user_row and follower_rows and body.device_id:
        try:
            follower_user_ids = [row["user_id"] for row in follower_rows]
            print(f"DEBUG: Calling notify_users_excluding_device with {len(follower_user_ids)} followers, excluding device {body.device_id}")
            sent = await notify_users_excluding_device(
                pool,
                follower_user_ids,
                exclude_device_id=body.device_id,
                title=f"💬 {user_row['username']} commented",
                body=body.body[:100] + ("..." if len(body.body) > 100 else ""),
                data={
                    "type": "comment",
                    "comment_id": str(row["id"]),
                    "sighting_id": sighting_id,
                },
            )
            print(f"DEBUG: notify_users_excluding_device returned {sent}")
            logger.info(f"Comment notification sent: {sent} notifications for sighting {sighting_id} (excluded device {body.device_id})")
        except Exception as e:
            print(f"DEBUG: Exception in notify_users_excluding_device: {e}")
            logger.error(f"Failed to send comment notifications: {e}")
    elif user_row and follower_rows and not body.device_id:
        # Fallback to user-exclusion if no device_id provided (for backward compatibility)
        try:
            follower_user_ids = [row["user_id"] for row in follower_rows if row["user_id"] != user_id]
            print(f"DEBUG: No device_id provided, falling back to user-exclusion with {len(follower_user_ids)} followers")
            from app.services.notify import notify_users
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
            print(f"DEBUG: fallback notify_users returned {sent}")
            logger.info(f"Comment notification sent (fallback): {sent} notifications for sighting {sighting_id}")
        except Exception as e:
            print(f"DEBUG: Exception in fallback notify_users: {e}")
            logger.error(f"Failed to send comment notifications (fallback): {e}")

    # Trigger SSE broadcast for real-time web updates
    try:
        async with httpx.AsyncClient() as client:
            await client.post(
                f"https://ufobeep.com/api/alerts/{sighting_id}/comments",
                json={"broadcast_only": True},
                timeout=2.0
            )
        logger.info(f"SSE broadcast triggered for sighting {sighting_id}")
    except Exception as e:
        logger.warning(f"Failed to trigger SSE broadcast: {e}")

    return {"id": row["id"]}

@router.delete("/{sighting_id}/comments/{comment_id}", status_code=200)
async def delete_comment(
    sighting_id: str,
    comment_id: str,
    user_id: str = Depends(_uid)
) -> Dict[str, Any]:
    """Delete a comment - only the comment author can delete their comment"""
    pool = await get_database_pool()

    async with pool.acquire() as conn:
        # Convert comment_id to integer since it comes from URL as string
        try:
            comment_id_int = int(comment_id)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid comment ID format")

        # First check if the comment exists and belongs to the user
        comment_row = await conn.fetchrow(
            "SELECT user_id FROM comments WHERE id = $1 AND sighting_id = $2",
            comment_id_int, sighting_id
        )

        if not comment_row:
            raise HTTPException(status_code=404, detail="Comment not found")

        if str(comment_row['user_id']) != str(user_id):
            raise HTTPException(status_code=403, detail="You can only delete your own comments")

        # Delete the comment
        result = await conn.execute(
            "DELETE FROM comments WHERE id = $1 AND sighting_id = $2 AND user_id = $3",
            comment_id_int, sighting_id, user_id
        )

        if result == "DELETE 0":
            raise HTTPException(status_code=404, detail="Comment not found or already deleted")

    # Trigger SSE broadcast for real-time web updates
    try:
        async with httpx.AsyncClient() as client:
            await client.post(
                f"https://ufobeep.com/api/alerts/{sighting_id}/comments",
                json={"broadcast_only": True},
                timeout=2.0
            )
        logger.info(f"SSE broadcast triggered for comment deletion on sighting {sighting_id}")
    except Exception as e:
        logger.warning(f"Failed to trigger SSE broadcast for comment deletion: {e}")

    return {"message": "Comment deleted successfully"}

@router.post("/{sighting_id}/follow", status_code=201)
async def follow_sighting(sighting_id: str, user_id: str = Depends(_uid)) -> Dict[str, Any]:
    pool = await get_database_pool()
    async with pool.acquire() as conn:
        await conn.execute(
            "INSERT INTO follows(sighting_id,user_id) VALUES ($1,$2) ON CONFLICT (sighting_id,user_id) DO NOTHING",
            sighting_id, user_id
        )
    return {"message": "Following sighting for notifications"}

@router.delete("/{sighting_id}/follow", status_code=200)
async def unfollow_sighting(sighting_id: str, user_id: str = Depends(_uid)) -> Dict[str, Any]:
    pool = await get_database_pool()
    async with pool.acquire() as conn:
        result = await conn.execute(
            "DELETE FROM follows WHERE sighting_id = $1 AND user_id = $2",
            sighting_id, user_id
        )
        # Check if any rows were actually deleted
        if result == "DELETE 0":
            return {"message": "You were not following this sighting"}
    return {"message": "Unfollowed sighting - you will no longer receive notifications"}

@router.get("/{sighting_id}/follow", status_code=200)
async def get_follow_status(sighting_id: str, user_id: str = Depends(_uid)) -> Dict[str, Any]:
    pool = await get_database_pool()
    async with pool.acquire() as conn:
        result = await conn.fetchrow(
            "SELECT 1 FROM follows WHERE sighting_id = $1 AND user_id = $2",
            sighting_id, user_id
        )
    return {"following": result is not None}

@router.get("/following", status_code=200)
async def get_user_subscriptions(user_id: str = Depends(_uid)) -> Dict[str, Any]:
    """Get all sightings that the user is following"""
    pool = await get_database_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch("""
            SELECT 
                s.id as sighting_id,
                s.title,
                s.description,
                COALESCE(
                    enrichment_data->'geocoding'->>'display_name',
                    enrichment_data->'geocoding'->>'location',
                    enrichment_data->>'location_name',
                    'Unknown Location'
                ) as location_name,
                s.created_at,
                COUNT(c.id) as comment_count
            FROM follows f
            JOIN sightings s ON f.sighting_id = s.id
            LEFT JOIN comments c ON s.id = c.sighting_id
            WHERE f.user_id = $1
            GROUP BY s.id, s.title, s.description, s.created_at, s.enrichment_data
            ORDER BY f.created_at DESC
            LIMIT 50
        """, user_id)
        
        subscriptions = []
        for row in rows:
            subscriptions.append({
                'sighting_id': str(row['sighting_id']),
                'title': row['title'] or (row['description'][:50] + '...' if row['description'] else 'UFO Sighting'),
                'location_name': row['location_name'] or 'Unknown Location',
                'comment_count': row['comment_count'],
                'created_at': row['created_at'].isoformat()
            })
    
    return {"subscriptions": subscriptions}
