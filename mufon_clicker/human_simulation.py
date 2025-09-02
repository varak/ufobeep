#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False, slow_mo=500)  # Slow like human
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
    
    print("👤 Simulating human interaction...")
    
    # Get all select elements
    selects = page.locator("select").all()
    print(f"Found {len(selects)} dropdowns")
    
    # Human approach: Click dropdown, wait, select option
    for i, select in enumerate(selects[:6]):  # First 6 for date fields
        try:
            print(f"Human clicking dropdown {i+1}...")
            
            # Click to open dropdown (like human)
            select.click()
            time.sleep(1)  # Human pause
            
            # Get all options in this dropdown
            options = select.locator("option").all()
            print(f"  Dropdown {i+1} has {len(options)} options")
            
            # Select appropriate value based on position
            if i == 0 or i == 3:  # Month fields
                target = "9"  # September
            elif i == 1 or i == 4:  # Day fields  
                target = "1"  # 1st
            else:  # Year fields
                target = "2025"
                
            # Human looks for the right option
            for option in options:
                try:
                    value = option.get_attribute('value') or ''
                    text = option.inner_text() or ''
                    if target in value or target in text:
                        print(f"  Human selecting: {text}")
                        option.click()
                        time.sleep(0.5)  # Human pause
                        break
                except:
                    pass
                    
        except Exception as e:
            print(f"  Error with dropdown {i+1}: {e}")
            continue
    
    # Human takes a moment to review
    time.sleep(2)
    page.screenshot(path="human_filled_form.png")
    print("📸 Human reviewed form - saved human_filled_form.png")
    
    # Human clicks SUBMIT
    print("👤 Human clicking SUBMIT...")
    try:
        page.click("input[value='SUBMIT']")
        print("✅ Human clicked SUBMIT!")
        
        # Human waits for results
        time.sleep(10)
        page.screenshot(path="human_search_results.png", full_page=True)
        print("📸 Human got results - saved human_search_results.png")
        
        # Human reads the results
        text = page.locator("body").inner_text()
        if "case" in text.lower():
            print("🎉 Human found UFO cases!")
        elif "no records" in text.lower():
            print("😔 Human found no records")
        else:
            print("🤔 Human is confused by results")
            
    except Exception as e:
        print(f"❌ Human failed to submit: {e}")
    
    print(f"📍 Human ended up at: {page.url}")
    browser.close()