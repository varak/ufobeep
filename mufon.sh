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

def log(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def extract_and_import_mufon(date_str):
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    month, day, year = date_obj.month, date_obj.day, date_obj.year
    
    log(f"🎯 Processing MUFON cases for {date_str}")
    
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
                        # MUFON table structure: Case#, Report Date, Sighting Date/Time, Description, Location, [Media]
                        raw_case = cells[0].inner_text().strip()
                        report_date = cells[1].inner_text().strip()
                        sighting_datetime = cells[2].inner_text().strip()
                        short_description = cells[3].inner_text().strip()
                        location = cells[4].inner_text().strip() if len(cells) > 4 else "Unknown Location"
                        
                        log(f"🔍 RAW PARSE - Case: '{raw_case}', ReportDate: '{report_date}', SightingDT: '{sighting_datetime[:30]}', Desc: '{short_description[:30]}', Loc: '{location[:20]}'")
                        
                        # Skip header rows and invalid cases
                        if not raw_case or raw_case in ["", "#", "Case"]:
                            continue
                            
                        # Use display number temporarily, will get real case ID from URL
                        numeric_case = raw_case.replace("#", "").strip()
                        if not numeric_case.isdigit():
                            log(f"⚠️ Skipping non-numeric case: {raw_case}")
                            continue
                        
                        log(f"🔍 Processing Case #{numeric_case}")
                        
                        # Get real case ID from VIEW links
                        real_case_id = numeric_case
                        view_links = row.locator("a").all()
                        for link in view_links:
                            href = link.get_attribute('href') or ''
                            if "neonPage.jsp" in href:
                                case_match = re.search(r'caseId[=:](\d+)', href)
                                if case_match:
                                    real_case_id = case_match.group(1)
                                    log(f"✅ Extracted real case ID: {real_case_id}")
                                break
                        
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
                                    
                                    file_type = "image" if any(ext in filename.lower() for ext in ['.jpg', '.jpeg', '.png']) else "video"
                                    media_files.append({
                                        "filename": filename,
                                        "url": href,
                                        "type": file_type
                                    })
                        
                        log(f"📎 Found {len(media_files)} media files")
                        
                        # Get long description by clicking VIEW
                        long_description = short_description
                        for link in view_links:
                            href = link.get_attribute('href') or ''
                            if "neonPage.jsp" in href:
                                try:
                                    log("📖 Getting long description...")
                                    page.goto(f"https://mufon.z2systems.com/np/clients/mufon/{href}")
                                    time.sleep(3)
                                    
                                    # Extract description
                                    desc_elements = page.locator("td").all()
                                    for elem in desc_elements:
                                        text = elem.inner_text()
                                        if len(text) > 100 and any(keyword in text.lower() for keyword in ['observed', 'saw', 'witnessed', 'description']):
                                            long_description = text.strip()
                                            break
                                    
                                    page.go_back()
                                    time.sleep(2)
                                    break
                                except Exception as e:
                                    log(f"⚠️ Failed to get long description: {e}")
                                    pass
                        
                        # CREATE ALERT
                        log(f"📤 Creating alert for case #{real_case_id}...")
                        alert_payload = {
                            "title": f"MUFON Case #{real_case_id}",
                            "description": long_description,
                            "category": "Unknown",
                            "location": {"latitude": 39.7392, "longitude": -104.9903, "name": location},
                            "alert_level": "medium",
                            "source": "mufon",
                            "external_id": f"mufon_{real_case_id}",
                            "device_id": "mufon_scraper_device",
                            "metadata": {
                                "report_date": report_date,
                                "sighting_datetime": sighting_datetime,
                                "short_description": short_description
                            }
                        }
                        
                        response = requests.post("http://localhost:8000/alerts", json=alert_payload, timeout=30)
                        if response.status_code != 200:
                            log(f"❌ Failed to create alert for case #{real_case_id}: {response.status_code}")
                            continue
                        
                        result = response.json()
                        if result.get('status') != 'success':
                            log(f"❌ Alert creation failed for case #{real_case_id}: {result}")
                            continue
                        
                        alert_id = result['alert_id']
                        imported_count += 1
                        log(f"✅ Created alert: {alert_id}")
                        
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