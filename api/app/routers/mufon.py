"""
MUFON sightings import router
"""
from fastapi import APIRouter, HTTPException, BackgroundTasks
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from pydantic import BaseModel
import asyncpg
import json
import re
from app.config.environment import settings

router = APIRouter(prefix="/mufon", tags=["mufon"])

class MufonSighting(BaseModel):
    """MUFON sighting data model"""
    date_submitted: str
    date_event: str
    time_event: Optional[str]
    short_description: str
    location: str
    long_description: Optional[str]
    attachments: List[str] = []
    mufon_case_id: Optional[str]
    
class MufonImportRequest(BaseModel):
    """Request to import MUFON sightings"""
    sightings: List[MufonSighting]
    import_source: str = "manual"
    
class MufonImportResponse(BaseModel):
    """Response from MUFON import"""
    imported: int
    skipped: int
    errors: List[str]
    sighting_ids: List[str]

def parse_location(location_str: str) -> tuple:
    """Parse MUFON location string to extract city, state, country"""
    # Format: "City, STATE, US" or "City, Country"
    parts = [p.strip() for p in location_str.split(',')]
    
    city = parts[0] if len(parts) > 0 else "Unknown"
    state = parts[1] if len(parts) > 1 else None
    country = parts[2] if len(parts) > 2 else parts[1] if len(parts) > 1 else "US"
    
    return city, state, country

def parse_datetime(date_str: str, time_str: Optional[str] = None) -> datetime:
    """Parse MUFON date and time strings"""
    try:
        # Parse date (YYYY-MM-DD format)
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        
        # Parse time if provided (HH:MMAM/PM format)
        if time_str:
            # Remove PM/AM and parse
            time_clean = re.sub(r'(AM|PM)', '', time_str).strip()
            if 'PM' in time_str.upper():
                # Add 12 hours for PM times (except 12PM)
                hour, minute = map(int, time_clean.split(':'))
                if hour != 12:
                    hour += 12
                time_clean = f"{hour}:{minute}"
            elif 'AM' in time_str.upper() and time_clean.startswith('12:'):
                # 12AM is midnight (00:00)
                time_clean = '0' + time_clean[2:]
                
            # Combine date and time
            datetime_str = f"{date_str} {time_clean}"
            return datetime.strptime(datetime_str, "%Y-%m-%d %H:%M")
        
        return date_obj
    except Exception as e:
        print(f"Error parsing datetime: {date_str} {time_str} - {e}")
        return datetime.now()

