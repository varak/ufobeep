#!/usr/bin/env python3
"""
Debug script to identify the actual form structure for date fields
"""
from playwright.sync_api import sync_playwright
import time

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        
        # Fresh login
        context = browser.new_context()
        page = context.new_page()
        
        print("🔐 Logging in...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(2)
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        
        print("🔍 Going to search page...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # Take full page screenshot first
        print("📸 Taking full page screenshot...")
        page.screenshot(path="form_debug_full.png", full_page=True)
        
        # Get iframe
        iframe = page.frame_locator("iframe")
        
        # Take iframe screenshot  
        print("📸 Taking iframe screenshot...")
        page.screenshot(path="form_debug_iframe.png")
        
        # Get all form elements in iframe
        print("🔍 Analyzing iframe form elements...")
        
        # Get page HTML content
        print("📝 Getting iframe HTML...")
        iframe_html = iframe.locator("body").inner_html()
        with open("iframe_form.html", "w") as f:
            f.write(iframe_html)
        
        # Get all input elements
        inputs = iframe.locator("input").all()
        print(f"\n📋 Found {len(inputs)} input elements:")
        
        for i, inp in enumerate(inputs):
            try:
                inp_type = inp.get_attribute('type') or 'text'
                inp_name = inp.get_attribute('name') or 'no_name'
                inp_id = inp.get_attribute('id') or 'no_id'
                inp_value = inp.get_attribute('value') or 'empty'
                inp_placeholder = inp.get_attribute('placeholder') or 'no_placeholder'
                
                print(f"  Input {i+1}:")
                print(f"    Type: {inp_type}")
                print(f"    Name: {inp_name}")
                print(f"    ID: {inp_id}")
                print(f"    Value: {inp_value}")
                print(f"    Placeholder: {inp_placeholder}")
                print()
            except Exception as e:
                print(f"  Input {i+1}: Error - {e}")
        
        # Get all select elements
        selects = iframe.locator("select").all()
        print(f"\n📋 Found {len(selects)} select elements:")
        
        for i, sel in enumerate(selects):
            try:
                sel_name = sel.get_attribute('name') or 'no_name'
                sel_id = sel.get_attribute('id') or 'no_id'
                
                # Get options
                options = sel.locator("option").all()
                option_values = []
                for opt in options[:5]:  # First 5 options
                    try:
                        opt_value = opt.get_attribute('value') or 'no_value'
                        opt_text = opt.inner_text() or 'no_text'
                        option_values.append(f"{opt_text}={opt_value}")
                    except:
                        continue
                
                print(f"  Select {i+1}:")
                print(f"    Name: {sel_name}")
                print(f"    ID: {sel_id}")
                print(f"    Options (first 5): {', '.join(option_values)}")
                print()
                
            except Exception as e:
                print(f"  Select {i+1}: Error - {e}")
        
        # Get all text content to look for date patterns
        print("📝 Getting all visible text...")
        page_text = iframe.locator("body").inner_text()
        
        # Look for date-related text
        date_keywords = ['date', 'Date', 'month', 'Month', 'day', 'Day', 'year', 'Year', 'from', 'to', 'range']
        found_keywords = []
        
        for keyword in date_keywords:
            if keyword in page_text:
                found_keywords.append(keyword)
        
        print(f"🔍 Found date-related keywords: {found_keywords}")
        
        # Save text content
        with open("form_text_content.txt", "w") as f:
            f.write(page_text)
        
        print("\n📋 Debug files created:")
        print("  - form_debug_full.png (full page)")
        print("  - form_debug_iframe.png (iframe view)")
        print("  - iframe_form.html (form HTML)")
        print("  - form_text_content.txt (visible text)")
        
        browser.close()

if __name__ == "__main__":
    main()