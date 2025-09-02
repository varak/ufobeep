#!/usr/bin/env python3
"""
Complete MUFON scraper that gets real case numbers and long descriptions
Based on working_mufon_search.py but enhanced to click into each case
"""
import time, json, re
from datetime import datetime, timedelta
from pathlib import Path
from playwright.sync_api import sync_playwright

def extract_case_details(page, row, row_index):
    """Click into a case and extract detailed information"""
    try:
        print(f"   🔗 Extracting details for case {row_index}...")
        
        # Find clickable link in the row
        case_link = None
        cells = row.locator("td").all()
        
        # Look for links in first few cells (usually date or description)
        for i in range(min(3, len(cells))):
            link = cells[i].locator("a").first
            if link.count() > 0:
                case_link = link
                break
        
        if not case_link:
            print(f"   ⚠️ No clickable link found")
            return {"Case_Number": row_index, "Long_Description": ""}
        
        # Store current URL to return to
        results_url = page.url
        
        # Click into case detail
        case_link.click()
        page.wait_for_load_state("networkidle", timeout=10000)
        
        # Extract real case number
        page_content = page.locator("body").text_content()
        actual_case_number = row_index  # Default fallback
        
        # Look for real MUFON case numbers
        case_number_patterns = [
            r"Case\s*#?\s*(\d{6,})",
            r"MUFON\s*#?\s*(\d{6,})",
            r"Report\s*#?\s*(\d{6,})",
            r"CMS\s*ID\s*:?\s*(\d{6,})",
            r"(\d{6,})"  # Fallback: any 6+ digit number
        ]
        
        for pattern in case_number_patterns:
            matches = re.findall(pattern, page_content, re.IGNORECASE)
            if matches:
                # Take the first reasonable case number (6+ digits)
                for match in matches:
                    if len(match) >= 6:
                        actual_case_number = match
                        print(f"   ✅ Found real case number: {actual_case_number}")
                        break
                break
        
        # Extract long description
        long_description = ""
        
        # Strategy 1: Look for textarea fields (most likely to contain long description)
        textareas = page.locator("textarea").all()
        for textarea in textareas:
            text = textarea.text_content().strip()
            if len(text) > 100:  # Must be substantial
                long_description = text
                print(f"   📝 Found description in textarea ({len(text)} chars)")
                break
        
        # Strategy 2: Look for specific description sections
        if not long_description:
            desc_sections = page.locator("div, td").all()
            for section in desc_sections:
                try:
                    text = section.text_content().strip()
                    # Look for text that contains witness keywords and is substantial
                    if (200 < len(text) < 2000 and 
                        any(word in text.lower() for word in 
                            ['witnessed', 'observed', 'saw', 'sighting', 'report', 'description'])):
                        long_description = text
                        print(f"   📖 Found description by content match ({len(text)} chars)")
                        break
                except:
                    continue
        
        # Strategy 3: Take the largest text block as fallback
        if not long_description:
            try:
                all_text_elements = page.locator("div, p, td").all()
                largest_text = ""
                for elem in all_text_elements:
                    text = elem.text_content().strip()
                    if len(text) > len(largest_text) and 100 < len(text) < 3000:
                        largest_text = text
                
                if largest_text:
                    long_description = largest_text
                    print(f"   📄 Using largest text block ({len(largest_text)} chars)")
            except:
                pass
        
        # Limit description length
        if long_description:
            long_description = long_description[:1200]  # Reasonable limit
        
        # Return to results page
        print(f"   ⬅️ Returning to results...")
        page.go_back()
        page.wait_for_load_state("networkidle", timeout=8000)
        
        # Verify we're back (and navigate back if needed)
        if page.url != results_url:
            try:
                page.goto(results_url)
                page.wait_for_load_state("networkidle", timeout=10000)
            except:
                pass
        
        return {
            "Case_Number": actual_case_number,
            "Long_Description": long_description
        }
        
    except Exception as e:
        print(f"   ❌ Error extracting details: {e}")
        # Try to get back to results
        try:
            page.go_back()
            page.wait_for_load_state("networkidle", timeout=5000)
        except:
            pass
        return {"Case_Number": row_index, "Long_Description": ""}

