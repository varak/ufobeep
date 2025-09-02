#!/usr/bin/env python3
"""
Get the REAL authenticated MUFON internal database with VIEW buttons
"""
from playwright.sync_api import sync_playwright
import time
import json

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)  # Visible so we can see what's happening
        context = browser.new_context(storage_state="mufon_artifacts/storage_state.json")
        page = context.new_page()
        
        print("🔑 Using authenticated session...")
        
        # Go to main MUFON member portal
        page.goto("https://mufon.app.neoncrm.com/np/clients/mufon/memberHome.do", wait_until="domcontentloaded")
        time.sleep(3)
        
        page.screenshot(path="member_portal.png", full_page=True)
        print("📸 Screenshot 1: Member portal")
        
        # Look for database search - try multiple approaches
        try:
            # Method 1: Look for database/search links
            print("🔍 Looking for database search...")
            links = page.locator("a").all()
            for link in links:
                text = link.inner_text().lower()
                if any(keyword in text for keyword in ['database', 'search', 'case', 'report']):
                    href = link.get_attribute('href') or ''
                    print(f"  Found: '{text}' -> {href}")
                    
            # Method 2: Try the dropdown that was working before
            try:
                dropdown = page.locator("select[name='choice']").first
                if dropdown.count() > 0:
                    options = dropdown.locator("option").all()
                    print("📋 Dropdown options:")
                    for opt in options:
                        value = opt.get_attribute('value') or ''
                        text = opt.inner_text()
                        print(f"  {value} -> {text}")
                        
                        # Look for CMS or database options
                        if 'cms' in value.lower() or 'database' in text.lower():
                            print(f"🎯 Selecting: {text}")
                            dropdown.select_option(value)
                            page.locator("input[type='submit']").first.click()
                            page.wait_for_load_state("domcontentloaded")
                            time.sleep(3)
                            break
            except Exception as e:
                print(f"Dropdown error: {e}")
                
        except Exception as e:
            print(f"Search error: {e}")
            
        # Take another screenshot
        page.screenshot(path="after_search.png", full_page=True)
        print("📸 Screenshot 2: After search attempt")
        
        # Save current URL and content
        current_url = page.url
        print(f"📍 Current URL: {current_url}")
        
        # Look for VIEW buttons or case details
        view_buttons = page.locator("text=VIEW").all()
        case_links = page.locator("a:has-text('143')").all()  # Case numbers start with 143
        
        print(f"👁️ Found {len(view_buttons)} VIEW buttons")
        print(f"🔢 Found {len(case_links)} case number links")
        
        if view_buttons or case_links:
            print("✅ SUCCESS: Found case interface!")
            
            # Save this URL as the working results URL
            with open("working_auth_url.txt", "w") as f:
                f.write(current_url)
                
        else:
            print("❌ Still no case interface found")
            
        # Save page content for debugging
        with open("auth_page_debug.html", "w") as f:
            f.write(page.content())
            
        print("\n🔍 Manual check: Look at member_portal.png and after_search.png")
        print("📋 Check auth_page_debug.html for available links")
        
        browser.close()

if __name__ == "__main__":
    main()