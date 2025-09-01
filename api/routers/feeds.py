from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException
import asyncpg

# Wire these to your app's DI
def get_db_pool() -> asyncpg.Pool:
    raise NotImplementedError("Wire get_db_pool() to your app's pool provider")

def require_admin():
    return True

from ..feeds.ingest import ingest_mufon as _ingest_mufon
from ..feeds.ingest_all import ingest_all_feeds as _ingest_all

router = APIRouter(prefix="/admin/feeds", tags=["feeds"])

@router.post("/mufon/run")
async def run_mufon(pool: asyncpg.Pool = Depends(get_db_pool), _admin = Depends(require_admin)):
    try:
        inserted = await _ingest_mufon(pool)
        return {"ok": True, "inserted": inserted}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/all/run")
async def run_all(pool: asyncpg.Pool = Depends(get_db_pool), _admin = Depends(require_admin)):
    try:
        result = await _ingest_all(pool)
        return {"ok": True, **result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
