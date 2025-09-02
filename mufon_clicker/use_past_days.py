#!/usr/bin/env python3
"""
Use PAST N DAYS buttons to search MUFON database
"""
from playwright.sync_api import sync_playwright
import time

def main():
    print("🎯 Using PAST 7 DAYS for search")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(storage_state="mufon_artifacts/member_storage_state.json")
        page = context.new_page()
        
        print("📍 Going to search page...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", wait_until="domcontentloaded")
        time.sleep(3)
        
        # Click on PAST 7 DAYS buttons to auto-fill dates
        print("🔘 Clicking PAST 7 DAYS buttons...")
        
        # There are "PAST 30 DAYS", "PAST 90 DAYS", "PAST 180 DAYS", "PAST 1YR" buttons
        # Let's click PAST 7 DAYS for Date Submitted
        try:
            # Click first PAST 7 DAYS button (for Date Submitted)
            page.click("button:has-text('PAST 7 DAYS'):first-of-type")
            print("✅ Clicked PAST 7 DAYS for Date Submitted")
        except:
            try:
                page.click("input[value='PAST 7 DAYS']:first-of-type")
                print("✅ Clicked PAST 7 DAYS button (input)")
            except:
                print("⚠️ Could not find PAST 7 DAYS button")
        
        time.sleep(1)
        
        # Click second PAST 7 DAYS button (for Date of Event)
        try:
            page.click("button:has-text('PAST 7 DAYS'):nth-of-type(2)")
            print("✅ Clicked PAST 7 DAYS for Date of Event")
        except:
            try:
                page.click("input[value='PAST 7 DAYS']:nth-of-type(2)")
                print("✅ Clicked second PAST 7 DAYS button")
            except:
                print("⚠️ Could not find second PAST 7 DAYS button")
        
        time.sleep(1)
        
        # Take screenshot to see filled dates
        page.screenshot(path="dates_auto_filled.png")
        print("📸 Dates should be filled - check dates_auto_filled.png")
        
        # Now click SUBMIT
        print("🚀 Clicking SUBMIT...")
        try:
            page.click("input[value='SUBMIT']:first-of-type")
            print("✅ Clicked SUBMIT")
        except:
            print("❌ Could not click SUBMIT")
        
        # Wait for results
        print("⏳ Waiting for results...")
        time.sleep(10)
        
        # Check results
        page.screenshot(path="search_results_7days.png", full_page=True)
        
        # Get text
        text = page.locator("body").inner_text()
        
        # Save results
        with open("results_7days.txt", "w") as f:
            f.write(text)
        
        print(f"📍 Final URL: {page.url}")
        
        # Check if we got real results
        if "case" in text.lower() and "ufo" in text.lower():
            print("✅ Got UFO case results!")
            
            # Try to find case numbers
            import re
            case_numbers = re.findall(r'Case #?(\d{5,7})', text)
            if case_numbers:
                print(f"🎯 Found case numbers: {case_numbers[:10]}")
        else:
            print("⚠️ No clear case results found")
        
        print("💾 Saved: search_results_7days.png and results_7days.txt")
        
        browser.close()

if __name__ == "__main__":
    main()