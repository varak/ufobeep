#!/usr/bin/env python3
"""
Direct MUFON import using the working classifier and import system
Combines extraction + classification + import in one script
"""

import sys
import os
import json
import requests
import time
import re
from pathlib import Path
from datetime import datetime
from playwright.sync_api import sync_playwright

# Add the API feeds directory to path so we can import the classifier
sys.path.append('/home/mike/D/ufobeep/api/feeds')
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
        r'in ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*), ([A-Z]{2})',  # City, ST
        r'from ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*), ([A-Z]{2})',  # from City, ST
        r'near ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*), ([A-Z]{2})',  # near City, ST
        r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*), ([A-Z]{2})(?:\s|\.)',  # City, ST
        r'([A-Z][a-z]+ [A-Z][a-z]+), ([A-Z]{2})',  # Two word city, ST
        r'past ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',  # past Oklahoma City
        r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*) area',  # City area
    ]
    
    for pattern in location_patterns:
        matches = re.findall(pattern, long_description)
        if matches:
            if len(matches[0]) == 2:  # City, State format
                city, state = matches[0]
                return f"{city}, {state}, US"
            else:  # Single location
                return f"{matches[0]}, US"
    
    return None

def geocode_location(location_string):
    """Geocode location using Nominatim (OpenStreetMap) API"""
    if not location_string or location_string == "0":
        return 39.8283, -98.5795, "Unknown Location, US"  # US center
    
    try:
        url = "https://nominatim.openstreetmap.org/search"
        params = {
            'q': location_string,
            'format': 'json',
            'limit': 1,
            'countrycodes': 'us'
        }
        
        headers = {'User-Agent': 'UFOBeep MUFON Import Script'}
        response = requests.get(url, params=params, headers=headers, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            if data:
                result = data[0]
                return float(result['lat']), float(result['lon']), result['display_name']
        
        print(f"   Geocoding failed for: {location_string}, using US center")
        return 39.8283, -98.5795, location_string
        
    except Exception as e:
        print(f"   Geocoding error for {location_string}: {e}")
        return 39.8283, -98.5795, location_string

def direct_import_with_classifier(date_str):
    """Direct import using the working classifier approach"""
    
    try:
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        month, day, year = date_obj.month, date_obj.day, date_obj.year
        search_year = year  # Use for historical classification
        print(f"📅 Processing MUFON cases for {date_str}")
    except ValueError:
        print("❌ Invalid date format. Use YYYY-MM-DD")
        return

    base_url = "https://api.ufobeep.com"
    classifier = UFOClassifier()
    imported_count = 0

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=200)
        context = browser.new_context(storage_state="mufon_artifacts/storage_state.json")
        page = context.new_page()

        # Navigate to search and fill form (same as before)
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(3)

        print("📝 Filling search form...")
        
        # Set FROM date
        page.mouse.click(360, 405)
        for _ in range(month):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        
        page.mouse.click(414, 405)
        for _ in range(day):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        
        page.mouse.click(478, 405)
        target_year_index = year - 1947
        for _ in range(target_year_index):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")

        # Set TO date (same)
        page.mouse.click(360, 424)
        for _ in range(month):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        
        page.mouse.click(414, 424)
        for _ in range(day):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        
        page.mouse.click(478, 424)
        for _ in range(target_year_index):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")

        # Submit search
        print("🚀 Submitting search...")
        page.mouse.click(633, 341)
        time.sleep(10)

        # Process results one by one
        iframe = page.frame_locator("iframe")
        rows = iframe.locator("table tbody tr").all()
        
        print(f"📊 Found {len(rows)} cases - processing each with full classifier...")
        
        for i, row in enumerate(rows, 1):
            try:
                print(f"\n=== Case {i}/{len(rows)} ===")
                
                # Extract basic data
                cells = row.locator("td").all()
                if len(cells) < 4:
                    continue
                
                case_number = cells[0].inner_text().strip()
                date_time = cells[1].inner_text().strip()
                short_description = cells[2].inner_text().strip()
                location = cells[3].inner_text().strip()
                
                print(f"📋 Case #{case_number}: {short_description[:50]}...")
                
                # Get long description
                long_description = short_description
                real_case_id = case_number
                
                view_button = row.locator("input[value='VIEW']").first
                if view_button.count() > 0:
                    print("🔍 Getting long description...")
                    view_button.click()
                    time.sleep(3)
                    
                    if len(page.context.pages) > 1:
                        popup = page.context.pages[-1]
                        popup.wait_for_load_state()
                        
                        popup_url = popup.url
                        if "id=" in popup_url:
                            real_case_id = popup_url.split("id=")[1].split("&")[0]
                        
                        detail_content = popup.locator("body").inner_text()
                        popup.close()
                        
                        # Extract meaningful long description
                        lines = [line.strip() for line in detail_content.split('\n') if len(line.strip()) > 30]
                        for line in lines:
                            if any(word in line.lower() for word in ['observed', 'saw', 'witnessed', 'light', 'object']):
                                long_description = line
                                break
                        
                        if not long_description or long_description == short_description:
                            if lines:
                                long_description = max(lines, key=len, default=short_description)

                print(f"📖 Long description: {len(long_description)} chars")

                # Extract and download media
                media_content_list = []
                if len(cells) > 4:
                    attachments_cell = cells[-1]
                    attachment_text = attachments_cell.inner_text().strip()
                    
                    if attachment_text:
                        print(f"📎 Processing attachments...")
                        for line in attachment_text.split('\n'):
                            line = line.strip()
                            if line and ('.jpg' in line.lower() or '.png' in line.lower() or 
                                        '.mp4' in line.lower() or '.mov' in line.lower()):
                                
                                media_url = f"https://mufoncms.com/case_files/{line}"
                                try:
                                    print(f"   🌐 Downloading {line}...")
                                    response = page.request.get(media_url)
                                    if response.status == 200:
                                        content = response.body()
                                        media_content_list.append((line, content))
                                        print(f"   ✅ Downloaded {line} ({len(content)} bytes)")
                                    else:
                                        print(f"   ❌ Failed to download {line}: HTTP {response.status}")
                                except Exception as e:
                                    print(f"   ❌ Error downloading {line}: {e}")

                # Geocode location with smart extraction  
                real_location = extract_location_from_description(long_description, location)
                query_location = real_location if real_location else location
                lat, lon, display_name = geocode_location(query_location)
                time.sleep(1)

                # Get reverse geocoding for enrichment
                try:
                    geocode_url = f"https://nominatim.openstreetmap.org/reverse"
                    params = {'lat': lat, 'lon': lon, 'format': 'json', 'addressdetails': 1}
                    headers = {'User-Agent': 'UFOBeep MUFON Import Script'}
                    
                    response = requests.get(geocode_url, params=params, headers=headers, timeout=5)
                    if response.status_code == 200:
                        geocoding_data = response.json()
                        formatted_address = geocoding_data.get('display_name', location)
                        print(f"   📍 Reverse geocoded: {formatted_address}")
                    else:
                        formatted_address = location
                        geocoding_data = {}
                        
                    time.sleep(1)
                except Exception as e:
                    print(f"   Reverse geocoding failed: {e}")
                    formatted_address = location
                    geocoding_data = {}

                # Build full description with MUFON metadata
                if long_description and len(long_description.strip()) > 10:
                    full_description = f"<p>{long_description.replace(chr(10), '</p><p>')}</p>"
                else:
                    full_description = f"<p>{short_description}</p>"

                # Classify UFO type using the working classifier
                classification = classifier.classify(full_description, short_description)
                print(f"🔬 Classified as: {classification['type']} (confidence: {classification['confidence']:.1f})")

                # Determine if historical
                try:
                    event_year = search_year
                    if '-' in short_description:
                        year_match = re.search(r'(\d{4})-\d{2}-\d{2}', short_description)
                        if year_match:
                            event_year = int(year_match.group(1))
                    
                    is_historical = (search_year - event_year) >= 1
                except:
                    is_historical = True

                # Create title with proper format
                ufo_type = classification['type'].title()
                if is_historical:
                    title = f"Historical {ufo_type} UFO Sighting" if ufo_type != "Unknown" else "Historical UFO Sighting"
                else:
                    title = f"{ufo_type} UFO Sighting" if ufo_type != "Unknown" else "UFO Sighting"

                # Add MUFON metadata to description
                full_description += f"""
<div style="margin-top: 20px; padding: 15px; background-color: #1a1a1a; border: 1px solid #333; border-radius: 8px;">
<h3 style="color: #39FF14; margin: 0 0 10px 0; font-size: 16px;">🛸 MUFON CASE DETAILS</h3>
<div style="color: #ccc; line-height: 1.6;">
<p><strong>Event Date:</strong> {date_time}</p>
<p><strong>Location:</strong> {location}</p>
<p><strong>Case Reference:</strong> #{real_case_id}</p>
<p><strong>UFO Type:</strong> {classification['type']} (confidence: {classification['confidence']:.1f})</p>
</div>
</div>"""

                # Create alert using exact same format as working system
                alert_data = {
                    "device_id": "mufon_direct_importer",
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
                    "source_id": real_case_id,
                    "external_id": f"mufon_{real_case_id}",
                    "enrichment_data": {
                        "ufo_classification": classification,
                        "data_source": "MUFON CMS", 
                        "historical_case": is_historical,
                        "event_date": date_time,
                        "submission_date": date_str,
                        "geocoding": {
                            "latitude": lat,
                            "longitude": lon,
                            "location_name": formatted_address,
                            "formatted_address": formatted_address,
                            "provider": "OpenStreetMap/Nominatim",
                            "raw_data": geocoding_data
                        }
                    }
                }

                print(f"📤 Creating alert: {title}")

                # Create alert
                headers = {
                    'Content-Type': 'application/json',
                    'X-Import-Source': 'mufon'
                }
                response = requests.post(f"{base_url}/alerts", json=alert_data, headers=headers)

                if response.status_code in [200, 201]:
                    alert = response.json()
                    alert_id = alert.get('sighting_id') or alert.get('id') or alert.get('data', {}).get('alert_id')
                    print(f"✅ Created alert {alert_id}")

                    # Upload media if we have it
                    if media_content_list:
                        print(f"📎 Uploading {len(media_content_list)} media files...")
                        
                        for filename, content in media_content_list:
                            try:
                                files = {'files': (filename, content)}
                                data = {'source': 'mufon_direct_import'}
                                
                                upload_response = requests.post(
                                    f"{base_url}/alerts/{alert_id}/media", 
                                    files=files,
                                    data=data
                                )
                                
                                if upload_response.status_code == 200:
                                    print(f"   ✅ Uploaded {filename}")
                                else:
                                    print(f"   ❌ Failed to upload {filename}: {upload_response.text}")
                                    
                            except Exception as e:
                                print(f"   ❌ Error uploading {filename}: {e}")

                    imported_count += 1
                    print(f"🎉 Case #{real_case_id} fully imported with classification!")
                    
                else:
                    print(f"❌ Failed to create alert: {response.status_code} - {response.text}")

                # Brief pause between cases
                time.sleep(2)

            except Exception as e:
                print(f"❌ Error processing case {i}: {e}")
                continue

        print(f"\n🏁 Direct import complete! Successfully imported {imported_count}/{len(rows)} MUFON cases")
        browser.close()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python direct_with_classifier.py YYYY-MM-DD")
        print("Example: python direct_with_classifier.py 2025-02-04")
        sys.exit(1)
    
    date_arg = sys.argv[1]
    direct_import_with_classifier(date_arg)