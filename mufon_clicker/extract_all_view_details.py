#!/usr/bin/env python3
"""
Extract all MUFON cases with VIEW details for complete import
"""
from playwright.sync_api import sync_playwright
import time
import json
from datetime import datetime

def main():
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
        
        # Set Feb 1, 2025 ONLY (same FROM and TO date)
        print("📅 Setting single date: Feb 1, 2025")
        page.mouse.click(360, 405); page.keyboard.press("ArrowDown"); page.keyboard.press("ArrowDown"); page.keyboard.press("Enter"); time.sleep(0.5)
        page.mouse.click(440, 405); page.keyboard.press("ArrowDown"); page.keyboard.press("Enter"); time.sleep(0.5)
        page.mouse.click(520, 405); page.keyboard.type("2025"); page.keyboard.press("Enter"); time.sleep(1)
        page.mouse.click(590, 405); page.keyboard.press("ArrowDown"); page.keyboard.press("ArrowDown"); page.keyboard.press("Enter"); time.sleep(0.5)
        page.mouse.click(670, 405); page.keyboard.press("ArrowDown"); page.keyboard.press("Enter"); time.sleep(0.5)
        page.mouse.click(750, 405); page.keyboard.type("2025"); page.keyboard.press("Enter"); time.sleep(1)
        page.mouse.click(633, 341); time.sleep(10)
        
        print("📊 Results loaded, extracting all cases...")
        
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
                date_time = cells[1].inner_text().strip()
                short_description = cells[2].inner_text().strip()
                location = cells[3].inner_text().strip()
                
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
                    
                    # Check for popup or navigation
                    long_description = ""
                    if len(page.context.pages) > 1:
                        # Popup approach
                        popup = page.context.pages[-1]
                        popup.wait_for_load_state()
                        detail_content = popup.locator("body").inner_text()
                        popup.close()
                        
                        # Extract long description from popup content
                        lines = [line.strip() for line in detail_content.split('\\n') if len(line.strip()) > 20]
                        for line in lines:
                            if "Long Description" in line:
                                continue
                            if any(word in line.lower() for word in ['observed', 'saw', 'witnessed', 'light', 'object', 'hovering', 'moving', 'sky', 'appeared', 'noticed', 'round', 'metalic', 'sphere', 'flew', 'traveling']):
                                long_description = line
                                break
                        
                        if not long_description and lines:
                            # Use the longest meaningful line as fallback
                            long_description = max([l for l in lines if len(l) > 30], key=len, default="")
                    
                    print(f"📖 Long description: {long_description[:80]}..." if long_description else "⚠️ No long description found")
                
                # Store case data
                case_data = {
                    "case_number": case_number,
                    "date_time": date_time,
                    "short_description": short_description,
                    "long_description": long_description if long_description else short_description,
                    "location": location,
                    "row_index": i
                }
                cases.append(case_data)
                
            except Exception as e:
                print(f"❌ Error processing row {i}: {e}")
                continue
        
        # Save results
        output = {
            "search_dates": "2025-02-01",
            "timestamp": datetime.now().isoformat(),
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open("mufon_complete_extraction.json", "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\\n🎉 Successfully extracted {len(cases)} complete MUFON cases!")
        print("💾 Saved to mufon_complete_extraction.json")
        
        # Show sample of what we got
        if cases:
            print("\\n📋 Sample case:")
            sample = cases[0]
            for key, value in sample.items():
                print(f"  {key}: {str(value)[:100]}...")
        
        browser.close()

if __name__ == "__main__":
    main()