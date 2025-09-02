#!/usr/bin/env python3
"""
Use existing storage_state.json to get to MUFON search results
"""
from playwright.sync_api import sync_playwright
import json
import time

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        
        # Load existing authenticated session
        context = browser.new_context(storage_state="mufon_artifacts/storage_state.json")
        page = context.new_page()
        
        print("🔑 Using existing auth session...")
        
        # Try direct URL to MUFON CMS search 
        page.goto("https://mufoncms.com/last_20_public.html", wait_until="domcontentloaded")
        time.sleep(3)
        
        current_url = page.url
        print(f"📍 Current URL: {current_url}")
        
        # Take screenshot
        page.screenshot(path="auth_result.png", full_page=True)
        
        # Look for table with cases
        try:
            rows = page.locator("tr").all()
            print(f"📊 Found {len(rows)} table rows")
            
            # Look for VIEW buttons/links
            view_elements = page.locator("text=VIEW").all()
            print(f"👁️ Found {len(view_elements)} VIEW elements")
            
            if view_elements:
                print("✅ SUCCESS: Found VIEW buttons - this page has case data!")
                
                # Extract some case data
                for i, view in enumerate(view_elements[:3]):  # First 3
                    try:
                        # Get parent row
                        row = view.locator("xpath=ancestor::tr[1]")
                        row_text = row.inner_text()
                        print(f"  Case {i+1}: {row_text[:100]}...")
                    except Exception as e:
                        print(f"  Case {i+1}: Error extracting - {e}")
                
                # Save working URL
                with open("working_results_url.txt", "w") as f:
                    f.write(current_url)
                print(f"💾 Saved working URL: {current_url}")
                
            else:
                print("❌ No VIEW elements found")
                
        except Exception as e:
            print(f"❌ Error checking for cases: {e}")
            
        # Save page content
        content = page.content()
        with open("auth_page_content.html", "w") as f:
            f.write(content)
            
        browser.close()

if __name__ == "__main__":
    main()