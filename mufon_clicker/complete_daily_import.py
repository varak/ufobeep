#!/usr/bin/env python3
"""
Complete daily MUFON import - extract cases with media and import to UFOBeep
Usage: python complete_daily_import.py
"""
import sys
import os
import json
import requests
import time
from pathlib import Path
from datetime import datetime
from playwright.sync_api import sync_playwright

# Add API feeds path
sys.path.append('/home/mike/D/ufobeep/api/feeds')
from import_via_alerts import import_mufon_cases

def download_media_with_auth(page, url, filename, case_number):
    """Download media file using authenticated browser session"""
    try:
        media_dir = Path("mufon_media")
        media_dir.mkdir(exist_ok=True)
        
        safe_filename = f"{case_number}_{filename}"
        local_path = media_dir / safe_filename
        
        print(f"   📥 Downloading {filename}")
        
        # Use the authenticated page to download
        response = page.request.get(url, timeout=15000)
        if response.status == 200:
            with open(local_path, "wb") as f:
                f.write(response.body())
            print(f"   ✅ Downloaded {filename} ({len(response.body())} bytes)")
            return str(local_path)
        else:
            print(f"   ❌ Failed to download {filename}: HTTP {response.status}")
            return None
            
    except Exception as e:
        print(f"   ❌ Error downloading {filename}: {e}")
        return None

def extract_and_import_daily():
    """Extract recent MUFON cases with media and import them"""
    print("🚀 Starting complete daily MUFON import...")
    
    cases = []
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()
        
        # Login
        print("🔐 Logging in to MUFON...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(2)
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        
        # Go to search (this should show recent cases)
        print("📍 Going to search results...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # Click submit to get default results (recent cases)
        try:
            submit_btn = page.locator("input[value='SUBMIT']").first
            submit_btn.click()
            time.sleep(8)
        except:
            print("⚠️ Submit button not found, continuing...")
        
        # Wait for results iframe
        print("📊 Loading results...")
        time.sleep(5)
        
        # Get iframe with results
        iframe = page.frame_locator("iframe").first
        
        # Count rows
        rows = iframe.locator("table tbody tr").all()
        print(f"Found {len(rows)} result rows")
        
        # Process first 10 cases (avoid timeouts)
        processed = 0
        for i, row in enumerate(rows[:10]):
            if processed >= 5:  # Limit to avoid timeout
                break
                
            print(f"\n--- Processing Case {i+1}/{min(len(rows), 10)} ---")
            
            try:
                # Get case data from row
                cells = row.locator("td").all()
                if len(cells) < 6:
                    continue
                
                # Extract basic info
                attachments_text = cells[0].inner_text().strip() if len(cells) > 0 else ""
                case_number = cells[1].inner_text().strip() if len(cells) > 1 else ""
                date_text = cells[2].inner_text().strip() if len(cells) > 2 else ""
                short_desc = cells[3].inner_text().strip() if len(cells) > 3 else ""
                location = cells[4].inner_text().strip() if len(cells) > 4 else ""
                
                print(f"📋 Case: {case_number}")
                print(f"📅 Date: {date_text}")
                print(f"📍 Location: {location}")
                print(f"📎 Attachments: {attachments_text}")
                
                if not case_number or case_number in ['Case Number', 'EDIT PROFILE']:
                    continue
                
                # Parse media files from attachments
                media_files = []
                if attachments_text and attachments_text not in ['Attachments', '']:
                    media_filenames = [f.strip() for f in attachments_text.split('\n') if f.strip()]
                    print(f"📎 Found {len(media_filenames)} media files")
                    
                    # Download each media file
                    for filename in media_filenames:
                        if filename:
                            # Construct MUFON media URL
                            media_url = f"https://mufoncms.com/cgi-bin/manage_attachment_images.pl?file={filename}"
                            local_path = download_media_with_auth(page, media_url, filename, case_number)
                            if local_path:
                                media_files.append({
                                    "filename": filename,
                                    "local_path": local_path,
                                    "type": "video" if filename.lower().endswith(('.mp4', '.mov', '.avi')) else "image"
                                })
                
                # Click VIEW button to get long description
                long_description = ""
                try:
                    view_button = row.locator("input[value='VIEW'], button:has-text('VIEW')").first
                    
                    with page.expect_popup(timeout=10000) as popup_info:
                        view_button.click()
                    
                    popup = popup_info.value
                    time.sleep(2)
                    
                    # Extract long description from popup
                    desc_text = popup.locator("#longDescription, .description").first.inner_text()
                    if desc_text:
                        long_description = desc_text.strip()
                        print(f"📖 Got long description ({len(long_description)} chars)")
                    
                    popup.close()
                    
                except Exception as e:
                    print(f"⚠️ Could not get long description: {e}")
                
                # Build case data
                case_data = {
                    "case_number": case_number,
                    "date_time": date_text,
                    "short_description": short_desc,
                    "long_description": long_description,
                    "location": location,
                    "media_files": media_files
                }
                
                cases.append(case_data)
                processed += 1
                
            except Exception as e:
                print(f"❌ Error processing case {i+1}: {e}")
        
        browser.close()
    
    # Save extracted data
    output_data = {
        "extraction_date": datetime.now().isoformat(),
        "total_cases": len(cases),
        "cases": cases
    }
    
    output_file = f"daily_mufon_{datetime.now().strftime('%Y_%m_%d')}.json"
    with open(output_file, "w") as f:
        json.dump(output_data, f, indent=2)
    
    print(f"\n💾 Saved {len(cases)} cases to {output_file}")
    
    # Import to UFOBeep
    if cases:
        print(f"\n📤 Importing {len(cases)} cases to UFOBeep...")
        
        # Create a temporary JSON file in the format the import script expects
        temp_import_file = "temp_for_import.json"
        with open(temp_import_file, "w") as f:
            json.dump(output_data, f, indent=2)
        
        # Use the existing import function
        os.system(f"python /home/mike/D/ufobeep/api/feeds/import_via_alerts.py {temp_import_file}")
        
        print("✅ Import completed!")
        
        # Clean up temp file
        if Path(temp_import_file).exists():
            Path(temp_import_file).unlink()
    
    return len(cases)

if __name__ == "__main__":
    try:
        count = extract_and_import_daily()
        print(f"\n🎉 Successfully processed {count} MUFON cases!")
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)