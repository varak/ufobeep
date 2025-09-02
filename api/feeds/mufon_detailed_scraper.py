#!/usr/bin/env python3
"""
Enhanced MUFON scraper that clicks into each case detail to get actual case numbers and long descriptions
"""
import time, json, re
from datetime import datetime, timedelta
from pathlib import Path
from playwright.sync_api import sync_playwright

def extract_case_details(page, case_row_element):
    """Click into a case row and extract detailed information"""
    try:
        # Get the link from the case row (usually the first cell)
        case_link = case_row_element.locator("td a").first
        if case_link.count() == 0:
            print("   ❌ No link found in case row")
            return None
            
        # Click to open case details
        case_link.click()
        page.wait_for_load_state("networkidle", timeout=10000)
        
        # Extract detailed case information
        case_details = {
            "url": page.url,
            "html_content": page.content()[:5000]  # First 5k chars for debugging
        }
        
        # Try to find actual case number in the detail page
        case_number_patterns = [
            r"Case\s*#?\s*(\d{6,})",  # Case #123456
            r"MUFON\s*#?\s*(\d{6,})",  # MUFON #123456  
            r"Report\s*#?\s*(\d{6,})", # Report #123456
            r"ID\s*:?\s*(\d{6,})"     # ID: 123456
        ]
        
        page_text = page.locator("body").text_content()
        actual_case_number = None
        
        for pattern in case_number_patterns:
            match = re.search(pattern, page_text, re.IGNORECASE)
            if match:
                actual_case_number = match.group(1)
                print(f"   ✅ Found actual case number: {actual_case_number}")
                break
        
        # Extract long description
        long_description = ""
        description_selectors = [
            "div:has-text('Description')",
            "div:has-text('Long Description')",
            "div:has-text('Details')",
            "textarea[name*='description']",
            "div.description",
            ".case-description"
        ]
        
        for selector in description_selectors:
            try:
                desc_element = page.locator(selector).first
                if desc_element.count() > 0:
                    desc_text = desc_element.text_content()
                    if len(desc_text.strip()) > 50:  # Only take substantial descriptions
                        long_description = desc_text.strip()
                        print(f"   ✅ Found long description ({len(long_description)} chars)")
                        break
            except:
                continue
        
        # Try to get description from any large text block
        if not long_description:
            try:
                # Look for the largest text block that might be the description
                text_blocks = page.locator("div, p").all()
                for block in text_blocks:
                    text = block.text_content().strip()
                    if len(text) > 100 and len(text) < 2000:  # Reasonable description length
                        long_description = text
                        print(f"   ✅ Found description from text block ({len(long_description)} chars)")
                        break
            except:
                pass
        
        case_details.update({
            "actual_case_number": actual_case_number,
            "long_description": long_description,
            "page_title": page.title(),
        })
        
        # Go back to search results
        page.go_back()
        page.wait_for_load_state("networkidle", timeout=10000)
        
        return case_details
        
    except Exception as e:
        print(f"   ❌ Error extracting case details: {e}")
        # Try to go back if we're stuck
        try:
            page.go_back()
            page.wait_for_load_state("networkidle", timeout=5000)
        except:
            pass
        return None

