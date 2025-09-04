#!/bin/bash
# MUFON Complete Pipeline - Self-contained script
# Usage: ./mufon.sh 2025-01-27
# Usage: ./mufon.sh yesterday 
# Usage: ./mufon.sh today

set -e

if [ $# -eq 0 ]; then
    echo "Usage: ./mufon.sh <date>"
    echo "Examples:"
    echo "  ./mufon.sh 2025-01-27"
    echo "  ./mufon.sh yesterday"
    echo "  ./mufon.sh today"
    exit 1
fi

DATE_INPUT="$1"

# Handle relative dates
if [ "$DATE_INPUT" = "yesterday" ]; then
    DATE=$(date -d "yesterday" +%Y-%m-%d)
elif [ "$DATE_INPUT" = "today" ]; then
    DATE=$(date +%Y-%m-%d)
else
    DATE="$DATE_INPUT"
fi

echo "🚀 MUFON Pipeline Starting for $DATE"
echo "===================================="

# Change to working directory
# cd /home/ufobeep/ufobeep

# Load environment credentials
echo "✅ Loading MUFON credentials..."
if [ -f /home/ufobeep/.secrets/.env.mufon ]; then
    source /home/ufobeep/.secrets/.env.mufon
elif [ -f .env.mufon ]; then
    source .env.mufon
else
    echo "❌ .env.mufon not found"
fi

if [ -z "$MUFON_USERNAME" ] || [ -z "$MUFON_PASSWORD" ]; then
    echo "❌ MUFON credentials not found in .env.mufon"
    exit 1
fi

# Export credentials for embedded Python script
export MUFON_USERNAME
export MUFON_PASSWORD

# Execute embedded Python script
echo "🔍 Running MUFON extraction and import..."
python3 - "$DATE" << 'EOF'
#!/usr/bin/env python3
import sys
import os
import time
import json
import requests
from datetime import datetime
from playwright.sync_api import sync_playwright
import httpx
import re
from typing import Optional, List, Dict

def log(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

class UFOClassifier:
    """Classifies UFOs based on description text with extended pattern matching"""
    
    def __init__(self):
        # UFO type patterns based on user's requested classifications
        self.classification_patterns = {
            "triangle": [
                r"triangl\w+", r"three.*light", r"delta.*shape", r"arrow.*shape",
                r"three.*corner", r"v.*shaped?", r"chevron"
            ],
            "disc": [
                r"disc\w*", r"saucer", r"round.*craft", r"circular.*object",
                r"disk\w*", r"plate.*shaped?"
            ],
            "sphere": [
                r"sphere\w*", r"ball.*shaped?", r"orb\w*", r"round.*ball",
                r"spherical", r"globe.*shaped?"
            ],
            "cigar": [
                r"cigar\w*", r"cylinder\w*", r"tube.*shaped?", r"elongated.*object",
                r"capsule.*shaped?", r"oblong.*craft"
            ],
            "light": [
                r"bright.*light", r"single.*light", r"white.*light", r"glowing.*light",
                r"beam.*light", r"flash\w*.*light", r"fireball", r"flash"
            ],
            "boomerang": [
                r"boomerang", r"v.*wing", r"crescent", r"banana.*shaped?"
            ],
            "diamond": [
                r"diamond.*shaped?", r"rhomb\w+", r"kite.*shaped?"
            ],
            "rectangle": [
                r"rectangl\w+", r"square.*craft", r"box.*shaped?", r"cubic",
                r"rectangular.*object", r"square.*rectangle"
            ],
            "oval": [
                r"oval\w*", r"egg.*shaped?", r"elliptical", r"oblong"
            ],
            "cone": [
                r"cone.*shaped?", r"conical", r"funnel.*shaped?"
            ],
            "cross": [
                r"cross.*shaped?", r"cruciform", r"plus.*shaped?"
            ],
            "cylinder": [
                r"cylinder\w*", r"cylindrical", r"barrel.*shaped?"
            ],
            "dumbbell": [
                r"dumbbell", r"dumbell", r"barbell", r"hourglass"
            ],
            "teardrop": [
                r"tear.*drop", r"teardrop", r"droplet.*shaped?"
            ],
            "tic-tac": [
                r"tic.*tac", r"pill.*shaped?", r"capsule"
            ],
            "bullet": [
                r"bullet.*missile", r"bullet.*shaped?", r"missile.*shaped?"
            ],
            "saturn": [
                r"saturn.*like", r"ringed.*object", r"hat.*shaped?"
            ],
            "starlike": [
                r"star.*like", r"stellar", r"point.*light"
            ],
            "blimp": [
                r"blimp", r"airship", r"dirigible"
            ]
        }
    
    def classify(self, description: str, title: str = "") -> Dict[str, any]:
        """Classify UFO based on description and title"""
        if not description and not title:
            return {"type": "unknown", "confidence": 0.0, "keywords": []}
        
        # Combine title and description for analysis
        text = f"{title} {description}".lower()
        
        # Score each classification type
        type_scores = {}
        matched_keywords = {}
        
        for ufo_type, patterns in self.classification_patterns.items():
            score = 0
            keywords = []
            
            for pattern in patterns:
                matches = re.findall(pattern, text, re.IGNORECASE)
                if matches:
                    score += len(matches) * 2
                    keywords.extend(matches)
            
            if score > 0:
                type_scores[ufo_type] = score
                matched_keywords[ufo_type] = keywords
        
        # If no strong classification, try fallback analysis
        if not type_scores:
            return self._fallback_classification(text)
        
        # Find best classification
        best_type = max(type_scores.keys(), key=lambda k: type_scores[k])
        max_score = type_scores[best_type]
        
        # Calculate confidence (0.0 to 1.0)
        confidence = min(max_score / 10.0, 1.0)
        
        return {
            "type": best_type,
            "confidence": confidence,
            "keywords": matched_keywords.get(best_type, []),
            "all_scores": type_scores
        }
    
    def _fallback_classification(self, text: str) -> Dict[str, any]:
        """Fallback classification for unclear descriptions"""
        if any(word in text for word in ["round", "circular", "ball"]):
            return {"type": "sphere", "confidence": 0.3, "keywords": ["round"]}
        
        if any(word in text for word in ["light", "glow", "bright"]):
            return {"type": "light", "confidence": 0.4, "keywords": ["light"]}
        
        return {"type": "unknown", "confidence": 0.0, "keywords": []}

def reverse_geocode(location_text: str) -> Optional[Dict[str, any]]:
    """Extract location from text and get coordinates using Nominatim"""
    if not location_text or len(location_text.strip()) < 3:
        return None
    
    text = location_text.strip()
    
    # Clean up MUFON location format like "Schenectady, NY, US" 
    cleaned_location = re.sub(r',?\s*(US|USA)$', '', text, flags=re.IGNORECASE).strip()
    
    # If it already looks like "City, ST", use it directly
    if re.match(r'^[A-Za-z\s]+,\s*[A-Z]{2}$', cleaned_location):
        search_location = cleaned_location
    else:
        # Extract location patterns from descriptions
        location_patterns = [
            r"in\s+([A-Za-z\s]+),\s*([A-Z]{2})\b",  # "in City, ST"
            r"near\s+([A-Za-z\s]+),\s*([A-Z]{2})\b",  # "near City, ST"
            r"from\s+([A-Za-z\s]+),\s*([A-Z]{2})\b",  # "from City, ST"
            r"([A-Za-z\s]+),\s*([A-Z]{2})\b",          # "City, ST"
        ]
        
        search_location = None
        for pattern in location_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                city = match.group(1).strip()
                state = match.group(2).strip()
                if len(city) > 2 and len(state) == 2:
                    search_location = f"{city}, {state}"
                    break
        
        # If no structured location found, don't geocode
        if not search_location:
            return None
    
    try:
        # Use Nominatim for geocoding
        import time
        time.sleep(1.2)  # Rate limit
        
        url = "https://nominatim.openstreetmap.org/search"
        params = {
            "q": search_location,
            "format": "json",
            "limit": 1,
            "countrycodes": "us"
        }
        
        headers = {"User-Agent": "UFOBeep-MUFON/1.0 (+https://ufobeep.com)"}
        
        response = requests.get(url, params=params, headers=headers, timeout=15)
        if response.status_code == 200:
            data = response.json()
            if data:
                result = data[0]
                lat = float(result["lat"])
                lon = float(result["lon"])
                
                # Validate coordinates are in US bounds
                if -180 <= lon <= -60 and 20 <= lat <= 70:
                    return {
                        "location": search_location,
                        "latitude": lat,
                        "longitude": lon,
                        "display_name": result.get("display_name", search_location)
                    }
                else:
                    log(f"⚠️ Invalid coordinates for '{search_location}': {lat}, {lon}")
        else:
            log(f"⚠️ Geocoding API error {response.status_code} for '{search_location}'")
    except Exception as e:
        log(f"⚠️ Geocoding failed for '{search_location}': {e}")
    
    return None

def extract_and_import_mufon(date_str):
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    month, day, year = date_obj.month, date_obj.day, date_obj.year
    
    log(f"🎯 Processing MUFON cases for {date_str}")
    
    # Initialize classifier
    classifier = UFOClassifier()
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        
        # Check for existing cookies
        cookies_file = "/tmp/mufon_cookies.json"
        if os.path.exists(cookies_file):
            log("🍪 Loading existing authentication cookies...")
            context = browser.new_context(storage_state=cookies_file)
        else:
            log("🔐 No stored cookies, will authenticate fresh...")
            context = browser.new_context()
        
        page = context.new_page()
        
        try:
            # AUTHENTICATE OR TEST EXISTING COOKIES
            log("🔐 Testing MUFON authentication...")
            page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
            page.wait_for_load_state('networkidle')
            time.sleep(2)
            
            # Check if we got redirected to login (cookies expired)
            current_url = page.url
            if "signIn" in current_url or "login" in current_url:
                log("🔐 Cookies expired, performing fresh login...")
                
                mufon_user = os.getenv('MUFON_USERNAME')
                mufon_pass = os.getenv('MUFON_PASSWORD')
                
                if not mufon_user or not mufon_pass:
                    log("❌ MUFON credentials not found")
                    return False
                
                log("📝 Filling login form...")
                page.fill("input[name='loginName']", mufon_user)
                page.fill("input[name='loginPassword']", mufon_pass)
                page.press("input[name='loginPassword']", "Enter")
                page.wait_for_load_state('networkidle')
                time.sleep(2)
                
                # Verify authentication worked
                current_url = page.url
                if "signIn" in current_url or "login" in current_url:
                    log("❌ AUTHENTICATION FAILED")
                    return False
                
                # Save cookies for reuse
                log("💾 Saving authentication cookies...")
                context.storage_state(path=cookies_file)
                
                # Go to search page after login
                log("🔍 Navigating to search page after login...")
                page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
                time.sleep(3)
            
            log("✅ Authentication successful - ready to search")
            
            # Get iframe and set date fields
            iframe = page.frame_locator("iframe")
            
            log(f"📅 Setting date fields for {month}/{day}/{year}...")
            # Event Date FROM
            iframe.locator("select[name='event_date_lo__month']").select_option(str(month))
            time.sleep(0.2)
            iframe.locator("select[name='event_date_lo__day']").select_option(str(day))
            time.sleep(0.2)
            iframe.locator("select[name='event_date_lo__year']").select_option(str(year))
            time.sleep(0.2)
            
            # Event Date TO (same as FROM for single day)
            iframe.locator("select[name='event_date_hi__month']").select_option(str(month))
            time.sleep(0.2)
            iframe.locator("select[name='event_date_hi__day']").select_option(str(day))
            time.sleep(0.2)
            iframe.locator("select[name='event_date_hi__year']").select_option(str(year))
            time.sleep(0.5)
            
            # Submit search
            log("🚀 Submitting search...")
            iframe.locator("input[type='submit'][value='SUBMIT']").first.click()
            log("⏳ Waiting for search results...")
            time.sleep(10)
            
            # Get results
            rows = iframe.locator("table tbody tr").all()
            log(f"📊 Found {len(rows)} result rows")
            
            # Process each case
            imported_count = 0
            
            for i, row in enumerate(rows, 1):
                try:
                    cells = row.locator("td").all()
                    if len(cells) >= 4:
                        # MUFON table structure: Row#, Date Submitted, Date/Time of Event, Short Description, Location, Long Description, Attachments
                        row_number = cells[0].inner_text().strip()
                        report_date = cells[1].inner_text().strip()
                        sighting_datetime = cells[2].inner_text().strip()
                        short_description = cells[3].inner_text().strip()
                        location = cells[4].inner_text().strip() if len(cells) > 4 else "Unknown Location"
                        
                        log(f"🔍 RAW PARSE - Row: '{row_number}', ReportDate: '{report_date}', SightingDT: '{sighting_datetime[:30]}', Desc: '{short_description[:30]}', Loc: '{location[:20]}'")
                        
                        # Skip header rows and invalid cases
                        if not row_number or row_number in ["", "#", "Case"] or not row_number.isdigit():
                            continue
                        
                        log(f"🔍 Processing Row #{row_number}")
                        
                        # DEBUG: Show ALL elements in this row
                        all_elements = row.locator("*").all()
                        log(f"🔍 ROW ELEMENTS DEBUG: Found {len(all_elements)} total elements")
                        
                        inputs = row.locator("input").all()
                        buttons = row.locator("button").all() 
                        links = row.locator("a").all()
                        
                        log(f"🔍 ROW DEBUG: {len(inputs)} inputs, {len(buttons)} buttons, {len(links)} links")
                        
                        for i, inp in enumerate(inputs):
                            value = inp.get_attribute('value') or ''
                            type_attr = inp.get_attribute('type') or ''
                            onclick = inp.get_attribute('onclick') or ''
                            log(f"🔍 INPUT[{i}]: type='{type_attr}', value='{value}', onclick='{onclick}'")
                        
                        for i, btn in enumerate(buttons):
                            text = btn.inner_text().strip()
                            onclick = btn.get_attribute('onclick') or ''
                            log(f"🔍 BUTTON[{i}]: text='{text}', onclick='{onclick}'")
                        
                        for i, link in enumerate(links):
                            href = link.get_attribute('href') or ''
                            text = link.inner_text().strip()
                            log(f"🔍 LINK[{i}]: text='{text}', href='{href}'")
                        
                        # Get real case ID from VIEW button (single source of truth)
                        real_case_id = None
                        
                        # Extract case ID from VIEW button onclick attribute
                        for inp in inputs:
                            onclick = inp.get_attribute('onclick') or ''
                            value = inp.get_attribute('value') or ''
                            if 'VIEW' in value and 'id=' in onclick:
                                match = re.search(r'id=(\d+)', onclick)
                                if match:
                                    real_case_id = match.group(1)
                                    log(f"✅ Extracted real case ID from VIEW link: {real_case_id}")
                                    break
                        
                        # Skip if no case ID found
                        if not real_case_id:
                            log(f"⚠️ No VIEW button with case ID found, skipping row")
                            continue
                        
                        # Extract media files
                        media_files = []
                        if len(cells) > 4:
                            attachments_cell = cells[-1]
                            attachment_links = attachments_cell.locator('a')
                            for j in range(attachment_links.count()):
                                link = attachment_links.nth(j)
                                filename = link.inner_text().strip()
                                href = link.get_attribute('href')
                                
                                if filename and any(ext in filename.lower() for ext in ['.jpg', '.png', '.mp4', '.mov', '.jpeg']):
                                    if href and not href.startswith('http'):
                                        href = f"https://mufoncms.com{href}"
                                    elif href and href.startswith('http://'):
                                        href = href.replace('http://', 'https://')
                                    
                                    file_type = "image" if any(ext in filename.lower() for ext in ['.jpg', '.jpeg', '.png']) else "video"
                                    media_files.append({
                                        "filename": filename,
                                        "url": href,
                                        "type": file_type
                                    })
                        
                        log(f"📎 Found {len(media_files)} media files")
                        
                        # Get long description from VIEW page
                        long_description = short_description
                        
                        # Look for VIEW button/input in the row (use the same input we found for case ID)
                        if real_case_id:
                            try:
                                log("📖 Clicking VIEW for long description...")
                                
                                # Find the VIEW button we already identified  
                                view_input = None
                                for inp in inputs:
                                    value = inp.get_attribute('value') or ''
                                    if 'VIEW' in value:
                                        view_input = inp
                                        break
                                
                                # Properly wait for popup and extract content
                                if view_input:
                                    try:
                                        with page.expect_popup() as popup_info:
                                            view_input.click()
                                        popup = popup_info.value
                                        popup.wait_for_load_state("domcontentloaded")
                                        
                                        # Long description is typically inside <pre>; fall back to body
                                        try:
                                            popup.wait_for_selector("pre", timeout=5000)
                                            popup_text = popup.locator("pre").inner_text()
                                        except:
                                            popup_text = popup.locator("body").inner_text()
                                        
                                        long_description = popup_text.strip()
                                        log(f"📝 Found long description from popup: {long_description[:80]}...")
                                        popup.close()
                                    except Exception as e:
                                        log(f"⚠️ Popup failed, trying same-page navigation: {e}")
                                        # Fallback: handle same-page nav 
                                        before_url = page.url
                                        view_input.click()
                                        page.wait_for_load_state("domcontentloaded")
                                        if page.url != before_url:
                                            try:
                                                page.wait_for_selector("pre", timeout=5000)
                                                long_description = page.locator("pre").inner_text().strip()
                                            except:
                                                long_description = page.locator("body").inner_text().strip()
                                            log(f"📝 Found long description from same-page: {long_description[:80]}...")
                                    
                            except Exception as e:
                                log(f"⚠️ Failed to get long description: {e}")
                        
                        # Classify UFO type
                        classification = classifier.classify(long_description, short_description)
                        log(f"🔍 UFO Classification: {classification['type']} (confidence: {classification['confidence']:.2f})")
                        
                        # Extract location and geocode
                        geo_data = None
                        try:
                            # First try the location field directly
                            if location and len(location.strip()) > 3:
                                geo_data = reverse_geocode(location)
                            
                            # If that fails, try extracting from description
                            if not geo_data and long_description:
                                geo_data = reverse_geocode(long_description)
                                
                            if geo_data:
                                log(f"📍 Geocoded: {geo_data['location']} -> {geo_data['latitude']}, {geo_data['longitude']}")
                        except Exception as e:
                            log(f"⚠️ Geocoding error: {e}")
                        
                        # CREATE ALERT in production
                        import uuid
                        alert_id = str(uuid.uuid4())
                        
                        log(f"📤 Creating alert for MUFON Case #{real_case_id}...")
                        
                        # Prepare alert data with correct API structure
                        alert_data = {
                            "device_id": f"mufon_import_{real_case_id}",
                            "title": classification['type'].title(),
                            "description": f"MUFON Case #{real_case_id}\\n\\n{long_description}",
                            "username": "MUFON",
                            "source": "mufon",
                            "external_id": f"mufon_{real_case_id}",
                            "external_url": f"https://mufon.com/case/{real_case_id}",
                            "has_media": len(media_files) > 0
                        }
                        
                        # Add location as nested object if we have geocoding data
                        if geo_data:
                            alert_data["location"] = {
                                "latitude": geo_data["latitude"],
                                "longitude": geo_data["longitude"]
                            }
                        
                        # Store all enrichment data (classification, geocoding, etc.) 
                        enrichment_data = {
                            "classification": classification,
                            "geocoding": geo_data,
                            "mufon_case_id": real_case_id,
                            "report_date": report_date,
                            "sighting_datetime": sighting_datetime,
                            "location_raw": location
                        }
                        
                        # Store enrichment data in the description for now 
                        # (will be properly stored in enrichment_data field by the service)
                        alert_data["enrichment"] = enrichment_data
                        
                        # Create the alert via API
                        try:
                            response = requests.post(
                                "http://localhost:8000/alerts", 
                                json=alert_data,
                                timeout=30
                            )
                            if response.status_code in [200, 201]:
                                log(f"✅ Created alert: {alert_id}")
                            else:
                                log(f"⚠️ Alert creation failed: {response.status_code} - {response.text}")
                        except Exception as e:
                            log(f"❌ Alert creation error: {e}")
                        
                        log(f"📤 ALERT DETAILS:")
                        log(f"   ID: {alert_id}")
                        log(f"   Title: MUFON Case #{real_case_id}")
                        log(f"   Report Date: {report_date}")
                        log(f"   Sighting Date/Time: {sighting_datetime}")
                        log(f"   Location: {location}")
                        log(f"   Short Description: {short_description}")
                        log(f"   Long Description: {long_description}")
                        log(f"   Source ID: mufon_{real_case_id}")
                        log(f"   External URL: https://mufon.com/case/{real_case_id}")
                        log(f"   Media Files: {len(media_files)}")
                        log(f"   UFO Type: {classification['type']} (confidence: {classification['confidence']:.2f})")
                        log(f"   Keywords: {', '.join(classification.get('keywords', []))}")
                        if geo_data:
                            log(f"   Coordinates: {geo_data['latitude']}, {geo_data['longitude']}")
                            log(f"   Geocoded Location: {geo_data['display_name']}")
                        else:
                            log(f"   Geocoding: Failed - no coordinates extracted")
                        
                        imported_count += 1
                        
                        # UPLOAD MEDIA
                        if media_files:
                            log(f"📤 Uploading {len(media_files)} media files...")
                            uploaded_count = 0
                            cookies = context.cookies()
                            
                            for media in media_files:
                                try:
                                    cookie_dict = {c['name']: c['value'] for c in cookies}
                                    with httpx.Client(cookies=cookie_dict, timeout=30.0) as client:
                                        media_response = client.get(media['url'])
                                        media_response.raise_for_status()
                                        
                                        files = {'file': (media['filename'], media_response.content, 'application/octet-stream')}
                                        upload_response = requests.post(f"http://localhost:8000/alerts/{alert_id}/media", files=files, timeout=120)
                                        
                                        if upload_response.status_code == 200:
                                            uploaded_count += 1
                                            log(f"✅ Uploaded: {media['filename']}")
                                        else:
                                            log(f"⚠️ Upload failed for {media['filename']}: {upload_response.status_code}")
                                            
                                except Exception as e:
                                    log(f"⚠️ Media upload failed for {media['filename']}: {e}")
                            
                            log(f"✅ Case #{real_case_id}: {uploaded_count}/{len(media_files)} media uploaded")
                        
                        log(f"🎯 Case #{real_case_id} complete")
                        
                except Exception as e:
                    log(f"⚠️ Error processing row {i}: {e}")
                    continue
            
            log(f"🎉 Processing completed: {imported_count} cases imported")
            return imported_count > 0
            
        finally:
            browser.close()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py DATE")
        sys.exit(1)
    
    success = extract_and_import_mufon(sys.argv[1])
    sys.exit(0 if success else 1)
EOF

SCRIPT_EXIT=$?
if [ $SCRIPT_EXIT -eq 0 ]; then
    echo "✅ MUFON import completed successfully!"
else
    echo "❌ MUFON import failed"
    exit 1
fi