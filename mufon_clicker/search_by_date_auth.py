#!/usr/bin/env python3
"""
Use existing auth to search MUFON by date range
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta
import json

def main():
    # Calculate yesterday's date  
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
    today = datetime.now().strftime("%Y-%m-%d")
    
    print(f"🗓️ Searching for cases from {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        
        # Use existing authenticated session
        context = browser.new_context(storage_state="mufon_artifacts/storage_state.json")
        page = context.new_page()
        
        print("🔑 Using existing authenticated session...")
        
        # Go to MUFON member portal/dashboard
        page.goto("https://mufon.app.neoncrm.com/np/clients/mufon/memberHome.do", wait_until="domcontentloaded")
        time.sleep(3)
        
        page.screenshot(path="member_dashboard.png")
        print("📸 Screenshot: member_dashboard.png")
        
        # Look for search/database options in the authenticated interface
        print("🔍 Looking for search interface...")
        
        # Check for forms and dropdowns
        dropdowns = page.locator("select").all()
        print(f"📋 Found {len(dropdowns)} dropdown menus")
        
        for i, dropdown in enumerate(dropdowns):
            try:
                name = dropdown.get_attribute('name') or f"dropdown_{i}"
                print(f"  Dropdown {i}: {name}")
                
                # Get options
                options = dropdown.locator("option").all()
                for opt in options:
                    value = opt.get_attribute('value') or ''
                    text = opt.inner_text().strip()
                    if text and value:
                        print(f"    {value} -> {text}")
                        
                        # Look for CMS or database search options
                        if any(keyword in text.lower() for keyword in ['cms', 'database', 'search', 'case', 'report']):
                            print(f"🎯 Found potential search option: {text}")
                            
                            # Select it and submit
                            try:
                                dropdown.select_option(value)
                                time.sleep(1)
                                
                                # Look for submit button
                                submit_btns = page.locator("input[type='submit'], button[type='submit']").all()
                                if submit_btns:
                                    submit_btns[0].click()
                                    page.wait_for_load_state("domcontentloaded", timeout=10000)
                                    time.sleep(3)
                                    print(f"✅ Navigated via: {text}")
                                    break
                            except Exception as e:
                                print(f"Error selecting option: {e}")
            except Exception as e:
                print(f"Error processing dropdown {i}: {e}")
        
        # Take screenshot after navigation attempt
        page.screenshot(path="after_nav_attempt.png", full_page=True)
        print("📸 Screenshot: after_nav_attempt.png")
        
        current_url = page.url
        print(f"📍 Current URL: {current_url}")
        
        # Look for search fields or case interface
        print("🔍 Looking for search interface...")
        
        # Look for iframes (common in MUFON interface)
        iframes = page.locator("iframe").all()
        print(f"🖼️ Found {len(iframes)} iframes")
        
        for i, iframe in enumerate(iframes):
            try:
                src = iframe.get_attribute('src') or f"iframe_{i}"
                print(f"  Iframe {i}: {src}")
                
                # Check iframe content
                frame_content = iframe.content_frame()
                if frame_content:
                    # Look for search elements in iframe
                    date_inputs = frame_content.locator("input[type='date'], input[name*='date']").all()
                    search_forms = frame_content.locator("form").all()
                    
                    print(f"    Iframe has {len(date_inputs)} date inputs, {len(search_forms)} forms")
                    
                    if date_inputs or search_forms:
                        print(f"🎯 Found search interface in iframe {i}")
                        
                        # Try to use the search interface
                        for date_input in date_inputs[:2]:  # Try first 2 date fields
                            try:
                                field_name = date_input.get_attribute('name') or 'date_field'
                                print(f"    Filling {field_name} with {yesterday}")
                                date_input.fill(yesterday)
                                time.sleep(0.5)
                            except Exception as e:
                                print(f"    Error filling date: {e}")
                        
                        # Look for search button in iframe
                        search_btns = frame_content.locator("input[type='submit'], button:has-text('Search')").all()
                        if search_btns:
                            try:
                                print("    Clicking search button...")
                                search_btns[0].click()
                                time.sleep(5)  # Wait for search results
                                break
                            except Exception as e:
                                print(f"    Search button error: {e}")
                        
            except Exception as e:
                print(f"Iframe {i} error: {e}")
        
        # Final screenshot and save state
        page.screenshot(path="final_search_state.png", full_page=True)
        print("📸 Final screenshot: final_search_state.png")
        
        # Look for results
        tables = page.locator("table").all()
        view_elements = page.locator("text=VIEW").all()
        case_elements = page.locator("text=Case").all()
        
        print(f"📊 Found {len(tables)} tables, {len(view_elements)} VIEW elements, {len(case_elements)} case elements")
        
        if view_elements or (tables and len(tables) > 0):
            print("✅ SUCCESS: Found potential results interface")
            
            # Save working session
            context.storage_state(path="mufon_artifacts/search_session.json")
            
            with open("search_results_url.txt", "w") as f:
                f.write(page.url)
                
        else:
            print("❌ No clear results found")
        
        # Save page content for debugging
        with open("search_debug_content.html", "w") as f:
            f.write(page.content())
            
        print("\n📋 Check these files:")
        print("  - member_dashboard.png")
        print("  - after_nav_attempt.png") 
        print("  - final_search_state.png")
        print("  - search_debug_content.html")
        
        browser.close()

if __name__ == "__main__":
    main()