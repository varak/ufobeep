#!/usr/bin/env python3
"""
Complete login and search - fresh login then search
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta

def main():
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%m/%d/%Y")
    today = datetime.now().strftime("%m/%d/%Y")
    
    print(f"🎯 Target dates: {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        
        # Step 1: Fresh login
        print("🔐 Logging into MUFON...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp", wait_until="domcontentloaded")
        time.sleep(2)
        
        # Fill login
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        
        print("✅ Logged in")
        
        # Step 2: Go to search database
        print("📍 Going to search database...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", wait_until="domcontentloaded")
        time.sleep(5)
        
        # Step 3: Fill the search form
        print("📝 Filling search form with dates...")
        
        # Get all text inputs on the page
        all_inputs = page.locator("input[type='text']").all()
        print(f"Found {len(all_inputs)} text inputs")
        
        # The date fields should be among the first text inputs
        # Based on the form structure:
        # - First two inputs: Date Submitted range
        # - Next two inputs: Date of Event range
        
        if len(all_inputs) >= 4:
            # Date Submitted From
            all_inputs[0].click()
            all_inputs[0].fill("")
            all_inputs[0].type(yesterday)
            print(f"  Date Submitted From: {yesterday}")
            
            # Date Submitted To
            all_inputs[1].click()
            all_inputs[1].fill("")
            all_inputs[1].type(today)
            print(f"  Date Submitted To: {today}")
            
            # Date of Event From
            all_inputs[2].click()
            all_inputs[2].fill("")
            all_inputs[2].type(yesterday)
            print(f"  Date of Event From: {yesterday}")
            
            # Date of Event To
            all_inputs[3].click()
            all_inputs[3].fill("")
            all_inputs[3].type(today)
            print(f"  Date of Event To: {today}")
            
            print("✅ All date fields filled")
        else:
            print(f"⚠️ Only found {len(all_inputs)} inputs, expected at least 4")
        
        # Take screenshot before submit
        page.screenshot(path="form_filled.png")
        print("📸 Check form_filled.png to verify dates")
        
        # Step 4: Submit the search
        print("🚀 Submitting search...")
        
        # Find and click SUBMIT button
        submit_buttons = page.locator("input[value='SUBMIT']").all()
        if submit_buttons:
            submit_buttons[0].click()
            print(f"✅ Clicked SUBMIT (found {len(submit_buttons)} submit buttons)")
        else:
            print("❌ No SUBMIT button found")
            return
        
        # Wait for results
        print("⏳ Waiting for results...")
        time.sleep(10)
        
        # Step 5: Capture results
        page.screenshot(path="search_complete.png", full_page=True)
        
        # Get page text
        page_text = page.locator("body").inner_text()
        
        # Save results
        with open("search_complete.txt", "w") as f:
            f.write(f"Search dates: {yesterday} to {today}\n")
            f.write(f"Final URL: {page.url}\n")
            f.write("=" * 50 + "\n")
            f.write(page_text)
        
        print("\n📊 Results:")
        print(f"  URL: {page.url}")
        
        # Check if we got actual case results
        if "no records found" in page_text.lower():
            print("  ⚠️ No records found for this date range")
        elif "case" in page_text.lower() or "results" in page_text.lower():
            print("  ✅ Got search results!")
            
            # Try to extract case numbers
            import re
            case_numbers = re.findall(r'\b\d{6}\b', page_text)
            if case_numbers:
                print(f"  🎯 Potential case numbers: {case_numbers[:5]}")
        
        print("\n💾 Saved files:")
        print("  - form_filled.png (form with dates)")
        print("  - search_complete.png (results page)")
        print("  - search_complete.txt (text content)")
        
        # Save session for future use
        context.storage_state(path="mufon_artifacts/fresh_session.json")
        print("  - mufon_artifacts/fresh_session.json (session)")
        
        browser.close()

if __name__ == "__main__":
    main()