#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import time
import json
from datetime import datetime

def main():
    cases = []
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        
        # Login
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(2)
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        
        # Go to search page and perform search again
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        print("🎯 Performing search to get results...")
        # Set dates
        page.mouse.click(360, 405)  # Month dropdown
        page.keyboard.press("ArrowDown")
        page.keyboard.press("ArrowDown") 
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(440, 405)  # Day dropdown
        page.keyboard.press("ArrowDown")
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        page.mouse.click(520, 405)  # Year dropdown
        page.keyboard.type("2025")
        page.keyboard.press("Enter")
        time.sleep(1)
        
        # Submit search
        page.mouse.click(633, 341)  # SUBMIT button
        time.sleep(10)
        
        print("✅ Got search results, now extracting case data...")
        
        # Find all table rows (skip header)
        rows = page.locator("table tbody tr").all()
        print(f"📊 Found {len(rows)} case rows")
        
        # Extract first 5 cases to test
        for i, row in enumerate(rows[:5], 1):
            try:
                # Extract basic info from the row
                cells = row.locator("td").all()
                if len(cells) >= 7:
                    case_number = cells[0].inner_text().strip()
                    date_submitted = cells[1].inner_text().strip()
                    short_desc = cells[2].inner_text().strip()
                    location = cells[3].inner_text().strip()
                    
                    print(f"\n--- Processing Case {case_number} ---")
                    print(f"Date: {date_submitted}")
                    print(f"Description: {short_desc}")
                    print(f"Location: {location}")
                    
                    # Click the VIEW button in the last column
                    view_button = cells[-1].locator("a:has-text('VIEW'), button:has-text('VIEW')").first
                    if view_button.count() > 0:
                        print("🔍 Clicking VIEW button...")
                        view_button.click()
                        time.sleep(3)
                        
                        # Extract long description from the detail page
                        long_desc = ""
                        try:
                            # Look for common long description selectors
                            desc_selectors = [
                                "#longDescription",
                                ".long-description", 
                                ".description",
                                "textarea[name*='description']",
                                "*:has-text('Long Description') + *",
                                "td:has-text('Description:') + td"
                            ]
                            
                            for selector in desc_selectors:
                                try:
                                    desc_elem = page.locator(selector).first
                                    if desc_elem.count() > 0:
                                        long_desc = desc_elem.inner_text().strip()
                                        if long_desc and len(long_desc) > 50:
                                            print(f"✅ Found long description: {long_desc[:100]}...")
                                            break
                                except:
                                    continue
                            
                            if not long_desc:
                                # Fallback: get all text and look for the longest paragraph
                                page_text = page.locator("body").inner_text()
                                paragraphs = [p.strip() for p in page_text.split('\n') if len(p.strip()) > 100]
                                if paragraphs:
                                    long_desc = max(paragraphs, key=len)
                                    print(f"📝 Found description via fallback: {long_desc[:100]}...")
                            
                        except Exception as e:
                            print(f"❌ Error extracting description: {e}")
                        
                        # Go back to results
                        try:
                            page.go_back()
                            time.sleep(2)
                        except:
                            # If go_back fails, re-run the search
                            print("🔄 Re-running search...")
                            page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
                            time.sleep(3)
                            page.mouse.click(633, 341)  # Submit again
                            time.sleep(8)
                    else:
                        print("⚠️ No VIEW button found")
                        long_desc = short_desc  # Use short description as fallback
                    
                    # Store case data
                    case_data = {
                        "case_number": case_number,
                        "date_submitted": date_submitted,
                        "short_description": short_desc,
                        "long_description": long_desc or short_desc,
                        "location": location,
                        "extracted_at": datetime.now().isoformat()
                    }
                    cases.append(case_data)
                    
            except Exception as e:
                print(f"❌ Error processing row {i}: {e}")
                continue
        
        # Save extracted cases
        output = {
            "timestamp": datetime.now().isoformat(),
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open("mufon_cases_with_descriptions.json", "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"\n🎉 Extracted {len(cases)} cases with long descriptions!")
        print("💾 Saved to mufon_cases_with_descriptions.json")
        
        browser.close()

if __name__ == "__main__":
    main()