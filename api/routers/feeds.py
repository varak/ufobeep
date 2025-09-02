from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, Query
import asyncpg

async def get_db():
    """Get database connection pool from service"""
    from app.services.database_service import get_database_pool
    return await get_database_pool()

def require_admin():
    return True

from feeds.ingest import ingest_mufon as _ingest_mufon
from feeds.ingest_all import ingest_all_feeds as _ingest_all

router = APIRouter(prefix="/admin/feeds", tags=["feeds"])

@router.post("/mufon/run")
async def run_mufon(_admin = Depends(require_admin)):
    try:
        pool = await get_db()
        inserted = await _ingest_mufon(pool)
        return {"ok": True, "inserted": inserted}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/all/run")
async def run_all(_admin = Depends(require_admin)):
    try:
        pool = await get_db()
        result = await _ingest_all(pool)
        return {"ok": True, **result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