def main():
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        print("🔍 MUFON Complete Case Extractor")
        print("=================================")
        
        # Navigate to MUFON and get to search results (reuse working navigation)
        print("Step 1: Navigating to MUFON...")
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        
        # Click Track UFOs
        track_ufos = page.locator("text=Track UFOs").first
        if track_ufos.count() > 0:
            track_ufos.click()
            time.sleep(1)
            print("✅ Clicked Track UFOs")
        
        # Click Database Search
        db_search = page.locator("text=Search Database").first
        if db_search.count() > 0:
            db_search.click()
            page.wait_for_load_state("networkidle")
            print("✅ Clicked Database Search")
        
        # Handle Terms and Conditions if present
        if "terms" in page.url.lower():
            print("Step 2: Handling Terms and Conditions...")
            agree_radio = page.locator("input[type='radio'][value*='agree']").first
            if agree_radio.count() > 0:
                agree_radio.check()
                print("✅ Agreed to terms")
        
        # Access search form in iframe and perform search
        print("Step 3: Performing search...")
        iframe = page.locator("iframe").first
        if iframe.count() > 0:
            frame = page.frame_locator("iframe").first
            
            # Set date to TODAY
            today_btn = frame.locator("input[value='TODAY']").first
            if today_btn.count() > 0:
                today_btn.click()
                print("✅ Set search to TODAY")
            
            # Submit search
            submit_btn = frame.locator("input[value='SUBMIT']").first
            if submit_btn.count() > 0:
                submit_btn.click()
                page.wait_for_load_state("networkidle", timeout=15000)
                print("✅ Search submitted")
        
        # Extract and enhance case data
        print("Step 4: Extracting complete case data...")
        
        results_table = page.locator("table").first
        if results_table.count() == 0:
            print("❌ No results table found")
            return
        
        case_rows = results_table.locator("tr").all()[1:]  # Skip header
        print(f"📊 Processing {len(case_rows)} cases...")
        
        complete_cases = []
        
        for i, row in enumerate(case_rows, 1):
            print(f"\n--- Case {i}/{len(case_rows)} ---")
            
            # Extract basic table data
            cells = row.locator("td").all()
            if len(cells) < 4:
                continue
            
            basic_info = {
                "Row_Number": i,
                "Date_Submitted": cells[0].text_content().strip(),
                "DateTime_Event": cells[1].text_content().strip(),
                "Short_Description": cells[2].text_content().strip(),
                "Location": cells[3].text_content().strip(),
                "Attachments": cells[4].text_content().strip() if len(cells) > 4 else ""
            }
            
            print(f"   📝 {basic_info['Short_Description'][:60]}")
            
            # Extract detailed info by clicking into the case
            detailed_info = extract_case_details(page, row, i)
            
            # Combine all information
            complete_case = {**basic_info, **detailed_info}
            
            # Process media attachments
            attachments_media = []
            if complete_case["Attachments"]:
                attachment_files = [f.strip() for f in complete_case["Attachments"].split('\n') if f.strip()]
                for filename in attachment_files:
                    if filename and '.' in filename:
                        # Construct media URL based on pattern from working cases
                        media_url = f"http://mufoncms.com/cgi-bin/ffplay.pl?file={filename}"
                        attachments_media.append({
                            "filename": filename,
                            "url": media_url
                        })
            
            complete_case["Attachments_media"] = attachments_media
            complete_cases.append(complete_case)
            
            # Brief pause to be respectful
            time.sleep(1.5)
        
        # Save complete results
        output = {
            "timestamp": datetime.now().isoformat(),
            "url": page.url,
            "title": "MUFON Complete Case Extraction",
            "total_cases": len(complete_cases),
            "cases": complete_cases
        }
        
        output_file = Path("mufon_complete_results.json")
        with open(output_file, "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\n🎉 Extraction complete! Saved to {output_file}")
        print(f"📊 Total cases: {len(complete_cases)}")
        
        # Summary report
        for case in complete_cases:
            case_num = case.get('Case_Number', 'Unknown')
            desc_len = len(case.get('Long_Description', ''))
            media_count = len(case.get('Attachments_media', []))
            print(f"  - #{case_num}: {case['Short_Description'][:50]} "
                  f"[{desc_len} chars desc, {media_count} media]")
        
        # Save session state
        context.storage_state(path=str(state_file))
        browser.close()

if __name__ == "__main__":
    main()