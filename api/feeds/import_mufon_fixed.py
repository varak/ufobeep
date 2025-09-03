#!/usr/bin/env python3
"""
Fixed MUFON import script with proper field mapping and media upload
"""
import json
import requests
import os
import sys
from pathlib import Path
from datetime import datetime
import time
import re
import httpx
from ufo_classifier import UFOClassifier

def download_media_files(media_files, download_dir="/tmp/mufon_media"):
    """Download media files from MUFON URLs and return list with local_path"""
    if not media_files:
        return []
    
    # Create download directory
    os.makedirs(download_dir, exist_ok=True)
    downloaded_files = []
    
    for media in media_files:
        try:
            url = media.get('url')
            filename = media.get('filename')
            
            if not url or not filename:
                continue
                
            print(f"   📥 Downloading: {filename}")
            
            # Download with httpx (handles redirects and HTTPS properly)
            with httpx.Client(follow_redirects=True, timeout=30) as client:
                response = client.get(url)
                response.raise_for_status()
                
                local_path = os.path.join(download_dir, filename)
                
                with open(local_path, 'wb') as f:
                    f.write(response.content)
                
                # Add local_path to media info
                downloaded_media = media.copy()
                downloaded_media['local_path'] = local_path
                downloaded_files.append(downloaded_media)
                
                print(f"   ✅ Downloaded: {filename} ({len(response.content)} bytes)")
                
        except Exception as e:
            print(f"   ❌ Download failed for {filename}: {e}")
            continue
    
    return downloaded_files

def extract_real_location_from_long_description(long_description):
    """Extract actual location from MUFON long description text"""
    if not long_description or len(long_description.strip()) < 10:
        return None
    
    # Look for common location patterns in MUFON descriptions
    patterns = [
        # "in [City], [State]" pattern (most reliable)
        r'\bin\s+([A-Za-z\s]+),\s*([A-Z]{2})\b',
        # "[City], [State]" at start of sentences  
        r'\b([A-Za-z]+),\s*([A-Z]{2})\b',
        # "near [City], [State]" pattern
        r'\bnear\s+([A-Za-z\s]+),\s*([A-Z]{2})\b',
        # "at [City], [State]" pattern
        r'\bat\s+([A-Za-z\s]+),\s*([A-Z]{2})\b',
        # "from [City]" pattern (like "driving from Martinsville")
        r'\bfrom\s+([A-Za-z\s]+?)(?:\s+when|\s+to|\s+and|,|$)',
        # "near [City]" pattern
        r'\bnear\s+([A-Za-z\s]+?)(?:\s+when|\s+and|\s+it|,|$)',
        # "[City] area" pattern
        r'\b([A-Za-z]+)\s+area\b',
        # "to [City]" pattern
        r'\bto\s+([A-Za-z\s]+?)(?:\s+when|\s+and|\s+it|,|$)',
        # "at [City]" pattern  
        r'\bat\s+([A-Za-z\s]+?)(?:\s+this|\s+morning|\s+I|,|$)',
        # State names alone (like "we were in Texas when")
        r'\bin\s+(Alabama|Alaska|Arizona|Arkansas|California|Colorado|Connecticut|Delaware|Florida|Georgia|Hawaii|Idaho|Illinois|Indiana|Iowa|Kansas|Kentucky|Louisiana|Maine|Maryland|Massachusetts|Michigan|Minnesota|Mississippi|Missouri|Montana|Nebraska|Nevada|New\s+Hampshire|New\s+Jersey|New\s+Mexico|New\s+York|North\s+Carolina|North\s+Dakota|Ohio|Oklahoma|Oregon|Pennsylvania|Rhode\s+Island|South\s+Carolina|South\s+Dakota|Tennessee|Texas|Utah|Vermont|Virginia|Washington|West\s+Virginia|Wisconsin|Wyoming)\b'
    ]
    
    for pattern in patterns:
        matches = re.findall(pattern, long_description, re.IGNORECASE)
        for match in matches:
            if isinstance(match, tuple) and len(match) == 2:
                city, state = match
                if len(city.strip()) > 2 and len(state) == 2:
                    return f"{city.strip().title()}, {state.upper()}"
            elif isinstance(match, str) and len(match.strip()) > 3:
                city = match.strip().title()
                # Filter out common false positives
                if city not in ['Work', 'Home', 'TV', 'That', 'It', 'Phone', 'Car', 'Sky', 'Light']:
                    return f"{city}, US"
    
    return None

