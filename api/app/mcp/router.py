"""
MCP Server Router - Clean FastAPI routes for MCP endpoints
"""

from fastapi import APIRouter
from typing import Optional
from .endpoints import search_sightings, recent_alerts, sighting_details, basic_stats

# Create MCP router
mcp_router = APIRouter(prefix="/api/mcp", tags=["mcp"])

# Import database service
from services.database_service import DatabaseService
database_service = DatabaseService()

@mcp_router.get("/search-sightings")
async def mcp_search_sightings_endpoint(
    lat: float,
    lon: float,
    radius: int = 50,
    limit: int = 20,
    hours: Optional[int] = None
):
    """Search UFO sightings by location for AI systems"""
    return await search_sightings(database_service.pool, lat, lon, radius, limit, hours)

@mcp_router.get("/recent-alerts")
async def mcp_recent_alerts_endpoint(
    hours: int = 24,
    limit: int = 50,
):
    """Get recent UFO alerts for AI systems"""
    return await recent_alerts(database_service.pool, hours, limit)

@mcp_router.get("/sighting/{sighting_id}")
async def mcp_sighting_details_endpoint(
    sighting_id: str,
):
    """Get detailed UFO sighting information for AI systems"""
    return await sighting_details(database_service.pool, sighting_id)

@mcp_router.get("/stats")
async def mcp_basic_stats_endpoint(database_service.pool=Depends(lambda: None)):
    """Get basic UFO database statistics for AI systems"""
    return await basic_stats(database_service.pool)