"""
Beep engagement and witness confirmation endpoints

Handles quick action API calls from push notification interactions:
- "I see it too" confirmations
- "I checked but don't see it" engagement tracking
- "I missed this one" engagement tracking
- Comprehensive metrics logging for all user interactions
"""

import asyncio
import asyncpg
import uuid
from datetime import datetime
from typing import Optional, Dict, Any
from fastapi import APIRouter, HTTPException, Depends, Request
from pydantic import BaseModel, Field

from app.services.metrics_service import get_metrics_service, EngagementType

router = APIRouter(prefix="/beep", tags=["beep", "engagement"])

class WitnessEngagementRequest(BaseModel):
    """Request model for witness engagement tracking"""
    device_id: str = Field(..., min_length=1, max_length=255)
    witness_type: str = Field(..., description="Type of witness engagement: confirmed, checked_no_sighting, missed")
    quick_action: bool = Field(default=True, description="Whether this came from a quick action button")
    latitude: Optional[float] = Field(None, ge=-90.0, le=90.0)
    longitude: Optional[float] = Field(None, ge=-180.0, le=180.0)
    accuracy: Optional[float] = Field(None, ge=0.0)
    description: Optional[str] = Field(None, max_length=500)
    still_visible: Optional[bool] = Field(None)
    app_version: Optional[str] = Field(None, max_length=50)
    platform: Optional[str] = Field(None, max_length=20)

class WitnessEngagementResponse(BaseModel):
    """Response model for witness engagement"""
    success: bool
    witness_id: Optional[str] = None
    engagement_type: str
    sighting_id: str
    device_id: str
    witness_count_updated: Optional[int] = None
    escalation_triggered: bool = False
    message: str

# Database connection helper
async def get_db_connection():
    """Get database connection from main app"""
    from app.main import db_pool
    return await db_pool.acquire()

@router.post("/{sighting_id}/witness", response_model=WitnessEngagementResponse)
async def record_witness_engagement(
    sighting_id: str,
    engagement: WitnessEngagementRequest,
    request: Request
):
    """
    Record witness engagement from quick action buttons or manual confirmation
    
    This endpoint handles all types of user engagement with UFO sighting alerts:
    - confirmed: User pressed "I see it too" 
    - checked_no_sighting: User pressed "I checked but don't see it"
    - missed: User pressed "I missed this one"
    
    All engagements are logged for comprehensive metrics tracking.
    """
    try:
        # Validate sighting ID format
        try:
            sighting_uuid = uuid.UUID(sighting_id)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid sighting ID format")
        
        # Get database connection
        from app.main import db_pool
        async with db_pool.acquire() as conn:
            
            # Verify sighting exists
            sighting = await conn.fetchrow(
                "SELECT id, title, witness_count FROM sightings WHERE id = $1",
                sighting_uuid
            )
            
            if not sighting:
                raise HTTPException(status_code=404, detail="Sighting not found")
            
            # Get metrics service for comprehensive logging
            metrics_service = get_metrics_service(db_pool)
            
            witness_id = None
            witness_count_updated = None
            escalation_triggered = False
            
            # Handle different engagement types
            if engagement.witness_type == "confirmed":
                # This is a real witness confirmation - add to witness_confirmations table
                witness_id, witness_count_updated, escalation_triggered = await _record_witness_confirmation(
                    conn, sighting_uuid, engagement, metrics_service
                )
                
                # Log simple engagement
                await metrics_service.log_engagement(
                    engagement.device_id,
                    EngagementType.QUICK_ACTION_SEE_IT_TOO,
                    sighting_uuid
                )
                
                message = f"Witness confirmation recorded. Total witnesses: {witness_count_updated}"
                if escalation_triggered:
                    message += " - Alert escalated due to high witness count!"
                    
            elif engagement.witness_type == "checked_no_sighting":
                # User checked but didn't see anything - record engagement but not as witness
                await _record_engagement_only(
                    conn, sighting_uuid, engagement, "checked_no_sighting", metrics_service
                )
                
                await metrics_service.log_engagement(
                    engagement.device_id,
                    EngagementType.QUICK_ACTION_DONT_SEE,
                    sighting_uuid
                )
                
                message = "Engagement recorded - thank you for checking!"
                
            elif engagement.witness_type == "missed":
                # User missed the sighting - record engagement 
                await _record_engagement_only(
                    conn, sighting_uuid, engagement, "missed", metrics_service
                )
                
                await metrics_service.log_engagement(
                    engagement.device_id,
                    EngagementType.QUICK_ACTION_MISSED,
                    sighting_uuid
                )
                
                message = "Thanks for the feedback - we'll note you missed this one"
                
            else:
                raise HTTPException(
                    status_code=400, 
                    detail=f"Invalid witness_type: {engagement.witness_type}. Must be: confirmed, checked_no_sighting, or missed"
                )
            
            return WitnessEngagementResponse(
                success=True,
                witness_id=witness_id,
                engagement_type=engagement.witness_type,
                sighting_id=sighting_id,
                device_id=engagement.device_id,
                witness_count_updated=witness_count_updated,
                escalation_triggered=escalation_triggered,
                message=message
            )
            
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error recording witness engagement: {e}")
        raise HTTPException(
            status_code=500, 
            detail=f"Failed to record engagement: {str(e)}"
        )

