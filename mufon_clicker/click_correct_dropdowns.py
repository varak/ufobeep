#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False, slow_mo=1000)
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
    
    print("👁️ Looking at the correct date dropdowns in the form...")
    
    # Target the date dropdowns that are visible in the form
    # These are the ones next to "Date Submitted (within date range):"
    
    # Find all select elements in the search form area
    form_selects = page.locator("select").all()
    print(f"Found {len(form_selects)} select elements")
    
    # The date dropdowns should be the first several selects
    # Date Submitted FROM: month, day, year (first 3)
    # Date Submitted TO: month, day, year (next 3) 
    # Date of Event FROM: month, day, year (next 3)
    # Date of Event TO: month, day, year (next 3)
    
    try:
        # Date Submitted FROM - September 1, 2025
        print("Setting Date Submitted FROM to Sep 1, 2025...")
        form_selects[0].select_option("9")    # September
        time.sleep(0.5)
        form_selects[1].select_option("1")    # 1st
        time.sleep(0.5)
        form_selects[2].select_option("2025") # 2025
        time.sleep(0.5)
        
        # Date Submitted TO - September 2, 2025
        print("Setting Date Submitted TO to Sep 2, 2025...")
        form_selects[3].select_option("9")    # September
        time.sleep(0.5)
        form_selects[4].select_option("2")    # 2nd
        time.sleep(0.5)
        form_selects[5].select_option("2025") # 2025
        time.sleep(0.5)
        
        print("✅ Set Date Submitted range!")
        
    except Exception as e:
        print(f"❌ Error setting dates: {e}")
    
    # Take screenshot to verify
    time.sleep(1)
    page.screenshot(path="correct_dates_set.png")
    print("📸 Check correct_dates_set.png")
    
    # Now click SUBMIT
    print("Clicking SUBMIT button...")
    try:
        page.locator("input[value='SUBMIT']").first.click()
        print("✅ Clicked SUBMIT!")
        
        time.sleep(10)
        page.screenshot(path="correct_search_results.png", full_page=True)
        print("📸 Results in correct_search_results.png")
        
        print(f"📍 Results URL: {page.url}")
        
    except Exception as e:
        print(f"❌ Submit failed: {e}")
    
    browser.close()