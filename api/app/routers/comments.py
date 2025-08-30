from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from datetime import datetime, timezone
from typing import Optional, Dict, Any
from app.security import verify_access_token
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

@router.get("/{aid}/comments")
async def list_comments(aid: int, limit: int = 30) -> Dict[str, Any]:
    rows = await database.fetch_all(
        "SELECT id, user_id, body, media_url, created_at FROM comments WHERE alert_id=:a ORDER BY created_at DESC LIMIT :l",
        {"a": aid, "l": limit}
    )
    return {"items": [dict(r) for r in rows], "next_cursor": None}

@router.post("/{aid}/comments", status_code=201)
async def create_comment(aid: int, body: CommentIn, user_id: str = Depends(_uid)) -> Dict[str, Any]:
    now = datetime.now(timezone.utc)
    row = await database.fetch_one(
        "INSERT INTO comments(alert_id,user_id,body,media_url,created_at) VALUES (:a,:u,:b,:m,:t) RETURNING id",
        {"a": aid, "u": user_id, "b": body.body, "m": body.media_url, "t": now}
    )
    await database.execute(
        "INSERT INTO follows(alert_id,user_id) VALUES (:a,:u) ON CONFLICT (alert_id,user_id) DO NOTHING",
        {"a": aid, "u": user_id}
    )
    return {"id": row["id"]}
