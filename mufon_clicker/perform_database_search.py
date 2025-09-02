#!/usr/bin/env python3
"""
Perform actual database search on MUFON CMS Search page
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta
import json

def main():
    # Target date (one day backwards)
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%m/%d/%Y")
    today = datetime.now().strftime("%m/%d/%Y")
    
    print(f"🎯 Searching for cases from {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        # Use the authenticated session
        context = browser.new_context(storage_state="mufon_artifacts/member_storage_state.json")
        page = context.new_page()
        
        print("🔑 Loading MUFON search database...")
        
        # Go directly to the search database page
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", wait_until="domcontentloaded")
        time.sleep(5)
        
        print("📝 Filling search form...")
        
        # Fill in the date range - I can see the date fields in the screenshot
        # Date Submitted (within date range)
        date_inputs = page.locator("input[type='text']").all()
        
        # Find the date inputs - they appear after "Date Submitted" and "Date of Event" labels
        # Based on the screenshot, there are date range inputs with "CLEAR DATE" buttons
        
        # Try to fill the date fields based on their position
        try:
            # Fill Date Submitted range
            page.fill("input[type='text']:nth-of-type(1)", yesterday)
            page.fill("input[type='text']:nth-of-type(2)", today)
            print(f"✅ Set Date Submitted range: {yesterday} to {today}")
        except:
            pass
        
        try:
            # Fill Date of Event range  
            page.fill("input[type='text']:nth-of-type(3)", yesterday)
            page.fill("input[type='text']:nth-of-type(4)", today)
            print(f"✅ Set Date of Event range: {yesterday} to {today}")
        except:
            pass
        
        # Click SUBMIT button
        print("🔍 Clicking SUBMIT...")
        try:
            # Try different selectors for the submit button
            page.click("button:has-text('SUBMIT')")
        except:
            try:
                page.click("input[value='SUBMIT']")
            except:
                try:
                    page.click("text=SUBMIT")
                except:
                    print("❌ Could not find SUBMIT button")
                    # Take screenshot to see what's on the page
                    page.screenshot(path="search_form_filled.png", full_page=True)
                    return
        
        if True:
            time.sleep(10)
            
            # Take screenshot of results
            page.screenshot(path="search_results_final.png", full_page=True)
            
            # Get results
            page_text = page.locator("body").inner_text()
            print("\n📊 SEARCH RESULTS:")
            print("=" * 50)
            print(page_text[:3000] + ("..." if len(page_text) > 3000 else ""))
            print("=" * 50)
            
            # Look for result tables
            tables = page.locator("table").all()
            print(f"\n📋 Found {len(tables)} tables")
            
            # Find the results table (usually has case data)
            for table_idx, table in enumerate(tables):
                rows = table.locator("tr").all()
                if len(rows) > 1:  # Has data
                    print(f"\n📊 Table {table_idx + 1} has {len(rows)} rows")
                    
                    cases = []
                    for i, row in enumerate(rows):
                        try:
                            cells = row.locator("td").all()
                            if len(cells) >= 3:
                                row_data = []
                                for cell in cells:
                                    text = cell.inner_text().strip()
                                    row_data.append(text)
                                
                                # First row might be headers
                                if i == 0 and any('case' in str(d).lower() for d in row_data):
                                    print(f"  Headers: {row_data}")
                                else:
                                    print(f"  Row {i}: {row_data[:5]}...")  # Show first 5 columns
                                    cases.append({
                                        "row_index": i,
                                        "data": row_data
                                    })
                        except Exception as e:
                            print(f"  Row {i}: Error - {e}")
                    
                    if cases:
                        # Save results
                        output = {
                            "timestamp": datetime.now().isoformat(),
                            "search_dates": f"{yesterday} to {today}",
                            "url": page.url,
                            "total_cases": len(cases),
                            "cases": cases
                        }
                        
                        with open("mufon_search_results.json", "w") as f:
                            json.dump(output, f, indent=2)
                        
                        print(f"\n🎉 Found {len(cases)} cases!")
                        print("💾 Saved to mufon_search_results.json")
                        break
        else:
            print("❌ Submit button not found")
        
        print(f"\n📍 Final URL: {page.url}")
        print("📸 Check search_results_final.png")
        
        # Keep browser open briefly
        time.sleep(5)
        browser.close()

if __name__ == "__main__":
    main()