def upload_media_to_alert(alert_id, media_files, base_url="http://localhost:8000"):
    """Upload media files to existing UFOBeep alert using multipart form upload"""
    uploaded_files = []
    
    for media in media_files:
        try:
            # Get local file path
            local_path = media.get('local_path')
            if not local_path:
                continue
                
            # Handle relative paths
            if not os.path.isabs(local_path):
                local_path = os.path.join('/home/ufobeep/ufobeep/mufon_clicker', local_path)
                
            if not os.path.exists(local_path):
                print(f"   ⚠️  Media file not found: {local_path}")
                continue
            
            filename = media.get('filename', os.path.basename(local_path))
            print(f"   📤 Uploading: {filename}")
            
            # Upload using correct format (files plural, like mobile app)
            with open(local_path, 'rb') as f:
                files = {
                    'files': (filename, f, media.get('type', 'application/octet-stream'))
                }
                
                # Upload to the correct endpoint
                response = requests.post(
                    f"{base_url}/alerts/{alert_id}/media", 
                    files=files, 
                    timeout=60
                )
                
                if response.status_code in [200, 201]:
                    result = response.json()
                    print(f"   ✅ Uploaded {filename}")
                    uploaded_files.append(result)
                else:
                    print(f"   ❌ Upload failed for {filename}: {response.status_code}")
                    if response.text:
                        print(f"       Error: {response.text[:200]}")
                
        except Exception as e:
            print(f"   ❌ Error uploading {media.get('filename', 'unknown')}: {e}")
    
    return uploaded_files

