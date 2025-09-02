#!/usr/bin/env python3
"""
Recreate the exact working MUFON pipeline that you described:
- Extract cases with authentication (like extract_one_day.py)
- Use working media URL format (CGI script)
- Import via /sightings/create endpoint (like import_mufon_cases.py)
- Process one case at a time completely
"""

import sys
import os
import json
import requests
import time
import uuid
import mimetypes
from pathlib import Path
from datetime import datetime
from playwright.sync_api import sync_playwright

def download_media_file(url, filename):
    """Download media file like the working system did"""
    try:
        # Create media directory like the working system
        media_dir = Path("/home/mike/D/ufobeep/api/media")
        media_dir.mkdir(exist_ok=True)
        
        # Generate unique filename to avoid conflicts
        file_ext = Path(filename).suffix
        unique_filename = f"{uuid.uuid4()}{file_ext}"
        file_path = media_dir / unique_filename
        
        print(f"   📥 Downloading {filename} from {url}")
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        # Write the file
        with open(file_path, 'wb') as f:
            f.write(response.content)
        
        print(f"   ✅ Saved as {unique_filename} ({len(response.content)} bytes)")
        return {
            'original_filename': filename,
            'stored_filename': unique_filename,
            'file_path': str(file_path),
            'file_size': len(response.content),
            'mime_type': mimetypes.guess_type(filename)[0]
        }
        
    except Exception as e:
        print(f"   ❌ Failed to download {filename}: {e}")
        return None

def insert_sighting_via_api(case_data, media_files):
    """Insert sighting via the working /sightings/create endpoint"""
    try:
        # Prepare sighting data like the working system
        sighting_payload = {
            'external_id': f"mufon_{case_data.get('Case_Number', '')}",
            'source': 'mufon',
            'title': case_data.get('title', '')[:100],
            'description': case_data.get('description', ''),
            'location': case_data.get('location', ''),
            'sighted_at': case_data.get('sighted_at', ''),
            'reported_at': case_data.get('reported_at', ''),
            'status': 'verified',
            'visibility': 'public',
            'media_files': media_files
        }
        
        print(f"   📤 Creating sighting via /sightings/create: {sighting_payload['title'][:50]}...")
        
        # Call the working endpoint
        response = requests.post(
            'http://localhost:8000/sightings/create',
            json=sighting_payload,
            timeout=30
        )
        
        if response.status_code == 201:
            sighting_data = response.json()
            print(f"   ✅ Created sighting ID: {sighting_data.get('id')}")
            return sighting_data
        else:
            print(f"   ❌ API error: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"   ❌ Failed to create sighting via API: {e}")
        return None

def working_mufon_pipeline(date_str):
    """Recreate the exact working MUFON pipeline"""
    
    try:
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        month, day, year = date_obj.month, date_obj.day, date_obj.year
        print(f"📅 Processing MUFON cases for {date_str} using working pipeline")
    except ValueError:
        print("❌ Invalid date format. Use YYYY-MM-DD")
        return

    imported_count = 0
    total_media_downloaded = 0

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=500)
        context = browser.new_context()
        page = context.new_page()

        # Do fresh login every time to ensure authentication
        print("🔐 Performing fresh login...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(3)
        
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass") 
        page.click("text=Log In")
        time.sleep(8)
        
        print("✅ Login completed, navigating to search...")

        # Navigate to CMS search page
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # Verify we're on the search page (not login page)
        if "neonPage.jsp" not in page.url:
            print("❌ Not on search page after login!")
            page.screenshot(path="wrong_page.png")
            browser.close()
            return
        
        print("✅ Successfully authenticated to CMS search page")
        page.screenshot(path="cms_search_ready.png")

        print("📝 Filling search form with working coordinate approach...")
        
        # Set FROM date (working coordinate approach)
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

        # Process results one by one (working approach)
        iframe = page.frame_locator("iframe")
        rows = iframe.locator("table tbody tr").all()
        
        print(f"📊 Found {len(rows)} cases - processing each completely like working system...")
        
        for i, row in enumerate(rows, 1):
            try:
                print(f"\n=== Case {i}/{len(rows)} - Complete Processing ===")
                
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

                # Extract and download media using WORKING CGI URL format
                downloaded_media = []
                if len(cells) > 4:
                    attachments_cell = cells[-1]
                    attachment_text = attachments_cell.inner_text().strip()
                    
                    if attachment_text:
                        print(f"📎 Processing attachments with working CGI format...")
                        attachment_files = [f.strip() for f in attachment_text.split('\n') if f.strip()]
                        
                        for filename in attachment_files:
                            if filename and '.' in filename:
                                # Use the WORKING CGI URL format from mufon_complete_scraper.py
                                media_url = f"http://mufoncms.com/cgi-bin/ffplay.pl?file={filename}"
                                
                                downloaded = download_media_file(media_url, filename)
                                if downloaded:
                                    downloaded_media.append(downloaded)
                                    total_media_downloaded += 1

                # Prepare case data for working /sightings/create endpoint  
                case_data = {
                    'Case_Number': real_case_id,
                    'title': f"MUFON Case #{real_case_id}",
                    'description': long_description,
                    'location': location,
                    'sighted_at': date_time.replace('\n', ' '),
                    'reported_at': date_str
                }

                print(f"📤 Importing case #{real_case_id} via working pipeline...")

                # Insert via working /sightings/create endpoint
                sighting = insert_sighting_via_api(case_data, downloaded_media)
                
                if sighting:
                    imported_count += 1
                    if downloaded_media:
                        print(f"   📎 Downloaded and stored {len(downloaded_media)} media files")
                    print(f"🎉 Case #{real_case_id} completely processed via working pipeline!")
                else:
                    print(f"❌ Failed to import case #{real_case_id}")

                # Brief pause between cases
                time.sleep(2)

            except Exception as e:
                print(f"❌ Error processing case {i}: {e}")
                continue

        print(f"\n🏁 Working pipeline complete!")
        print(f"✅ Successfully imported {imported_count}/{len(rows)} MUFON cases")
        print(f"📥 Downloaded {total_media_downloaded} media files")
        print(f"💾 Media stored in: /home/mike/D/ufobeep/api/media/")
        
        browser.close()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python recreate_working_pipeline.py YYYY-MM-DD")
        print("Example: python recreate_working_pipeline.py 2025-02-05")
        sys.exit(1)
    
    date_arg = sys.argv[1]
    working_mufon_pipeline(date_arg)