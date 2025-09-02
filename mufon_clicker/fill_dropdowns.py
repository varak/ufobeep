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
    
    print("Filling date dropdowns...")
    
    # Get all select dropdowns on the page
    selects = page.locator("select").all()
    
    # Date Submitted From (first 3 dropdowns: month/day/year)
    if len(selects) >= 6:
        # Date Submitted FROM
        selects[0].select_option(str(yesterday.month))  # Month
        selects[1].select_option(str(yesterday.day))    # Day
        selects[2].select_option(str(yesterday.year))   # Year
        
        # Date Submitted TO
        selects[3].select_option(str(today.month))      # Month
        selects[4].select_option(str(today.day))        # Day
        selects[5].select_option(str(today.year))       # Year
        
        print(f"✅ Set Date Submitted: {yesterday.month}/{yesterday.day}/{yesterday.year} to {today.month}/{today.day}/{today.year}")
    
    # Date of Event (next 6 dropdowns)
    if len(selects) >= 12:
        # Date of Event FROM
        selects[6].select_option(str(yesterday.month))  # Month
        selects[7].select_option(str(yesterday.day))    # Day
        selects[8].select_option(str(yesterday.year))   # Year
        
        # Date of Event TO
        selects[9].select_option(str(today.month))      # Month
        selects[10].select_option(str(today.day))       # Day
        selects[11].select_option(str(today.year))      # Year
        
        print(f"✅ Set Date of Event: {yesterday.month}/{yesterday.day}/{yesterday.year} to {today.month}/{today.day}/{today.year}")
    
    # Click SUBMIT
    print("Clicking SUBMIT...")
    try:
        page.click("input[value='SUBMIT']")
    except:
        try:
            page.click("button:has-text('SUBMIT')")
        except:
            page.click("text=SUBMIT")
    
    time.sleep(10)
    page.screenshot(path="dropdown_search_results.png")
    
    print("✅ Search submitted! Check dropdown_search_results.png")
    
    browser.close()