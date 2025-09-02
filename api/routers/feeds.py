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

@router.post("/mufon/list")
async def list_mufon_cases(_admin = Depends(require_admin)):
    """Get list of MUFON cases without processing details"""
    try:
        from feeds.mufon_case_processor import get_case_list
        cases = await get_case_list()
        return {"ok": True, "cases_found": len(cases), "cases": cases}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/mufon/process/{case_id}")
async def process_mufon_case(case_id: str, _admin = Depends(require_admin)):
    """Process individual MUFON case with full details and media"""
    try:
        pool = await get_db()
        from feeds.mufon_case_processor import get_case_details, insert_case_with_media
        
        # Find case URL from the list first
        from feeds.mufon_case_processor import get_case_list
        cases = await get_case_list()
        case_url = None
        for case in cases:
            if case.get("case_id") == case_id:
                case_url = case.get("url")
                break
        
        if not case_url:
            return {"ok": False, "error": f"Case {case_id} not found in recent cases"}
        
        # Get full case details with media
        case_data = await get_case_details(case_url)
        if not case_data:
            return {"ok": False, "error": f"Could not fetch details for case {case_id}"}
            
        # Process and insert with media
        inserted = await insert_case_with_media(pool, case_data)
        return {"ok": True, "case_id": case_id, "inserted": inserted, "media_files": len(case_data.get("media_urls", []))}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/mufon/run")
async def run_mufon(_admin = Depends(require_admin)):
    """Legacy endpoint - still works but may timeout"""
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