async def _record_witness_confirmation(
    conn: asyncpg.Connection,
    sighting_id: uuid.UUID,
    engagement: WitnessEngagementRequest,
    metrics_service
) -> tuple[str, int, bool]:
    """Record a confirmed witness sighting with full database updates"""
    
    # Check if device already confirmed this sighting
    existing = await conn.fetchrow(
        "SELECT id FROM witness_confirmations WHERE device_id = $1 AND sighting_id = $2",
        engagement.device_id, sighting_id
    )
    
    if existing:
        # Already confirmed, just return current state
        current_count = await conn.fetchval(
            "SELECT witness_count FROM sightings WHERE id = $1", sighting_id
        )
        return str(existing['id']), current_count, False
    
    # Calculate distance from original sighting if we have location
    distance_km = None
    if engagement.latitude and engagement.longitude:
        original_location = await conn.fetchrow("""
            SELECT 
                (sensor_data->>'location')::jsonb->>'latitude' as orig_lat,
                (sensor_data->>'location')::jsonb->>'longitude' as orig_lng
            FROM sightings WHERE id = $1
        """, sighting_id)
        
        if original_location and original_location['orig_lat'] and original_location['orig_lng']:
            # Simple distance calculation (could be improved with proper geospatial functions)
            import math
            lat1, lng1 = float(original_location['orig_lat']), float(original_location['orig_lng'])
            lat2, lng2 = engagement.latitude, engagement.longitude
            
            # Haversine formula for rough distance
            dlat = math.radians(lat2 - lat1)
            dlng = math.radians(lng2 - lng1)
            a = (math.sin(dlat/2) * math.sin(dlat/2) + 
                 math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
                 math.sin(dlng/2) * math.sin(dlng/2))
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
            distance_km = 6371 * c  # Earth radius in km
    
    # Insert witness confirmation
    witness_id = await conn.fetchval("""
        INSERT INTO witness_confirmations 
        (sighting_id, device_id, witness_latitude, witness_longitude, witness_altitude,
         location_accuracy, distance_km, confirmation_type, still_visible, 
         description, device_platform, app_version)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
        RETURNING id
    """, sighting_id, engagement.device_id, 
        engagement.latitude or 0.0, engagement.longitude or 0.0, 0.0, 
        engagement.accuracy, distance_km, 'visual', 
        engagement.still_visible if engagement.still_visible is not None else True,
        engagement.description, engagement.platform, engagement.app_version)
    
    # Update witness count on the sighting
    new_witness_count = await conn.fetchval("""
        UPDATE sightings 
        SET witness_count = witness_count + 1, updated_at = NOW()
        WHERE id = $1
        RETURNING witness_count
    """, sighting_id)
    
    # Check if escalation is triggered (3, 5, 10+ witnesses)
    escalation_triggered = new_witness_count in [3, 5, 10] or (new_witness_count > 10 and new_witness_count % 5 == 0)
    
    if escalation_triggered:
        print(f"🚨 ESCALATION: Sighting {sighting_id} reached {new_witness_count} witnesses!")
        
        # Log escalation event
        await metrics_service.log_engagement(
            "system",
            EngagementType.ALERT_SENT,
            sighting_id
        )
    
    return str(witness_id), new_witness_count, escalation_triggered

async def _record_engagement_only(
    conn: asyncpg.Connection,
    sighting_id: uuid.UUID,
    engagement: WitnessEngagementRequest,
    engagement_type: str,
    metrics_service
):
    """Record engagement without adding to witness count"""
    # Simple engagement is already logged in the calling function via metrics_service.log_engagement()
    # Just log that we processed this engagement
    print(f"📊 Engagement recorded: {engagement_type} from {engagement.device_id} for {sighting_id}")

@router.get("/{sighting_id}/engagement-stats")
async def get_engagement_stats(sighting_id: str):
    """Get engagement statistics for a specific sighting"""
    
    try:
        sighting_uuid = uuid.UUID(sighting_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid sighting ID format")
    
    from app.main import db_pool
    metrics_service = get_metrics_service(db_pool)
    
    # Get basic engagement metrics
    metrics = await metrics_service.get_basic_stats(hours=24*7)
    
    async with db_pool.acquire() as conn:
        # Get sighting stats
        sighting_stats = await conn.fetchrow("""
            SELECT 
                s.witness_count,
                s.title,
                s.created_at,
                COUNT(wc.id) as confirmed_witnesses
            FROM sightings s
            LEFT JOIN witness_confirmations wc ON s.id = wc.sighting_id
            WHERE s.id = $1
            GROUP BY s.id, s.witness_count, s.title, s.created_at
        """, sighting_uuid)
        
        if not sighting_stats:
            raise HTTPException(status_code=404, detail="Sighting not found")
            
        # Get engagement count for this sighting
        engagement_count = await conn.fetchval("""
            SELECT COUNT(*) FROM user_engagement 
            WHERE sighting_id = $1 AND event_type LIKE 'quick_action_%'
        """, sighting_uuid)
    
    return {
        "sighting_id": sighting_id,
        "sighting_title": sighting_stats['title'],
        "created_at": sighting_stats['created_at'].isoformat(),
        "witness_count": sighting_stats['witness_count'],
        "confirmed_witnesses": sighting_stats['confirmed_witnesses'],
        "total_engagements": engagement_count,
        "engagement_rate": (engagement_count / max(sighting_stats['witness_count'], 1)) * 100
    }