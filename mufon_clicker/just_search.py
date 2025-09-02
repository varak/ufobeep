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
    
    # Go to search
    page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
    time.sleep(5)
    
    # Click the PAST 7 DAYS buttons
    try:
        page.locator("input[value='PAST 7 DAYS']").first.click()
        time.sleep(1)
    except:
        pass
    
    try:
        page.locator("input[value='PAST 7 DAYS']").last.click()
        time.sleep(1)
    except:
        pass
    
    # Click SUBMIT
    page.locator("input[value='SUBMIT']").first.click()
    print("Submitted search")
    
    time.sleep(10)
    page.screenshot(path="final.png")
    
    browser.close()