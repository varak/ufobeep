#!/usr/bin/env python3
"""
Fill and submit the MUFON search form that's clearly visible
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
        context = browser.new_context(storage_state="mufon_artifacts/member_storage_state.json")
        page = context.new_page()
        
        print("🔑 Loading MUFON search database...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", wait_until="domcontentloaded")
        time.sleep(5)
        
        print("📝 Filling date fields in the visible form...")
        
        # The form is in an iframe or nested structure
        # I can see "Date Submitted (within date range):" and "Date of Event (within date range):"
        # with text input fields next to them
        
        # Fill the date inputs - they're regular text inputs
        # Find all text inputs and fill the date ones
        all_inputs = page.locator("input[type='text']").all()
        
        # Log what we find
        print(f"Found {len(all_inputs)} text inputs")
        
        # The date inputs are likely the first few after the labels
        # Try to fill by index based on what I see in the screenshot
        if len(all_inputs) >= 4:
            # Date Submitted range (first two date fields)
            all_inputs[0].fill(yesterday)
            all_inputs[1].fill(today)
            print(f"✅ Filled Date Submitted: {yesterday} to {today}")
            
            # Date of Event range (next two date fields)  
            all_inputs[2].fill(yesterday)
            all_inputs[3].fill(today)
            print(f"✅ Filled Date of Event: {yesterday} to {today}")
        
        # Now find and click the SUBMIT button
        # From the screenshot, it's a button at the bottom
        print("🔍 Looking for SUBMIT button...")
        
        # Take screenshot before submit
        page.screenshot(path="before_submit.png", full_page=True)
        
        # Try to find and click submit
        submit_found = False
        
        # Method 1: Look for button with SUBMIT text
        submit_buttons = page.locator("button:has-text('SUBMIT'), input[type='button']:has-text('SUBMIT'), input[type='submit']").all()
        print(f"Found {len(submit_buttons)} potential submit buttons")
        
        for btn in submit_buttons:
            try:
                btn_text = btn.get_attribute('value') or btn.inner_text() or ''
                print(f"  Button: {btn_text}")
                if 'SUBMIT' in btn_text.upper():
                    print(f"  ✅ Clicking: {btn_text}")
                    btn.click()
                    submit_found = True
                    break
            except:
                pass
        
        if not submit_found:
            # Method 2: Click by text
            try:
                page.click("text=SUBMIT")
                submit_found = True
                print("✅ Clicked SUBMIT by text")
            except:
                pass
        
        if not submit_found:
            # Method 3: Try frame if it's in an iframe
            try:
                frames = page.frames
                print(f"Found {len(frames)} frames")
                for frame in frames:
                    try:
                        frame.click("text=SUBMIT")
                        submit_found = True
                        print("✅ Clicked SUBMIT in frame")
                        break
                    except:
                        pass
            except:
                pass
        
        if submit_found:
            print("⏳ Waiting for results...")
            time.sleep(10)
            
            # Take screenshot of results
            page.screenshot(path="after_submit.png", full_page=True)
            
            # Get page text
            page_text = page.locator("body").inner_text()
            
            # Save the text
            with open("search_results_text.txt", "w") as f:
                f.write(page_text)
            
            print("\n📊 Page after submit:")
            print("=" * 50)
            print(page_text[:2000] + ("..." if len(page_text) > 2000 else ""))
            print("=" * 50)
            
            print("\n✅ Screenshots saved:")
            print("  - before_submit.png")
            print("  - after_submit.png")
            print("  - search_results_text.txt")
        else:
            print("❌ Could not find SUBMIT button")
            print("📸 Check before_submit.png to see the form")
        
        print(f"\n📍 Final URL: {page.url}")
        
        # Close browser
        time.sleep(3)
        browser.close()

if __name__ == "__main__":
    main()