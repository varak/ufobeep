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
    
    print("🎯 Just clicking SUBMIT to see what happens...")
    
    # Try clicking SUBMIT button directly
    try:
        page.click("input[value='SUBMIT']")
        print("✅ Clicked SUBMIT!")
        
        time.sleep(10)
        page.screenshot(path="submit_results.png", full_page=True)
        
        text = page.locator("body").inner_text()
        print(f"📍 URL after submit: {page.url}")
        
        if "case" in text.lower():
            print("🎉 Found case data!")
        elif "no records" in text.lower():
            print("⚠️ No records found")
        else:
            print("🤔 Unknown result, check submit_results.png")
            
    except Exception as e:
        print(f"❌ Failed to click SUBMIT: {e}")
        page.screenshot(path="submit_failed.png")
    
    browser.close()