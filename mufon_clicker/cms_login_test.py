#!/usr/bin/env python3
"""
Test the actual MUFON CMS login URLs found in the HTML
"""
from playwright.sync_api import sync_playwright
import time

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        
        print("🔍 Testing Field Investigator CMS Login...")
        
        # Try the CMS login URL directly
        page.goto("https://www.mufoncms.com/", wait_until="domcontentloaded")
        time.sleep(3)
        
        # Take screenshot
        page.screenshot(path="cms_login_page.png", full_page=True)
        
        # Get all text content
        page_text = page.locator("body").inner_text()
        print("\n📝 CMS LOGIN PAGE TEXT:")
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
                
                print(f"  Input {i+1}:")
                print(f"    Type: {field_type}")
                print(f"    Name: {field_name}")
                print(f"    ID: {field_id}")
                print(f"    Placeholder: {field_placeholder}")
                print()
            except Exception as e:
                print(f"  Input {i+1}: Error reading - {e}")
        
        # Get all forms
        forms = page.locator("form").all()
        print(f"\n📋 FOUND {len(forms)} FORMS:")
        
        for i, form in enumerate(forms):
            try:
                action = form.get_attribute('action') or 'no_action'
                method = form.get_attribute('method') or 'GET'
                print(f"  Form {i+1}:")
                print(f"    Action: {action}")
                print(f"    Method: {method}")
                print()
            except Exception as e:
                print(f"  Form {i+1}: Error reading - {e}")
        
        print(f"\n📍 CMS URL: {page.url}")
        print("💾 Saved: cms_login_page.png")
        
        # Now try the Member Login URL
        print("\n\n🔍 Testing Member Login URL...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp", wait_until="domcontentloaded")
        time.sleep(3)
        
        page.screenshot(path="member_login_page.png", full_page=True)
        
        # Get all text content
        page_text = page.locator("body").inner_text()
        print("\n📝 MEMBER LOGIN PAGE TEXT:")
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
                
                print(f"  Input {i+1}:")
                print(f"    Type: {field_type}")
                print(f"    Name: {field_name}")
                print(f"    ID: {field_id}")
                print(f"    Placeholder: {field_placeholder}")
                print()
            except Exception as e:
                print(f"  Input {i+1}: Error reading - {e}")
        
        print(f"\n📍 Member URL: {page.url}")
        print("💾 Saved: member_login_page.png")
        
        browser.close()

if __name__ == "__main__":
    main()