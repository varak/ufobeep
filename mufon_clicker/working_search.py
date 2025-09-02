#!/usr/bin/env python3
"""
Working search - properly fill and submit the MUFON search form
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta

def main():
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%m/%d/%Y")
    today = datetime.now().strftime("%m/%d/%Y")
    
    print(f"🎯 Searching: {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(storage_state="mufon_artifacts/member_storage_state.json")
        page = context.new_page()
        
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", wait_until="domcontentloaded")
        time.sleep(3)
        
        # The form might be in an iframe
        # Try to find the iframe with the search form
        frames = page.frames
        print(f"Found {len(frames)} frames")
        
        # Work with the main page or frame that has the form
        target_frame = page
        for frame in frames:
            if "search" in frame.url.lower() or "cms" in frame.url.lower():
                target_frame = frame
                print(f"Using frame: {frame.url}")
                break
        
        # Fill date fields using more specific selectors
        # Looking at the form, the date inputs are likely in a specific order
        print("Filling date fields...")
        
        # Method 1: Try filling by position in the form
        all_inputs = target_frame.locator("input[type='text']").all()
        print(f"Found {len(all_inputs)} text inputs")
        
        if len(all_inputs) >= 4:
            # Date Submitted range
            all_inputs[0].click()
            all_inputs[0].fill("")
            all_inputs[0].type(yesterday)
            
            all_inputs[1].click()
            all_inputs[1].fill("")
            all_inputs[1].type(today)
            
            # Date of Event range
            all_inputs[2].click()
            all_inputs[2].fill("")
            all_inputs[2].type(yesterday)
            
            all_inputs[3].click()
            all_inputs[3].fill("")
            all_inputs[3].type(today)
            
            print("✅ Filled all date fields")
        
        # Take screenshot to verify dates are filled
        page.screenshot(path="dates_filled.png")
        print("📸 Screenshot saved: dates_filled.png")
        
        # Now click submit - try different methods
        print("Looking for SUBMIT button...")
        
        # Method 1: Click the first SUBMIT button
        try:
            target_frame.locator("input[value='SUBMIT']").first.click()
            print("✅ Clicked SUBMIT (method 1)")
        except:
            # Method 2: Try with JavaScript
            try:
                target_frame.evaluate("document.querySelector('input[value=\"SUBMIT\"]').click()")
                print("✅ Clicked SUBMIT (method 2)")
            except:
                # Method 3: Find form and submit it
                try:
                    target_frame.evaluate("document.querySelector('form').submit()")
                    print("✅ Submitted form directly (method 3)")
                except:
                    print("❌ Could not submit form")
        
        # Wait for results or page change
        print("⏳ Waiting for results...")
        time.sleep(10)
        
        # Check if URL changed or results appeared
        new_url = page.url
        print(f"📍 New URL: {new_url}")
        
        # Screenshot results
        page.screenshot(path="after_submit.png", full_page=True)
        
        # Get page text
        text = page.locator("body").inner_text()
        
        # Check if we got results
        if "no records found" in text.lower():
            print("⚠️ No records found for date range")
        elif "results" in text.lower() or "case" in text.lower():
            print("✅ Got results!")
            
            # Look for case data
            tables = page.locator("table").all()
            for table in tables:
                rows = table.locator("tr").all()
                if len(rows) > 1:
                    print(f"📊 Found table with {len(rows)} rows")
                    for i, row in enumerate(rows[:5]):  # First 5 rows
                        cells = row.locator("td").all()
                        if cells:
                            row_text = " | ".join([cell.inner_text().strip()[:30] for cell in cells[:5]])
                            print(f"  Row {i}: {row_text}")
        
        # Save results
        with open("search_output.txt", "w") as f:
            f.write(f"URL: {new_url}\n")
            f.write(f"Search dates: {yesterday} to {today}\n\n")
            f.write(text)
        
        print("💾 Saved: after_submit.png and search_output.txt")
        
        browser.close()

if __name__ == "__main__":
    main()