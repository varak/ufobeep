#!/usr/bin/env python3
"""
Extract MUFON cases with media from existing search results
Skip the slow form filling and use existing results
"""
from playwright.sync_api import sync_playwright
import time
import json
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
        
        print(f"   📥 Downloading {filename}")
        
        # Download the file using the browser context (authenticated)
        response = page.request.get(url, timeout=30000)  # 30 second timeout
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

def main(date_str="2025-01-01"):
    """Extract MUFON cases for a specific date (YYYY-MM-DD format)"""
    import sys
    if len(sys.argv) > 1:
        if sys.argv[1] in ['-h', '--help']:
            print("Usage: python extract_with_media.py [YYYY-MM-DD]")
            print("Example: python extract_with_media.py 2025-01-01")
            return
        date_str = sys.argv[1]
    
    # Parse date
    year, month, day = date_str.split("-")
    print(f"🗓️ Extracting MUFON cases for {date_str}")
    
    cases = []
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, slow_mo=100)
        context = browser.new_context()
        page = context.new_page()
        
        # Login
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(2)
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        
        # Go to search page and set date
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # Set date range using working approach
        print(f"📅 Setting date to {date_str}...")
        
        # Try method 1: Text inputs (MM/DD/YYYY format)
        inputs = page.locator("input[type='text']").all()
        if len(inputs) >= 4:
            print("Using text input method...")
            formatted_date = f"{month.zfill(2)}/{day.zfill(2)}/{year}"
            
            # Clear and fill Date Submitted range
            inputs[0].fill(formatted_date)
            inputs[1].fill(formatted_date)
            
            # Clear and fill Date of Event range  
            inputs[2].fill(formatted_date)
            inputs[3].fill(formatted_date)
            
            print(f"✅ Set date ranges to {formatted_date}")
        else:
            # Method 2: Dropdown selectors (fallback)
            print("Using dropdown method...")
            selects = page.locator("select").all()
            if len(selects) >= 6:
                # Date Submitted FROM
                selects[0].select_option(str(int(month)))  # Month
                selects[1].select_option(str(int(day)))    # Day
                selects[2].select_option(year)             # Year
                
                # Date Submitted TO (same date)
                selects[3].select_option(str(int(month)))  # Month
                selects[4].select_option(str(int(day)))    # Day
                selects[5].select_option(year)             # Year
                
                print(f"✅ Set dropdown dates to {month}/{day}/{year}")
            else:
                print(f"❌ Could not find date fields. Found {len(inputs)} inputs and {len(selects)} selects")
        
        time.sleep(2)
        
        # Submit search using reliable method
        print(f"🚀 Searching for cases on {date_str}...")
        try:
            # Method 1: Click SUBMIT button by value
            page.locator("input[value='SUBMIT']").first.click()
            print("✅ Clicked SUBMIT button")
        except:
            try:
                # Method 2: Find submit inputs by type
                submit_buttons = page.locator("input[type='submit'], input[type='button']").all()
                for button in submit_buttons:
                    value = button.get_attribute('value') or ''
                    if 'SUBMIT' in value.upper():
                        button.click()
                        print(f"✅ Clicked SUBMIT button: {value}")
                        break
            except:
                # Method 3: Fallback to coordinates (original method)
                page.mouse.click(633, 341)
                print("⚠️ Used fallback coordinate click")
        
        time.sleep(10)
        
        print("📊 Results loaded, extracting with media...")
        
        # Get iframe with results
        iframe = page.frame_locator("iframe")
        
        # Get all table rows
        rows = iframe.locator("table tbody tr").all()
        print(f"Found {len(rows)} result rows")
        
        visited_cases = set()
        
        for i, row in enumerate(rows, 1):
            try:
                print(f"\n--- Processing Case {i}/{len(rows)} ---")
                
                # Extract basic info from the row
                cells = row.locator("td").all()
                if len(cells) < 5:
                    continue
                
                case_number = cells[0].inner_text().strip()
                date_time = cells[2].inner_text().strip()  # Event date/time
                short_description = cells[3].inner_text().strip()  # Object description
                location = cells[4].inner_text().strip()  # REAL location (Quincy, IL, US)
                
                # Extract media from attachments column (last column)
                media_files = []
                if len(cells) > 4:
                    attachments_cell = cells[-1]  # Last column
                    attachment_text = attachments_cell.inner_text().strip()
                    print(f"📎 Attachments text: {attachment_text}")
                    
                    if attachment_text and attachment_text != "" and any(ext in attachment_text.lower() for ext in ['.jpg', '.png', '.mp4', '.mov']):
                        # Split by newlines to get individual file names
                        for line in attachment_text.split('\n'):
                            line = line.strip()
                            if line and ('.jpg' in line.lower() or '.png' in line.lower() or '.mp4' in line.lower() or '.mov' in line.lower()):
                                # Download the media file using authenticated session
                                media_url = f"https://mufoncms.com/cgi-bin/manage_attachment_images.pl?file={line}"
                                local_path = download_media_file(page, media_url, line, case_number)
                                
                                media_files.append({
                                    "filename": line,
                                    "url": media_url,
                                    "local_path": local_path,
                                    "type": "image" if any(ext in line.lower() for ext in ['.jpg', '.png']) else "video"
                                })
                
                # Skip if we've already processed this case
                if case_number in visited_cases:
                    print(f"⏭️ Skipping duplicate case {case_number}")
                    continue
                
                visited_cases.add(case_number)
                
                print(f"📋 Case: {case_number}")
                print(f"📅 Date: {date_time}")
                print(f"📝 Short: {short_description[:50]}...")
                print(f"📍 Location: {location}")
                
                if media_files:
                    print(f"📎 Found {len(media_files)} media files:")
                    for media in media_files:
                        print(f"   - {media['filename']} ({media['type']})")
                
                # Click the VIEW button to get long description
                view_button = row.locator("input[value='VIEW']").first
                if view_button.count() > 0:
                    print("🔍 Clicking VIEW button...")
                    view_button.click()
                    time.sleep(3)
                    
                    # Get case ID from popup and long description
                    long_description = ""
                    real_case_id = case_number  # fallback
                    
                    if len(page.context.pages) > 1:
                        popup = page.context.pages[-1]
                        popup.wait_for_load_state()
                        
                        # Extract case ID from popup URL
                        popup_url = popup.url
                        print(f"🔗 Popup URL: {popup_url}")
                        
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
                            if any(word in line.lower() for word in ['observed', 'saw', 'witnessed', 'light', 'object', 'hovering', 'moving', 'sky', 'appeared', 'noticed']):
                                long_description = line
                                break
                        
                        if not long_description and lines:
                            long_description = max([l for l in lines if len(l) > 30], key=len, default="")
                        
                        # Download media files now while we have the popup open and authenticated
                        if media_files:
                            print(f"📥 Downloading {len(media_files)} media files...")
                            for media in media_files:
                                filename = media['filename']
                                # Use the case ID from popup URL for proper media URL
                                media_url = f"https://mufoncms.com/cgi-bin/manage_attachment_images.pl?file={real_case_id}_submitter_file_{filename}"
                                local_path = download_media_file(page, media_url, filename, real_case_id)
                                if local_path:
                                    media['local_path'] = local_path
                    
                    print(f"📖 Long description: {long_description[:80]}..." if long_description else "⚠️ No long description found")
                    print(f"🆔 Real case ID: {real_case_id}")
                
                # Store case data with case ID incorporated into long description
                enhanced_long_description = f"MUFON Case #{real_case_id}: {long_description}" if long_description else f"MUFON Case #{real_case_id}: {short_description}"
                
                case_data = {
                    "case_number": real_case_id,
                    "date_time": date_time,
                    "short_description": short_description,
                    "long_description": enhanced_long_description,
                    "location": location,
                    "media_files": media_files,
                    "row_index": i
                }
                cases.append(case_data)
                
                # Continue processing all cases - no timeout limit
                
            except Exception as e:
                print(f"❌ Error processing row {i}: {e}")
                continue
        
        # Save results
        output = {
            "search_type": "quick_results",
            "timestamp": datetime.now().isoformat(),
            "total_cases": len(cases),
            "cases": cases
        }
        
        filename = f"mufon_with_media_{datetime.now().strftime('%H_%M')}.json"
        with open(filename, "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\n🎉 Successfully extracted {len(cases)} MUFON cases with media!")
        print(f"💾 Saved to {filename}")
        
        browser.close()

if __name__ == "__main__":
    main()