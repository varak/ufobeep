#!/usr/bin/env python3
"""
Simple test - just click one VIEW button to see what happens
"""
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
    
    # Go to search and submit
    page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
    time.sleep(5)
    
    # Quick search - just click submit to get any results
    print("🚀 Clicking submit to get results...")
    page.mouse.click(633, 341)  # SUBMIT
    time.sleep(10)
    
    page.screenshot(path="before_view_click.png")
    print("📸 Saved before_view_click.png")
    
    # Try to click the first VIEW button
    print("🔍 Looking for first VIEW button...")
    try:
        # Try clicking by text first
        page.click("text=VIEW", timeout=5000)
        print("✅ Clicked VIEW by text!")
        
        time.sleep(5)
        page.screenshot(path="after_view_click.png")
        print("📸 Saved after_view_click.png")
        
        text = page.locator("body").inner_text()
        with open("view_page_content.txt", "w") as f:
            f.write(text)
        
        print("💾 Saved view_page_content.txt")
        print(f"📍 URL after VIEW click: {page.url}")
        
        if "description" in text.lower():
            print("🎉 Found description content!")
        
    except Exception as e:
        print(f"❌ Error clicking VIEW: {e}")
        
        # Try alternative - find all links and look for VIEW
        links = page.locator("a").all()
        print(f"Found {len(links)} links, looking for VIEW...")
        
        for i, link in enumerate(links):
            try:
                text = link.inner_text().strip()
                if text == "VIEW":
                    print(f"Found VIEW link at index {i}")
                    link.click()
                    time.sleep(5)
                    page.screenshot(path="view_clicked_alt.png")
                    print("📸 Saved view_clicked_alt.png")
                    break
            except:
                continue
    
    browser.close()