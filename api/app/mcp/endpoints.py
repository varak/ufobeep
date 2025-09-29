"""
MCP Server Endpoints - UFO data access for AI systems
Lean implementation using existing UFOBeep infrastructure
"""

from fastapi import HTTPException
from typing import Optional
import logging

logger = logging.getLogger(__name__)

async def search_sightings(
    database_pool,
    lat: float,
    lon: float,
    radius: int = 50,
    limit: int = 20,
    hours: Optional[int] = None
):
    """Search UFO sightings by location - reuses existing beep search logic"""
    try:
        from services.alerts_service import AlertsService
        alerts_service = AlertsService(database_pool)

        # Use existing search logic
        result = await alerts_service.get_alerts(
            page=1,
            limit=limit,
            latitude=lat,
            longitude=lon,
            verified_only=False,
            sort_by="newest"
        )

        # Format for MCP
        sightings = []
        for alert in result.get("alerts", []):
            sightings.append({
                "id": alert.get("id"),
                "title": alert.get("title", "UFO Sighting"),
                "location": alert.get("location", {}).get("name", "Unknown"),
                "coordinates": [alert.get("latitude", 0), alert.get("longitude", 0)],
                "timestamp": alert.get("created_at"),
                "description": alert.get("description", ""),
                "witness_count": alert.get("witness_count", 1),
                "distance_km": alert.get("distance_km", 0),
                "source": alert.get("source", "ufobeep")
            })

        return {
            "tool": "search_ufo_sightings",
            "sightings": sightings,
            "total_count": result.get("total", 0),
            "search_location": [lat, lon],
            "radius_km": radius
        }

    except Exception as e:
        logger.error(f"MCP search error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

async def recent_alerts(database_pool, hours: int = 24, limit: int = 50):
    """Get recent UFO alerts - simple recent query"""
    try:
        return await search_sightings(
            database_pool,
            lat=0, lon=0,
            radius=20000,
            limit=limit,
            hours=hours
        )
    except Exception as e:
        logger.error(f"MCP recent alerts error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

async def sighting_details(database_pool, sighting_id: str):
    """Get detailed UFO sighting information"""
    try:
        from services.alerts_service import AlertsService
        alerts_service = AlertsService(database_pool)

        alert = await alerts_service.get_alert_by_id(sighting_id)
        if not alert:
            raise HTTPException(status_code=404, detail="Sighting not found")

        return {
            "tool": "get_sighting_details",
            "sighting": {
                "id": alert.get("id"),
                "title": alert.get("title", "UFO Sighting"),
                "description": alert.get("description", ""),
                "location": alert.get("location", {}).get("name", "Unknown"),
                "coordinates": [alert.get("latitude", 0), alert.get("longitude", 0)],
                "timestamp": alert.get("created_at"),
                "witness_count": alert.get("witness_count", 1),
                "environmental_data": alert.get("enrichment_data", {}),
                "media_count": len(alert.get("media_files", [])),
                "source": alert.get("source", "ufobeep")
            }
        }

    except Exception as e:
        logger.error(f"MCP sighting details error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

async def basic_stats(database_pool):
    """Basic UFO database statistics"""
    try:
        async with database_pool.acquire() as conn:
            total = await conn.fetchval("SELECT COUNT(*) FROM sightings")
            with_media = await conn.fetchval("SELECT COUNT(*) FROM sightings WHERE array_length(media_files, 1) > 0")

            return {
                "tool": "get_basic_stats",
                "total_sightings": total,
                "sightings_with_media": with_media,
                "last_updated": "real-time"
            }

    except Exception as e:
        logger.error(f"MCP stats error: {e}")
        raise HTTPException(status_code=500, detail=str(e))