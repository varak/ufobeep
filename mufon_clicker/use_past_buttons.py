#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)
    context = browser.new_context()
    page = context.new_page()
    
    # Login
    page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
    time.sleep(2)
    page.fill("input[name='loginName']", "varak")
    page.fill("input[name='loginPassword']", "ufobeep123pass")
    page.click("text=Log In")
    time.sleep(5)
    
    # Go to search page
    page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
    time.sleep(5)
    
    print("Using PAST N DAYS buttons instead of dropdowns...")
    
    # I can see "PAST N DAYS" buttons in purple - these should work
    # Click the first PAST N DAYS button (for Date Submitted)
    try:
        page.locator("input[value='PAST N DAYS']").first.click()
        print("✅ Clicked first PAST N DAYS")
        time.sleep(1)
    except Exception as e:
        print(f"Error clicking first PAST N DAYS: {e}")
    
    # Click the second PAST N DAYS button (for Date of Event)
    try:
        page.locator("input[value='PAST N DAYS']").last.click()
        print("✅ Clicked second PAST N DAYS")
        time.sleep(1)
    except Exception as e:
        print(f"Error clicking second PAST N DAYS: {e}")
    
    # Take screenshot to see if dates are now filled
    page.screenshot(path="after_past_n_days.png")
    print("📸 Check after_past_n_days.png")
    
    # Now try to submit
    print("Clicking SUBMIT...")
    try:
        # Look for the SUBMIT button at the top of the form
        page.locator("input[value='SUBMIT']").first.click()
        print("✅ Clicked SUBMIT")
        
        # Wait for results
        time.sleep(10)
        page.screenshot(path="search_complete.png", full_page=True)
        print("📸 Results in search_complete.png")
        
    except Exception as e:
        print(f"Error clicking SUBMIT: {e}")
        # Try alternative method
        try:
            page.click("text=SUBMIT")
            print("✅ Clicked SUBMIT (alternative method)")
            time.sleep(10)
            page.screenshot(path="search_complete_alt.png", full_page=True)
        except Exception as e2:
            print(f"Both SUBMIT methods failed: {e2}")
    
    browser.close()