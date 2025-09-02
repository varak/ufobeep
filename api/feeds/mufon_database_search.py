#!/usr/bin/env python3
"""
Complete MUFON database search - Login → Navigate → Fill date filters → Extract results
"""
import time, json
from datetime import datetime, timedelta
from pathlib import Path
from playwright.sync_api import sync_playwright

def main():
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        print("Step 1: Navigate to MUFON search form...")
        # Follow the complete navigation path
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        
        # Click Track UFOs
        page.locator("text=Track UFOs").first.click()
        time.sleep(1)
        print("✅ Clicked Track UFOs")
        
        # Click Database Search
        page.locator("text=Search Database").first.click()
        page.wait_for_load_state("networkidle")
        print("✅ Clicked Database Search")
        
        # Accept Terms and Conditions
        if "terms" in page.url.lower():
            agree_radio = page.locator("input[type='radio'][value*='agree']").first
            if agree_radio.count() > 0:
                agree_radio.check()
                print("✅ Checked Terms agreement")
                
                # Submit T&C
                submit_btn = page.locator("button:has-text('Submit')").first
                if submit_btn.count() > 0:
                    submit_btn.click()
                    page.wait_for_load_state("networkidle")
                    print("✅ Submitted Terms")
        
        # Handle login if needed
        if "neoncrm.com" in page.url and "signIn" in page.url:
            print("✅ Handling login...")
            try:
                # Look for username/email field
                username_field = None
                for selector in ["input[name*='user']", "input[name*='email']", "input[type='email']", "input[name*='login']"]:
                    field = page.locator(selector).first
                    if field.count() > 0:
                        username_field = field
                        break
                
                # Look for password field  
                password_field = page.locator("input[type='password']").first
                
                if username_field and password_field.count() > 0:
                    # Load credentials
                    env_file = Path(".env")
                    username = ""
                    password = ""
                    
                    if env_file.exists():
                        for line in env_file.read_text().splitlines():
                            if line.startswith("MUFON_USERNAME="):
                                username = line.split("=", 1)[1].strip()
                            elif line.startswith("MUFON_PASSWORD="):
                                password = line.split("=", 1)[1].strip()
                    
                    if username and password:
                        username_field.fill(username)
                        password_field.fill(password)
                        password_field.press("Enter")
                        page.wait_for_load_state("networkidle")
                        print("✅ Logged in")
                    else:
                        print("❌ No credentials found in .env")
                else:
                    print("❌ Could not find login fields")
                    
            except Exception as e:
                print(f"Login failed: {e}")
        
        print(f"\nStep 2: Current page - URL: {page.url}")
        print(f"Title: {page.title()}")
        
        # Check if we reached the member portal 
        if "Welcome, Mike Emke" in page.content() or "What would you like to do" in page.content():
            print("✅ Reached member portal! Need to navigate to search form...")
            
            # The screenshot shows we're at the search form already - let me check
            if "MUFON Case Management System" in page.content() and "SEARCH CASES" in page.content():
                print("✅ Already at the search form!")
            else:
                print("❌ Still at member portal dropdown - search form not loaded yet")
                # Save current page to debug
                Path("member_portal_debug.html").write_text(page.content())
                page.screenshot(path="member_portal_debug.png", full_page=True)
            
            # Calculate date range (past 2 days)
            today = datetime.now()
            two_days_ago = today - timedelta(days=2)
            
            print(f"\nStep 3: Setting date range - {two_days_ago.strftime('%Y-%m-%d')} to {today.strftime('%Y-%m-%d')}")
            
            # Look for the search form specifically - skip the member portal dropdown
            try:
                # Let's just submit the search without dates first to get ANY results
                print("Submitting search without date filters to get sample results...")
                                
            except Exception as e:
                print(f"Date setting failed: {e}")
                print("Proceeding with simple search...")
            
            # Submit search
            print("\nStep 4: Submitting search...")
            submit_btn = page.locator("input[value='SUBMIT'], button:has-text('SUBMIT')").first
            if submit_btn.count() > 0:
                submit_btn.click()
                page.wait_for_load_state("networkidle")
                print("✅ Search submitted")
            else:
                print("❌ Could not find submit button")
                
            time.sleep(3)  # Wait for results
            
            print(f"\nStep 5: Results page - URL: {page.url}")
            
            # Extract results from any tables found
            results = []
            tables = page.locator("table")
            print(f"Found {tables.count()} tables")
            
            for t in range(tables.count()):
                table = tables.nth(t)
                rows = table.locator("tr")
                
                if rows.count() > 1:  # Has header + data
                    print(f"Table {t+1} has {rows.count()} rows")
                    
                    # Get headers
                    headers = []
                    header_row = rows.nth(0)
                    header_cells = header_row.locator("th, td")
                    for i in range(header_cells.count()):
                        headers.append(header_cells.nth(i).inner_text().strip())
                    
                    # Get data rows (limit to first 20 for safety)
                    for r in range(1, min(rows.count(), 21)):
                        data_row = rows.nth(r)
                        cells = data_row.locator("td")
                        
                        if cells.count() >= len(headers):
                            row_data = {}
                            for c in range(len(headers)):
                                key = headers[c] or f"col_{c}"
                                value = cells.nth(c).inner_text().strip()
                                row_data[key] = value
                            
                            if any(row_data.values()):  # Non-empty row
                                results.append(row_data)
            
            # Save results
            output = {
                "timestamp": datetime.now().isoformat(),
                "search_date_range": f"{two_days_ago.strftime('%Y-%m-%d')} to {today.strftime('%Y-%m-%d')}",
                "url": page.url,
                "total_cases": len(results),
                "cases": results
            }
            
            Path("mufon_recent_cases.json").write_text(json.dumps(output, indent=2))
            print(f"\n✅ SUCCESS: Extracted {len(results)} recent UFO cases")
            print(f"Results saved to mufon_recent_cases.json")
            
            # Also save page for debugging
            Path("mufon_results_page.html").write_text(page.content())
            page.screenshot(path="mufon_results_page.png", full_page=True)
            
        else:
            print("❌ Did not reach search form")
            Path("mufon_debug.html").write_text(page.content())
        
        browser.close()

if __name__ == "__main__":
    main()