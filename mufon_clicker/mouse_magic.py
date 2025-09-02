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
    
    print("🖱️ Using mouse magic to interact with the dropdowns...")
    
    # Get all select elements
    selects = page.locator("select").all()
    print(f"Found {len(selects)} select dropdowns")
    
    if len(selects) >= 6:
        # Try to interact with the first dropdown (Date Submitted Month)
        print("Clicking on first dropdown (Date Submitted Month)...")
        try:
            # Hover over it first
            selects[0].hover()
            time.sleep(0.5)
            
            # Click it
            selects[0].click()
            time.sleep(1)
            
            # Try to select September (month 9)
            selects[0].select_option("9")
            time.sleep(0.5)
            
            print("✅ Selected month 9")
            
            # Move to day dropdown
            selects[1].click()
            time.sleep(0.5)
            selects[1].select_option("1")  # Day 1
            print("✅ Selected day 1")
            
            # Move to year dropdown  
            selects[2].click()
            time.sleep(0.5)
            selects[2].select_option("2025")
            print("✅ Selected year 2025")
            
            # Take screenshot to see if it worked
            page.screenshot(path="mouse_magic_attempt.png")
            print("📸 Check mouse_magic_attempt.png")
            
        except Exception as e:
            print(f"❌ Mouse magic failed: {e}")
            page.screenshot(path="mouse_magic_failed.png")
    
    # Try clicking one of the PAST buttons instead
    print("🔘 Trying PAST 7 DAYS buttons...")
    try:
        # Look for buttons with "PAST" in the text
        past_buttons = page.locator("input[type='button']").all()
        
        for btn in past_buttons:
            try:
                value = btn.get_attribute('value') or ''
                if 'PAST' in value and 'DAYS' in value:
                    print(f"Found PAST button: {value}")
                    btn.click()
                    time.sleep(1)
                    break
            except:
                pass
                
        page.screenshot(path="after_past_button.png")
        print("📸 Check after_past_button.png")
        
    except Exception as e:
        print(f"❌ PAST button failed: {e}")
    
    browser.close()