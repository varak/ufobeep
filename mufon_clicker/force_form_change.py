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
    page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=9&")
    time.sleep(5)
    
    print("💪 FORCING the form to change with extreme JavaScript...")
    
    # Nuclear option - force change all possible form elements
    force_js = """
    // Force change all selects
    const selects = document.querySelectorAll('select');
    console.log('Forcing', selects.length, 'selects');
    
    selects.forEach((select, i) => {
        // Try all possible month/day/year values
        const options = select.querySelectorAll('option');
        if (options.length > 1) {
            let value = '';
            if (i % 3 === 0) value = '9';      // Month (September)
            else if (i % 3 === 1) value = '1'; // Day
            else value = '2025';               // Year
            
            // Try to find matching option
            for (let opt of options) {
                if (opt.value === value || opt.textContent.includes(value)) {
                    select.value = opt.value;
                    select.selectedIndex = opt.index;
                    break;
                }
            }
            
            // Fire all events
            ['focus', 'click', 'change', 'blur', 'input'].forEach(eventType => {
                select.dispatchEvent(new Event(eventType, { bubbles: true }));
            });
        }
    });
    
    // Also try clicking PAST buttons
    const pastButtons = document.querySelectorAll('input[type="button"]');
    pastButtons.forEach(btn => {
        if (btn.value && btn.value.includes('PAST') && btn.value.includes('DAYS')) {
            console.log('Clicking PAST button:', btn.value);
            btn.click();
        }
    });
    
    // Force form submission if possible
    setTimeout(() => {
        const submitBtn = document.querySelector('input[value="SUBMIT"]');
        if (submitBtn) {
            console.log('Auto-clicking SUBMIT');
            submitBtn.click();
        }
    }, 3000);
    
    'Nuclear form modification complete!';
    """
    
    result = page.evaluate(force_js)
    print(f"💥 {result}")
    
    # Wait and take screenshots
    time.sleep(2)
    page.screenshot(path="forced_form.png")
    print("📸 Check forced_form.png")
    
    # Wait for auto-submit
    time.sleep(5)
    page.screenshot(path="auto_submit_result.png", full_page=True)
    print("📸 Check auto_submit_result.png")
    
    # Check results
    text = page.locator("body").inner_text()
    print(f"📍 Final URL: {page.url}")
    
    if "case" in text.lower():
        print("🎉 SUCCESS! Found case data!")
    elif "no records" in text.lower():
        print("⚠️ Form worked but no records found")
    elif page.url != "https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=9&":
        print("✅ URL changed - something happened!")
    else:
        print("🤔 Still working on it...")
    
    browser.close()