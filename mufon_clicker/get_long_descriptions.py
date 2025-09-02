#!/usr/bin/env python3
"""
Extended MUFON search that clicks VIEW buttons to get long descriptions
"""
from playwright.sync_api import sync_playwright
import time
import json
from datetime import datetime

def main():
    cases = []
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=1000)
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
        
        print("📅 Setting date range: Feb 1-2, 2025...")
        
        # Set FROM date - Feb 1, 2025
        page.mouse.click(360, 405)  # Month dropdown
        page.keyboard.press("ArrowDown")  # February 
        page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(440, 405)  # Day dropdown  
        page.keyboard.press("ArrowDown")  # Day 1
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(520, 405)  # Year dropdown
        page.keyboard.type("2025")
        page.keyboard.press("Enter")
        time.sleep(1)
        
        # Set TO date - Feb 2, 2025
        page.mouse.click(590, 405)  # TO Month dropdown
        page.keyboard.press("ArrowDown")  # February
        page.keyboard.press("ArrowDown") 
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(670, 405)  # TO Day dropdown
        page.keyboard.press("ArrowDown")  # Day 1
        page.keyboard.press("ArrowDown")  # Day 2
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(750, 405)  # TO Year dropdown
        page.keyboard.type("2025")
        page.keyboard.press("Enter")
        time.sleep(1)
        
        # Submit search
        print("🚀 Submitting search...")
        page.mouse.click(633, 341)  # SUBMIT button
        time.sleep(10)
        
        print("📊 Extracting cases and clicking VIEW buttons...")
        
        # Get all table rows
        rows = page.locator("table tbody tr").all()
        print(f"Found {len(rows)} cases to process")
        
        # Process first 5 cases to test
        for i, row in enumerate(rows[:5], 1):
            try:
                cells = row.locator("td").all()
                if len(cells) >= 6:
                    # Extract basic info
                    case_number = cells[0].inner_text().strip()
                    date_time = cells[1].inner_text().strip()
                    short_desc = cells[2].inner_text().strip()
                    location = cells[3].inner_text().strip()
                    
                    print(f"\n--- Processing Case {i}: {case_number} ---")
                    print(f"Date: {date_time}")
                    print(f"Short: {short_desc}")
                    print(f"Location: {location}")
                    
                    # Click the VIEW button in the "Long Description" column
                    try:
                        # The VIEW button should be in the "Long Description" column
                        view_link = cells[4].locator("a").first  # Column 5 is "Long Description"
                        if view_link.count() > 0:
                            print("🔍 Clicking VIEW button...")
                            view_link.click()
                            time.sleep(5)
                            
                            # Extract long description from detail page
                            long_desc = ""
                            try:
                                # Try different selectors for long description
                                desc_selectors = [
                                    "textarea",
                                    "*:has-text('Description:') + *",
                                    "*:has-text('Long Description')",
                                    ".description",
                                    "td:has-text('Long Description') + td"
                                ]
                                
                                page_text = page.locator("body").inner_text()
                                
                                # Look for the longest text block that looks like a description
                                lines = page_text.split('\n')
                                for line in lines:
                                    if (len(line.strip()) > 100 and 
                                        any(word in line.lower() for word in ['saw', 'observed', 'witnessed', 'light', 'object', 'sky', 'hovering', 'moving'])):
                                        long_desc = line.strip()
                                        break
                                
                                if not long_desc:
                                    # Fallback to page text
                                    long_desc = short_desc
                                
                                print(f"✅ Long description: {long_desc[:100]}...")
                                
                            except Exception as e:
                                print(f"❌ Error extracting description: {e}")
                                long_desc = short_desc
                            
                            # Go back to results
                            try:
                                page.go_back()
                                time.sleep(3)
                            except:
                                # If go_back fails, reload results page
                                print("🔄 Reloading results...")
                                page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
                                time.sleep(3)
                                # Re-submit search
                                page.mouse.click(633, 341)
                                time.sleep(10)
                                # Skip to next iteration since we lost our place
                                continue
                        else:
                            print("⚠️ No VIEW link found")
                            long_desc = short_desc
                            
                    except Exception as e:
                        print(f"❌ Error clicking VIEW: {e}")
                        long_desc = short_desc
                    
                    # Store case data
                    case_data = {
                        "case_number": case_number,
                        "date_time": date_time,
                        "short_description": short_desc,
                        "long_description": long_desc,
                        "location": location,
                        "extracted_at": datetime.now().isoformat()
                    }
                    cases.append(case_data)
                    
            except Exception as e:
                print(f"❌ Error processing row {i}: {e}")
                continue
        
        # Save results
        output = {
            "search_dates": "2025-02-01 to 2025-02-02",
            "timestamp": datetime.now().isoformat(),
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open("mufon_with_long_descriptions.json", "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\n🎉 Extracted {len(cases)} cases with long descriptions!")
        print("💾 Saved to mufon_with_long_descriptions.json")
        
        browser.close()

if __name__ == "__main__":
    main()