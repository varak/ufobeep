#!/usr/bin/env python3
"""
Login to MUFON and search by specific date range
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta
import json

def main():
    # Calculate yesterday's date
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%m/%d/%Y")
    today = datetime.now().strftime("%m/%d/%Y")
    
    print(f"🗓️ Searching for cases from {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)  # Visible to see what happens
        context = browser.new_context()
        page = context.new_page()
        
        print("🔐 Logging into MUFON...")
        
        # Go to MUFON login
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        time.sleep(2)
        
        # Click Member Login
        page.click("text=Member Login")
        page.wait_for_load_state("domcontentloaded")
        time.sleep(2)
        
        # Login with credentials
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("button:has-text('Sign In')")
        page.wait_for_load_state("domcontentloaded")
        time.sleep(3)
        
        print("✅ Logged in successfully")
        
        # Look for database search options
        print("🔍 Looking for database search...")
        
        # Try to find and click search database
        try:
            # Look for dropdown with database options
            dropdown = page.locator("select[name='choice']").first
            if dropdown.count() > 0:
                print("📋 Found search dropdown")
                
                # Look for database/search options
                options = dropdown.locator("option").all()
                for opt in options:
                    value = opt.get_attribute('value') or ''
                    text = opt.inner_text()
                    print(f"  Option: {text} -> {value}")
                    
                    # Try various database search options
                    if any(keyword in text.lower() for keyword in ['database', 'search', 'case', 'cms']):
                        print(f"🎯 Selecting: {text}")
                        dropdown.select_option(value)
                        
                        # Submit the form
                        submit_btn = page.locator("input[type='submit']").first
                        if submit_btn.count() > 0:
                            submit_btn.click()
                            page.wait_for_load_state("domcontentloaded")
                            time.sleep(3)
                            break
        except Exception as e:
            print(f"Dropdown search failed: {e}")
        
        # Take screenshot to see current page
        page.screenshot(path="after_login_search.png", full_page=True)
        
        # Look for date search fields
        print("📅 Looking for date search fields...")
        
        # Common date field patterns
        date_selectors = [
            "input[type='date']",
            "input[name*='date']", 
            "input[name*='Date']",
            "input[id*='date']",
            "input[id*='Date']",
            "select[name*='date']",
            "select[name*='Date']"
        ]
        
        date_fields_found = []
        for selector in date_selectors:
            elements = page.locator(selector).all()
            if elements:
                print(f"  Found {len(elements)} date fields: {selector}")
                date_fields_found.extend(elements)
        
        # Try to fill date fields
        if date_fields_found:
            print(f"📝 Attempting to fill {len(date_fields_found)} date fields...")
            
            for i, field in enumerate(date_fields_found[:2]):  # Try first 2
                try:
                    field_name = field.get_attribute('name') or field.get_attribute('id') or f"field_{i}"
                    print(f"  Filling {field_name} with {yesterday}")
                    field.fill(yesterday)
                    time.sleep(0.5)
                except Exception as e:
                    print(f"  Error filling field {i}: {e}")
        
        # Look for and click search/submit button
        search_buttons = [
            "input[type='submit']",
            "button:has-text('Search')",
            "button:has-text('Submit')",
            "input[value*='Search']",
            "input[value*='Submit']"
        ]
        
        search_clicked = False
        for selector in search_buttons:
            try:
                btn = page.locator(selector).first
                if btn.count() > 0:
                    print(f"🔍 Clicking search button: {selector}")
                    btn.click()
                    page.wait_for_load_state("domcontentloaded")
                    time.sleep(3)
                    search_clicked = True
                    break
            except Exception as e:
                print(f"Search button error {selector}: {e}")
                continue
        
        if not search_clicked:
            print("❌ No search button found - taking screenshot for debug")
        
        # Final screenshot
        page.screenshot(path="search_results_page.png", full_page=True)
        
        # Look for case results
        print("📊 Looking for case results...")
        
        # Look for cases/results
        case_indicators = [
            "table tr",
            "text=Case", 
            "text=VIEW",
            "[onclick*='view']",
            "a[href*='case']"
        ]
        
        results_found = False
        for selector in case_indicators:
            try:
                elements = page.locator(selector).all()
                if elements:
                    print(f"  Found {len(elements)} elements: {selector}")
                    if selector == "table tr" and len(elements) > 1:
                        results_found = True
            except:
                continue
        
        current_url = page.url
        print(f"📍 Final URL: {current_url}")
        
        if results_found:
            print("✅ SUCCESS: Found case results table")
            
            # Save this URL and session
            context.storage_state(path="mufon_artifacts/search_storage_state.json")
            
            with open("working_search_url.txt", "w") as f:
                f.write(current_url)
                
        else:
            print("❌ No case results found")
        
        # Save page content for debugging
        with open("search_page_debug.html", "w") as f:
            f.write(page.content())
        
        print("\n📋 Check screenshots and debug files:")
        print("  - after_login_search.png")
        print("  - search_results_page.png") 
        print("  - search_page_debug.html")
        
        browser.close()

if __name__ == "__main__":
    main()