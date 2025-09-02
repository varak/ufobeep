#!/usr/bin/env python3
"""
Clean MUFON → UFOBeep importer
- No fake coordinates or fake comment counts
- Uses real MUFON case numbers and descriptions
- Location extraction fallback when coordinates missing
- Faithful to extracted JSON data structure
"""

import json
import requests
import os
import re
import sys
import time
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, List, Optional, Tuple

# Configuration
API_BASE = os.getenv("UFOBEEP_API_BASE", "http://localhost:8000")
API_TOKEN = os.getenv("UFOBEEP_API_TOKEN")  # Bearer token if needed
ALLOW_NO_COORDS = os.getenv("UFOBEEP_ALLOW_NO_COORDS", "false").lower() == "true"

def extract_location_from_description(long_description: str, location_field: str = "") -> Optional[str]:
    """Extract location hints from MUFON case description"""
    if not long_description:
        return location_field if location_field else None
    
    text = long_description.lower()
    
    # Location patterns found in the real MUFON data
    location_patterns = [
        # "Tucson Arizona", "anchorage Alaska" 
        (r'\b([a-z]+)\s+(alaska|arizona|california|texas|florida|missouri|kansas|illinois|ohio)\b', 
         lambda m: f"{m.group(1).title()}, {m.group(2).upper()[:2]}"),
        
        # "Independence area...I70...Lee's Summit" -> Missouri
        (r'\bindependence\b.*?\bi70\b.*?\blee\'?s summit\b',
         lambda m: "Lee's Summit, MO"),
        
        # "O'Hare Airport" -> Chicago
        (r'\bo\'?hare\s+airport\b',
         lambda m: "Chicago, IL"),
         
        # "Merrill field" -> Anchorage  
        (r'\bmerrill\s+field\b',
         lambda m: "Anchorage, AK"),
         
        # General "City, State" pattern
        (r'\b([a-z][a-z\s]+),\s*([a-z]{2})\b',
         lambda m: f"{m.group(1).title()}, {m.group(2).upper()}"),
         
        # Single well-known cities
        (r'\b(phoenix|tucson|seattle|chicago|denver|houston|miami)\b',
         lambda m: m.group(1).title()),
    ]
    
    for pattern, formatter in location_patterns:
        match = re.search(pattern, text)
        if match:
            return formatter(match)
    
    # Fallback to original location field
    return location_field if location_field else None

