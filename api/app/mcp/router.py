"""
MCP Server Router - Clean FastAPI routes for MCP endpoints
"""

from fastapi import APIRouter, Depends
from typing import Optional
from .endpoints import search_sightings, recent_alerts, sighting_details, basic_stats

# Create MCP router
mcp_router = APIRouter(prefix="/api/mcp", tags=["mcp"])

@mcp_router.get("/search-sightings")
async def mcp_search_sightings_endpoint(
    lat: float,
    lon: float,
    radius: int = 50,
    limit: int = 20,
    hours: Optional[int] = None,
    database_pool=Depends(lambda: None)  # Will be injected
):
    """Search UFO sightings by location for AI systems"""
    return await search_sightings(database_pool, lat, lon, radius, limit, hours)

@mcp_router.get("/recent-alerts")
async def mcp_recent_alerts_endpoint(
    hours: int = 24,
    limit: int = 50,
    database_pool=Depends(lambda: None)
):
    """Get recent UFO alerts for AI systems"""
    return await recent_alerts(database_pool, hours, limit)

@mcp_router.get("/sighting/{sighting_id}")
async def mcp_sighting_details_endpoint(
    sighting_id: str,
    database_pool=Depends(lambda: None)
):
    """Get detailed UFO sighting information for AI systems"""
    return await sighting_details(database_pool, sighting_id)

@mcp_router.get("/stats")
async def mcp_basic_stats_endpoint(database_pool=Depends(lambda: None)):
    """Get basic UFO database statistics for AI systems"""
    return await basic_stats(database_pool)