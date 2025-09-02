#!/usr/bin/env python3
"""
Final working search - just fill the dates and submit
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta

def main():
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%m/%d/%Y")
    today = datetime.now().strftime("%m/%d/%Y")
    
    print(f"🎯 Search dates: {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state="mufon_artifacts/member_storage_state.json")
        page = context.new_page()
        
        # Go to search page
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", wait_until="domcontentloaded")
        time.sleep(3)
        
        # The form has text inputs we need to fill
        # Based on the screenshot, there are date range inputs
        # Fill them by their position
        
        inputs = page.locator("input[type='text']").all()
        if len(inputs) >= 4:
            # Clear and fill Date Submitted range
            inputs[0].fill(yesterday)
            inputs[1].fill(today)
            
            # Clear and fill Date of Event range  
            inputs[2].fill(yesterday)
            inputs[3].fill(today)
            
            print("✅ Filled date ranges")
        
        # Submit the form
        page.locator("input[value='SUBMIT']").first.click()
        print("✅ Submitted search")
        
        # Wait for results
        time.sleep(10)
        
        # Save results
        page.screenshot(path="final_results.png", full_page=True)
        
        text = page.locator("body").inner_text()
        with open("final_results.txt", "w") as f:
            f.write(f"Search: {yesterday} to {today}\n")
            f.write(f"URL: {page.url}\n\n")
            f.write(text)
        
        print(f"💾 Saved: final_results.png and final_results.txt")
        print(f"📍 URL: {page.url}")
        
        # Check if we got case results
        if "case" in text.lower():
            print("✅ Found case data in results")
        
        browser.close()

if __name__ == "__main__":
    main()