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
                        
                        # PRINT what we WOULD insert (unless --insert flag is used)
                        import uuid
                        alert_id = str(uuid.uuid4())
                        
                        log(f"📤 WOULD CREATE ALERT:")
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