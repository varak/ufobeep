#!/usr/bin/env python3
"""
MUFON Playwright with Views - Convert the WORKING httpx flow to Playwright and add VIEW clicking
Follow the EXACT same steps as mufon_authenticated_client.py but with Playwright
"""
from playwright.sync_api import sync_playwright
import json
import time
import re
from pathlib import Path

def mufon_playwright_with_views():
    """Follow the exact working authentication flow but with Playwright to click VIEW buttons"""
    
    # Credentials (same as working client)
    username = "varak"
    password = "ufobeep123pass"
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()
        
        try:
            print("Step 1: Navigating to MUFON research page...")
            page.goto("https://mufon.com/research/", wait_until="domcontentloaded")
            print(f"✅ Research page loaded")
            
            print("Step 2: Looking for login link...")
            login_links = page.locator("a:has-text('Member Login')").all()
            print(f"Found {len(login_links)} login links")
            
            if login_links:
                login_links[0].click()
                page.wait_for_load_state("networkidle")
                print("✅ Login page loaded")
                
                print("Step 3: Authenticating...")
                # Try different field name variations
                username_selectors = ["input[name='loginName']", "input[name='username']", "input[type='text']", "#username", "#loginName"]
                password_selectors = ["input[name='loginPassword']", "input[name='password']", "input[type='password']", "#password", "#loginPassword"]
                
                # Fill username
                for selector in username_selectors:
                    try:
                        page.fill(selector, username, timeout=2000)
                        print(f"    ✅ Filled username with: {selector}")
                        break
                    except:
                        continue
                
                # Fill password
                for selector in password_selectors:
                    try:
                        page.fill(selector, password, timeout=2000)
                        print(f"    ✅ Filled password with: {selector}")
                        break
                    except:
                        continue
                
                # Try different submit button selectors
                submit_selectors = ["input[type='submit']", "button[type='submit']", "button:has-text('Login')", "button:has-text('Sign In')", "[value='Login']", "[value='Submit']"]
                
                for selector in submit_selectors:
                    try:
                        page.click(selector, timeout=2000)
                        print(f"    ✅ Clicked submit with: {selector}")
                        break
                    except:
                        continue
                page.wait_for_load_state("networkidle")
                print("✅ Successfully authenticated!")
                
                print("Step 4: Looking for Track UFOs/Search Database...")
                # Look for search database links with multiple variations
                search_selectors = [
                    "a:has-text('SEARCH DATABASE')",
                    "a:has-text('Search Database')",
                    "text=SEARCH DATABASE",
                    "text=Search Database",
                    "a[href*='database']",
                    "a[href*='search']",
                    "text=Track UFOs",
                    "a:has-text('Track UFOs')"
                ]
                
                search_links = []
                for selector in search_selectors:
                    try:
                        links = page.locator(selector).all()
                        if links:
                            print(f"  Found {len(links)} links with selector: {selector}")
                            search_links = links
                            break
                    except:
                        continue
                
                print(f"Total search links found: {len(search_links)}")
                
                if search_links:
                    search_links[0].click()
                    page.wait_for_load_state("networkidle")
                    print("✅ Navigated to search page")
                    
                    print("Step 5: Taking screenshot and reading page content...")
                    page.screenshot(path="after_search_navigation.png", full_page=True)
                    
                    # Read the page content to see what's actually there
                    page_text = page.locator("body").inner_text()
                    print("PAGE CONTENT:")
                    print("=" * 50)
                    print(page_text[:2000])  # First 2000 chars
                    print("=" * 50)
                    
                    # Save full page text
                    with open("search_page_content.txt", "w") as f:
                        f.write(page_text)
                    
                    print("Step 6: Checking for Terms and Conditions...")
                    if "TERMS AND CONDITIONS" in page_text:
                        print("Found T&C page, accepting terms...")
                        
                        # Click "Yes, I Agree" radio button
                        try:
                            # Find radio button near "Yes, I Agree" text
                            radios = page.locator("input[type='radio']").all()
                            print(f"  Found {len(radios)} radio buttons")
                            
                            # Click the first radio button (usually "Yes")
                            if radios:
                                radios[0].click()
                                print("  ✅ Clicked 'Yes' radio button")
                            else:
                                print("  ❌ No radio buttons found")
                        except Exception as e:
                            print(f"  ❌ Error clicking agree radio: {e}")
                        
                        # Click Submit button
                        try:
                            # Try the black Submit button at the bottom
                            submit_btn = page.locator("button:has-text('Submit')").first
                            if submit_btn.count() > 0:
                                print("  Found Submit button, clicking...")
                                submit_btn.click()
                                print("  Waiting for navigation...")
                                page.wait_for_load_state("domcontentloaded", timeout=10000)
                                time.sleep(5)  # Wait longer
                                print("  ✅ Clicked Submit button and waited")
                            else:
                                print("  No Submit button found, trying alternatives...")
                                # Try any submit buttons
                                submit_btns = page.locator("input[type='submit'], button[type='submit']").all()
                                if submit_btns:
                                    submit_btns[0].click()
                                    page.wait_for_load_state("domcontentloaded", timeout=10000)
                                    time.sleep(5)
                                    print("  ✅ Clicked alternative submit button")
                        except Exception as e:
                            print(f"  ❌ Error clicking submit: {e}")
                            page.screenshot(path="terms_submit_error.png", full_page=True)
                    
                    print("Step 7: After T&C submit, checking current page...")
                    current_page_text = page.locator("body").inner_text()
                    print(f"Current page content preview: {current_page_text[:500]}...")
                    page.screenshot(path="after_tc_submit.png", full_page=True)
                    
                    print("Step 8: After T&C submit, looking for Track UFOs link...")
                    track_ufo_links = page.locator("a:has-text('TRACK UFO'), a:has-text('Track UFOs')").all()
                    print(f"Found {len(track_ufo_links)} Track UFO links")
                    
                    if track_ufo_links:
                        track_ufo_links[0].click()
                        page.wait_for_load_state("domcontentloaded")
                        time.sleep(3)
                        print("✅ Clicked Track UFOs link - should be at TRACK UFO's page now")
                    
                    print("Step 9: After Track UFOs click, checking current page...")
                    track_page_text = page.locator("body").inner_text()
                    print(f"Track UFOs page preview: {track_page_text[:500]}...")
                    page.screenshot(path="after_track_ufos.png", full_page=True)
                    
                    print("Step 10: Looking for SEARCH DATABASE link on TRACK UFO's page...")
                    # I can see "SEARCH DATABASE" in the page content, so click it directly
                    search_db_links = page.locator("a:has-text('SEARCH DATABASE')").all()
                    print(f"Found {len(search_db_links)} SEARCH DATABASE links")
                    
                    if search_db_links:
                        search_db_links[0].click()
                        page.wait_for_load_state("domcontentloaded")
                        time.sleep(3)
                        print("✅ Clicked SEARCH DATABASE link")
                    else:
                        print("❌ No SEARCH DATABASE link found")
                    
                    print("Step 11: After SEARCH DATABASE click, checking current page...")
                    search_db_text = page.locator("body").inner_text()
                    print(f"Search DB page preview: {search_db_text[:500]}...")
                    page.screenshot(path="after_search_db.png", full_page=True)
                    
                    print("Step 12: Checking if we need to log in again...")
                    if "Account Login" in search_db_text and "Login Name" in search_db_text:
                        print("Found login form, filling credentials...")
                        
                        # Fill login form
                        login_name_field = page.locator("input[name*='login'], input[placeholder*='Login']").first
                        password_field = page.locator("input[type='password']").first
                        
                        if login_name_field.count() > 0:
                            login_name_field.fill(username)
                            print("  ✅ Filled login name")
                        
                        if password_field.count() > 0:
                            password_field.fill(password)
                            print("  ✅ Filled password")
                        
                        # Click Log In button
                        login_btn = page.locator("button:has-text('Log In'), input[value='Log In']").first
                        if login_btn.count() > 0:
                            login_btn.click()
                            page.wait_for_load_state("domcontentloaded")
                            time.sleep(3)
                            print("  ✅ Clicked Log In button")
                    
                    print("Step 13: Looking for choice dropdown...")
                    choice_dropdown = page.locator("select[name='choice']")
                    
                    if choice_dropdown.count() > 0:
                        print("Found choice dropdown, selecting Last 20 Reports...")
                        
                        # List options for debugging
                        options = choice_dropdown.locator("option").all()
                        print(f"Choice field has {len(options)} options:")
                        for i, option in enumerate(options):
                            value = option.get_attribute("value")
                            text = option.inner_text()
                            print(f"  {i+1}. '{value}' = '{text}'")
                            
                        # Look for SEARCH DATABASE option first
                        search_db_found = False
                        for option in options:
                            text = option.inner_text()
                            value = option.get_attribute("value")
                            print(f"  Option: '{value}' = '{text}'")
                            if "SEARCH DATABASE" in text.upper() or "DATABASE" in text.upper():
                                print(f"✅ Found SEARCH DATABASE option: {value}")
                                choice_dropdown.select_option(value)
                                search_db_found = True
                                break
                        
                        if not search_db_found:
                            print("❌ No SEARCH DATABASE in dropdown, trying hover click on visible link...")
                            # Try hover clicking the visible SEARCH DATABASE link
                            search_links = page.locator("a:has-text('SEARCH DATABASE')").all()
                            if search_links:
                                search_links[0].hover()
                                search_links[0].click()
                                print("✅ Hover-clicked SEARCH DATABASE link")
                        
                        # Submit the search form to get results
                        submit_btns = page.locator("input[value='SUBMIT']").all()
                        if submit_btns:
                            submit_btns[0].click(timeout=5000)
                            page.wait_for_load_state("domcontentloaded", timeout=5000)
                            time.sleep(2)
                            print("✅ Search submitted, looking for results...")
                        else:
                            print("❌ No SUBMIT button found")
                        
                        # Save current state
                        context.storage_state(path="mufon_artifacts/fresh_storage_state.json")
                        
                        print("Step 6: Looking for iframe with results...")
                        iframes = page.locator("iframe").all()
                        print(f"Found {len(iframes)} iframes")
                        
                        results_frame = None
                        
                        if iframes:
                            print("Found iframe, accessing it to find SUBMIT button...")
                            iframe = iframes[0]
                            frame = iframe.content_frame()
                            
                            # Look for SUBMIT button in the iframe (the search form)
                            submit_btns = frame.locator("input[value='SUBMIT']").all()
                            if submit_btns:
                                print("Found SUBMIT button in iframe, clicking...")
                                submit_btns[0].click()
                                frame.wait_for_load_state("domcontentloaded", timeout=10000)
                                time.sleep(3)
                                print("✅ Search submitted in iframe!")
                                
                                # Now check for results with VIEW buttons
                                tables = frame.locator("table").count()
                                rows = frame.locator("tr").count() 
                                view_elements = frame.locator("text=VIEW").count()
                                
                                print(f"Results: {tables} tables, {rows} rows, {view_elements} VIEW elements")
                                
                                if view_elements > 0 or (tables > 0 and rows > 3):
                                    results_frame = frame
                                    print("✅ Found case results with data!")
                                else:
                                    print("❌ No case data found after submit")
                            else:
                                print("❌ No SUBMIT button found in iframe")
                        else:
                            print("  No iframes found, checking main page...")
                            tables = page.locator("table").count()
                            rows = page.locator("tr").count()
                            view_elements = page.locator("text=VIEW").count()
                            
                            print(f"  Main page: {tables} tables, {rows} rows, {view_elements} VIEW elements")
                            
                            if view_elements > 0 or (tables > 0 and rows > 3):
                                results_frame = page
                        
                        if results_frame:
                            print("Step 7: Processing case rows...")
                            
                            # Take screenshot
                            results_frame.screenshot(path="playwright_results.png")
                            
                            # Get table rows
                            table_rows = results_frame.locator("table tr").all()
                            print(f"Found {len(table_rows)} table rows")
                            
                            extracted_cases = []
                            
                            # Process each row (skip header)
                            for i in range(1, min(len(table_rows), 12)):  # Skip header, max 11 cases
                                try:
                                    print(f"\n  Processing row {i}...")
                                    row = table_rows[i]
                                    row_text = row.inner_text()
                                    print(f"    Row: {row_text[:80]}...")
                                    
                                    # Look for VIEW button in this row
                                    view_selectors = [
                                        row.locator("input[value='VIEW']"),
                                        row.locator("button:has-text('VIEW')"),
                                        row.locator("a:has-text('VIEW')"),
                                        row.locator("text=VIEW"),
                                        row.locator("td").last.locator("input"),
                                        row.locator("td").last.locator("button")
                                    ]
                                    
                                    view_clicked = False
                                    case_data = {"row_index": i, "row_text": row_text}
                                    
                                    for j, view_selector in enumerate(view_selectors):
                                        try:
                                            if view_selector.count() > 0:
                                                print(f"      Trying VIEW selector {j+1}...")
                                                
                                                # Try clicking
                                                view_selector.first.click(timeout=3000)
                                                time.sleep(3)
                                                
                                                # Check if we navigated
                                                current_url = results_frame.url
                                                print(f"      After click URL: {current_url}")
                                                
                                                # Extract case ID from URL
                                                case_id_match = re.search(r'id=(\d+)', current_url)
                                                if case_id_match:
                                                    real_case_id = case_id_match.group(1)
                                                    case_data["real_case_id"] = real_case_id
                                                    print(f"      ✅ Real case ID: {real_case_id}")
                                                    
                                                    # Extract description
                                                    detail_text = results_frame.locator("body").inner_text()
                                                    
                                                    # Save for debugging
                                                    with open(f"playwright_case_{real_case_id}.txt", "w") as f:
                                                        f.write(detail_text)
                                                    
                                                    # Find description
                                                    lines = detail_text.split('\n')
                                                    best_desc = ""
                                                    
                                                    for line in lines:
                                                        line = line.strip()
                                                        if (len(line) > 100 and
                                                            not line.startswith('Case #') and
                                                            'mufon' not in line.lower() and
                                                            'copyright' not in line.lower()):
                                                            if len(line) > len(best_desc):
                                                                best_desc = line
                                                    
                                                    if best_desc:
                                                        case_data["long_description"] = best_desc
                                                        print(f"      ✅ Description: {len(best_desc)} chars")
                                                        print(f"      Preview: {best_desc[:60]}...")
                                                    
                                                    # Go back
                                                    results_frame.go_back()
                                                    time.sleep(2)
                                                    view_clicked = True
                                                    break
                                                    
                                        except Exception as e:
                                            print(f"      Error with selector {j+1}: {e}")
                                            continue
                                    
                                    if not view_clicked:
                                        print(f"      ❌ Could not click VIEW in row {i}")
                                    
                                    extracted_cases.append(case_data)
                                    
                                except Exception as e:
                                    print(f"    ❌ Error processing row {i}: {e}")
                                    continue
                            
                            # Save results
                            output = {
                                "timestamp": time.time(),
                                "extraction_method": "playwright_working_flow",
                                "total_cases": len(extracted_cases),
                                "cases": extracted_cases
                            }
                            
                            with open("playwright_with_views_results.json", "w") as f:
                                json.dump(output, f, indent=2)
                            
                            success_count = sum(1 for case in extracted_cases if case.get("long_description"))
                            real_id_count = sum(1 for case in extracted_cases if case.get("real_case_id"))
                            
                            print(f"\n🎉 Playwright extraction complete!")
                            print(f"📊 Processed {len(extracted_cases)} rows")
                            print(f"🆔 Cases with real IDs: {real_id_count}")
                            print(f"📝 Cases with descriptions: {success_count}")
                            print(f"💾 Saved to playwright_with_views_results.json")
                            
                        else:
                            print("❌ No results frame found")
                            page.screenshot(path="playwright_no_results.png", full_page=True)
                    else:
                        print("❌ No choice dropdown found")
                else:
                    print("❌ No SEARCH DATABASE links found")
            else:
                print("❌ No login links found")
                
        except Exception as e:
            print(f"❌ Error: {e}")
            page.screenshot(path="playwright_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    mufon_playwright_with_views()