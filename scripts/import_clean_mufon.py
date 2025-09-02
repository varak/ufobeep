#!/usr/bin/env python3
"""
Clean MUFON importer for properly extracted JSON data
Works with httpx_proper_extractor.py output with correct field mapping
"""

import json
import requests
import os
import sys
import time
from pathlib import Path
from datetime import datetime

# Configuration
API_BASE = os.getenv("UFOBEEP_API_BASE", "http://localhost:8000")
API_TOKEN = os.getenv("UFOBEEP_API_TOKEN")

def import_mufon_json(json_file, dry_run=False):
    """Import MUFON cases from properly extracted JSON"""
    
    if not os.path.exists(json_file):
        print(f"❌ File not found: {json_file}")
        return
    
    # Load the JSON data
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    cases = data.get('cases', [])
    total_cases = len(cases)
    
    print(f"📊 Processing {total_cases} MUFON cases from {json_file}")
    print(f"🔧 API: {API_BASE}")
    print(f"📅 Search date: {data.get('search_date', 'unknown')}")
    print(f"🛠️  Extraction method: {data.get('extraction_method', 'unknown')}")
    
    if dry_run:
        print("🔍 DRY RUN MODE - no data will be posted")
    
    imported = 0
    skipped = 0
    
    for i, case in enumerate(cases, 1):
        case_number = case.get('case_number', 'unknown')
        print(f"\n[{i}/{total_cases}] Processing MUFON case #{case_number}")
        
        # Show what we have for this case
        print(f"   📋 Fields available:")
        for key, value in case.items():
            if key != 'media_files' and value:
                display_value = str(value)[:80] + "..." if len(str(value)) > 80 else str(value)
                print(f"     {key}: {display_value}")
        
        media_count = len(case.get('media_files', []))
        print(f"     media_files: {media_count} files")
        
        # Build the sighting payload
        payload = build_sighting_payload(case)
        
        if not payload:
            print(f"   ⏭️  Skipped - insufficient data")
            skipped += 1
            continue
        
        if dry_run:
            print(f"   📋 Would create: {payload['title']}")
            if payload.get('latitude') and payload.get('longitude'):
                print(f"   📍 Location: {payload.get('location_name', 'unknown')} ({payload['latitude']:.4f}, {payload['longitude']:.4f})")
            else:
                print(f"   📍 Location: {payload.get('location_name', 'No coordinates')}")
            print(f"   📎 Media files: {len(payload.get('media_urls', []))}")
            imported += 1
            continue
        
        # Post to API
        if post_mufon_report(payload):
            imported += 1
        else:
            skipped += 1
        
        # Rate limiting
        time.sleep(0.5)
    
    print(f"\n🎉 Completed: {imported} imported, {skipped} skipped")

def build_sighting_payload(case):
    """Build UFOBeep sighting payload from MUFON case data"""
    
    case_number = case.get('case_number')
    if not case_number:
        return None
    
    # Use the properly extracted fields
    location_name = case.get('location')
    description = case.get('long_description') or case.get('description', '')
    date_time = case.get('date_time', '')
    media_files = case.get('media_files', [])
    
    # Basic validation - require either description OR media files
    has_description = description and len(description.strip()) >= 10
    has_media = len(media_files) > 0
    
    if not has_description and not has_media:
        return None
        
    # Use a minimal description if none exists but we have media
    if not has_description and has_media:
        description = f"MUFON case #{case_number} with {len(media_files)} media file(s)."
    
    # Create title
    title = f"MUFON Case #{case_number}"
    
    # Parse timestamp if available
    observed_at = None
    if date_time:
        try:
            # Handle various date formats
            if '-' in date_time:
                observed_at = f"{date_time}T12:00:00Z"
            else:
                observed_at = date_time
        except:
            pass
    
    # Handle media files
    media_files = case.get('media_files', [])
    media_urls = []
    for media in media_files:
        if media.get('url'):
            media_urls.append(media['url'])
    
    # For now, we'll import without coordinates and let the API handle geocoding
    # The properly extracted location field should contain actual location info
    payload = {
        "source": "mufon",
        "source_id": str(case_number),
        "title": title,
        "description": description,
        "observed_at": observed_at,
        "location_name": location_name,
        "username": "MUFON Database",
        "enrichment_data": {
            "mufon_case_number": str(case_number),
            "extraction_method": "httpx_json_parsing",
            "media_count": len(media_urls),
            "original_case_data": case  # Keep original for reference
        }
    }
    
    # Add media URLs if available
    if media_urls:
        payload["media_urls"] = media_urls
    
    return payload

def post_mufon_report(payload):
    """Post MUFON report to UFOBeep API"""
    url = f"{API_BASE}/alerts"
    headers = {"Content-Type": "application/json"}
    if API_TOKEN:
        headers["Authorization"] = f"Bearer {API_TOKEN}"
    
    try:
        response = requests.post(url, headers=headers, json=payload, timeout=30)
        if response.status_code in (200, 201):
            result = response.json()
            report_id = result.get('id') or result.get('alert_id')
            print(f"   ✅ Created alert {report_id}")
            return True
        else:
            print(f"   ❌ Failed to create alert: {response.status_code} - {response.text[:200]}")
            return False
    except Exception as e:
        print(f"   ❌ Request error: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: python import_clean_mufon.py <json_file> [--dry-run]")
        print("Example: python import_clean_mufon.py mufon_json_2024_09_06.json")
        sys.exit(1)
    
    json_file = sys.argv[1]
    dry_run = "--dry-run" in sys.argv
    
    import_mufon_json(json_file, dry_run)

if __name__ == "__main__":
    main()