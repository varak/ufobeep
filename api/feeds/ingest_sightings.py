"""
MUFON ingestion for the unified sightings table - single source of truth
"""
from __future__ import annotations
from typing import List, Dict, Any
import asyncpg
import uuid
import json
import asyncio
import re
from datetime import datetime

from .mufon_authenticated_client import fetch_authenticated_reports
import httpx
from pathlib import Path
import hashlib

class DateTimeEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super().default(obj)

def _clean_mufon_location_data(city: str, state: str = None, country: str = None) -> tuple[str, str, str]:
    """Clean messy MUFON location data - but keep data that might be meaningful"""
    # We found that "0, PA, US" actually geocodes to a real location in PA
    # So we should be less aggressive about cleaning
    
    # Only clean if it's just "0" by itself, not "0, STATE"
    if city and city.strip() == '0':
        city = ""
    
    # Clean up standalone zero state
    if state and state.strip() == '0':
        state = ""
    
    # Default country if missing or just zero
    if not country or country.strip() in ['', '0']:
        country = "US"
    
    return city.strip() if city else "", state.strip() if state else "", country.strip()

async def geocode_location(city: str, state: str = None, country: str = "USA") -> tuple[float | None, float | None, str]:
    """
    Geocode city/state to lat/lon coordinates and location name.
    Returns (latitude, longitude, location_name) - lat/lon are None if geocoding fails
    """
    # Clean the messy MUFON data first
    clean_city, clean_state, clean_country = _clean_mufon_location_data(city, state, country)
    
    # Build original location string exactly as reported by MUFON
    original_location_parts = []
    if city and city.strip():
        original_location_parts.append(city.strip())
    if state and state.strip():
        original_location_parts.append(state.strip())
    if country and country.strip():
        original_location_parts.append(country.strip())
    
    original_location = ", ".join(original_location_parts) if original_location_parts else "Unknown Location"
    
    # Only attempt geocoding if we have meaningful location data
    if not clean_city and not clean_state:
        print(f"⚠️  No meaningful location data to geocode: '{original_location}'")
        return None, None, original_location
    
    try:
        # Try multiple geocoding strategies with cleaned data
        queries_to_try = []
        
        # Strategy 1: Full location if we have city
        if clean_city and clean_state:
            queries_to_try.append(f"{clean_city}, {clean_state}, {clean_country}")
        
        # Strategy 2: Just state if no city but have state
        if clean_state and not clean_city:
            queries_to_try.append(f"{clean_state}, {clean_country}")
        
        # Strategy 3: Just city if we have it but no state
        if clean_city and not clean_state:
            queries_to_try.append(f"{clean_city}, {clean_country}")
        
        for query in queries_to_try:
            try:
                print(f"🌍 Geocoding: '{query}'")
                
                # Use OpenStreetMap Nominatim for free geocoding
                async with httpx.AsyncClient() as client:
                    response = await client.get(
                        "https://nominatim.openstreetmap.org/search",
                        params={
                            "q": query,
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
                            
                            print(f"✅ Geocoded '{query}' to {lat}, {lon}")
                            return lat, lon, original_location
                        else:
                            print(f"❌ No geocoding results for '{query}'")
                    
                    # Rate limit to be nice to the service
                    await asyncio.sleep(0.5)
                    
            except Exception as e:
                print(f"❌ Geocoding error for '{query}': {e}")
                continue
                    
    except Exception as e:
        print(f"❌ Geocoding setup error: {e}")
    
    # Return None coordinates but preserve original location string
    print(f"⚠️  Could not geocode location, preserving original: '{original_location}'")
    return None, None, original_location

async def mufon_to_sighting(report: Dict[str, Any]) -> Dict[str, Any]:
    """Convert MUFON report to sightings table format with proper geocoding"""
    sighting_id = str(uuid.uuid4())
    
    # Get real description from MUFON data
    description = report.get("state") or report.get("short_description") or report.get("long_description") or ""
    
    # Extract case ID first - this is our key to the database
    case_id = report.get("case_number") or report.get("id")
    if not case_id:
        # Try to extract from URL if available
        url = report.get("url") or ""
        import re
        match = re.search(r'id=(\d+)', url)
        if match:
            case_id = match.group(1)
        else:
            case_id = str(uuid.uuid4())[:8]
    
    # Extract location from MUFON data - preserve exactly as reported
    city = report.get("city") or ""
    state = report.get("state_abbr") or report.get("state") or ""
    country = report.get("country") or ""
    
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
    
    # Process and download media attachments from MUFON if available
    media_info = {"files": [], "file_count": 0}
    raw_media = report.get("media_files", [])
    
    if raw_media:
        processed_media = []
        for i, media in enumerate(raw_media):
            try:
                # Download and mirror the media file
                mirrored_file = await _download_and_mirror_mufon_media(
                    media.get("url"), 
                    sighting_id, 
                    media.get("case_number", "unknown"), 
                    i,
                    media.get("type", "image")
                )
                
                if mirrored_file:
                    processed_media.append(mirrored_file)
            except Exception as e:
                print(f"Failed to mirror MUFON media {media.get('url')}: {e}")
                continue
        
        media_info = {
            "files": processed_media,
            "file_count": len(processed_media),
            "source": "mufon_mirrored"
        }
    
    # Build original MUFON location string exactly as reported
    original_location = ", ".join(filter(None, [city, state, country]))
    
    # Create proper sensor_data with location and MUFON-specific data
    sensor_data = {
        "location": {
            "latitude": latitude,
            "longitude": longitude,
            "name": location_name
        },
        "mufon_data": {
            "original_location": original_location,
            "case_id": case_id,
            "raw_city": city,
            "raw_state": state,
            "raw_country": country
        },
        "source": "mufon_authenticated", 
        "timestamp": occurred_at.isoformat() if occurred_at else datetime.now().isoformat(),
        "ingested_at": datetime.now().isoformat()
    }
    
    return {
        "id": sighting_id,
        "title": short_desc[:100] if short_desc else None,
        "description": full_description,
        "category": "ufo",
        "witness_count": 1,
        "is_public": True,
        "tags": ["mufon", "verified"],
        "media_info": media_info,
        "sensor_data": sensor_data,
        "alert_level": "low",
        "status": "verified",  # MUFON reports are already verified
        "lat": latitude,  # Can be None if geocoding fails
        "lon": longitude,  # Can be None if geocoding fails
        "occurred_at": occurred_at,
        "source": "mufon",
        "source_id": case_id,  # Use extracted case ID as database key
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
        # Fetch reports from MUFON (3-day window from changes in mufon_authenticated_client.py)
        reports = await fetch_authenticated_reports(limit=30)
        
        if not reports:
            print("No MUFON reports found")
            return 0
        
        print(f"Processing {len(reports)} MUFON reports...")
        
        # Pre-check: Get existing MUFON case IDs to avoid reprocessing
        existing_case_ids = set()
        async with pool.acquire() as conn:
            rows = await conn.fetch(
                "SELECT source_id FROM sightings WHERE source = 'mufon' AND source_id IS NOT NULL"
            )
            existing_case_ids = {row['source_id'] for row in rows}
            print(f"Found {len(existing_case_ids)} existing MUFON case IDs in database")
        
        inserted_count = 0
        skipped_count = 0
        
        async with pool.acquire() as conn:
            for report in reports:
                try:
                    # Extract case ID to check if we already have it
                    case_id = report.get("case_number") or report.get("id")
                    if not case_id:
                        # Try to extract from URL
                        url = report.get("url") or ""
                        import re
                        match = re.search(r'id=(\d+)', url)
                        if match:
                            case_id = match.group(1)
                    
                    # Skip if we already have this case
                    if case_id and case_id in existing_case_ids:
                        print(f"⏭️  Skipping existing case ID: {case_id}")
                        skipped_count += 1
                        continue
                    
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
        
        print(f"✅ Inserted {inserted_count} new MUFON reports, skipped {skipped_count} existing")
        return inserted_count
        
    except Exception as e:
        print(f"Error in MUFON sightings ingestion: {e}")
        return 0

# Alias for backward compatibility
async def ingest_mufon(pool: asyncpg.Pool) -> int:
    """Backward compatibility alias"""
    return await ingest_mufon_sightings(pool)

async def _download_and_mirror_mufon_media(url: str, sighting_id: str, case_number: str, index: int, media_type: str) -> Dict[str, Any]:
    """Download MUFON media and store like a normal sighting - use existing UFOBeep media infrastructure"""
    try:
        # Use same media path as normal sightings
        media_root = Path("/home/ufobeep/ufobeep/media")
        sighting_media_dir = media_root / sighting_id
        sighting_media_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate filename like normal uploads
        url_hash = hashlib.md5(url.encode()).hexdigest()[:8]
        file_extension = Path(url).suffix or ('.jpg' if media_type == 'image' else '.mp4')
        filename = f"{uuid.uuid4()}{file_extension}"  # Same pattern as normal uploads
        file_path = sighting_media_dir / filename
        
        # Skip if already exists
        if not file_path.exists():
            # Download with auth session (reuse MUFON session)
            async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
                response = await client.get(url)
                response.raise_for_status()
                
                with open(file_path, 'wb') as f:
                    f.write(response.content)
                
                print(f"Downloaded MUFON media: {filename} ({len(response.content)} bytes)")
        
        # Return same format as normal sighting media - UFOBeep will handle thumbnails/processing automatically
        return {
            "type": media_type,
            "filename": filename,
            "url": f"https://api.ufobeep.com/media/{sighting_id}/{filename}",
            "thumbnail_url": f"https://api.ufobeep.com/media/{sighting_id}/{filename}?thumbnail=true",
            "web_url": f"https://api.ufobeep.com/media/{sighting_id}/{filename}",
            "preview_url": f"https://api.ufobeep.com/media/{sighting_id}/{filename}?thumbnail=true"
        }
        
    except Exception as e:
        print(f"Failed to download MUFON media {url}: {e}")
        return None