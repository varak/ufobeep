#!/usr/bin/env python3
"""
Enhanced MUFON scraper to get actual case numbers and long descriptions
"""
import time, json, re
from datetime import datetime, timedelta
from pathlib import Path
from playwright.sync_api import sync_playwright

def extract_case_detail(page, row_index):
    """Extract detailed case information by clicking into case detail page"""
    try:
        print(f"   🔗 Clicking into case {row_index} detail...")
        
        # Get page content before navigation for debugging
        current_url = page.url
        
        # Click on the case row - usually the date cell has a link
        row = page.locator("table tr").nth(row_index)  # nth(0) is header, so nth(1) is first data row
        link = row.locator("a").first
        
        if link.count() == 0:
            print(f"   ❌ No link found in row {row_index}")
            return {"Case_Number": row_index, "Long_Description": ""}
        
        # Click the link
        link.click()
        page.wait_for_load_state("networkidle", timeout=10000)
        
        print(f"   📄 On detail page: {page.url}")
        
        # Extract actual case number
        page_text = page.locator("body").text_content()
        actual_case_number = row_index  # Default fallback
        
        # Look for real MUFON case number
        case_patterns = [
            r"Case\s*#?\s*(\d{6,})",
            r"MUFON\s*#?\s*(\d{6,})", 
            r"Report\s*ID\s*:?\s*(\d{6,})",
            r"CMS\s*#?\s*(\d{6,})"
        ]
        
        for pattern in case_patterns:
            match = re.search(pattern, page_text, re.IGNORECASE)
            if match:
                actual_case_number = match.group(1)
                print(f"   ✅ Found real case #: {actual_case_number}")
                break
        
        # Extract long description
        long_description = ""
        
        # Strategy 1: Look for description sections
        desc_elements = page.locator("div, p, td").all()
        for element in desc_elements:
            try:
                text = element.text_content().strip()
                # Look for substantial text that looks like a description
                if (len(text) > 100 and 
                    len(text) < 2000 and 
                    ("sighting" in text.lower() or 
                     "saw" in text.lower() or 
                     "observed" in text.lower() or
                     "witness" in text.lower())):
                    long_description = text
                    print(f"   ✅ Found description ({len(text)} chars)")
                    break
            except:
                continue
        
        # Strategy 2: If no good description found, take the largest text block
        if not long_description:
            try:
                largest_text = ""
                for element in desc_elements:
                    text = element.text_content().strip()
                    if len(text) > len(largest_text) and len(text) > 50:
                        largest_text = text
                
                if len(largest_text) > 100:
                    long_description = largest_text[:800]  # Limit length
                    print(f"   📝 Using largest text block ({len(largest_text)} chars)")
            except:
                pass
        
        # Return to results page
        page.go_back()
        page.wait_for_load_state("networkidle", timeout=8000)
        print(f"   ⬅️ Back to results")
        
        return {
            "Case_Number": actual_case_number,
            "Long_Description": long_description
        }
        
    except Exception as e:
        print(f"   ❌ Error extracting case {row_index}: {e}")
        # Try to get back to results
        try:
            if page.url != current_url:
                page.go_back()
                page.wait_for_load_state("networkidle", timeout=5000)
        except:
            pass
        return {"Case_Number": row_index, "Long_Description": ""}

def main():
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)  # Use headful for debugging
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        print("🚀 Enhanced MUFON Scraper - Getting Full Case Details")
        print("=" * 55)
        
        # Navigate through MUFON to get to search results
        print("Step 1: Navigating to MUFON search...")
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        
        # Click Track UFOs
        track_link = page.locator("text=Track UFOs").first
        if track_link.count() > 0:
            track_link.click()
            time.sleep(1)
        
        # Click Database Search  
        db_link = page.locator("text=Search Database").first
        if db_link.count() > 0:
            db_link.click()
            page.wait_for_load_state("networkidle")
        
        # Handle Terms and Conditions
        if "terms" in page.url.lower():
            agree_radio = page.locator("input[type='radio'][value*='agree']").first
            if agree_radio.count() > 0:
                agree_radio.check()
                print("✅ Agreed to terms")
        
        # Access search in iframe
        print("Step 2: Performing search...")
        iframe = page.locator("iframe").first
        if iframe.count() > 0:
            frame = page.frame_locator("iframe").first
            
            # Click TODAY to search recent cases
            today_btn = frame.locator("input[value='TODAY']").first
            if today_btn.count() > 0:
                today_btn.click()
                print("✅ Set date to TODAY")
            
            # Submit search
            submit_btn = frame.locator("input[value='SUBMIT']").first
            if submit_btn.count() > 0:
                submit_btn.click()
                page.wait_for_load_state("networkidle", timeout=15000)
                print("✅ Search submitted")
        
        print("Step 3: Extracting enhanced case data...")
        
        # Process results with enhanced detail extraction
        results_table = page.locator("table").first
        if results_table.count() == 0:
            print("❌ No results table found")
            return
        
        # Get all data rows (skip header)
        data_rows = results_table.locator("tr").all()[1:]
        print(f"📊 Found {len(data_rows)} cases to process")
        
        enhanced_cases = []
        
        for i, row in enumerate(data_rows, 1):
            print(f"\n--- Processing Case {i}/{len(data_rows)} ---")
            
            # Extract basic info from table row
            cells = row.locator("td").all()
            if len(cells) < 4:
                continue
                
            basic_case = {
                "Row_Number": i,
                "Date_Submitted": cells[0].text_content().strip(),
                "DateTime_Event": cells[1].text_content().strip(),
                "Short_Description": cells[2].text_content().strip(),
                "Location": cells[3].text_content().strip(),
                "Attachments": cells[4].text_content().strip() if len(cells) > 4 else ""
            }
            
            print(f"   📝 {basic_case['Short_Description'][:60]}")
            
            # Get enhanced details by clicking into the case
            enhanced_details = extract_case_detail(page, i)
            
            # Combine basic and enhanced data
            final_case = {**basic_case, **enhanced_details}
            
            # Parse media attachments
            attachments_media = []
            if final_case["Attachments"]:
                files = [f.strip() for f in final_case["Attachments"].split('\n') if f.strip()]
                for filename in files:
                    if filename and '.' in filename:
                        # Construct media URL (pattern observed from existing data)
                        media_url = f"http://mufoncms.com/cgi-bin/ffplay.pl?file={filename.replace('.', '_').replace(' ', '_')}"
                        attachments_media.append({
                            "filename": filename,
                            "url": media_url
                        })
            
            final_case["Attachments_media"] = attachments_media
            enhanced_cases.append(final_case)
            
            # Add delay to be respectful
            time.sleep(1)
        
        # Save enhanced results
        output = {
            "timestamp": datetime.now().isoformat(),
            "url": page.url,
            "title": "MUFON Enhanced Search Results",
            "total_cases": len(enhanced_cases),
            "cases": enhanced_cases
        }
        
        output_file = Path("mufon_enhanced_results.json")
        with open(output_file, "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\n🎉 Saved {len(enhanced_cases)} enhanced cases to {output_file}")
        
        # Print summary
        for case in enhanced_cases:
            print(f"  - MUFON #{case['Case_Number']}: {case['Short_Description'][:50]}")
            if case['Long_Description']:
                print(f"    📖 Has long description ({len(case['Long_Description'])} chars)")
        
        # Save session state
        context.storage_state(path=str(state_file))
        browser.close()

if __name__ == "__main__":
    main()