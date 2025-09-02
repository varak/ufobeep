#!/usr/bin/env python3
"""
Test member login system and find database search
"""
from playwright.sync_api import sync_playwright
import time

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        
        print("🔐 Testing Member Login...")
        
        # Go to member login
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp", wait_until="domcontentloaded")
        time.sleep(2)
        
        # Fill login form
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        
        # Submit login - click "Log In" button
        page.click("text=Log In")
        time.sleep(5)
        
        print("✅ Member login submitted")
        
        # Take screenshot
        page.screenshot(path="member_after_login.png", full_page=True)
        
        # Check what we got
        page_text = page.locator("body").inner_text()
        print("\n📝 AFTER MEMBER LOGIN:")
        print("=" * 50)
        print(page_text[:1500] + ("..." if len(page_text) > 1500 else ""))
        print("=" * 50)
        
        # Look for database/search related links
        links = page.locator("a").all()
        print(f"\n🔗 SEARCHING {len(links)} LINKS FOR DATABASE ACCESS:")
        
        database_links = []
        for i, link in enumerate(links):
            try:
                href = link.get_attribute('href') or ''
                text = link.inner_text().strip()
                if any(keyword in text.lower() for keyword in ['track', 'search', 'database', 'case', 'report', 'ufo']):
                    print(f"  ✅ '{text}' -> {href}")
                    database_links.append((text, href))
            except Exception as e:
                continue
        
        # Try to find and click "Track UFOs" or similar
        if database_links:
            for text, href in database_links:
                if 'track' in text.lower() or 'search' in text.lower():
                    print(f"\n🎯 Trying to click: {text}")
                    try:
                        page.click(f"text={text}")
                        time.sleep(5)
                        
                        # Take screenshot after click
                        page.screenshot(path=f"after_click_{text.replace(' ', '_').lower()}.png", full_page=True)
                        
                        # Check if we got to a search page
                        new_text = page.locator("body").inner_text()
                        print(f"\n📝 AFTER CLICKING '{text}':")
                        print("=" * 30)
                        print(new_text[:1000] + ("..." if len(new_text) > 1000 else ""))
                        print("=" * 30)
                        
                        break
                    except Exception as e:
                        print(f"❌ Failed to click {text}: {e}")
        
        # Save session if successful
        if "login" not in page.url.lower():
            print("\n✅ Login successful! Saving session...")
            import os
            os.makedirs("mufon_artifacts", exist_ok=True)
            context.storage_state(path="mufon_artifacts/member_storage_state.json")
            print("💾 Saved: mufon_artifacts/member_storage_state.json")
        
        print(f"\n📍 Final URL: {page.url}")
        
        # Close browser
        time.sleep(2)
        browser.close()

if __name__ == "__main__":
    main()