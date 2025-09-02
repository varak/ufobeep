#!/usr/bin/env python3
"""
Debug MUFON Navigation - Step by step to find the VIEW buttons
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time

def debug_navigation():
    """Debug the MUFON navigation step by step"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)  # Run with browser visible for debugging
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("Step 1: Going to MUFON...")
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            page.screenshot(path="debug_01_home.png", full_page=True)
            
            print("Step 2: Looking for Track UFOs...")
            track_ufo_links = page.locator("text=Track UFOs").all()
            print(f"Found {len(track_ufo_links)} 'Track UFOs' links")
            
            if track_ufo_links:
                track_ufo_links[0].click()
                time.sleep(2)
                page.screenshot(path="debug_02_after_track_ufos.png", full_page=True)
                
                print("Step 3: Looking for Search Database...")
                search_db_links = page.locator("text=Search Database").all()
                print(f"Found {len(search_db_links)} 'Search Database' links")
                
                if search_db_links:
                    search_db_links[0].click()
                    page.wait_for_load_state("networkidle")
                    page.screenshot(path="debug_03_search_database.png", full_page=True)
                    
                    print("Step 4: Looking for terms and conditions...")
                    agree_radios = page.locator("input[type='radio'][value*='agree']").all()
                    print(f"Found {len(agree_radios)} agree radio buttons")
                    
                    if agree_radios:
                        agree_radios[0].check()
                        submit_buttons = page.locator("button:has-text('Submit')").all()
                        print(f"Found {len(submit_buttons)} submit buttons")
                        
                        if submit_buttons:
                            submit_buttons[0].click()
                            page.wait_for_load_state("networkidle")
                            time.sleep(3)
                            page.screenshot(path="debug_04_after_submit.png", full_page=True)
                            
                            print("Step 5: Looking for iframes...")
                            iframes = page.locator("iframe").all()
                            print(f"Found {len(iframes)} iframes")
                            
                            if iframes:
                                print("Switching to iframe...")
                                iframe_content = iframes[0].content_frame()
                                time.sleep(2)
                                
                                iframe_content.screenshot(path="debug_05_iframe_content.png")
                                
                                # Save iframe HTML
                                html_content = iframe_content.content()
                                with open("debug_iframe.html", "w") as f:
                                    f.write(html_content)
                                
                                print("Step 6: Looking for table rows...")
                                rows = iframe_content.locator("tr").all()
                                print(f"Found {len(rows)} table rows")
                                
                                print("Step 7: Looking for VIEW elements...")
                                view_elements = iframe_content.locator("text=VIEW").all()
                                print(f"Found {len(view_elements)} VIEW text elements")
                                
                                # Also try other selectors
                                view_buttons = iframe_content.locator("button:has-text('VIEW')").all()
                                view_links = iframe_content.locator("a:has-text('VIEW')").all()
                                view_inputs = iframe_content.locator("input[value*='VIEW']").all()
                                
                                print(f"Found {len(view_buttons)} VIEW buttons")
                                print(f"Found {len(view_links)} VIEW links")
                                print(f"Found {len(view_inputs)} VIEW inputs")
                                
                                # Look for onclick handlers with view_long_desc
                                onclick_elements = iframe_content.locator("[onclick*='view_long_desc']").all()
                                print(f"Found {len(onclick_elements)} onclick view_long_desc elements")
                                
                                # Try to click first VIEW element if found
                                if view_elements:
                                    print("Trying to click first VIEW element...")
                                    view_elements[0].click()
                                    time.sleep(3)
                                    iframe_content.screenshot(path="debug_06_after_view_click.png")
                                    
                                    # Check URL
                                    current_url = iframe_content.url
                                    print(f"After VIEW click URL: {current_url}")
                                    
                                    # Get page content
                                    detail_text = iframe_content.inner_text()
                                    with open("debug_view_detail.txt", "w") as f:
                                        f.write(detail_text)
                            
                            else:
                                print("❌ No iframes found")
                                
                                # Debug: look at page content
                                page_text = page.inner_text()
                                with open("debug_no_iframe_page.txt", "w") as f:
                                    f.write(page_text)
            
            print("Debug complete - check the screenshots and files")
            input("Press Enter to close browser...")
            
        except Exception as e:
            print(f"❌ Error: {e}")
            page.screenshot(path="debug_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    debug_navigation()