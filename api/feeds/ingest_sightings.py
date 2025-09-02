"""
MUFON ingestion for the unified sightings table - single source of truth
"""
from __future__ import annotations
from typing import List, Dict, Any
import asyncpg
import uuid
import json
from datetime import datetime

from .mufon_authenticated_client import fetch_authenticated_reports
import httpx

class DateTimeEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super().default(obj)

async def geocode_location(city: str, state: str = None, country: str = "USA") -> tuple[float, float, str]:
    """
    Geocode city/state to lat/lon coordinates and location name.
    Returns (latitude, longitude, location_name)
    """
    try:
        # Build location string
        location_parts = [city]
        if state:
            location_parts.append(state)
        location_parts.append(country)
        location_query = ", ".join(location_parts)
        
        # Use OpenStreetMap Nominatim for free geocoding
        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://nominatim.openstreetmap.org/search",
                params={
                    "q": location_query,
                    "format": "json",
                    "limit": 1,
                    "addressdetails": 1
                },
                headers={"User-Agent": "UFOBeep/1.0"}
            )
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    result = data[0]
                    lat = float(result["lat"])
                    lon = float(result["lon"])
                    
                    # Build nice location name
                    addr = result.get("address", {})
                    city_name = addr.get("city") or addr.get("town") or addr.get("village") or city
                    state_name = addr.get("state") or state
                    location_name = f"{city_name}, {state_name}" if state_name else city_name
                    
                    return lat, lon, location_name
                    
    except Exception as e:
        print(f"Geocoding failed for {city}, {state}: {e}")
    
    # Fallback to center of USA
    return 39.8283, -98.5795, f"{city}, {state}" if state else city

async def mufon_to_sighting(report: Dict[str, Any]) -> Dict[str, Any]:
    """Convert MUFON report to sightings table format with proper geocoding"""
    sighting_id = str(uuid.uuid4())
    
    # Get real description from MUFON data
    description = report.get("state") or report.get("short_description") or report.get("long_description") or ""
    
    # Extract location from city/state and geocode it
    city = report.get("city") or "Unknown"
    state = report.get("state_abbr") or report.get("state") or None
    country = report.get("country") or "USA"
    
    # Geocode to get proper coordinates and location name
    latitude, longitude, location_name = await geocode_location(city, state, country)
    
    # Handle occurred_at timestamp
    occurred_at = report.get("date_time_of_event")
    
    # Build proper description from both short and long descriptions
    short_desc = report.get("short_description", "").strip()
    long_desc = report.get("long_description", "").strip()
    
    # Combine descriptions appropriately
    if short_desc and long_desc and short_desc != long_desc:
        full_description = f"{short_desc}\n\n{long_desc}"
    else:
        full_description = long_desc or short_desc or description
    
    # Add MUFON source attribution
    if full_description:
        full_description = f"[MUFON Report] {full_description}"
    
    # Create proper sensor_data with location and source info
    sensor_data = {
        "location": {
            "latitude": latitude,
            "longitude": longitude,
            "name": location_name
        },
        "source": "mufon_authenticated",
        "timestamp": occurred_at.isoformat() if occurred_at else datetime.now().isoformat()
    }
    
    return {
        "id": sighting_id,
        "title": short_desc[:100] if short_desc else None,
        "description": full_description,
        "category": "ufo",
        "witness_count": 1,
        "is_public": True,
        "tags": ["mufon", "verified"],
        "media_info": {},
        "sensor_data": sensor_data,
        "alert_level": "low",
        "status": "verified",  # MUFON reports are already verified
        "lat": float(latitude),
        "lon": float(longitude),
        "occurred_at": occurred_at,
        "source": "mufon_auth",
        "source_id": report.get("case_number") or report.get("id"),
        "external_url": report.get("url"),
        "shape": report.get("shape"),
        "duration": report.get("duration"),
        "raw": report,
        "enrichment_data": {},
        "reporter_id": None,
        "firebase_uid": None
    }

async def ingest_mufon_sightings(pool: asyncpg.Pool) -> int:
    """Ingest MUFON reports into the unified sightings table"""
    try:
        # Fetch reports from MUFON
        reports = await fetch_authenticated_reports(limit=30)
        
        if not reports:
            return 0
        
        inserted_count = 0
        
        async with pool.acquire() as conn:
            for report in reports:
                try:
                    # Convert to sightings format with geocoding
                    sighting_data = await mufon_to_sighting(report)
                    
                    # Insert with conflict resolution
                    await conn.execute("""
                        INSERT INTO sightings (
                            id, title, description, category, witness_count, is_public, 
                            tags, media_info, sensor_data, alert_level, status,
                            lat, lon, occurred_at, source, source_id, external_url,
                            shape, duration, raw, enrichment_data, reporter_id, firebase_uid,
                            ingestion_hash, ingested_at
                        ) VALUES (
                            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, 
                            $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, NOW()
                        )
                        ON CONFLICT (source, source_id) DO NOTHING
                    """,
                        sighting_data["id"],
                        sighting_data["title"],
                        sighting_data["description"], 
                        sighting_data["category"],
                        sighting_data["witness_count"],
                        sighting_data["is_public"],
                        sighting_data["tags"],
                        json.dumps(sighting_data["media_info"]),
                        json.dumps(sighting_data["sensor_data"]),
                        sighting_data["alert_level"],
                        sighting_data["status"],
                        sighting_data["lat"],
                        sighting_data["lon"],
                        sighting_data["occurred_at"],
                        sighting_data["source"],
                        sighting_data["source_id"],
                        sighting_data["external_url"],
                        sighting_data["shape"],
                        sighting_data["duration"],
                        json.dumps(sighting_data["raw"], cls=DateTimeEncoder),
                        json.dumps(sighting_data["enrichment_data"]),
                        sighting_data["reporter_id"],
                        sighting_data["firebase_uid"],
                        f"mufon_{sighting_data['source_id']}_{hash(str(sighting_data['raw']))}"
                    )
                    inserted_count += 1
                    
                except Exception as e:
                    print(f"Failed to insert MUFON report: {e}")
                    continue
                    
        return inserted_count
        
    except Exception as e:
        print(f"Error in MUFON sightings ingestion: {e}")
        return 0

# Alias for backward compatibility
async def ingest_mufon(pool: asyncpg.Pool) -> int:
    """Backward compatibility alias"""
    return await ingest_mufon_sightings(pool)