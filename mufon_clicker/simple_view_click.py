#!/usr/bin/env python3
"""
Very simple - just get results and click first VIEW button
"""
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
    
    # Go to search
    page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
    time.sleep(5)
    
    # Just click submit with no date filters to get any results
    print("Getting results...")
    page.mouse.click(633, 341)  # SUBMIT
    time.sleep(15)
    
    # Take screenshot of results
    page.screenshot(path="results_ready.png")
    print("📸 Results ready - check results_ready.png")
    
    # Look for VIEW text on the page
    page_text = page.locator("body").inner_text()
    if "VIEW" in page_text:
        print("✅ Found VIEW text on page")
        view_count = page_text.count("VIEW")
        print(f"Found {view_count} instances of VIEW")
    else:
        print("❌ No VIEW text found")
    
    # Try to find and click the first VIEW link
    print("Looking for VIEW links...")
    view_links = page.locator("a:has-text('VIEW')").all()
    print(f"Found {len(view_links)} VIEW links")
    
    if view_links:
        print("🔍 Clicking first VIEW link...")
        view_links[0].click()
        time.sleep(5)
        
        # Take screenshot after click
        page.screenshot(path="view_result.png", full_page=True)
        print("📸 After VIEW click - check view_result.png")
        
        print(f"📍 URL after VIEW: {page.url}")
        
        # Save page content
        view_text = page.locator("body").inner_text()
        with open("view_content.txt", "w") as f:
            f.write(view_text)
        print("💾 Saved view_content.txt")
        
        # Look for description content
        if "description" in view_text.lower():
            print("🎉 SUCCESS! Found description content")
        else:
            print("⚠️ Clicked VIEW but no clear description found")
    else:
        print("❌ No VIEW links found")
    
    browser.close()