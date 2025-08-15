#!/usr/bin/env python3
"""
Parse and import MUFON sighting data from clipboard or file
"""
import re
import json
import requests
from datetime import datetime
from typing import List, Dict, Any

def parse_mufon_table(text: str) -> List[Dict[str, Any]]:
    """Parse MUFON table data from text"""
    sightings = []
    
    # Split by lines and process each sighting
    lines = text.strip().split('\n')
    current_sighting = None
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Check if this is a new sighting (starts with number)
        if re.match(r'^\d+\s+\d{4}-\d{2}-\d{2}', line):
            # Save previous sighting if exists
            if current_sighting:
                sightings.append(current_sighting)
            
            # Parse new sighting
            parts = line.split('\t') if '\t' in line else re.split(r'\s{2,}', line)
            
            # Extract fields
            if len(parts) >= 5:
                current_sighting = {
                    'date_submitted': parts[1].strip(),
                    'date_event': '',
                    'time_event': None,
                    'short_description': '',
                    'location': '',
                    'long_description': '',
                    'attachments': []
                }
                
                # Parse date/time of event (format: 2025-08-14\n10:07PM or just date)
                event_parts = parts[2].strip().split('\n') if '\n' in parts[2] else parts[2].strip().split()
                if len(event_parts) >= 1:
                    current_sighting['date_event'] = event_parts[0]
                    if len(event_parts) >= 2:
                        current_sighting['time_event'] = event_parts[1]
                
                # Get description
                if len(parts) > 3:
                    current_sighting['short_description'] = parts[3].strip()
                
                # Get location
                if len(parts) > 4:
                    current_sighting['location'] = parts[4].strip()
                
                # Get long description if present
                if len(parts) > 5:
                    current_sighting['long_description'] = parts[5].strip()
                
                # Get attachments if present
                if len(parts) > 6:
                    attachments = parts[6].strip()
                    if attachments:
                        # Split by newlines or common separators
                        att_list = re.split(r'[\n,]', attachments)
                        current_sighting['attachments'] = [a.strip() for a in att_list if a.strip()]
        
        # If line contains attachment files (ends with common extensions)
        elif current_sighting and re.search(r'\.(mp4|mov|jpg|jpeg|png|gif)$', line, re.IGNORECASE):
            # Add to attachments of current sighting
            files = re.findall(r'[\w\d_-]+\.\w+', line)
            current_sighting['attachments'].extend(files)
    
    # Don't forget the last sighting
    if current_sighting:
        sightings.append(current_sighting)
    
    return sightings

def import_to_ufobeep(sightings: List[Dict[str, Any]], api_url: str = "https://api.ufobeep.com"):
    """Import sightings to UFOBeep via API"""
    
    # Prepare import request
    import_request = {
        "sightings": sightings,
        "import_source": "mufon_manual"
    }
    
    # Send to API
    response = requests.post(
        f"{api_url}/mufon/import",
        json=import_request,
        headers={"Content-Type": "application/json"}
    )
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Import successful!")
        print(f"  - Imported: {result['imported']}")
        print(f"  - Skipped (duplicates): {result['skipped']}")
        if result.get('errors'):
            print(f"  - Errors: {len(result['errors'])}")
            for error in result['errors'][:5]:  # Show first 5 errors
                print(f"    • {error}")
    else:
        print(f"❌ Import failed: {response.status_code}")
        print(response.text)

def main():
    # Sample MUFON data (from the table you provided)
    sample_data = """
1    2025-08-15    2025-03-18 10:23PM    A star-like vibrating orb, that vibrated and then changed shape and color. It went from a vibrating white orb, then expanded and turned bluish.    Staten Island, NY, US        SIUFO2025.mp4
2    2025-08-15    2025-08-15 6:30AM    White line stationary in air    Winchester, KY, US        
3    2025-08-15    2025-08-14 1:15AM    Star Like UAPs over GINNA Power Plant    Rochester, NY, US        20250803235554.mp4 20250803235818.mp4
4    2025-08-15    2025-08-14 11:47PM    Multiple lights in the sky over three consecutive nights    Placerville, CA, US        IMG8251.mov IMG8249.mov
5    2025-08-15    2025-08-14 8:02PM    group of objects flew overhead and fanned out and kept going    Santee, CA, US        IMG4301.mov
"""
    
    # Parse the data
    print("📊 Parsing MUFON sighting data...")
    sightings = parse_mufon_table(sample_data)
    
    print(f"Found {len(sightings)} sightings to import")
    
    # Show preview
    for i, sighting in enumerate(sightings[:3], 1):
        print(f"\n{i}. {sighting['date_event']} - {sighting['location']}")
        print(f"   {sighting['short_description'][:80]}...")
        if sighting['attachments']:
            print(f"   Media: {', '.join(sighting['attachments'][:3])}")
    
    # Import to UFOBeep
    print("\n📤 Importing to UFOBeep...")
    import_to_ufobeep(sightings)

if __name__ == "__main__":
    main()