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
    # Check location field first - it often contains the actual location
    if location_field:
        # Look for "City State" pattern in location field
        loc_match = re.search(r'\b([A-Za-z]+)\s+([A-Za-z]{4,})\b', location_field)
        if loc_match:
            word1, word2 = loc_match.groups()
            return f"{word1.title()}, {word2[:2].upper()}"
    
    if not long_description:
        return None
    
    # Look for "City State" pattern in description
    pattern = re.search(r'\b([A-Za-z]+)\s+([A-Za-z]{4,})\b', long_description)
    if pattern:
        word1, word2 = pattern.groups()
        return f"{word1.title()}, {word2[:2].upper()}"
    
    return None

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
    
    # Use local API directly
    base_url = "http://localhost:8000"
    print("Using local API at http://localhost:8000")
    imported_count = 0
    classifier = UFOClassifier()  # Initialize UFO classifier
    
    for case in cases:
        try:
            case_num = case.get('case_number') or case.get('Case_Number', '')
            print(f"\n--- Processing Case #{case_num} ---")
            
            # Parse the datetime event (e.g., "1997-02-24\n9:00PM")
            datetime_event = (case.get('date_time') or case.get('DateTime_Event', '')).replace('\n', ' ')
            
            # Get case reference from the actual case number
            case_reference = case.get('case_number', 'Unknown')
            
            # Structure descriptions properly:
            # - Short description for alert card display
            # - Long description with MUFON metadata for detail page
            short_desc = case.get('short_description') or case.get('Short_Description', '')
            long_desc = case.get('long_description') or case.get('Long_Description', '')
            
            # Extract location from description and geocode
            location = extract_location_from_description(long_desc, case.get('location', ''))
            
            print(f"   Original location field: '{case.get('location', '')}'")
            print(f"   Long description: '{(long_desc or '')[:100]}...'")
            print(f"   Extracted location: '{location}'")
            
            if not location:
                print(f"   Skipping case {case_num} - no location found")
                continue
                
            # Geocode the location
            lat, lon = None, None
            try:
                geocode_url = "https://nominatim.openstreetmap.org/search"
                params = {
                    'q': location,
                    'format': 'json',
                    'limit': 1
                }
                headers_geo = {'User-Agent': 'UFOBeep MUFON Import Script'}
                
                response = requests.get(geocode_url, params=params, headers=headers_geo, timeout=10)
                if response.status_code == 200:
                    data = response.json()
                    if data and len(data) > 0:
                        result = data[0]
                        lat = float(result['lat'])
                        lon = float(result['lon'])
                        location = result.get('display_name', location)
                        print(f"   📍 Geocoded: {location} ({lat:.4f}, {lon:.4f})")
                        
                time.sleep(1)  # Rate limiting
                        
            except Exception as e:
                print(f"   Geocoding error: {e}")
                
            if not lat or not lon:
                print(f"   Skipping case {case_num} - geocoding failed")
                continue
            
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
<p><strong>Case Reference:</strong> #{case_reference}</p>
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
            
            # Create title: "Historical Triangle UFO Sighting" or just "Triangle UFO Sighting" for recent
            if is_historical:
                if ufo_type == "Unknown":
                    title = f"Historical UFO Sighting"
                else:
                    title = f"Historical {ufo_type} UFO Sighting"
            else:
                if ufo_type == "Unknown":
                    title = f"UFO Sighting"
                else:
                    title = f"{ufo_type} UFO Sighting"
            
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
            response = requests.post(f"{base_url}/alerts", json=beep_data, headers=headers)
            
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