def import_mufon_cases_fixed(json_file_path):
    """Import MUFON cases with proper field mapping"""
    
    # Load MUFON extraction data
    if not os.path.exists(json_file_path):
        print(f"❌ MUFON data file not found: {json_file_path}")
        return
    
    with open(json_file_path) as f:
        mufon_data = json.load(f)
    
    cases = mufon_data.get('cases', [])
    total_cases = len(cases)
    search_date = mufon_data.get('search_date', '')
    
    print(f"📊 Processing {total_cases} MUFON cases from {search_date}")
    
    base_url = "http://localhost:8000"
    imported_count = 0
    classifier = UFOClassifier()  # Initialize UFO classifier
    
    for case in cases:
        try:
            # Extract real data using correct field names from our extraction
            case_number = case.get('case_number', '')
            if not case_number or case_number in ['', 'None', None]:
                print(f"   ⚠️  Skipping case with no case number")
                continue
                
            print(f"\n--- Processing MUFON Case #{case_number} ---")
            
            # Extract event details
            date_time = case.get('date_time', '')
            short_desc = case.get('short_description', '')
            long_desc = case.get('long_description', '') 
            location_field = case.get('location', '')
            media_files = case.get('media_files', [])
            
            # Parse the actual event date from short description (format: "2024-08-04\n11:57PM")
            event_date = ""
            event_time = ""
            if short_desc and '\n' in short_desc:
                parts = short_desc.split('\n')
                if len(parts) >= 2:
                    event_date = parts[0].strip()
                    event_time = parts[1].strip()
            
            # Extract real location from long description
            real_location = extract_real_location_from_long_description(long_desc)
            if not real_location:
                # Try fallback: analyze location field only if it contains clear geographic terms
                if location_field and len(location_field) > 10:
                    # Only try if location field contains obvious geographic indicators
                    if any(word in location_field.lower() for word in ['city', 'county', 'state', 'street', 'avenue', 'road', 'drive']):
                        real_location = extract_real_location_from_long_description(location_field)
            
            if not real_location:
                print(f"   ⚠️  No geographic location found for case {case_number} - will create without location")
            
            print(f"   📅 Event Date: {event_date} {event_time}")
            print(f"   📍 Location: {real_location}")
            print(f"   📄 Description: {long_desc[:100]}...")
            print(f"   📎 Media Files: {len(media_files)}")
            
            # Geocode the real location ONLY if we have a valid location
            lat, lon = None, None
            if real_location:
                try:
                    geocode_url = "https://nominatim.openstreetmap.org/search"
                    params = {
                        'q': real_location,
                        'format': 'json',
                        'limit': 1
                    }
                    headers = {'User-Agent': 'UFOBeep MUFON Import'}
                    
                    response = requests.get(geocode_url, params=params, headers=headers, timeout=10)
                    if response.status_code == 200:
                        data = response.json()
                        if data and len(data) > 0:
                            result = data[0]
                            geocoded_name = result.get('display_name', real_location)
                            
                            # REJECT fake Georgia data - never allow it
                            if 'savannah' in geocoded_name.lower() or 'carmelite' in geocoded_name.lower():
                                print(f"   🚫 REJECTED fake Georgia geocoding: {geocoded_name}")
                                lat, lon = None, None
                            else:
                                lat = float(result['lat'])
                                lon = float(result['lon'])
                                print(f"   🌍 Geocoded: {geocoded_name}")
                        else:
                            print(f"   ⚠️  No geocoding results for: {real_location}")
                            
                    time.sleep(1)  # Rate limiting
                            
                except Exception as e:
                    print(f"   ❌ Geocoding error: {e}")
            else:
                print(f"   ⏭️  Skipping geocoding - no location to process")
                
            # Classify UFO type for enrichment (before building description)
            # Use long description as main content, short description as title for analysis
            classification = classifier.classify(long_desc, short_desc)
            ufo_type = classification['type'].title()
            print(f"   🔍 UFO Classification: {ufo_type} (confidence: {classification['confidence']:.2f})")
                
            # Build description first (needed for alert_data)
            # Use location field as the main description for alert card (clean, descriptive text)
            if location_field and len(location_field.strip()) > 10:
                card_description = location_field.strip()
            else:
                card_description = f"MUFON UFO sighting report from case #{case_number}"
            
            # Clean long description - remove "Long Description of Sighting Report" prefix
            clean_long_desc = long_desc
            if clean_long_desc and clean_long_desc.startswith("Long Description of Sighting Report"):
                clean_long_desc = clean_long_desc.replace("Long Description of Sighting Report", "").strip()
                if clean_long_desc.startswith("\n"):
                    clean_long_desc = clean_long_desc[1:].strip()
            
            # Build description: simple text for card, detailed for full page
            if clean_long_desc and len(clean_long_desc.strip()) > 20:
                # Use cleaned long description for detail page
                description = clean_long_desc.strip()
            else:
                # Fallback to card description
                description = card_description
                
            # Add MUFON metadata (will only show on detail page)
            # Use \n for line breaks that won't show on alert cards but will format properly on detail pages
            description += f"""

🛸 MUFON Case Details:
📅 Event Date: {event_date} {event_time}
📤 Submitted: {date_time}
📍 Location: {real_location or 'Not specified'}
🔢 Case Reference: #{case_number}
👽 UFO Type: {ufo_type} (confidence: {classification['confidence']:.1f})

This is a MUFON case report. Additional witness details may be available in the original MUFON database."""

            # Create enriched title based on UFO classification
            if ufo_type == "Unknown":
                title = f"MUFON UFO Report"
            else:
                title = f"MUFON {ufo_type} UFO Report"
            
            # Create enrichment data with UFO classification for map icons
            enrichment_data = {
                "ufo_classification": {
                    "type": classification['type'],
                    "confidence": classification['confidence'],
                    "keywords": classification.get('keywords', []),
                    "characteristics": classification.get('characteristics', [])
                },
                "data_source": "MUFON CMS",
                "mufon_case": {
                    "case_number": case_number,
                    "event_date": f"{event_date} {event_time}",
                    "submission_date": date_time,
                    "location_extracted": real_location
                }
            }
            
            # Create alert data - location is optional for MUFON cases
            alert_data = {
                "device_id": f"mufon_case_{case_number}",
                "title": title,
                "description": description,
                "username": "MUFON_Database", 
                "source": "mufon",  # This prevents notifications/beeps
                "case_reference": case_number,  # Add MUFON case reference
                # UI Widget Controls - hide for MUFON
                "witness_count": None,  # No witness count for MUFON 
                "can_confirm_witness": False,  # Disable witness confirmation 
                "hide_witness_section": True,  # Hide entire witness section
                "hide_witness_widget": True,  # Hide witness widget
                "hide_location_widget": True,  # Hide location widget  
                "hide_time_modal": True,  # Disable time modal
                "disable_time_pin": True,  # Disable time pin feature
                "hide_map_widget": True,  # Hide map widget
                "hide_map_section": True,  # Hide entire map section
                "show_map": False,  # Don't show map
                "show_witness_count": False,  # Don't show witness count
                "show_location_pin": False,  # Don't show location pin
                # Comments
                "comment_count": 0,  # Explicitly set to 0
                "comments_enabled": False,  # Disable comments for MUFON
                # Enrichment data
                "enrichment_data": enrichment_data  # Add classification for map icons
            }
            
            # Add location - use coordinates if available, otherwise use default generic location
            if lat and lon:
                alert_data["location"] = {
                    "latitude": lat,
                    "longitude": lon,
                    "accuracy": 100.0
                }
                print(f"   📍 Using location: {real_location} ({lat:.4f}, {lon:.4f})")
            else:
                # Don't add any location data when none is found - leave it completely blank
                print(f"   📍 No location data - creating alert without location")
            
            print(f"   📤 Creating alert...")
            
            # Create the alert
            headers = {'Content-Type': 'application/json'}
            response = requests.post(f"{base_url}/alerts", json=alert_data, headers=headers, timeout=30)
            
            if response.status_code in [200, 201]:
                result = response.json()
                alert_id = result.get('id') or result.get('sighting_id') or result.get('data', {}).get('alert_id')
                print(f"   ✅ Created alert: {alert_id}")
                
                # Download and upload media files if any exist
                if media_files and alert_id:
                    print(f"   📎 Processing {len(media_files)} media files...")
                    
                    # Download media files from MUFON URLs
                    downloaded_media = download_media_files(media_files)
                    
                    if downloaded_media:
                        print(f"   📤 Uploading {len(downloaded_media)} downloaded files...")
                        uploaded = upload_media_to_alert(alert_id, downloaded_media, base_url)
                        if uploaded:
                            print(f"   ✅ Successfully uploaded {len(uploaded)} media files")
                        else:
                            print(f"   ⚠️  Media upload failed")
                    else:
                        print(f"   ⚠️  No media files could be downloaded")
                
                imported_count += 1
                
            else:
                print(f"   ❌ Failed to create alert: {response.status_code}")
                if response.text:
                    print(f"       Error: {response.text[:200]}")
                
        except Exception as e:
            print(f"   ❌ Error processing case {case.get('case_number', 'unknown')}: {e}")
        
        # Small delay between cases
        time.sleep(0.5)
    
    print(f"\n🎉 Import completed: {imported_count}/{total_cases} cases imported")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python import_mufon_fixed.py <mufon_data.json>")
        print("Example: python import_mufon_fixed.py mufon_working_2024_09_05.json")
        sys.exit(1)
    
    json_file = sys.argv[1]
    import_mufon_cases_fixed(json_file)