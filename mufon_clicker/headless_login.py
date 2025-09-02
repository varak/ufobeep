#!/usr/bin/env python3
"""
Simple headless Playwright login to MUFON and get to search results
"""
import os
import time
from playwright.sync_api import sync_playwright

def main():
    # Get credentials
    user = "varak"  
    password = "ufobeep123pass"
    
    with sync_playwright() as p:
        # Launch headless browser
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()
        
        print("🔐 Logging into MUFON...")
        
        # Go to the working MUFON login path from successful script
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        time.sleep(1)
        
        # Click Member Login (like the working authenticated client)
        page.click("text=Member Login")
        page.wait_for_load_state("domcontentloaded")
        time.sleep(1)
        
        # Fill login form (using the working field names from authenticated client)
        page.fill("input[name='loginName']", user)
        page.fill("input[name='loginPassword']", password)
        page.click("button:has-text('Sign In')")
        
        print("✅ Login submitted, waiting for page load...")
        page.wait_for_load_state("domcontentloaded")
        time.sleep(3)
        
        # Check current URL and page content
        current_url = page.url
        print(f"📍 Current URL: {current_url}")
        
        # Take screenshot to see what we got
        page.screenshot(path="headless_login_result.png")
        
        # Look for search or database elements
        try:
            # Try to find search database link
            db_links = page.locator("a:has-text('Database')").all()
            if db_links:
                print(f"🔍 Found {len(db_links)} database links")
                for i, link in enumerate(db_links):
                    href = link.get_attribute("href")
                    text = link.inner_text()
                    print(f"  Link {i+1}: '{text}' → {href}")
        except Exception as e:
            print(f"❌ Error looking for database links: {e}")
        
        # Try to find any UFO/case related content
        try:
            case_elements = page.locator("text=case").all()[:5]  # First 5
            print(f"📋 Found {len(case_elements)} case-related elements")
        except Exception:
            pass
            
        # Save page content for debugging
        content = page.content()
        with open("headless_page_content.html", "w") as f:
            f.write(content)
        
        print("💾 Saved screenshot and page content for debugging")
        print("🎯 Check headless_login_result.png to see what page we landed on")
        
        browser.close()

if __name__ == "__main__":
    main()