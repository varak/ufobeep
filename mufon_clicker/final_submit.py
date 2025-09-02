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
    
    # Set dates using the method that worked
    print("🎯 Setting dates using visual clicking...")
    page.mouse.click(360, 405)  # Month dropdown
    page.keyboard.press("ArrowDown")
    page.keyboard.press("ArrowDown") 
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(440, 405)  # Day dropdown
    page.keyboard.press("ArrowDown")
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(520, 405)  # Year dropdown
    page.keyboard.type("2025")
    page.keyboard.press("Enter")
    time.sleep(1)
    
    print("✅ Dates set!")
    
    # Now click SUBMIT - it's visible in the form
    print("🚀 Clicking SUBMIT button...")
    
    # Try clicking the actual SUBMIT button by coordinates since selectors don't work
    page.mouse.click(633, 341)  # Approximate position of SUBMIT button
    print("✅ Clicked SUBMIT!")
    
    # Wait for results
    time.sleep(15)
    page.screenshot(path="FINAL_RESULTS.png", full_page=True)
    
    text = page.locator("body").inner_text()
    with open("FINAL_RESULTS.txt", "w") as f:
        f.write(f"Final URL: {page.url}\n\n")
        f.write(text)
    
    print(f"📍 Final URL: {page.url}")
    
    if "case" in text.lower():
        print("🎉 SUCCESS! Found UFO cases!")
    elif "no records" in text.lower():
        print("⚠️ No records found for date range")
    elif page.url != "https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&":
        print("✅ URL changed - search was submitted!")
    else:
        print("🤔 Check FINAL_RESULTS.png")
    
    browser.close()