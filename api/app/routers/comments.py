from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from datetime import datetime, timezone
from typing import Optional, Dict, Any
from app.core.auth import verify_access_token
from app.db import database

router = APIRouter(prefix="/alerts", tags=["comments"])

class CommentIn(BaseModel):
    body: str
    media_url: Optional[str] = None

def _uid(payload=Depends(verify_access_token)) -> str:
    sub = payload.get("sub")
    if not sub:
        raise HTTPException(status_code=401, detail="Invalid token payload")
    return str(sub)

@router.get("/{sighting_id}/comments")
async def list_comments(sighting_id: str, limit: int = 30) -> Dict[str, Any]:
    rows = await database.fetch_all(
        "SELECT id, user_id, body, media_url, created_at FROM comments WHERE sighting_id=:s ORDER BY created_at DESC LIMIT :l",
        {"s": sighting_id, "l": limit}
    )
    return {"items": [dict(r) for r in rows], "next_cursor": None}

@router.post("/{sighting_id}/comments", status_code=201)
async def create_comment(sighting_id: str, body: CommentIn, user_id: str = Depends(_uid)) -> Dict[str, Any]:
    now = datetime.now(timezone.utc)
    row = await database.fetch_one(
        "INSERT INTO comments(sighting_id,user_id,body,media_url,created_at) VALUES (:s,:u,:b,:m,:t) RETURNING id",
        {"s": sighting_id, "u": user_id, "b": body.body, "m": body.media_url, "t": now}
    )
    await database.execute(
        "INSERT INTO follows(sighting_id,user_id) VALUES (:s,:u) ON CONFLICT (sighting_id,user_id) DO NOTHING",
        {"s": sighting_id, "u": user_id}
    )
    return {"id": row["id"]}

@router.post("/{sighting_id}/follow", status_code=201)
async def follow_sighting(sighting_id: str, user_id: str = Depends(_uid)) -> Dict[str, Any]:
    await database.execute(
        "INSERT INTO follows(sighting_id,user_id) VALUES (:s,:u) ON CONFLICT (sighting_id,user_id) DO NOTHING",
        {"s": sighting_id, "u": user_id}
    )
    return {"message": "Following sighting for notifications"}
