#!/usr/bin/env python3
"""
Working CMS login to access MUFON database search results
"""
from playwright.sync_api import sync_playwright
import time
def main():
    # Direct credentials
    username = "varak"
    password = "ufobeep123pass"
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        
        print("🔐 Logging into MUFON CMS...")
        
        # Go to CMS login
        page.goto("https://www.mufoncms.com/", wait_until="domcontentloaded")
        time.sleep(2)
        
        # Fill login form
        page.fill("input[name='username']", username)
        page.fill("input[name='password']", password)
        
        # Submit login
        page.click("input[type='submit']")
        time.sleep(5)
        
        print("✅ Login submitted")
        
        # Take screenshot of result
        page.screenshot(path="cms_after_login.png", full_page=True)
        
        # Check what we got
        page_text = page.locator("body").inner_text()
        print("\n📝 AFTER LOGIN PAGE TEXT:")
        print("=" * 50)
        print(page_text[:1000] + ("..." if len(page_text) > 1000 else ""))
        print("=" * 50)
        
        # Look for search forms or database access
        forms = page.locator("form").all()
        print(f"\n📋 FOUND {len(forms)} FORMS:")
        
        for i, form in enumerate(forms):
            try:
                action = form.get_attribute('action') or 'no_action'
                method = form.get_attribute('method') or 'GET'
                print(f"  Form {i+1}: {method} {action}")
            except Exception as e:
                print(f"  Form {i+1}: Error - {e}")
        
        # Look for links that might be database search
        links = page.locator("a").all()
        print(f"\n🔗 FOUND {len(links)} LINKS:")
        
        for i, link in enumerate(links):
            try:
                href = link.get_attribute('href') or ''
                text = link.inner_text().strip()
                if any(keyword in text.lower() for keyword in ['search', 'database', 'case', 'report']):
                    print(f"  Link {i+1}: '{text}' -> {href}")
            except Exception as e:
                continue
        
        # Save session state
        if "login" not in page.url.lower():
            print("\n✅ Login successful! Saving session...")
            os.makedirs("mufon_artifacts", exist_ok=True)
            context.storage_state(path="mufon_artifacts/cms_storage_state.json")
            print("💾 Saved: mufon_artifacts/cms_storage_state.json")
        else:
            print("\n❌ Still on login page - check credentials")
        
        print(f"\n📍 Current URL: {page.url}")
        print("📸 Check cms_after_login.png")
        
        # Keep browser open to explore
        input("Press Enter to continue exploring or Ctrl+C to exit...")
        
        browser.close()

if __name__ == "__main__":
    main()