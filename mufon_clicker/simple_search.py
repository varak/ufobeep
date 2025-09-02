#!/usr/bin/env python3
"""
Simple search - fill dates and click submit
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
        
        # Fill the date fields - they are text inputs in the form
        # Get all text inputs
        inputs = page.locator("input[type='text']").all()
        
        # Fill first 4 inputs (Date Submitted from/to, Date of Event from/to)
        if len(inputs) >= 4:
            inputs[0].fill(yesterday)
            inputs[1].fill(today)
            inputs[2].fill(yesterday) 
            inputs[3].fill(today)
            print("✅ Filled dates")
        
        # Click the SUBMIT button - it's at the TOP of the form
        # First SUBMIT button we encounter
        submit_buttons = page.locator("input[value='SUBMIT']").all()
        if submit_buttons:
            submit_buttons[0].click()  # Click the first (top) SUBMIT button
        print("✅ Clicked SUBMIT")
        
        # Wait for results
        time.sleep(10)
        
        # Screenshot results
        page.screenshot(path="results.png", full_page=True)
        
        # Get text
        text = page.locator("body").inner_text()
        with open("results.txt", "w") as f:
            f.write(text)
        
        print(f"📸 Saved: results.png and results.txt")
        print(f"📍 URL: {page.url}")
        
        browser.close()

if __name__ == "__main__":
    main()