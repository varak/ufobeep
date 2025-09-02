#!/usr/bin/env python3
"""
Save MUFON cases with geocoded data to JSON for later import
"""
import json
import requests
import time
from pathlib import Path
from datetime import datetime

def geocode_and_save():
    """Geocode MUFON cases and save to JSON"""
    
    # Load extracted MUFON data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON data file found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    print(f"📊 Processing {mufon_data['total_cases']} MUFON cases...")
    
    geocoded_cases = []
    
    def geocode_location(location_string):
        """Geocode location using Nominatim (OpenStreetMap) API with creative parsing"""
        if not location_string or location_string == "0":
            return 39.8283, -98.5795, "Unknown Location, US"  # US center
        
        # Clean up and parse the location string creatively
        query = location_string
        
        # Handle special cases
        if "15 1/2 North-Fm 491 Colonia" in location_string:
            # This appears to be near Laredo, TX on FM 491
            query = "FM 491, Laredo, TX, US"
        elif location_string.startswith("0,"):
            # Extract state if present (e.g., "0, PA, US" -> "Pennsylvania, US")
            parts = location_string.split(',')
            if len(parts) >= 2:
                state = parts[1].strip()
                if state and state != "0":
                    query = f"{state}, US"
        
        # Clean up the query
        query = query.replace("  ", " ").strip()
        
        try:
            # First attempt with the cleaned query
            url = "https://nominatim.openstreetmap.org/search"
            params = {
                'q': query,
                'format': 'json',
                'limit': 1,
                'countrycodes': 'us'  # Limit to US for MUFON data
            }
            
            headers = {'User-Agent': 'UFOBeep MUFON Import Script'}
            response = requests.get(url, params=params, headers=headers, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    result = data[0]
                    print(f"   ✅ Geocoded: {query}")
                    return float(result['lat']), float(result['lon']), result['display_name']
            
            # If first attempt fails, try extracting just city and state
            if ',' in location_string:
                # Try just the city and state (first two parts)
                parts = location_string.split(',')
                if len(parts) >= 2:
                    fallback_query = f"{parts[0].strip()}, {parts[1].strip()}, US"
                    params['q'] = fallback_query
                    response = requests.get(url, params=params, headers=headers, timeout=5)
                    
                    if response.status_code == 200:
                        data = response.json()
                        if data:
                            result = data[0]
                            print(f"   ✅ Geocoded '{location_string}' as '{fallback_query}'")
                            return float(result['lat']), float(result['lon']), result['display_name']
            
            print(f"   ⚠️ Geocoding failed for: {location_string}, using US center")
            return 39.8283, -98.5795, location_string  # Fallback to US center
            
        except Exception as e:
            print(f"   ❌ Geocoding error for {location_string}: {e}")
            return 39.8283, -98.5795, location_string  # Fallback
    
    for case in mufon_data['cases']:
        print(f"\n--- Processing Case #{case.get('Case_Number')} ---")
        print(f"   Location: {case.get('Location', '')}")
        
        # Parse location and geocode it
        location = case.get('Location', '')
        lat, lon, display_name = geocode_location(location)
        time.sleep(1)  # Be respectful to free geocoding API
        
        # Build geocoded case data
        geocoded_case = {
            "case_number": case.get('Case_Number'),
            "date_submitted": case.get('Date_Submitted'),
            "datetime_event": case.get('DateTime_Event', '').replace('\n', ' '),
            "title": case.get('Short_Description', '')[:100],
            "description": case.get('Short_Description', ''),
            "original_location": location,
            "geocoded_location": display_name,
            "latitude": lat,
            "longitude": lon,
            "attachments": case.get('Attachments', ''),
            "media_files": case.get('Attachments_media', [])
        }
        
        geocoded_cases.append(geocoded_case)
        print(f"   📍 Coordinates: {lat:.4f}, {lon:.4f}")
    
    # Save to JSON
    output_file = Path("mufon_geocoded_ready.json")
    with open(output_file, 'w') as f:
        json.dump({
            "timestamp": datetime.now().isoformat(),
            "total_cases": len(geocoded_cases),
            "cases": geocoded_cases
        }, f, indent=2)
    
    print(f"\n✅ Saved {len(geocoded_cases)} geocoded cases to {output_file}")
    print("\n📋 Sample case:")
    print(json.dumps(geocoded_cases[0], indent=2))

if __name__ == "__main__":
    geocode_and_save()