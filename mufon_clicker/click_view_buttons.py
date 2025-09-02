#!/usr/bin/env python3
"""
Click VIEW buttons based on visual coordinates from the results table
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
        
        # Login and get to results page
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(2)
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # Set date range and submit (same as working script)
        page.mouse.click(360, 405)  # Month
        page.keyboard.press("ArrowDown")
        page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(440, 405)  # Day
        page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(520, 405)  # Year
        page.keyboard.type("2025")
        page.keyboard.press("Enter")
        time.sleep(1)
        
        page.mouse.click(590, 405)  # TO Month
        page.keyboard.press("ArrowDown")
        page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(670, 405)  # TO Day
        page.keyboard.press("ArrowDown")
        page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(750, 405)  # TO Year
        page.keyboard.type("2025")
        page.keyboard.press("Enter")
        time.sleep(1)
        
        page.mouse.click(633, 341)  # SUBMIT
        time.sleep(10)
        
        print("📊 Results loaded, clicking VIEW buttons...")
        
        # Based on the screenshot, VIEW buttons are in the rightmost column
        # Starting around Y=326 for first row, roughly 20px apart for each row
        # X coordinate around 670 for VIEW column
        
        view_coordinates = [
            (670, 326),   # Row 1
            (670, 348),   # Row 2  
            (670, 370),   # Row 3
            (670, 392),   # Row 4
            (670, 414),   # Row 5
            (670, 436),   # Row 6
            (670, 458),   # Row 7
            (670, 480),   # Row 8
            (670, 502),   # Row 9
            (670, 524),   # Row 10
        ]
        
        # Also try to extract text from each row before clicking
        for i, (x, y) in enumerate(view_coordinates, 1):
            try:
                print(f"\n--- Processing Case {i} ---")
                
                # First, try to extract row data by clicking on the row
                # Case number is usually in first column around x=70
                page.mouse.click(70, y)  # Click case number cell
                time.sleep(0.5)
                
                # Extract text from the row by getting the table row element
                row_element = page.locator(f"table tbody tr:nth-child({i})").first
                if row_element.count() > 0:
                    cells = row_element.locator("td").all()
                    if len(cells) >= 4:
                        case_number = cells[0].inner_text().strip()
                        date_time = cells[1].inner_text().strip() 
                        short_desc = cells[2].inner_text().strip()
                        location = cells[3].inner_text().strip()
                        
                        print(f"Case: {case_number}")
                        print(f"Date: {date_time}")
                        print(f"Description: {short_desc}")
                        print(f"Location: {location}")
                
                # Now click the VIEW button at coordinates
                print(f"🔍 Clicking VIEW button at ({x}, {y})...")
                page.mouse.click(x, y)
                time.sleep(5)
                
                # Extract long description from detail page
                long_desc = ""
                page_text = page.locator("body").inner_text()
                
                # Look for description text in the detail page
                lines = [line.strip() for line in page_text.split('\n') if len(line.strip()) > 50]
                for line in lines:
                    if any(word in line.lower() for word in ['observed', 'saw', 'witnessed', 'light', 'object', 'hovering', 'moving', 'sky']):
                        long_desc = line
                        break
                
                if long_desc:
                    print(f"✅ Long description: {long_desc[:150]}...")
                else:
                    long_desc = short_desc
                    print("⚠️ Using short description as fallback")
                
                # Store case data
                case_data = {
                    "case_number": case_number if 'case_number' in locals() else f"Case_{i}",
                    "date_time": date_time if 'date_time' in locals() else "Unknown",
                    "short_description": short_desc if 'short_desc' in locals() else "Unknown", 
                    "long_description": long_desc,
                    "location": location if 'location' in locals() else "Unknown",
                    "row_index": i
                }
                cases.append(case_data)
                
                # Go back to results
                page.go_back()
                time.sleep(3)
                
            except Exception as e:
                print(f"❌ Error processing row {i}: {e}")
                # Try to get back to results page
                try:
                    page.go_back()
                    time.sleep(2)
                except:
                    pass
                continue
        
        # Save results
        output = {
            "search_dates": "2025-02-01 to 2025-02-02",
            "timestamp": datetime.now().isoformat(),
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open("mufon_cases_with_views.json", "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\n🎉 Extracted {len(cases)} cases by clicking VIEW buttons!")
        print("💾 Saved to mufon_cases_with_views.json")
        
        browser.close()

if __name__ == "__main__":
    main()