#!/usr/bin/env python3
"""
Fresh login to MUFON and find the proper search interface
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta

def main():
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
    today = datetime.now().strftime("%Y-%m-%d")
    
    print(f"🗓️ Target dates: {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        
        print("🔐 Fresh login to MUFON...")
        
        # Start at main MUFON site
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        time.sleep(2)
        
        # Click Member Login
        page.click("text=Member Login")
        time.sleep(2)
        
        # Fill login form
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        
        # Submit login
        page.click("input[type='submit']")
        time.sleep(3)
        
        print("✅ Login submitted")
        
        # Look for the dropdown that was working before
        dropdown = page.locator("select[name='choice']").first
        if dropdown.count() > 0:
            print("📋 Found choice dropdown")
            
            # Get all options
            options = dropdown.locator("option").all()
            for opt in options:
                value = opt.get_attribute('value') or ''
                text = opt.inner_text()
                print(f"  {value} -> {text}")
                
                # Look for Last 20 Reports option (we know this works)
                if 'last_20_public.html' in value or 'Last 20 Reports' in text:
                    print(f"🎯 Using: {text}")
                    dropdown.select_option(value)
                    
                    # Submit
                    page.click("input[type='submit']")
                    time.sleep(5)
                    break
        
        # Take screenshot of results
        page.screenshot(path="fresh_results.png", full_page=True)
        
        # Look for case table
        rows = page.locator("table tr").all()
        print(f"📊 Found {len(rows)} table rows")
        
        if len(rows) > 1:  # Has header + data rows
            print("✅ Found case table!")
            
            # Filter rows by date
            target_rows = []
            for i, row in enumerate(rows[1:], 1):  # Skip header
                try:
                    cells = row.locator("td").all()
                    if len(cells) >= 3:
                        date_cell = cells[2].inner_text().strip()
                        print(f"  Row {i}: Date = {date_cell}")
                        
                        # Check if date matches our target
                        if yesterday in date_cell or today in date_cell:
                            target_rows.append((i, row))
                            print(f"    ✅ MATCH: Row {i}")
                except Exception as e:
                    print(f"  Row {i}: Error reading - {e}")
            
            print(f"🎯 Found {len(target_rows)} rows matching {yesterday}-{today}")
            
            if target_rows:
                # Process the matching rows
                cases = []
                for row_num, row in target_rows:
                    try:
                        cells = row.locator("td").all()
                        case_num = cells[0].inner_text().strip()
                        date_sub = cells[1].inner_text().strip()
                        date_event = cells[2].inner_text().strip()
                        desc = cells[3].inner_text().strip()
                        location = cells[4].inner_text().strip()
                        
                        print(f"\n--- Case {case_num} ---")
                        print(f"Date: {date_event}")
                        print(f"Description: {desc}")
                        print(f"Location: {location}")
                        
                        case_data = {
                            "Case_Number": case_num,
                            "Date_Submitted": date_sub,
                            "DateTime_Event": date_event,
                            "Short_Description": desc,
                            "Location": location
                        }
                        cases.append(case_data)
                        
                    except Exception as e:
                        print(f"Error processing row {row_num}: {e}")
                
                # Save results
                import json
                output = {
                    "timestamp": datetime.now().isoformat(),
                    "search_dates": f"{yesterday} to {today}",
                    "total_cases": len(cases),
                    "cases": cases
                }
                
                with open("fresh_mufon_results.json", "w") as f:
                    json.dump(output, f, indent=2)
                
                print(f"\n🎉 Extracted {len(cases)} cases for target dates!")
                print("💾 Saved to fresh_mufon_results.json")
                
                # Save working session
                context.storage_state(path="mufon_artifacts/fresh_storage_state.json")
                
            else:
                print("❌ No cases found for target dates")
        else:
            print("❌ No case table found")
        
        print(f"\n📍 Final URL: {page.url}")
        print("📸 Check fresh_results.png")
        
        browser.close()

if __name__ == "__main__":
    main()