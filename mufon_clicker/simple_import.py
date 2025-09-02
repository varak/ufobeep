#!/usr/bin/env python3
"""
Simple MUFON importer that works with our extracted data format
"""
import json
import requests
import time
from datetime import datetime, timezone

def import_mufon_cases(json_file):
    """Import MUFON cases directly to UFOBeep alerts API"""
    
    with open(json_file) as f:
        data = json.load(f)
    
    print(f"📊 Importing {data['total_cases']} MUFON cases to UFOBeep...")
    
    api_url = "https://api.ufobeep.com/alerts"
    imported_count = 0
    
    for case in data['cases']:
        try:
            print(f"\n--- Importing MUFON Case #{case['case_number']} ---")
            
            # Create alert payload
            alert_data = {
                "title": f"MUFON Case #{case['case_number']}",
                "description": case['long_description'],
                "location_name": case['location'],
                "latitude": 39.8283,  # Default to US center for now
                "longitude": -98.5795,
                "source": "MUFON",
                "source_id": str(case['case_number']),
                "sighting_date": case['date_time'],
                "classification": "unidentified",
                "credibility": 0.7,
                "tags": ["mufon", "imported", "ufo"],
                "media_urls": []
            }
            
            print(f"📝 Title: {alert_data['title']}")
            print(f"📍 Location: {alert_data['location_name']}")
            print(f"📅 Date: {alert_data['sighting_date']}")
            print(f"📖 Description: {alert_data['description'][:80]}...")
            
            # Send to UFOBeep API
            response = requests.post(
                api_url,
                json=alert_data,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            
            if response.status_code == 201:
                print(f"✅ Successfully imported case #{case['case_number']}")
                imported_count += 1
            else:
                print(f"❌ Failed to import case #{case['case_number']}: {response.status_code}")
                print(f"   Response: {response.text}")
            
            time.sleep(1)  # Be respectful to API
            
        except Exception as e:
            print(f"❌ Error importing case #{case['case_number']}: {e}")
            continue
    
    print(f"\n🎉 Import complete! Successfully imported {imported_count}/{data['total_cases']} cases")
    return imported_count

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python simple_import.py mufon_cases_file.json")
        sys.exit(1)
    
    json_file = sys.argv[1]
    import_mufon_cases(json_file)