#!/usr/bin/env python3
"""
MUFON Hybrid Extractor - Replicate EXACT working httpx flow in Playwright
Final attempt before asking ChatGPT!
"""
from playwright.sync_api import sync_playwright
import json
import time
import re

def main():
    """Replicate the EXACT working httpx flow but with Playwright for VIEW clicking"""
    print("🐱 Final attempt: Hybrid httpx→Playwright approach")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)  
        context = browser.new_context()
        page = context.new_page()
        
        try:
            # Step 1: Go to research page (like httpx does)
            print("Step 1: Going to MUFON research page...")
            page.goto("https://mufon.com/research/")
            
            # Step 2: Find and click Member Login (like httpx does)
            print("Step 2: Looking for Member Login...")
            login_links = page.locator("a:has-text('Member Login')").all()
            if login_links:
                login_links[0].click()
                page.wait_for_load_state("domcontentloaded")
                print("✅ Clicked Member Login")
                
                # Step 3: Fill login form (like httpx does)
                print("Step 3: Filling login form...")
                page.fill("input[name='loginName']", "varak")
                page.fill("input[name='loginPassword']", "ufobeep123pass")
                page.click("input[type='submit']")
                page.wait_for_load_state("domcontentloaded")
                print("✅ Logged in")
                
                # Step 4: Look for SEARCH DATABASE link (like httpx finds)
                print("Step 4: Looking for SEARCH DATABASE link...")
                search_links = page.locator("a:has-text('SEARCH DATABASE')").all()
                if search_links:
                    search_links[0].click()
                    page.wait_for_load_state("domcontentloaded") 
                    print("✅ Clicked SEARCH DATABASE")
                    
                    # Step 5: Submit search form (like httpx does)
                    print("Step 5: Looking for search form...")
                    choice_dropdown = page.locator("select[name='choice']")
                    
                    if choice_dropdown.count() > 0:
                        # Select Last 20 Reports (like httpx working flow)
                        choice_dropdown.select_option("https://mufoncms.com/last_20_public.html?orgId=mufon")
                        
                        # Find and click submit 
                        submit_btn = page.locator("input[type='submit']").first
                        submit_btn.click()
                        page.wait_for_load_state("domcontentloaded")
                        print("✅ Submitted search form")
                        
                        # Step 6: NOW WE HAVE RESULTS - Look for VIEW buttons!
                        print("Step 6: Looking for VIEW buttons in results...")
                        
                        # Take screenshot
                        page.screenshot(path="hybrid_results.png", full_page=True)
                        
                        # Look for iframes or main content
                        iframes = page.locator("iframe").all()
                        if iframes:
                            print(f"Found {len(iframes)} iframes")
                            frame = iframes[0].content_frame()
                            view_elements = frame.locator("text=VIEW").all()
                            print(f"Found {len(view_elements)} VIEW elements in iframe")
                            
                            if view_elements:
                                print("🎉 FOUND VIEW BUTTONS! Clicking first one...")
                                view_elements[0].click()
                                time.sleep(3)
                                
                                # Extract description
                                page_text = frame.locator("body").inner_text()
                                with open("hybrid_view_result.txt", "w") as f:
                                    f.write(page_text)
                                print("✅ Clicked VIEW and saved result!")
                                
                                return True
                        else:
                            view_elements = page.locator("text=VIEW").all() 
                            print(f"Found {len(view_elements)} VIEW elements on main page")
                            
                            if view_elements:
                                print("🎉 FOUND VIEW BUTTONS on main page!")
                                return True
                        
                        print("❌ No VIEW buttons found")
                        return False
                    else:
                        print("❌ No choice dropdown found")
                        return False
                else:
                    print("❌ No SEARCH DATABASE link found") 
                    return False
            else:
                print("❌ No Member Login found")
                return False
                
        except Exception as e:
            print(f"❌ Error: {e}")
            page.screenshot(path="hybrid_error.png", full_page=True)
            return False
        finally:
            browser.close()

if __name__ == "__main__":
    success = main()
    if success:
        print("🐱 SUCCESS! Cat can come inside!")
    else:
        print("❌ FAILED - Time to ask ChatGPT for help")