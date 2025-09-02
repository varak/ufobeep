#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta

yesterday = datetime.now() - timedelta(days=1)
today = datetime.now()

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
    
    print("Looking for date dropdowns...")
    
    # Find all select elements (dropdowns)
    selects = page.locator("select").all()
    print(f"Found {len(selects)} dropdowns")
    
    # Click on each dropdown to activate it, then select value
    if len(selects) >= 6:
        # Date Submitted FROM
        print("Setting Date Submitted FROM...")
        selects[0].click()  # Click to open
        time.sleep(0.5)
        selects[0].select_option(str(yesterday.month))
        
        selects[1].click()
        time.sleep(0.5)
        selects[1].select_option(str(yesterday.day))
        
        selects[2].click()
        time.sleep(0.5)
        selects[2].select_option(str(yesterday.year))
        
        # Date Submitted TO
        print("Setting Date Submitted TO...")
        selects[3].click()
        time.sleep(0.5)
        selects[3].select_option(str(today.month))
        
        selects[4].click()
        time.sleep(0.5)
        selects[4].select_option(str(today.day))
        
        selects[5].click()
        time.sleep(0.5)
        selects[5].select_option(str(today.year))
        
        print(f"✅ Date Submitted: {yesterday.strftime('%m/%d/%Y')} to {today.strftime('%m/%d/%Y')}")
    
    # Take screenshot to verify dates are set
    page.screenshot(path="dates_set.png")
    print("📸 Check dates_set.png")
    
    # Find and click SUBMIT
    print("Looking for SUBMIT button...")
    
    # Try different methods to find SUBMIT
    submit_found = False
    
    # Method 1: Look for input with SUBMIT value
    submits = page.locator("input[type='submit'], input[type='button']").all()
    for submit in submits:
        try:
            value = submit.get_attribute('value') or ''
            if 'SUBMIT' in value.upper():
                print(f"Found SUBMIT button: {value}")
                submit.click()
                submit_found = True
                break
        except:
            pass
    
    if not submit_found:
        # Method 2: Click by text
        try:
            page.click("text=SUBMIT")
            submit_found = True
        except:
            pass
    
    if submit_found:
        print("✅ Clicked SUBMIT!")
        time.sleep(10)
        page.screenshot(path="search_results.png")
        print("📸 Results saved to search_results.png")
    else:
        print("❌ Could not find SUBMIT button")
    
    browser.close()