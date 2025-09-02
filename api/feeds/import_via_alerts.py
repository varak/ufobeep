#!/usr/bin/env python3
"""
Import MUFON cases using existing UFOBeep alert creation system
"""
import json
import requests
import asyncio
import os
from pathlib import Path
from datetime import datetime
import time
import re
from ufo_classifier import UFOClassifier

def extract_location_from_description(long_description, location_field):
    """Extract real location from long description text"""
    if not long_description:
        return None
    
    # Skip if location field looks like a real location already
    if any(indicator in location_field.lower() for indicator in ['county', 'city', ', tx', ', ca', ', fl', ', ny', 'oklahoma', 'california']):
        return location_field
    
    # Look for location patterns in long description
    location_patterns = [
        r'([A-Z][a-z]+) ([A-Z][a-z]+)(?=\s|,|\.|$)',  # "Quincy Illinois" pattern
        r'in ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*), ([A-Z]{2})',  # in City, ST
        r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*), ([A-Z]{2})(?:\s|\.)',  # City, ST
        r'near ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*), ([A-Z]{2})',  # near City, ST
        r'in ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',  # in City
        r'near ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',  # near City  
    ]
    
    for pattern in location_patterns:
        matches = re.findall(pattern, long_description)
        if matches:
            match = matches[0]
            if isinstance(match, tuple) and len(match) == 2:  # City, State format like ("Quincy", "Illinois")
                city, state = match
                return f"{city} {state}"  # Let geocoding handle "Quincy Illinois"
            else:  # Single location
                return match if isinstance(match, str) else str(match)
    
    # Fallback to location field if no patterns match
    return location_field if location_field else None

