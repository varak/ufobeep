#!/usr/bin/env python3
"""
Direct access to MUFON search database using authenticated session
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta
import json

def main():
    # Target date (one day backwards)
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
    today = datetime.now().strftime("%Y-%m-%d")
    
    print(f"🎯 Target dates: {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        # Use the authenticated session we saved
        context = browser.new_context(storage_state="mufon_artifacts/member_storage_state.json")
        page = context.new_page()
        
        print("🔑 Going directly to MUFON search database...")
        
        # Go directly to the search database URL we found in the logs
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", wait_until="domcontentloaded")
        time.sleep(5)
        
        # Take screenshot
        page.screenshot(path="direct_search_page.png", full_page=True)
        
        # Get page content
        page_text = page.locator("body").inner_text()
        print("\n📝 DIRECT SEARCH DATABASE PAGE:")
        print("=" * 50)
        print(page_text[:2000] + ("..." if len(page_text) > 2000 else ""))
        print("=" * 50)
        
        # Look for all input fields
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
        
        # Look for select dropdowns
        selects = page.locator("select").all()
        print(f"\n📋 FOUND {len(selects)} SELECT DROPDOWNS:")
        
        for i, select in enumerate(selects):
            try:
                select_name = select.get_attribute('name') or f'unnamed_{i}'
                options = select.locator("option").all()
                print(f"  Select {i+1}: {select_name}")
                
                for j, option in enumerate(options):
                    value = option.get_attribute('value') or ''
                    text = option.inner_text()
                    print(f"    Option {j+1}: {value} -> {text}")
                print()
            except Exception as e:
                print(f"  Select {i+1}: Error reading - {e}")
        
        # Look for buttons
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
        
        print(f"\n📍 Current URL: {page.url}")
        print("💾 Saved: direct_search_page.png")
        
        # Keep browser open for manual exploration
        time.sleep(5)
        browser.close()

if __name__ == "__main__":
    main()