from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel
from datetime import datetime, timezone
from typing import Optional, Dict, Any
from app.core.auth import verify_access_token
from app.services.database_service import get_database_pool

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
        rows = await conn.fetch(
            "SELECT c.id, c.user_id, u.username, c.body, c.media_url, c.created_at FROM comments c JOIN users u ON c.user_id = u.id WHERE c.sighting_id=$1 ORDER BY c.created_at DESC LIMIT $2",
            sighting_id, limit
        )
    return {"items": [dict(r) for r in rows], "next_cursor": None}

@router.post("/{sighting_id}/comments", status_code=201)
async def create_comment(sighting_id: str, body: CommentIn, user_id: str = Depends(_uid)) -> Dict[str, Any]:
    now = datetime.now(timezone.utc)
    pool = await get_database_pool()
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            "INSERT INTO comments(sighting_id,user_id,body,media_url,created_at) VALUES ($1,$2,$3,$4,$5) RETURNING id",
            sighting_id, user_id, body.body, body.media_url, now
        )
        await conn.execute(
            "INSERT INTO follows(sighting_id,user_id) VALUES ($1,$2) ON CONFLICT (sighting_id,user_id) DO NOTHING",
            sighting_id, user_id
        )
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
