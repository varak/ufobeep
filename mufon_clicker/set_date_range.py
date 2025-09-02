#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False, slow_mo=500)
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
    
    print("📅 Setting date range: Feb 1, 2025 to Feb 2, 2025...")
    
    # Set FROM date - Feb 1, 2025
    print("Setting FROM date (Feb 1, 2025)...")
    page.mouse.click(360, 405)  # Month dropdown
    page.keyboard.press("ArrowDown")  # February 
    page.keyboard.press("ArrowDown")
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(440, 405)  # Day dropdown  
    page.keyboard.press("ArrowDown")  # Day 1
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(520, 405)  # Year dropdown
    page.keyboard.type("2025")
    page.keyboard.press("Enter")
    time.sleep(1)
    
    # Set TO date - Feb 2, 2025
    print("Setting TO date (Feb 2, 2025)...")
    page.mouse.click(590, 405)  # TO Month dropdown (further right)
    page.keyboard.press("ArrowDown")  # February
    page.keyboard.press("ArrowDown") 
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(670, 405)  # TO Day dropdown
    page.keyboard.press("ArrowDown")  # Day 1
    page.keyboard.press("ArrowDown")  # Day 2
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(750, 405)  # TO Year dropdown
    page.keyboard.type("2025")
    page.keyboard.press("Enter")
    time.sleep(1)
    
    print("✅ Date range set!")
    
    # Take screenshot to verify both dates
    page.screenshot(path="date_range_set.png")
    print("📸 Check date_range_set.png")
    
    # Submit search
    print("🚀 Submitting search with date range...")
    page.mouse.click(633, 341)  # SUBMIT button
    time.sleep(10)
    
    # Take final screenshot
    page.screenshot(path="feb_search_results.png", full_page=True)
    print("📸 Results in feb_search_results.png")
    
    # Check results
    text = page.locator("body").inner_text()
    if "Cases Found" in text:
        import re
        cases_match = re.search(r'Cases Found = (\d+)', text)
        if cases_match:
            print(f"🎉 Found {cases_match.group(1)} cases in Feb 1-2, 2025!")
    
    print(f"📍 Results URL: {page.url}")
    
    browser.close()