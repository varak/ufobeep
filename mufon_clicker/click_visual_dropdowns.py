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
    
    print("🎯 Clicking on the VISUAL dropdown elements...")
    
    # Try clicking on the dropdown-looking elements by their position
    # Looking at the form, these are positioned after the labels
    
    try:
        # Let's try clicking on coordinates where the dropdowns appear to be
        # This is a bit hacky but might work for custom widgets
        
        print("Clicking on first month dropdown...")
        # Click where the first month dropdown should be (after "Date Submitted")
        page.mouse.click(360, 405)  # Approximate position
        time.sleep(1)
        
        # Try typing or using arrow keys to change value
        page.keyboard.press("ArrowDown")
        page.keyboard.press("ArrowDown") # Move to September
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        print("Trying day dropdown...")
        page.mouse.click(440, 405)  # Day dropdown position
        time.sleep(1)
        page.keyboard.press("ArrowDown") # Day 1
        page.keyboard.press("Enter")
        time.sleep(0.5)
        
        print("Trying year dropdown...")
        page.mouse.click(520, 405)  # Year dropdown position  
        time.sleep(1)
        page.keyboard.type("2025")
        page.keyboard.press("Enter")
        
        print("✅ Attempted to set first date range")
        
    except Exception as e:
        print(f"❌ Visual clicking failed: {e}")
    
    # Take screenshot to see what happened
    time.sleep(2)
    page.screenshot(path="visual_click_result.png")
    print("📸 Check visual_click_result.png")
    
    # Try the PAST 7 DAYS buttons as backup
    print("🔘 Trying PAST buttons as backup...")
    try:
        # Look for any element containing "PAST" and "DAYS"
        past_elements = page.locator("*").filter(has_text="PAST").filter(has_text="DAYS").all()
        print(f"Found {len(past_elements)} PAST elements")
        
        for elem in past_elements:
            try:
                text = elem.inner_text()
                if "7" in text or "PAST" in text:
                    print(f"Clicking: {text}")
                    elem.click()
                    time.sleep(1)
                    break
            except:
                pass
    except Exception as e:
        print(f"PAST buttons failed: {e}")
    
    # Final attempt - just click SUBMIT to see what happens with empty form
    print("🚀 Final attempt - clicking SUBMIT...")
    try:
        page.click("text=SUBMIT")
        print("✅ Clicked SUBMIT by text!")
        
        time.sleep(10)
        page.screenshot(path="empty_form_submit.png", full_page=True)
        print("📸 Empty form results in empty_form_submit.png")
        
    except Exception as e:
        print(f"Even SUBMIT by text failed: {e}")
    
    browser.close()