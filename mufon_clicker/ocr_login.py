#!/usr/bin/env python3
"""
OCR the MUFON login page to see what fields are available
"""
from playwright.sync_api import sync_playwright
import time

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        
        print("📸 Taking screenshot of MUFON login page...")
        
        # Go to MUFON
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        time.sleep(2)
        
        # Click Member Login
        try:
            member_login = page.locator("text=MEMBER LOGIN").first
            if member_login.count() > 0:
                member_login.click()
                time.sleep(3)
                print("✅ Clicked MEMBER LOGIN")
            else:
                print("❌ MEMBER LOGIN not found")
        except Exception as e:
            print(f"Member Login click failed: {e}")
        
        # Take full page screenshot
        page.screenshot(path="mufon_login_full.png", full_page=True)
        
        # Get all text content
        page_text = page.locator("body").inner_text()
        print("\n📝 PAGE TEXT:")
        print("=" * 50)
        print(page_text)
        print("=" * 50)
        
        # Get all input fields
        inputs = page.locator("input").all()
        print(f"\n🔍 FOUND {len(inputs)} INPUT FIELDS:")
        
        for i, input_field in enumerate(inputs):
            try:
                field_type = input_field.get_attribute('type') or 'text'
                field_name = input_field.get_attribute('name') or f'unnamed_{i}'
                field_id = input_field.get_attribute('id') or 'no_id'
                field_placeholder = input_field.get_attribute('placeholder') or 'no_placeholder'
                field_value = input_field.get_attribute('value') or 'empty'
                
                print(f"  Input {i+1}:")
                print(f"    Type: {field_type}")
                print(f"    Name: {field_name}")
                print(f"    ID: {field_id}")
                print(f"    Placeholder: {field_placeholder}")
                print(f"    Value: {field_value}")
                print()
            except Exception as e:
                print(f"  Input {i+1}: Error reading - {e}")
        
        # Get all buttons
        buttons = page.locator("button, input[type='submit']").all()
        print(f"\n🔘 FOUND {len(buttons)} BUTTONS:")
        
        for i, button in enumerate(buttons):
            try:
                button_type = button.get_attribute('type') or 'button'
                button_text = button.inner_text() or 'no_text'
                button_value = button.get_attribute('value') or 'no_value'
                button_name = button.get_attribute('name') or 'unnamed'
                
                print(f"  Button {i+1}:")
                print(f"    Type: {button_type}")
                print(f"    Text: {button_text}")
                print(f"    Value: {button_value}")
                print(f"    Name: {button_name}")
                print()
            except Exception as e:
                print(f"  Button {i+1}: Error reading - {e}")
        
        # Save HTML for analysis
        with open("login_page.html", "w") as f:
            f.write(page.content())
        
        print(f"📍 Current URL: {page.url}")
        print("💾 Saved: mufon_login_full.png")
        print("💾 Saved: login_page.html")
        
        browser.close()

if __name__ == "__main__":
    main()