def main():
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        print("🔍 Enhanced MUFON Case Scraper")
        print("===============================")
        
        # Navigate to search results (reuse existing navigation logic)
        print("Step 1: Going to MUFON homepage...")
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        
        print("\nStep 2: Looking for Track UFOs...")
        track_ufos_clicked = False
        for selector in ["text=Track UFOs", "text=TRACK UFOS", "text=Track UFO's"]:
            try:
                element = page.locator(selector).first
                if element.count() > 0:
                    element.click()
                    time.sleep(1)
                    print(f"✅ Clicked {selector}")
                    track_ufos_clicked = True
                    break
            except:
                continue
        
        print("\nStep 3: Looking for Database Search...")
        db_search_clicked = False
        for selector in ["text=Database Search", "text=Search Database", "text=Case Search"]:
            try:
                element = page.locator(selector).first
                if element.count() > 0:
                    element.click()
                    page.wait_for_load_state("networkidle")
                    print(f"✅ Clicked {selector}")
                    db_search_clicked = True
                    break
            except Exception as e:
                print(f"Failed {selector}: {e}")
        
        if not db_search_clicked:
            print("❌ Could not find Database Search, trying direct URL...")
            page.goto("https://mufon.com/search_database-terms-and-conditions/", wait_until="networkidle")
        
        # Handle Terms and Conditions
        if "terms" in page.url.lower():
            print("\nStep 4: Handling Terms and Conditions...")
            try:
                agree_radio = page.locator("input[type='radio'][value*='agree']").first
                if agree_radio.count() > 0:
                    agree_radio.check()
                    print("✅ Checked 'I Agree'")
                    
                    # Submit the form
                    submit_btn = page.locator("input[type='submit'], button[type='submit']").first
                    if submit_btn.count() > 0:
                        submit_btn.click()
                        page.wait_for_load_state("networkidle")
                        print("✅ Submitted terms agreement")
            except Exception as e:
                print(f"❌ Terms handling error: {e}")
        
        # Navigate to search form in iframe
        print("\nStep 5: Accessing search form...")
        try:
            iframe = page.locator("iframe").first
            if iframe.count() > 0:
                frame = page.frame_locator("iframe").first
                
                # Fill search criteria (search recent cases)
                print("✅ Found search iframe")
                
                # Click TODAY button to search today's cases
                today_btn = frame.locator("input[value='TODAY']").first
                if today_btn.count() > 0:
                    today_btn.click()
                    print("✅ Clicked TODAY button")
                else:
                    print("❌ TODAY button not found")
                
                # Submit search
                submit_btn = frame.locator("input[value='SUBMIT'], input[type='submit']").first
                if submit_btn.count() > 0:
                    submit_btn.click()
                    page.wait_for_load_state("networkidle", timeout=15000)
                    print("✅ Submitted search")
                else:
                    print("❌ Submit button not found")
        
        except Exception as e:
            print(f"❌ Search form error: {e}")
        
        # Extract and enhance case results
        print("\nStep 6: Extracting detailed case information...")
        
        try:
            # Look for results table
            results_table = page.locator("table").first
            if results_table.count() == 0:
                print("❌ No results table found")
                return
            
            # Get all case rows (skip header)
            case_rows = results_table.locator("tr").all()[1:]  # Skip header row
            print(f"📊 Found {len(case_rows)} case rows")
            
            detailed_cases = []
            
            for i, row in enumerate(case_rows, 1):
                print(f"\n--- Processing Case Row {i} ---")
                
                # Extract basic info from row first
                cells = row.locator("td").all()
                if len(cells) < 4:
                    print(f"   ⚠️ Row {i} has insufficient columns")
                    continue
                
                # Basic case data from table row
                case_data = {
                    "Row_Number": i,
                    "Date_Submitted": cells[0].text_content().strip() if cells[0] else "",
                    "DateTime_Event": cells[1].text_content().strip() if cells[1] else "",
                    "Short_Description": cells[2].text_content().strip() if cells[2] else "",
                    "Location": cells[3].text_content().strip() if cells[3] else "",
                    "Attachments": cells[4].text_content().strip() if len(cells) > 4 and cells[4] else ""
                }
                
                print(f"   Basic: {case_data['Short_Description'][:50]}...")
                
                # Extract detailed information by clicking into the case
                case_details = extract_case_details(page, row)
                
                if case_details:
                    case_data.update({
                        "Actual_Case_Number": case_details.get("actual_case_number"),
                        "Long_Description": case_details.get("long_description", ""),
                        "Detail_URL": case_details.get("url", ""),
                    })
                
                # Extract media files if any
                attachments_media = []
                if case_data["Attachments"]:
                    # Parse attachment filenames and try to construct URLs
                    attachment_files = [f.strip() for f in case_data["Attachments"].split('\n') if f.strip()]
                    for filename in attachment_files:
                        if filename and '.' in filename:
                            # Construct likely media URL (may need adjustment)
                            media_url = f"http://mufoncms.com/cgi-bin/ffplay.pl?file={filename}"
                            attachments_media.append({
                                "filename": filename,
                                "url": media_url
                            })
                
                case_data["Attachments_media"] = attachments_media
                
                detailed_cases.append(case_data)
                
                # Small delay to be respectful
                time.sleep(0.5)
            
            # Save detailed results
            results = {
                "timestamp": datetime.now().isoformat(),
                "url": page.url,
                "title": page.title(),
                "total_cases": len(detailed_cases),
                "cases": detailed_cases
            }
            
            output_file = Path("mufon_detailed_results.json")
            with open(output_file, "w") as f:
                json.dump(results, f, indent=2)
            
            print(f"\n✅ Saved {len(detailed_cases)} detailed cases to {output_file}")
            
            # Print summary
            for case in detailed_cases:
                actual_num = case.get("Actual_Case_Number", "Unknown")
                print(f"  - Row {case['Row_Number']}: MUFON #{actual_num} - {case['Short_Description'][:50]}")
        
        except Exception as e:
            print(f"❌ Results extraction error: {e}")
        
        finally:
            # Save storage state for next run
            context.storage_state(path=str(state_file))
            browser.close()

if __name__ == "__main__":
    main()