@router.post("/import", response_model=MufonImportResponse)
async def import_mufon_sightings(
    request: MufonImportRequest,
    background_tasks: BackgroundTasks
):
    """Import MUFON sightings into UFOBeep database"""
    
    imported = 0
    skipped = 0
    errors = []
    sighting_ids = []
    
    # Get database connection
    try:
        db_pool = await asyncpg.create_pool(
            host="localhost",
            port=5432,
            user="ufobeep_user",
            password="ufopostpass",
            database="ufobeep_db",
            min_size=1,
            max_size=5
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    try:
        async with db_pool.acquire() as conn:
            # Create MUFON imports table if it doesn't exist
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS mufon_sightings (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    mufon_case_id TEXT,
                    date_submitted DATE,
                    date_event DATE,
                    time_event TEXT,
                    short_description TEXT,
                    location_raw TEXT,
                    location_city TEXT,
                    location_state TEXT,
                    location_country TEXT,
                    latitude DECIMAL(10,8),
                    longitude DECIMAL(11,8),
                    long_description TEXT,
                    attachments JSONB DEFAULT '[]',
                    import_source TEXT,
                    import_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    processed BOOLEAN DEFAULT false,
                    ufobeep_sighting_id UUID,
                    UNIQUE(mufon_case_id, date_event, location_raw)
                )
            """)
            
            for sighting in request.sightings:
                try:
                    # Parse location
                    city, state, country = parse_location(sighting.location)
                    
                    # Parse datetime
                    event_datetime = parse_datetime(sighting.date_event, sighting.time_event)
                    submitted_date = datetime.strptime(sighting.date_submitted, "%Y-%m-%d")
                    
                    # Check if already imported (avoid duplicates)
                    exists = await conn.fetchval("""
                        SELECT COUNT(*) FROM mufon_sightings 
                        WHERE date_event = $1 
                        AND location_raw = $2 
                        AND short_description = $3
                    """, event_datetime.date(), sighting.location, sighting.short_description)
                    
                    if exists > 0:
                        skipped += 1
                        continue
                    
                    # Insert MUFON sighting
                    sighting_id = await conn.fetchval("""
                        INSERT INTO mufon_sightings (
                            mufon_case_id,
                            date_submitted,
                            date_event,
                            time_event,
                            short_description,
                            location_raw,
                            location_city,
                            location_state,
                            location_country,
                            long_description,
                            attachments,
                            import_source
                        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
                        RETURNING id
                    """, 
                        sighting.mufon_case_id,
                        submitted_date,
                        event_datetime.date(),
                        sighting.time_event,
                        sighting.short_description,
                        sighting.location,
                        city,
                        state,
                        country,
                        sighting.long_description,
                        json.dumps(sighting.attachments),
                        request.import_source
                    )
                    
                    sighting_ids.append(str(sighting_id))
                    imported += 1
                    
                    # TODO: Background task to geocode location and create UFOBeep sighting
                    
                except Exception as e:
                    error_msg = f"Failed to import sighting from {sighting.date_event}: {str(e)}"
                    errors.append(error_msg)
                    print(error_msg)
    
    finally:
        await db_pool.close()
    
    return MufonImportResponse(
        imported=imported,
        skipped=skipped,
        errors=errors,
        sighting_ids=sighting_ids
    )

@router.get("/recent")
async def get_recent_mufon_sightings(
    days: int = 7,
    limit: int = 50
):
    """Get recently imported MUFON sightings"""
    
    # Get database connection
    try:
        db_pool = await asyncpg.create_pool(
            host="localhost",
            port=5432,
            user="ufobeep_user",
            password="ufopostpass",
            database="ufobeep_db",
            min_size=1,
            max_size=5
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    try:
        async with db_pool.acquire() as conn:
            # Get recent MUFON sightings
            since_date = datetime.now() - timedelta(days=days)
            
            rows = await conn.fetch("""
                SELECT 
                    id,
                    mufon_case_id,
                    date_submitted,
                    date_event,
                    time_event,
                    short_description,
                    location_raw,
                    location_city,
                    location_state,
                    location_country,
                    latitude,
                    longitude,
                    long_description,
                    attachments,
                    import_date,
                    processed,
                    ufobeep_sighting_id
                FROM mufon_sightings
                WHERE date_event >= $1
                ORDER BY date_event DESC, import_date DESC
                LIMIT $2
            """, since_date, limit)
            
            sightings = []
            for row in rows:
                sightings.append({
                    "id": str(row["id"]),
                    "mufon_case_id": row["mufon_case_id"],
                    "date_submitted": row["date_submitted"].isoformat() if row["date_submitted"] else None,
                    "date_event": row["date_event"].isoformat() if row["date_event"] else None,
                    "time_event": row["time_event"],
                    "short_description": row["short_description"],
                    "location": {
                        "raw": row["location_raw"],
                        "city": row["location_city"],
                        "state": row["location_state"],
                        "country": row["location_country"],
                        "latitude": float(row["latitude"]) if row["latitude"] else None,
                        "longitude": float(row["longitude"]) if row["longitude"] else None,
                    },
                    "long_description": row["long_description"],
                    "attachments": json.loads(row["attachments"]) if row["attachments"] else [],
                    "import_date": row["import_date"].isoformat() if row["import_date"] else None,
                    "processed": row["processed"],
                    "ufobeep_sighting_id": str(row["ufobeep_sighting_id"]) if row["ufobeep_sighting_id"] else None
                })
            
            return {
                "success": True,
                "count": len(sightings),
                "sightings": sightings,
                "query": {
                    "days": days,
                    "limit": limit,
                    "since": since_date.isoformat()
                }
            }
    
    finally:
        await db_pool.close()

@router.post("/process/{sighting_id}")
async def process_mufon_to_ufobeep(
    sighting_id: str,
    background_tasks: BackgroundTasks
):
    """Process a MUFON sighting and create UFOBeep alert"""
    
    # TODO: Implement conversion of MUFON sighting to UFOBeep alert
    # This would:
    # 1. Geocode the location if not already done
    # 2. Download/process media attachments if available
    # 3. Create UFOBeep sighting with enrichment
    # 4. Mark MUFON sighting as processed
    
    return {
        "success": True,
        "message": f"Processing MUFON sighting {sighting_id}",
        "status": "queued"
    }