#!/usr/bin/env python3
"""
Complete MUFON pipeline: Extract + Download Media + Import + Cleanup
Usage: python mufon_complete_pipeline.py 2024-09-06
Does everything in one go and cleans up after itself
"""
import sys
import json
import os
import time
import httpx
import requests
from pathlib import Path
from datetime import datetime
from playwright.sync_api import sync_playwright

def download_media_file_httpx(url, filename, case_number, cookies):
    """Download media file using httpx with authentication"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
        }
        
        with httpx.Client(cookies=cookies, headers=headers, timeout=30.0, follow_redirects=True) as client:
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
                print(f"   ❌ Download failed: HTTP {response.status_code}, {len(response.content)} bytes")
                return None
                
    except Exception as e:
        print(f"   ❌ Download error: {e}")
        return None

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

def extract_mufon_day_complete(date_str):
    """Extract MUFON cases with Playwright + httpx media downloads"""
    try:
        # Parse the date
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        year = str(date_obj.year)
        month = date_obj.month - 1  # Convert to 0-based for dropdown
        day = date_obj.day - 1      # Convert to 0-based for dropdown
    except ValueError:
        print("❌ Invalid date format. Use YYYY-MM-DD (e.g., 2025-02-01)")
        return None
    
    print(f"📅 Extracting MUFON cases for {date_str}")
    
    # Load httpx cookies for media downloads
    httpx_cookies = load_httpx_cookies()
    print(f"🔑 Loaded {len(httpx_cookies)} httpx cookies for media downloads")
    
    cases = []
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=500)
        context = browser.new_context(storage_state="mufon_artifacts/storage_state.json")
        page = context.new_page()
        
        # Step 1: Go to MUFON homepage and login
        print("🌐 Going to MUFON homepage...")
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        time.sleep(3)
        print(f"✅ At: {page.url}")
        
        # Click Track UFOs
        print("🔍 Looking for Track UFOs link...")
        track_ufos_clicked = False
        for selector in ["text=Track UFOs", "text=TRACK UFOS", "text=Track UFO's"]:
            try:
                element = page.locator(selector).first
                if element.count() > 0:
                    print(f"✅ Clicking {selector}")
                    element.click()
                    time.sleep(2)
                    track_ufos_clicked = True
                    break
            except:
                continue
        
        if not track_ufos_clicked:
            print("❌ Could not find Track UFOs link")
            return None
        
        print(f"📍 Now at: {page.url}")
        
        # Look for Database Search
        print("🔍 Looking for Database Search...")
        db_search_clicked = False
        for selector in ["text=Database Search", "text=Search Database", "text=Case Search"]:
            try:
                element = page.locator(selector).first
                if element.count() > 0:
                    print(f"✅ Clicking {selector}")
                    element.click()
                    page.wait_for_load_state("networkidle")
                    time.sleep(3)
                    db_search_clicked = True
                    break
            except:
                continue
        
        if not db_search_clicked:
            print("❌ Could not find Database Search")
            return None
        
        print(f"📍 Now at: {page.url}")
        
        # Check if we need to login (auth popup)
        print("🔐 Checking for login popup...")
        time.sleep(2)
        
        # Look for login form
        if page.locator("input[name='loginName']").count() > 0:
            print("🔑 Login form detected, filling credentials...")
            page.fill("input[name='loginName']", "varak")
            page.fill("input[name='loginPassword']", "ufobeep123pass")
            page.click("text=Log In")
            print("✅ Login submitted, waiting...")
            time.sleep(5)
            print(f"📍 After login: {page.url}")
        else:
            print("✅ Already authenticated")
        
        print(f"📅 Setting date: {date_str}")
        
        # Set FROM date using coordinate clicking (working method)
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
        
        print("📊 Results loaded, extracting cases...")
        
        # Get iframe with results
        iframe = page.frame_locator("iframe")
        rows = iframe.locator("table tbody tr").all()
        print(f"Found {len(rows)} result rows for {date_str}")
        
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
                
                # Skip duplicates
                if case_number in visited_cases:
                    print(f"⏭️ Skipping duplicate case {case_number}")
                    continue
                visited_cases.add(case_number)
                
                print(f"📋 Case: {case_number}")
                print(f"📝 Short: {short_description[:50]}...")
                print(f"📍 Location: {location}")
                
                # Extract media from attachments column
                media_files = []
                if len(cells) > 4:
                    attachments_cell = cells[-1]  # Last column
                    attachment_links = attachments_cell.locator('a')
                    
                    for j in range(attachment_links.count()):
                        try:
                            link = attachment_links.nth(j)
                            filename = link.inner_text().strip()
                            
                            if filename and any(ext in filename.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov']):
                                href = link.get_attribute('href')
                                if href:
                                    if not href.startswith('http'):
                                        href = f"https://mufoncms.com{href}"
                                    
                                    file_type = "image" if any(ext in filename.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif']) else "video"
                                    
                                    print(f"   🔽 Downloading {filename} via httpx...")
                                    local_path = download_media_file_httpx(href, filename, case_number, httpx_cookies)
                                    
                                    media_entry = {
                                        "filename": filename,
                                        "url": href,
                                        "type": file_type
                                    }
                                    
                                    if local_path:
                                        media_entry["local_path"] = local_path
                                    
                                    media_files.append(media_entry)
                                    
                        except Exception as e:
                            print(f"   ❌ Error processing attachment: {e}")
                
                # Click VIEW button to get long description
                long_description = ""
                real_case_id = case_number
                
                view_button = row.locator("input[value='VIEW']").first
                if view_button.count() > 0:
                    print("🔍 Clicking VIEW button...")
                    view_button.click()
                    time.sleep(3)
                    
                    # Check for popup
                    if len(page.context.pages) > 1:
                        popup = page.context.pages[-1]
                        popup.wait_for_load_state()
                        
                        # Extract case ID from popup URL
                        popup_url = popup.url
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
                            if any(word in line.lower() for word in ['observed', 'saw', 'witnessed', 'light', 'object', 'hovering', 'moving', 'sky']):
                                long_description = line
                                break
                        
                        if not long_description and lines:
                            long_description = max([l for l in lines if len(l) > 30], key=len, default="")
                    
                    print(f"📖 Long description: {len(long_description)} chars" if long_description else "⚠️ No long description found")
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
                    print(f"📎 Found {len(media_files)} media files")
                
                cases.append(case_data)
                
            except Exception as e:
                print(f"❌ Error processing row {i}: {e}")
                continue
        
        browser.close()
    
    # Save extraction results
    filename = f"mufon_complete_{date_str.replace('-', '_')}.json"
    output = {
        "search_date": date_str,
        "timestamp": datetime.now().isoformat(),
        "method": "playwright_httpx_hybrid",
        "total_cases": len(cases),
        "cases": cases
    }
    
    with open(filename, "w") as f:
        json.dump(output, f, indent=2)
    
    print(f"\\n✅ Extracted {len(cases)} cases")
    print(f"💾 Saved to {filename}")
    
    return filename

def import_to_ufobeep(json_filename):
    """Import extracted data to UFOBeep database"""
    print(f"\\n🚀 Importing {json_filename} to UFOBeep...")
    
    # Use the existing import script
    import_script = "/home/mike/D/ufobeep/api/feeds/import_via_alerts.py"
    if not os.path.exists(import_script):
        print(f"❌ Import script not found: {import_script}")
        return False
    
    # Run the import
    import subprocess
    try:
        result = subprocess.run([
            "python", import_script, json_filename
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

def cleanup_files(json_filename):
    """Clean up temporary files"""
    print(f"\\n🧹 Cleaning up...")
    
    try:
        # Remove JSON file
        if os.path.exists(json_filename):
            os.remove(json_filename)
            print(f"🗑️ Removed {json_filename}")
        
        # Keep media files (they're useful)
        print("📁 Keeping media files in mufon_media/")
        
        print("✅ Cleanup completed")
        
    except Exception as e:
        print(f"❌ Cleanup error: {e}")

def main():
    """Main pipeline function"""
    if len(sys.argv) != 2:
        print("Usage: python mufon_complete_pipeline.py YYYY-MM-DD")
        print("Example: python mufon_complete_pipeline.py 2024-09-06")
        sys.exit(1)
    
    date_str = sys.argv[1]
    
    print("🎯 MUFON Complete Pipeline Starting...")
    print(f"📅 Date: {date_str}")
    print("🔄 Steps: Extract → Download Media → Cleanup → Import")
    
    # Step 1: Extract cases and download media
    json_filename = extract_mufon_day_complete(date_str)
    if not json_filename:
        print("❌ Extraction failed")
        sys.exit(1)
    
    # Step 2: Cleanup temporary files (keep JSON for import)
    print("\\n🧹 Cleaning up temporary files...")
    media_dir = Path("mufon_media")
    if media_dir.exists():
        print("📁 Keeping media files in mufon_media/")
    
    # Step 3: Import to UFOBeep
    import_success = import_to_ufobeep(json_filename)
    if not import_success:
        print("⚠️ Import failed, but keeping extraction data")
        print(f"📄 Data saved in: {json_filename}")
        sys.exit(1)
    
    # Step 4: Final cleanup - remove JSON after successful import
    try:
        os.remove(json_filename)
        print(f"🗑️ Removed {json_filename} after successful import")
    except Exception as e:
        print(f"❌ Cleanup error: {e}")
    
    print("\\n🎉 MUFON Complete Pipeline Finished!")
    print(f"✅ {date_str} data extracted, imported, and cleaned up")

if __name__ == "__main__":
    main()