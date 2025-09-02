#!/usr/bin/env python3
"""
Import MUFON cases using existing UFOBeep alert creation system
"""
import json
import requests
import asyncio
from pathlib import Path
from datetime import datetime
import time
from ufo_classifier import UFOClassifier

def import_mufon_cases():
    """Import MUFON cases using existing alert endpoints"""
    
    # Load extracted MUFON data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON data file found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    print(f"📊 Processing {mufon_data['total_cases']} MUFON cases...")
    
    base_url = "http://localhost:8000"
    imported_count = 0
    classifier = UFOClassifier()  # Initialize UFO classifier
    
    for case in mufon_data['cases']:
        try:
            print(f"\n--- Processing Case #{case.get('Case_Number')} ---")
            
            # Parse location and geocode it
            location = case.get('Location', '')
            
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
            datetime_event = case.get('DateTime_Event', '').replace('\n', ' ')
            
            # Structure descriptions properly:
            # - Short description for alert card display
            # - Long description with MUFON metadata for detail page
            short_desc = case.get('Short_Description', '')
            long_desc = case.get('Long_Description', '')
            
            # Build full description for detail page with HTML formatting
            if long_desc and len(long_desc.strip()) > 50:
                # Use long description if available, convert newlines to paragraphs
                full_description = f"<p>{long_desc.replace(chr(10), '</p><p>')}</p>"
            else:
                # Expand short description with HTML
                full_description = f"<p>{short_desc}</p><p><em>Detailed witness account and analysis.</em></p>"
            
            # Classify UFO type for MUFON enrichment data
            classification = classifier.classify(
                full_description, 
                case.get('Short_Description', '')
            )
            
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
            
            # Determine if this is historical (more than 1 year old)
            try:
                event_year = int(datetime_event.split('-')[0]) if '-' in datetime_event else datetime.now().year
                is_historical = (datetime.now().year - event_year) > 1
            except:
                is_historical = True  # Default to historical if can't parse
            
            # Create a proper title based on UFO type and historical status  
            ufo_type = classification['type'].title()
            time_indicator = "Historical" if is_historical else "Recent"
            
            # Create title: "Triangle UFO Sighting (Historical MUFON)" or "Light Anomaly (Recent MUFON)"
            if ufo_type == "Unknown":
                title = f"UFO Sighting ({time_indicator} MUFON)"
            else:
                title = f"{ufo_type} UFO Sighting ({time_indicator} MUFON)"
            
            # Create alert using existing endpoint with all MUFON fields
            alert_data = {
                "device_id": f"mufon_importer",
                "username": "MUFON_Database",
                "category": "ufo_sighting", 
                "title": title,
                "description": full_description,
                "location": {
                    "latitude": lat,
                    "longitude": lon,
                    "name": location
                },
                "witness_count": 1,
                "alert_level": "medium",
                "source": "mufon",
                "source_id": case.get('Case_Number'),
                "external_id": f"mufon_{case.get('Case_Number')}",
                "enrichment_data": {
                    "ufo_classification": classification,
                    "data_source": "MUFON CMS",
                    "historical_case": True,
                    "event_date": datetime_event,
                    "submission_date": case.get('Date_Submitted', '')
                }
            }
            
            print(f"Creating alert: {alert_data['title']}")
            
            # Create the alert
            response = requests.post(f"{base_url}/alerts", json=alert_data)
            
            if response.status_code in [200, 201]:
                alert = response.json()
                # Handle both response formats
                alert_id = alert.get('sighting_id') or alert.get('id') or alert.get('data', {}).get('alert_id')
                print(f"✅ Created alert {alert_id}")
                
                # Download and upload media files if they exist
                media_files = case.get('Attachments_media', [])
                if media_files:
                    print(f"📎 Processing {len(media_files)} media files...")
                    
                    for media in media_files:
                        try:
                            # Download the media file
                            media_response = requests.get(media['url'], timeout=30)
                            if media_response.status_code == 200:
                                
                                # Upload to alert using existing media upload endpoint
                                files = {
                                    'files': (media['filename'], media_response.content)
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