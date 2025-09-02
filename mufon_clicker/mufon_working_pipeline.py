#!/usr/bin/env python3
"""
Complete MUFON pipeline using the WORKING approach
Based on extract_one_day.py with httpx media + import + cleanup
Usage: python mufon_working_pipeline.py 2024-09-04
"""
import sys
from playwright.sync_api import sync_playwright
import time
import json
import os
import httpx
import subprocess
from datetime import datetime
from pathlib import Path

def load_httpx_cookies():
    """Load cookies for httpx from storage_state.json"""
    storage_state_path = Path("mufon_artifacts/storage_state.json")
    if not storage_state_path.exists():
        return {}
    
    with open(storage_state_path) as f:
        storage_data = json.load(f)
    
    cookies = {}
    for cookie in storage_data.get('cookies', []):
        cookies[cookie['name']] = cookie['value']
    
    return cookies

def download_media_file_httpx(url, filename, case_number, cookies):
    """Download media file using httpx with authentication"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
        }
        
        with httpx.Client(cookies=cookies, headers=headers, timeout=30.0, follow_redirects=True) as client:
            print(f"   🔽 Downloading {filename} with httpx...")
            response = client.get(url)
            
            if response.status_code == 200 and len(response.content) > 1000:
                # Create media directory
                media_dir = Path("mufon_media")
                media_dir.mkdir(exist_ok=True)
                
                # Save file
                local_path = media_dir / f"{case_number}_{filename}"
                with open(local_path, "wb") as f:
                    f.write(response.content)
                
                print(f"   ✅ Downloaded {filename} ({len(response.content)} bytes)")
                return str(local_path)
            else:
                print(f"   ❌ Download failed: HTTP {response.status_code}")
                return None
                
    except Exception as e:
        print(f"   ❌ Download error: {e}")
        return None

def extract_mufon_day_working(date_str):
    """Extract MUFON cases using the WORKING method"""
    try:
        # Parse the date
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        year = str(date_obj.year)
        month = date_obj.month - 1  # Convert to 0-based for dropdown
        day = date_obj.day - 1      # Convert to 0-based for dropdown
    except ValueError:
        print("❌ Invalid date format. Use YYYY-MM-DD (e.g., 2024-09-04)")
        return None
    
    print(f"🎯 Extracting MUFON cases for {date_str}")
    print("🔄 Using WORKING method: direct login + coordinate clicking")
    
    # Load httpx cookies for media downloads
    httpx_cookies = load_httpx_cookies()
    print(f"🔑 Loaded {len(httpx_cookies)} httpx cookies for media downloads")
    
    cases = []
    
    with sync_playwright() as p:
        print("🌐 Starting browser...")
        browser = p.chromium.launch(headless=True, slow_mo=500)
        context = browser.new_context()
        page = context.new_page()
        
        # Direct login (WORKING METHOD)
        print("🔐 Logging in directly...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(2)
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        print("✅ Login completed")
        
        # Go to search page (WORKING METHOD)  
        print("🔍 Going to search page...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        print("✅ At search page")
        
        print(f"📅 Setting date: {date_str}")
        print("🖱️ Using coordinate clicking (WORKING METHOD)...")
        
        # Set Date of Event FROM date (second row in screenshot)
        page.mouse.click(360, 430)  # Date of Event Month dropdown
        print(f"   📅 Setting Event month: {month + 1}")
        for _ in range(month):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.1)
        
        page.mouse.click(440, 430)  # Date of Event Day dropdown
        print(f"   📅 Setting Event day: {day + 1}")
        for _ in range(day):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.1)
        
        page.mouse.click(520, 430)  # Date of Event Year
        print(f"   📅 Setting Event year: {year}")
        page.keyboard.type(year)
        page.keyboard.press("Enter")
        time.sleep(0.3)
        
        # Set Date of Event TO date (same date for single day)
        page.mouse.click(590, 430)  # Date of Event TO Month
        for _ in range(month):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.1)
        
        page.mouse.click(670, 430)  # Date of Event TO Day
        for _ in range(day):
            page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.1)
        
        page.mouse.click(750, 430)  # Date of Event TO Year
        page.keyboard.type(year)
        page.keyboard.press("Enter")
        time.sleep(0.3)
        
        # Submit search - click the SUBMIT button visible in screenshot
        print("🚀 Submitting search...")
        page.mouse.click(633, 341)  # SUBMIT button location
        time.sleep(10)
        
        # Take screenshot to see what we got
        print("📸 Taking screenshot to debug...")
        page.screenshot(path=f"debug_search_results_{date_str.replace('-', '_')}.png")
        print("✅ Screenshot saved")
        
        print("📊 Results loaded, extracting all cases...")
        
        # Get iframe with results (WORKING METHOD)
        iframe = page.frame_locator("iframe")
        
        # Get all table rows
        rows = iframe.locator("table tbody tr").all()
        print(f"✅ Found {len(rows)} result rows for {date_str}")
        
        visited_cases = set()
        
        for i, row in enumerate(rows, 1):
            try:
                print(f"\\n--- Processing Case {i}/{len(rows)} ---")
                
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
                        print(f"   📎 Found attachments: {attachment_text}")
                        # Find and process attachment links
                        attachment_links = attachments_cell.locator('a')
                        for j in range(attachment_links.count()):
                            try:
                                link = attachment_links.nth(j)
                                filename = link.inner_text().strip()
                                if filename and ('.jpg' in filename.lower() or '.png' in filename.lower() or '.mp4' in filename.lower() or '.mov' in filename.lower()):
                                    # Get the actual href for download
                                    href = link.get_attribute('href')
                                    if href:
                                        if not href.startswith('http'):
                                            href = f"https://mufoncms.com{href}"
                                        
                                        # Determine file type
                                        file_type = "image" if any(ext in filename.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif']) else "video"
                                        
                                        # Download with httpx (WORKING METHOD)
                                        local_path = download_media_file_httpx(href, filename, case_number, httpx_cookies)
                                        
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
                
                # Click the VIEW button in this row (WORKING METHOD)
                long_description = ""
                real_case_id = case_number  # fallback
                
                view_button = row.locator("input[value='VIEW']").first
                if view_button.count() > 0:
                    print("🔍 Clicking VIEW button...")
                    view_button.click()
                    time.sleep(3)
                    
                    # Check for popup and extract case ID from URL
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
                        lines = [line.strip() for line in detail_content.split('\\n') if len(line.strip()) > 20]
                        for line in lines:
                            if "Long Description" in line:
                                continue
                            if any(word in line.lower() for word in ['observed', 'saw', 'witnessed', 'light', 'object', 'hovering', 'moving', 'sky', 'appeared', 'noticed']):
                                long_description = line
                                break
                        
                        if not long_description and lines:
                            long_description = max([l for l in lines if len(l) > 30], key=len, default="")
                    
                    print(f"📖 Long description: {long_description[:80]}...\" if long_description else \"⚠️ No long description found\"")
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
        filename = f"mufon_working_{date_str.replace('-', '_')}.json"
        output = {
            "search_date": date_str,
            "timestamp": datetime.now().isoformat(),
            "method": "working_playwright_httpx",
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open(filename, "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\\n🎉 Successfully extracted {len(cases)} MUFON cases for {date_str}!")
        print(f"💾 Saved to {filename}")
        
        browser.close()
        return filename

def import_to_ufobeep(json_filename):
    """Import extracted data to UFOBeep database"""
    print(f"\\n🚀 Importing {json_filename} to UFOBeep...")
    
    # Use the existing import script (adjust path for production)
    import_script = "ufobeep/api/feeds/import_via_alerts.py"
    if not os.path.exists(import_script):
        import_script = "/home/mike/D/ufobeep/api/feeds/import_via_alerts.py"
    if not os.path.exists(import_script):
        print(f"❌ Import script not found: {import_script}")
        return False
    
    # Run the import with full path
    try:
        full_json_path = os.path.abspath(json_filename)
        result = subprocess.run([
            "python", import_script, full_json_path
        ], cwd="/home/mike/D/ufobeep/api/feeds", capture_output=True, text=True, timeout=300)
        
        print("Import output:")
        print(result.stdout)
        if result.stderr:
            print("Import errors:")
            print(result.stderr)
        
        success = result.returncode == 0
        if success:
            print("✅ Import completed successfully")
        else:
            print("❌ Import failed")
        
        return success
        
    except Exception as e:
        print(f"❌ Import error: {e}")
        return False

def main():
    """Main pipeline function"""
    if len(sys.argv) != 2:
        print("Usage: python mufon_working_pipeline.py YYYY-MM-DD")
        print("Example: python mufon_working_pipeline.py 2024-09-04")
        sys.exit(1)
    
    date_str = sys.argv[1]
    
    print("🎯 MUFON WORKING Pipeline Starting...")
    print(f"📅 Date: {date_str}")
    print("🔄 Method: WORKING Playwright + httpx + import + cleanup")
    
    # Step 1: Extract cases with working method
    json_filename = extract_mufon_day_working(date_str)
    if not json_filename:
        print("❌ Extraction failed")
        sys.exit(1)
    
    # Step 2: Import to UFOBeep
    import_success = import_to_ufobeep(json_filename)
    if not import_success:
        print("⚠️ Import failed, but keeping extraction data")
        print(f"📄 Data saved in: {json_filename}")
        sys.exit(1)
    
    # Step 3: Cleanup
    try:
        os.remove(json_filename)
        print(f"🗑️ Removed {json_filename} after successful import")
        print("📁 Media files kept in mufon_media/")
    except Exception as e:
        print(f"❌ Cleanup error: {e}")
    
    print("\\n🎉 MUFON Working Pipeline Finished!")
    print(f"✅ {date_str} data extracted, imported, and cleaned up")

if __name__ == "__main__":
    main()