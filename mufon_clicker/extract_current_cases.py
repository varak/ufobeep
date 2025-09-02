#!/usr/bin/env python3
"""
Extract the current MUFON cases with long descriptions
"""
from playwright.sync_api import sync_playwright
import json
import time

def main():
    cases = []
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state="mufon_artifacts/storage_state.json")
        page = context.new_page()
        
        print("🔑 Loading MUFON cases...")
        page.goto("https://mufoncms.com/last_20_public.html", wait_until="domcontentloaded")
        time.sleep(3)
        
        # Extract cases from table
        rows = page.locator("table tr").all()[1:]  # Skip header
        
        print(f"📊 Processing {len(rows)} cases...")
        
        for i, row in enumerate(rows[:3]):  # Focus on first 3 current cases
            try:
                cells = row.locator("td").all()
                if len(cells) >= 5:
                    case_number = cells[0].inner_text().strip()
                    date_submitted = cells[1].inner_text().strip()
                    date_event = cells[2].inner_text().strip() 
                    short_desc = cells[3].inner_text().strip()
                    location_cell = cells[4].inner_text().strip()
                    attachments = cells[6].inner_text().strip() if len(cells) > 6 else ""
                    
                    print(f"\n--- Case {case_number} ---")
                    print(f"Date: {date_event}")
                    print(f"Description: {short_desc}")
                    print(f"Location: {location_cell}")
                    
                    # Click case number to get long description
                    case_link = cells[0].locator("a").first if cells[0].locator("a").count() > 0 else None
                    long_description = ""
                    
                    if case_link:
                        try:
                            print("🔍 Clicking for long description...")
                            case_link.click()
                            page.wait_for_load_state("domcontentloaded", timeout=10000)
                            time.sleep(2)
                            
                            # Extract long description from detail page
                            detail_content = page.content()
                            
                            # Look for description patterns
                            desc_text = page.locator("body").inner_text()
                            lines = desc_text.split('\n')
                            
                            # Find substantial description line
                            for line in lines:
                                line = line.strip()
                                if (len(line) > 100 and 
                                    'description' not in line.lower()[:20] and
                                    'mufon' not in line.lower() and
                                    not line.isdigit()):
                                    long_description = line
                                    break
                            
                            if long_description:
                                print(f"✅ Long description: {len(long_description)} chars")
                            else:
                                print("❌ No long description found")
                            
                            # Go back to list
                            page.go_back()
                            time.sleep(1)
                            
                        except Exception as e:
                            print(f"❌ Error getting long description: {e}")
                    
                    # Parse attachments
                    media_files = []
                    if attachments and attachments != "0":
                        attachment_lines = attachments.split('\n')
                        for att in attachment_lines:
                            if att.strip() and '.' in att:
                                media_files.append({
                                    "filename": att.strip(),
                                    "url": f"http://mufoncms.com/cgi-bin/ffplay.pl?file={case_number}_submitter_file_{att.strip()}"
                                })
                    
                    case_data = {
                        "Case_Number": case_number,
                        "Date_Submitted": date_submitted,
                        "DateTime_Event": date_event,
                        "Short_Description": short_desc,
                        "Long_Description": long_description,
                        "Location": location_cell,
                        "Attachments": attachments,
                        "Attachments_media": media_files
                    }
                    
                    cases.append(case_data)
                    
            except Exception as e:
                print(f"❌ Error processing row {i}: {e}")
        
        # Save results
        output = {
            "timestamp": "2025-09-02T03:30:00.000000",
            "url": "https://mufoncms.com/last_20_public.html", 
            "title": "MUFON Current Cases",
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open("mufon_current_results.json", "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\n🎉 Extracted {len(cases)} current MUFON cases!")
        print("💾 Saved to mufon_current_results.json")
        
        # Update the extend script to use this data
        with open("extend_mufon_details.py", "r") as f:
            extend_script = f.read()
        
        extend_script = extend_script.replace('JSON_PATH = "mufon_working_results.json"', 'JSON_PATH = "mufon_current_results.json"')
        
        with open("extend_mufon_details.py", "w") as f:
            f.write(extend_script)
        
        print("✅ Updated extend script to use current results")
        
        browser.close()

if __name__ == "__main__":
    main()