def geocode_location(location_text: str) -> Optional[Tuple[float, float, str]]:
    """Get coordinates for a location string using Nominatim"""
    if not location_text or location_text.strip() == "":
        return None
        
    try:
        # Clean up the location text
        clean_location = location_text.strip()
        
        # Skip obviously bad locations
        if any(skip in clean_location.lower() for skip in [
            "saw on tv", "kong channel", "light orbs", "fault line", "unknown"
        ]):
            return None
        
        url = "https://nominatim.openstreetmap.org/search"
        params = {
            'q': clean_location,
            'format': 'json',
            'limit': 1,
            'addressdetails': 1
        }
        headers = {'User-Agent': 'UFOBeep MUFON Import Script'}
        
        response = requests.get(url, params=params, headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data and len(data) > 0:
                result = data[0]
                lat = float(result['lat'])
                lon = float(result['lon'])
                display_name = result.get('display_name', clean_location)
                return lat, lon, display_name
                
        time.sleep(1)  # Rate limiting
        
    except Exception as e:
        print(f"   Geocoding error for '{location_text}': {e}")
        
    return None

def build_sighting_payload(case: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Convert MUFON case to UFOBeep sighting format"""
    
    # Get real MUFON case number
    case_number = case.get('case_number', '')
    if not case_number or case_number == "1":  # Skip malformed cases
        return None
    
    # Get descriptions
    long_description = case.get('long_description', '')
    short_description = case.get('short_description', '')
    location_field = case.get('location', '')
    
    # Use long description if available, otherwise short
    main_description = long_description if long_description and len(long_description) > len(short_description) else short_description
    
    if not main_description or len(main_description.strip()) < 10:
        return None
    
    # Try to extract and geocode location
    location_text = extract_location_from_description(long_description, location_field)
    geocoded = geocode_location(location_text) if location_text else None
    
    if not geocoded and not ALLOW_NO_COORDS:
        print(f"   Skipping case #{case_number} - no valid location found")
        return None
    
    # Build payload using existing UFOBeep sighting structure
    lat, lon, formatted_location = geocoded if geocoded else (None, None, location_text)
    
    # Parse timestamp 
    date_time = case.get('date_time', '')
    observed_at = None
    if date_time:
        try:
            # Handle format like "2024-08-04"
            if re.match(r'^\d{4}-\d{2}-\d{2}$', date_time):
                observed_at = f"{date_time}T12:00:00Z"
            else:
                observed_at = date_time
        except:
            pass
    
    # Format media files
    media_files = case.get('media_files', [])
    media_urls = []
    for media in media_files:
        url = media.get('url', '')
        if url:
            media_urls.append(url)
    
    # Create title
    title = f"MUFON Case #{case_number}"
    if "historical" in main_description.lower() or (date_time and date_time.startswith("19")):
        title = f"Historical {title}"
    
    payload = {
        "source": "mufon",
        "source_id": str(case_number),
        "title": title,
        "description": main_description,
        "observed_at": observed_at,
        "latitude": lat,
        "longitude": lon,
        "location_name": formatted_location,
        "username": "MUFON Database",
        "enrichment_data": {
            "mufon_case_number": str(case_number),
            "location_extraction_method": "description_analysis" if geocoded else "none",
            "media_count": len(media_urls),
            "original_location_field": location_field
        }
    }
    
    # Add media URLs if we have them
    if media_urls:
        payload["media_urls"] = media_urls
    
    return payload

def post_sighting(payload: Dict[str, Any]) -> bool:
    """Post sighting to UFOBeep API"""
    url = f"{API_BASE}/sightings"
    headers = {"Content-Type": "application/json"}
    if API_TOKEN:
        headers["Authorization"] = f"Bearer {API_TOKEN}"
    
    try:
        response = requests.post(url, headers=headers, json=payload, timeout=30)
        if response.status_code in (200, 201):
            result = response.json()
            sighting_id = result.get('id') or result.get('sighting_id')
            print(f"   ✅ Created sighting {sighting_id}")
            return True
        else:
            print(f"   ❌ Failed to create sighting: {response.status_code} - {response.text[:200]}")
            return False
    except Exception as e:
        print(f"   ❌ Request error: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: python import_mufon_clean.py <json_file> [--dry-run]")
        print("Example: python import_mufon_clean.py mufon_cases_2024_09_05.json")
        sys.exit(1)
    
    json_file = sys.argv[1]
    dry_run = "--dry-run" in sys.argv
    
    if not os.path.exists(json_file):
        print(f"❌ File not found: {json_file}")
        sys.exit(1)
    
    # Load MUFON data
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    cases = data.get('cases', [])
    total_cases = len(cases)
    
    print(f"📊 Processing {total_cases} MUFON cases from {json_file}")
    print(f"🔧 API: {API_BASE}")
    print(f"🗺️  Allow no coordinates: {ALLOW_NO_COORDS}")
    
    if dry_run:
        print("🔍 DRY RUN MODE - no data will be posted")
    
    imported = 0
    skipped = 0
    
    for i, case in enumerate(cases, 1):
        case_number = case.get('case_number', 'unknown')
        print(f"\n[{i}/{total_cases}] Processing MUFON case #{case_number}")
        
        # Build the payload
        payload = build_sighting_payload(case)
        if not payload:
            print(f"   ⏭️  Skipped - insufficient data")
            skipped += 1
            continue
        
        if dry_run:
            print(f"   📋 Would create: {payload['title']}")
            if payload.get('latitude'):
                print(f"   📍 Location: {payload['location_name']} ({payload['latitude']:.4f}, {payload['longitude']:.4f})")
            else:
                print(f"   📍 Location: No coordinates")
            print(f"   📎 Media files: {len(payload.get('media_urls', []))}")
            imported += 1
            continue
        
        # Post to API
        if post_sighting(payload):
            imported += 1
        else:
            skipped += 1
        
        # Rate limiting
        time.sleep(0.5)
    
    print(f"\n🎉 Completed: {imported} imported, {skipped} skipped")

if __name__ == "__main__":
    main()