def import_mufon_cases():
    """Import MUFON cases using existing alert endpoints"""
    import sys
    if len(sys.argv) < 2:
        print("Usage: python import_via_alerts.py <json_file>")
        print("Example: python import_via_alerts.py mufon_cases.json")
        return
    
    # Load extracted MUFON data
    data_file = Path(sys.argv[1])
    
    if not data_file.exists():
        print(f"❌ No MUFON data file found: {data_file}")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    cases = mufon_data['cases']
    total_cases = mufon_data['total_cases']
    
    print(f"📊 Processing {total_cases} MUFON cases...")
    
    # Extract search date from MUFON data to determine what's "recent"
    search_date_str = mufon_data.get('search_date', '')
    try:
        search_date = datetime.strptime(search_date_str, '%Y-%m-%d')
        search_year = search_date.year
    except:
        search_year = datetime.now().year  # Fallback to current year
    
    base_url = "http://localhost:8000"
    imported_count = 0
    classifier = UFOClassifier()  # Initialize UFO classifier
    
    for case in cases:
        try:
            case_num = case.get('case_number') or case.get('Case_Number', '')
            print(f"\n--- Processing Case #{case_num} ---")
            
            # Parse location and geocode it
            location = case.get('location') or case.get('Location', '')
            
            def geocode_location(location_string):
                """Geocode location using Nominatim (OpenStreetMap) API with creative parsing"""
                if not location_string or location_string == "0":
                    return 39.8283, -98.5795, "Unknown Location, US"  # US center
                
                # Try to extract real location from long description if location field is not helpful
                long_desc = case.get('long_description') or case.get('Long_Description', '')
                real_location = extract_location_from_description(long_desc, location_string)
                query = real_location if real_location else location_string
                
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
                                    print(f"   Geocoded '{location_string}' as '{fallback_query}'")
                                    return float(result['lat']), float(result['lon']), result['display_name']
                    
                    print(f"   Geocoding failed for: {location_string}, using US center")
                    return 39.8283, -98.5795, location_string  # Fallback to US center
                    
                except Exception as e:
                    print(f"   Geocoding error for {location_string}: {e}")
                    return 39.8283, -98.5795, location_string  # Fallback
            
            lat, lon, display_name = geocode_location(location)
            time.sleep(1)  # Be respectful to free geocoding API
            
            # Parse the datetime event (e.g., "1997-02-24\n9:00PM")
            datetime_event = (case.get('date_time') or case.get('DateTime_Event', '')).replace('\n', ' ')
            
            # Structure descriptions properly:
            # - Short description for alert card display
            # - Long description with MUFON metadata for detail page
            short_desc = case.get('short_description') or case.get('Short_Description', '')
            long_desc = case.get('long_description') or case.get('Long_Description', '')
            
            # Build full description for detail page with HTML formatting
            if long_desc and len(long_desc.strip()) > 10:
                # Use long description if available, convert newlines to paragraphs
                full_description = f"<p>{long_desc.replace(chr(10), '</p><p>')}</p>"
            else:
                # Use short description as the main content since long descriptions aren't available
                full_description = f"<p>{short_desc}</p>"
                if len(short_desc) < 100:
                    full_description += f"<p><em>This is a MUFON case report. Additional witness details may be available in the original MUFON database.</em></p>"
            
            # Classify UFO type for MUFON enrichment data
            classification = classifier.classify(
                full_description, 
                case.get('Short_Description', '')
            )
            
            # Do reverse geocoding to get proper location name
            geocoding_data = {}
            try:
                geocode_url = f"https://nominatim.openstreetmap.org/reverse"
                params = {
                    'lat': lat,
                    'lon': lon,
                    'format': 'json',
                    'addressdetails': 1
                }
                headers = {'User-Agent': 'UFOBeep MUFON Import Script'}
                
                response = requests.get(geocode_url, params=params, headers=headers, timeout=5)
                if response.status_code == 200:
                    data = response.json()
                    if data:
                        formatted_address = data.get('display_name', location)
                        geocoding_data = {
                            "latitude": lat,
                            "longitude": lon,
                            "location_name": formatted_address,
                            "formatted_address": formatted_address,
                            "provider": "OpenStreetMap/Nominatim",
                            "raw_data": data
                        }
                        print(f"   Reverse geocoded: {formatted_address}")
                    
                time.sleep(1)  # Be respectful to geocoding API
            except Exception as e:
                print(f"   Reverse geocoding failed: {e}")
                geocoding_data = {
                    "latitude": lat,
                    "longitude": lon,
                    "location_name": location,
                    "formatted_address": location
                }

            # Add MUFON metadata section with proper HTML formatting
            full_description += f"""

<div style="margin-top: 20px; padding: 15px; background-color: #1a1a1a; border: 1px solid #333; border-radius: 8px;">
<h3 style="color: #39FF14; margin: 0 0 10px 0; font-size: 16px;">🛸 MUFON CASE DETAILS</h3>
<div style="color: #ccc; line-height: 1.6;">
<p><strong>Event Date:</strong> {datetime_event}</p>
<p><strong>Submitted:</strong> {case.get('Date_Submitted', '')}</p>
<p><strong>Location:</strong> {location}</p>
<p><strong>Case Reference:</strong> #{case.get('Case_Number')}</p>
<p><strong>UFO Type:</strong> {classification['type']} (confidence: {classification['confidence']:.1f})</p>
</div>
</div>"""
            
            # Determine if this is historical (more than 1 year old from search date)
            # Extract real event year from short description which contains the actual sighting date
            try:
                short_desc = case.get('Short_Description', '')
                long_desc = case.get('Long_Description', '')
                
                # Look for year in short description first (format: "2022-10-27\n11:03PM")
                event_year = search_year
                if '-' in short_desc:
                    year_match = re.search(r'(\d{4})-\d{2}-\d{2}', short_desc)
                    if year_match:
                        event_year = int(year_match.group(1))
                
                # Fallback: look for year pattern in long description
                if event_year == search_year:
                    year_match = re.search(r'\b(20\d{2})\b', long_desc)
                    if year_match:
                        event_year = int(year_match.group(1))
                
                is_historical = (search_year - event_year) >= 1
                
            except:
                is_historical = True  # Default to historical if can't parse
            
            # Create a proper title based on UFO type and historical status  
            ufo_type = classification['type'].title()
            
            # Create title: "Historical MUFON Triangle UFO Sighting" or just "MUFON Triangle UFO Sighting" for recent
            if is_historical:
                if ufo_type == "Unknown":
                    title = f"Historical MUFON UFO Sighting"
                else:
                    title = f"Historical MUFON {ufo_type} UFO Sighting"
            else:
                if ufo_type == "Unknown":
                    title = f"MUFON UFO Sighting"
                else:
                    title = f"MUFON {ufo_type} UFO Sighting"
            
            # Create beep using the proper pipeline (with MUFON source to skip notifications)
            beep_data = {
                "device_id": f"mufon_{case_num}",
                "location": {
                    "latitude": lat,
                    "longitude": lon,
                    "accuracy": 100.0,
                    "name": location  # Original location text preserved
                },
                "title": title,
                "description": full_description,
                "username": "MUFON_Database",
                "source": "mufon"  # This will skip notifications
            }
            
            print(f"Creating beep: {beep_data['title']}")
            
            # Create the beep - uses proper enrichment pipeline
            headers = {
                'Content-Type': 'application/json',
                'X-Import-Source': 'mufon'  # Special header for imports
            }
            response = requests.post(f"{base_url}/beeps", json=beep_data, headers=headers)
            
            if response.status_code in [200, 201]:
                alert = response.json()
                # Handle both response formats
                alert_id = alert.get('sighting_id') or alert.get('id') or alert.get('data', {}).get('alert_id')
                print(f"✅ Created alert {alert_id}")
                
                # Download and upload media files if they exist
                media_files = case.get('media_files') or case.get('Attachments_media', [])
                if media_files:
                    print(f"📎 Processing {len(media_files)} media files...")
                    
                    for media in media_files:
                        try:
                            media_content = None
                            
                            # First check if we have a local file from extraction
                            if 'local_path' in media and os.path.exists(media['local_path']):
                                print(f"   📁 Using local file: {media['filename']}")
                                with open(media['local_path'], 'rb') as f:
                                    media_content = f.read()
                            else:
                                # Download from MUFON using authenticated CGI URL
                                filename = media['filename']
                                case_id = case_num  # Use extracted case number
                                
                                # Use working MUFON CGI URL format
                                cgi_url = f"https://mufoncms.com/cgi-bin/ffplay.pl?file=case_files/{filename}"
                                
                                print(f"   🌐 Downloading from MUFON: {filename}")
                                
                                # Load auth cookies from storage state
                                storage_state_path = Path("/home/mike/D/ufobeep/mufon_clicker/mufon_artifacts/storage_state.json")
                                cookies = {}
                                if storage_state_path.exists():
                                    with open(storage_state_path) as f:
                                        storage_data = json.load(f)
                                        for cookie in storage_data.get('cookies', []):
                                            cookies[cookie['name']] = cookie['value']
                                
                                # Download with auth cookies
                                headers = {
                                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
                                }
                                
                                media_response = requests.get(cgi_url, cookies=cookies, headers=headers, timeout=30)
                                if media_response.status_code == 200 and len(media_response.content) > 1000:
                                    media_content = media_response.content
                                    print(f"   ✅ Downloaded {filename} ({len(media_content)} bytes)")
                                else:
                                    print(f"   ❌ Failed to download {filename}: HTTP {media_response.status_code}")
                                    continue
                            
                            # Upload to UFOBeep if we have content
                            if media_content:
                                
                                # Upload to alert using existing media upload endpoint
                                files = {
                                    'files': (media['filename'], media_content)
                                }
                                data = {
                                    'source': 'mufon_import'
                                }
                                
                                upload_response = requests.post(
                                    f"{base_url}/alerts/{alert_id}/media", 
                                    files=files,
                                    data=data
                                )
                                
                                if upload_response.status_code == 200:
                                    print(f"   ✅ Uploaded {media['filename']}")
                                else:
                                    print(f"   ❌ Failed to upload {media['filename']}: {upload_response.text}")
                            else:
                                print(f"   ❌ Failed to download {media['filename']}: HTTP {media_response.status_code}")
                                    
                        except Exception as e:
                            print(f"   ❌ Media upload error for {media['filename']}: {e}")
                
                imported_count += 1
                
            else:
                print(f"❌ Failed to create alert: {response.status_code} - {response.text}")
                
            # Always print status for debugging
            print(f"   Response: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Failed to process case #{case.get('Case_Number', 'unknown')}: {e}")
    
    print(f"\n🎉 Successfully imported {imported_count} MUFON cases!")

if __name__ == "__main__":
    import_mufon_cases()