#!/usr/bin/env python3
"""
Fresh MUFON login using Playwright to get working cookies
"""
from playwright.sync_api import sync_playwright
import json

def login_to_mufon():
    with sync_playwright() as p:
        # Use head mode to see what's happening
        browser = p.chromium.launch(headless=False)
        page = browser.new_page()
        
        print("🌐 Going to MUFON login page...")
        page.goto("https://mufon.app.neoncrm.com/np/signIn.do")
        
        # Wait for page to load
        page.wait_for_load_state('networkidle')
        
        # Take screenshot to see the login form
        page.screenshot(path="login_page_screenshot.png")
        print("📸 Screenshot saved as login_page_screenshot.png")
        
        print("🔐 Filling login form...")
        # Fill the login form
        page.fill('input[name="loginName"]', 'varak')
        page.fill('input[name="loginPassword"]', 'ufobeep123pass')
        
        # Take screenshot after filling
        page.screenshot(path="login_filled_screenshot.png")
        print("📸 Filled form screenshot saved")
        
        # Find and click the actual login button
        print("📤 Looking for login button...")
        
        # Try different login button selectors
        login_selectors = [
            'input[value*="Sign In"]',
            'input[value*="Login"]', 
            'input[value*="Log In"]',
            'button:has-text("Sign In")',
            'button:has-text("Login")',
            'input[type="submit"]'
        ]
        
        clicked = False
        for selector in login_selectors:
            try:
                if page.locator(selector).is_visible():
                    print(f"Found login button: {selector}")
                    page.click(selector, timeout=5000)
                    clicked = True
                    break
            except:
                continue
        
        if not clicked:
            print("⚠️ Couldn't find login button, trying Enter key")
            page.press('input[name="loginPassword"]', 'Enter')
        
        # Wait for login to complete
        page.wait_for_load_state('networkidle')
        
        # Check if we're logged in
        if "dashboard" in page.url.lower() or "member" in page.url.lower():
            print("✅ Successfully logged in!")
        else:
            print("⚠️ Login may have failed, but saving cookies anyway")
        
        # Save the storage state with fresh cookies
        storage_state = page.context.storage_state()
        
        with open('mufon_artifacts/storage_state.json', 'w') as f:
            json.dump(storage_state, f, indent=2)
        
        print("💾 Saved fresh cookies to storage_state.json")
        
        # Navigate to the search page to make sure we can access it
        print("🔍 Testing search page access...")
        page.goto("https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19")
        page.wait_for_load_state('networkidle')
        
        if "signIn" not in page.url:
            print("✅ Can access search page - authentication working")
        else:
            print("❌ Still redirected to login - authentication failed")
        
        browser.close()

if __name__ == "__main__":
    login_to_mufon()