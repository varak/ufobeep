#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta

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
    
    print("🪄 Using JavaScript magic to fill the form...")
    
    yesterday = datetime.now() - timedelta(days=1)
    today = datetime.now()
    
    # JavaScript magic to set the dropdowns
    js_code = f"""
    // Find all select elements
    var selects = document.querySelectorAll('select');
    console.log('Found', selects.length, 'select elements');
    
    // Date Submitted FROM (first 3 selects: month, day, year)
    if (selects.length >= 6) {{
        selects[0].value = '{yesterday.month}';
        selects[0].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        selects[1].value = '{yesterday.day}';
        selects[1].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        selects[2].value = '{yesterday.year}';
        selects[2].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        // Date Submitted TO
        selects[3].value = '{today.month}';
        selects[3].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        selects[4].value = '{today.day}';
        selects[4].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        selects[5].value = '{today.year}';
        selects[5].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        console.log('Set Date Submitted range');
    }}
    
    // Date of Event (next 6 selects)
    if (selects.length >= 12) {{
        selects[6].value = '{yesterday.month}';
        selects[6].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        selects[7].value = '{yesterday.day}';
        selects[7].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        selects[8].value = '{yesterday.year}';
        selects[8].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        selects[9].value = '{today.month}';
        selects[9].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        selects[10].value = '{today.day}';
        selects[10].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        selects[11].value = '{today.year}';
        selects[11].dispatchEvent(new Event('change', {{ bubbles: true }}));
        
        console.log('Set Date of Event range');
    }}
    
    // Return success
    'Form filled with magic!';
    """
    
    # Execute the magic
    result = page.evaluate(js_code)
    print(f"✨ {result}")
    
    time.sleep(2)
    
    # Take screenshot to see if it worked
    page.screenshot(path="magic_filled.png")
    print("📸 Check magic_filled.png")
    
    # Now try to submit with more magic
    print("🚀 Using magic to submit...")
    
    submit_js = """
    // Find submit button and click it
    var submitBtn = document.querySelector('input[value="SUBMIT"]');
    if (submitBtn) {
        submitBtn.click();
        return 'Submit clicked!';
    }
    
    // Try form submission
    var forms = document.querySelectorAll('form');
    if (forms.length > 0) {
        forms[0].submit();
        return 'Form submitted!';
    }
    
    return 'No submit method found';
    """
    
    submit_result = page.evaluate(submit_js)
    print(f"✨ {submit_result}")
    
    # Wait for results
    print("⏳ Waiting for magic results...")
    time.sleep(10)
    
    page.screenshot(path="magic_results.png", full_page=True)
    print("📸 Magic results in magic_results.png")
    
    # Save text results
    text = page.locator("body").inner_text()
    with open("magic_results.txt", "w") as f:
        f.write(f"Search: {yesterday.strftime('%m/%d/%Y')} to {today.strftime('%m/%d/%Y')}\n")
        f.write(f"URL: {page.url}\n\n")
        f.write(text)
    
    print(f"📍 Final URL: {page.url}")
    
    # Check for case results
    if "case" in text.lower() and "ufo" in text.lower():
        print("🎉 MAGIC WORKED! Found UFO cases!")
    elif "no records" in text.lower():
        print("⚠️ Magic worked but no records found for date range")
    else:
        print("🤔 Magic attempted, check results...")
    
    browser.close()