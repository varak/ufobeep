#!/usr/bin/env python3
"""
Click PAST 7 DAYS buttons to fill dates and submit search
"""
from playwright.sync_api import sync_playwright
import time

def main():
    print("🎯 Using PAST 7 DAYS buttons to search")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()
        
        # Login
        print("🔐 Logging in...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp", wait_until="domcontentloaded")
        time.sleep(2)
        
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        
        print("✅ Logged in")
        
        # Go to search
        print("📍 Going to search page...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", wait_until="domcontentloaded")
        time.sleep(5)
        
        # Click PAST 7 DAYS buttons - I can see them in the screenshot!
        print("🔘 Clicking PAST N DAYS buttons...")
        
        # For Date Submitted - click the PAST N DAYS button (it's purple in the screenshot)
        try:
            # Find all buttons with "PAST N DAYS" text
            past_n_days_buttons = page.locator("button:has-text('PAST N DAYS'), input[value='PAST N DAYS']").all()
            print(f"Found {len(past_n_days_buttons)} PAST N DAYS buttons")
            
            # Click both (one for Date Submitted, one for Date of Event)
            if len(past_n_days_buttons) >= 2:
                past_n_days_buttons[0].click()
                print("✅ Clicked first PAST N DAYS")
                time.sleep(1)
                
                past_n_days_buttons[1].click()
                print("✅ Clicked second PAST N DAYS")
                time.sleep(1)
        except:
            print("⚠️ Could not find PAST N DAYS buttons")
        
        # Now the dates should be filled - click SUBMIT
        print("🚀 Clicking SUBMIT...")
        
        # The SUBMIT button is visible at the top of the form
        submit_button = page.locator("input[value='SUBMIT']").first
        if submit_button:
            submit_button.click()
            print("✅ Clicked SUBMIT")
        else:
            print("❌ No SUBMIT button found")
            return
        
        # Wait for results
        print("⏳ Waiting for results...")
        time.sleep(10)
        
        # Save results
        page.screenshot(path="past_7_days_results.png", full_page=True)
        
        text = page.locator("body").inner_text()
        with open("past_7_days_results.txt", "w") as f:
            f.write(text)
        
        print(f"📍 Final URL: {page.url}")
        
        # Check for results
        if "no records" in text.lower():
            print("⚠️ No records found")
        elif "case" in text.lower() and any(word in text.lower() for word in ["ufo", "object", "sighting"]):
            print("✅ Got UFO case results!")
            
            # Look for case numbers (6-digit numbers)
            import re
            case_nums = re.findall(r'\b\d{6}\b', text)
            if case_nums:
                print(f"🎯 Found case numbers: {case_nums[:10]}")
        
        print("💾 Saved: past_7_days_results.png and past_7_days_results.txt")
        
        browser.close()

if __name__ == "__main__":
    main()