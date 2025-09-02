#!/usr/bin/env python3
"""
Extract MUFON cases for ONE specific date
Usage: python extract_one_day.py 2025-02-01
"""
import sys
from playwright.sync_api import sync_playwright
import time
import json
import os
from datetime import datetime
from pathlib import Path

def download_media_file(page, url, filename, case_number):
    """Download media file using authenticated browser session"""
    try:
        # Create media directory for this extraction
        media_dir = Path("mufon_media")
        media_dir.mkdir(exist_ok=True)
        
        # Create unique filename with case number
        safe_filename = f"{case_number}_{filename}"
        local_path = media_dir / safe_filename
        
        # Download the file using the browser context (authenticated)
        response = page.request.get(url, timeout=10000)  # 10 second timeout
        if response.status == 200:
            with open(local_path, "wb") as f:
                f.write(response.body())
            print(f"   ✅ Downloaded {filename}")
            return str(local_path)
        else:
            print(f"   ❌ Failed to download {filename}: HTTP {response.status}")
            return None
            
    except Exception as e:
        print(f"   ❌ Error downloading {filename}: {e}")
        return None

def extract_mufon_day(date_str):
    """Extract MUFON cases for a specific date (YYYY-MM-DD)"""
    try:
        # Parse the date
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        year = str(date_obj.year)
        month = date_obj.month - 1  # Convert to 0-based for dropdown
        day = date_obj.day - 1      # Convert to 0-based for dropdown
    except ValueError:
        print("❌ Invalid date format. Use YYYY-MM-DD (e.g., 2025-02-01)")
        return
    
    cases = []
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=500)
        context = browser.new_context()
        page = context.new_page()
        
        # Login
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(2)
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        
        # Go to search page
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        print(f"📅 Setting date: {date_str}")
        
        # Set FROM date (faster form filling)
        page.mouse.click(360, 405)  # Month dropdown
        for _ in range(month):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.1)
        
        page.mouse.click(440, 405)  # Day dropdown
        for _ in range(day):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.1)
        
        page.mouse.click(520, 405)  # Year
        page.keyboard.type(year)
        page.keyboard.press("Enter")
        time.sleep(0.3)
        
        # Set TO date (same date for single day)
        page.mouse.click(590, 405)  # TO Month
        for _ in range(month):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.1)
        
        page.mouse.click(670, 405)  # TO Day
        for _ in range(day):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.1)
        
        page.mouse.click(750, 405)  # TO Year
        page.keyboard.type(year)
        page.keyboard.press("Enter")
        time.sleep(0.3)
        
        # Submit search
        page.mouse.click(633, 341)
        time.sleep(10)
        
        print("📊 Results loaded, extracting all cases...")
        
        # Get iframe with results
        iframe = page.frame_locator("iframe")
        
        # Get all table rows
        rows = iframe.locator("table tbody tr").all()
        print(f"Found {len(rows)} result rows for {date_str}")
        
        visited_cases = set()
        
        for i, row in enumerate(rows, 1):
            try:
                print(f"\n--- Processing Case {i}/{len(rows)} ---")
                
                # Extract basic info from the row
                cells = row.locator("td").all()
                if len(cells) < 5:
                    continue
                
                case_number = cells[0].inner_text().strip()
                date_time = cells[1].inner_text().strip()
                short_description = cells[2].inner_text().strip()
                location = cells[3].inner_text().strip()
                
                # Extract media from attachments column (usually last column)
                media_files = []
                if len(cells) > 4:
                    attachments_cell = cells[-1]  # Last column should be attachments
                    attachment_text = attachments_cell.inner_text().strip()
                    if attachment_text and attachment_text != "":
                        # Find and click actual attachment links
                        attachment_links = attachments_cell.locator('a')
                        for i in range(attachment_links.count()):
                            try:
                                link = attachment_links.nth(i)
                                filename = link.inner_text().strip()
                                if filename and ('.jpg' in filename.lower() or '.png' in filename.lower() or '.mp4' in filename.lower() or '.mov' in filename.lower()):
                                    # Get the actual href for download
                                    href = link.get_attribute('href')
                                    if href:
                                        if not href.startswith('http'):
                                            href = f"https://mufoncms.com{href}"
                                        
                                        # Determine file type
                                        file_type = "image" if any(ext in filename.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif']) else "video"
                                        
                                        # Download with timeout
                                        try:
                                            print(f"   🔽 Downloading {filename}...")
                                            local_path = download_media_file(page, href, filename, case_number)
                                        except Exception as e:
                                            print(f"   ❌ Download failed for {filename}: {e}")
                                            local_path = None
                                        
                                        # Create media file entry
                                        media_entry = {
                                            "filename": filename,
                                            "url": href,
                                            "type": file_type
                                        }
                                        
                                        # Add local path if download was successful
                                        if local_path:
                                            media_entry["local_path"] = local_path
                                        
                                        media_files.append(media_entry)
                            except Exception as e:
                                print(f"   ❌ Error processing attachment link: {e}")
                
                # Skip if we've already processed this case
                if case_number in visited_cases:
                    print(f"⏭️ Skipping duplicate case {case_number}")
                    continue
                
                visited_cases.add(case_number)
                
                print(f"📋 Case: {case_number}")
                print(f"📅 Date: {date_time}")
                print(f"📝 Short: {short_description[:50]}...")
                print(f"📍 Location: {location}")
                
                # Click the VIEW button in this row
                view_button = row.locator("input[value='VIEW']").first
                if view_button.count() > 0:
                    print("🔍 Clicking VIEW button...")
                    view_button.click()
                    time.sleep(3)
                    
                    # Check for popup and extract case ID from URL
                    long_description = ""
                    real_case_id = case_number  # fallback
                    
                    if len(page.context.pages) > 1:
                        popup = page.context.pages[-1]
                        popup.wait_for_load_state()
                        
                        # Extract case ID from popup URL
                        popup_url = popup.url
                        print(f"🔗 Popup URL: {popup_url}")
                        
                        # Look for case ID in URL parameters
                        if "case_id=" in popup_url:
                            real_case_id = popup_url.split("case_id=")[1].split("&")[0]
                        elif "id=" in popup_url:
                            real_case_id = popup_url.split("id=")[1].split("&")[0]
                        
                        detail_content = popup.locator("body").inner_text()
                        popup.close()
                        
                        # Extract long description
                        lines = [line.strip() for line in detail_content.split('\n') if len(line.strip()) > 20]
                        for line in lines:
                            if "Long Description" in line:
                                continue
                            if any(word in line.lower() for word in ['observed', 'saw', 'witnessed', 'light', 'object', 'hovering', 'moving', 'sky', 'appeared', 'noticed', 'round', 'metalic', 'sphere', 'flew', 'traveling']):
                                long_description = line
                                break
                        
                        if not long_description and lines:
                            long_description = max([l for l in lines if len(l) > 30], key=len, default="")
                    
                    print(f"📖 Long description: {long_description[:80]}..." if long_description else "⚠️ No long description found")
                    print(f"🆔 Real case ID: {real_case_id}")
                
                # Store case data
                case_data = {
                    "case_number": real_case_id,
                    "date_time": date_time,
                    "short_description": short_description,
                    "long_description": long_description if long_description else short_description,
                    "location": location,
                    "media_files": media_files,
                    "row_index": i
                }
                
                if media_files:
                    print(f"📎 Found {len(media_files)} media files: {[m['filename'] for m in media_files]}")
                cases.append(case_data)
                
            except Exception as e:
                print(f"❌ Error processing row {i}: {e}")
                continue
        
        # Save results with date in filename
        filename = f"mufon_cases_{date_str.replace('-', '_')}.json"
        output = {
            "search_date": date_str,
            "timestamp": datetime.now().isoformat(),
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open(filename, "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\n🎉 Successfully extracted {len(cases)} MUFON cases for {date_str}!")
        print(f"💾 Saved to {filename}")
        
        browser.close()
        return filename

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_one_day.py YYYY-MM-DD")
        print("Example: python extract_one_day.py 2025-02-01")
        sys.exit(1)
    
    date_arg = sys.argv[1]
    extract_mufon_day(date_arg)