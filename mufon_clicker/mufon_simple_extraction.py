#!/usr/bin/env python3
"""
Simple MUFON extraction using exact form field knowledge
Usage: python mufon_simple_extraction.py 2025-01-27
"""
import sys
import os
from playwright.sync_api import sync_playwright
import time
import json
from datetime import datetime

def extract_mufon_date(date_str):
    """Extract MUFON cases for specific date using known form structure"""
    
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    month = date_obj.month
    day = date_obj.day  
    year = date_obj.year
    
    print(f"🎯 MUFON Simple Extraction for {date_str}")
    print(f"📅 Target: {month}/{day}/{year}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, slow_mo=500)
        context = browser.new_context()
        page = context.new_page()
        
        # Login
        print("🔐 Logging in...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(2)
        # Get credentials from environment variables
        mufon_user = os.getenv('MUFON_USERNAME')
        mufon_pass = os.getenv('MUFON_PASSWORD')
        
        if not mufon_user or not mufon_pass:
            print("❌ MUFON credentials not found in environment variables")
            print("Set MUFON_USERNAME and MUFON_PASSWORD environment variables")
            browser.close()
            return None
            
        page.fill("input[name='loginName']", mufon_user)
        page.fill("input[name='loginPassword']", mufon_pass)
        page.click("text=Log In")
        time.sleep(5)
        
        # Go to search page
        print("🔍 Going to search page...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # Get iframe
        iframe = page.frame_locator("iframe")
        
        # Set date fields using exact selectors
        print(f"📅 Setting date fields...")
        
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
        time.sleep(0.2)
        
        print(f"✅ Date fields set to {month}/{day}/{year}")
        
        # Submit search
        print("🚀 Submitting search...")
        iframe.locator("input[type='submit'][value='SUBMIT']").first.click()
        time.sleep(10)
        
        # Take screenshot
        page.screenshot(path=f"simple_results_{date_str.replace('-', '_')}.png")
        print("📸 Screenshot saved")
        
        # Count results
        rows = iframe.locator("table tbody tr").all()
        result_count = len(rows)
        
        print(f"📊 Found {result_count} results")
        
        # Extract all cases with media and long descriptions
        cases = []
        visited_cases = set()
        
        for i, row in enumerate(rows, 1):  # Process ALL rows
            try:
                cells = row.locator("td").all()
                if len(cells) >= 4:
                    case_number = cells[0].inner_text().strip()
                    date_time = cells[1].inner_text().strip()
                    short_description = cells[2].inner_text().strip()
                    location = cells[3].inner_text().strip()
                    
                    # Skip duplicates
                    if case_number in visited_cases:
                        continue
                    visited_cases.add(case_number)
                    
                    print(f"\n--- Processing Case {i}: #{case_number} ---")
                    
                    # Extract media files from attachments column (usually last column)
                    media_files = []
                    if len(cells) > 4:
                        attachments_cell = cells[-1]  # Last column
                        attachment_text = attachments_cell.inner_text().strip()
                        
                        if attachment_text and attachment_text != "":
                            print(f"   📎 Found attachments: {attachment_text}")
                            
                            # Look for attachment links
                            attachment_links = attachments_cell.locator('a')
                            link_count = attachment_links.count()
                            
                            if link_count > 0:
                                print(f"   🔗 Processing {link_count} attachment links...")
                                for j in range(link_count):
                                    try:
                                        link = attachment_links.nth(j)
                                        filename = link.inner_text().strip()
                                        href = link.get_attribute('href')
                                        
                                        if filename and any(ext in filename.lower() for ext in ['.jpg', '.png', '.mp4', '.mov', '.jpeg', '.gif']):
                                            # Ensure HTTPS URLs for media files
                                            if href:
                                                if not href.startswith('http'):
                                                    href = f"https://mufoncms.com{href}"
                                                elif href.startswith('http://'):
                                                    href = href.replace('http://', 'https://')
                                            
                                            file_type = "image" if any(ext in filename.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif']) else "video"
                                            
                                            media_files.append({
                                                "filename": filename,
                                                "url": href,
                                                "type": file_type
                                            })
                                            print(f"   ✅ Found {file_type}: {filename}")
                                        
                                    except Exception as e:
                                        print(f"   ❌ Media error: {e}")
                                        continue
                    
                    # Get long description and real case ID from VIEW button
                    long_description = ""
                    real_case_id = case_number  # fallback to current
                    view_button = row.locator("input[value='VIEW']")
                    
                    if view_button.count() > 0:
                        # Extract real MUFON case ID from VIEW button onclick/form action
                        try:
                            onclick_attr = view_button.get_attribute('onclick')
                            if onclick_attr and 'id=' in onclick_attr:
                                # Extract case ID from onclick like "viewCase('12345')" or similar
                                import re
                                case_id_match = re.search(r'id=(\d+)', onclick_attr)
                                if case_id_match:
                                    real_case_id = case_id_match.group(1)
                                    print(f"   🆔 Extracted real MUFON case ID: {real_case_id}")
                        except Exception as e:
                            print(f"   ⚠️  Could not extract case ID from VIEW button: {e}")
                        
                        print(f"   🔍 Clicking VIEW for long description...")
                        try:
                            view_button.click()
                            time.sleep(3)
                            
                            # Check for popup window
                            if len(page.context.pages) > 1:
                                popup = page.context.pages[-1]
                                popup.wait_for_load_state()
                                
                                # Extract long description from popup
                                detail_content = popup.locator("body").inner_text()
                                popup.close()
                                
                                # Parse long description
                                lines = [line.strip() for line in detail_content.split('\\n') if len(line.strip()) > 20]
                                
                                # Look for descriptive content
                                for line in lines:
                                    if "Long Description" in line:
                                        continue  # Skip the header
                                    if any(word in line.lower() for word in ['observed', 'saw', 'witnessed', 'light', 'object', 'hovering', 'moving', 'sky', 'appeared', 'noticed', 'driving', 'looked']):
                                        long_description = line
                                        break
                                
                                # If no descriptive line found, use longest line
                                if not long_description and lines:
                                    long_description = max([l for l in lines if len(l) > 30], key=len, default="")
                                
                                if long_description:
                                    print(f"   📖 Long description: {long_description[:80]}...")
                                else:
                                    print(f"   ⚠️  No long description found")
                                    
                        except Exception as e:
                            print(f"   ❌ VIEW button error: {e}")
                    
                    case_data = {
                        "case_number": real_case_id,  # Use real MUFON case ID
                        "date_time": date_time,
                        "short_description": short_description,
                        "long_description": long_description if long_description else short_description,
                        "location": location,
                        "media_files": media_files,
                        "row_index": i
                    }
                    
                    cases.append(case_data)
                    print(f"   ✅ Complete: #{case_number}, Media: {len(media_files)}")
                    
            except Exception as e:
                print(f"❌ Error processing row {i}: {e}")
                continue
        
        # Save results in format expected by import script
        output = {
            "search_date": date_str,
            "timestamp": datetime.now().isoformat(),
            "total_cases": len(cases),  # Imported cases, not total found
            "cases": cases
        }
        
        filename = f"mufon_simple_{date_str.replace('-', '_')}.json"
        with open(filename, "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"💾 Results saved to {filename}")
        print(f"🎉 Successfully extracted data for {date_str} - {result_count} total results")
        
        # Keep browser open briefly to show results
        print("⏸️ Browser will close in 5 seconds...")
        time.sleep(5)
        
        browser.close()
        return filename

def main():
    if len(sys.argv) != 2:
        print("Usage: python mufon_simple_extraction.py YYYY-MM-DD")
        sys.exit(1)
    
    date_str = sys.argv[1]
    extract_mufon_date(date_str)

if __name__ == "__main__":
    main()