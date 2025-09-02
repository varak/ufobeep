#!/usr/bin/env python3
"""
Working MUFON search - Uses EXACT same navigation as headless_to_search.py but adds search execution
"""
import time, json
from datetime import datetime, timedelta
from pathlib import Path
from playwright.sync_api import sync_playwright

def main():
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        print("Step 1: Going to MUFON homepage...")
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        print(f"URL: {page.url} | Title: {page.title()}")
        
        print("\nStep 2: Looking for Track UFOs...")
        # Click Track UFOs
        track_ufos_clicked = False
        for selector in ["text=Track UFOs", "text=TRACK UFOS", "text=Track UFO's"]:
            try:
                element = page.locator(selector).first
                if element.count() > 0:
                    element.click()
                    time.sleep(1)
                    print(f"✅ Clicked {selector}")
                    track_ufos_clicked = True
                    break
            except:
                continue
                
        if not track_ufos_clicked:
            print("❌ Could not find Track UFOs")
            
        print("\nStep 3: Looking for Database Search...")
        # Click Database Search
        db_search_clicked = False
        for selector in ["text=Database Search", "text=Search Database", "text=Case Search"]:
            try:
                element = page.locator(selector).first
                if element.count() > 0:
                    element.click()
                    page.wait_for_load_state("networkidle")
                    print(f"✅ Clicked {selector}")
                    print(f"New URL: {page.url}")
                    db_search_clicked = True
                    break
            except Exception as e:
                print(f"Failed {selector}: {e}")
                
        if not db_search_clicked:
            print("❌ Could not find Database Search, trying direct URL...")
            page.goto("https://mufon.com/search_database-terms-and-conditions/", wait_until="networkidle")
            
        print(f"\nStep 4: Current page - URL: {page.url} | Title: {page.title()}")
        
        # Check if we're on terms and conditions page
        if "terms" in page.url.lower() or "terms" in page.title().lower():
            print("✅ On Terms and Conditions page")
            
            # Find and check the "Yes, I Agree" radio button
            agree_clicked = False
            try:
                # Look for the specific radio button structure we found earlier
                agree_radio = page.locator("input[type='radio'][value*='agree']").first
                if agree_radio.count() > 0:
                    agree_radio.check()
                    print("✅ Checked 'I Agree' radio button")
                    
                    # Try multiple submit approaches
                    submit_success = False
                    
                    # Method 1: Look for visible submit button
                    for submit_selector in ["button[type='submit']", "input[type='submit']", "button:has-text('Submit')", "button:has-text('Continue')", "button:has-text('Proceed')"]:
                        try:
                            submit_btn = page.locator(submit_selector).first
                            if submit_btn.count() > 0 and submit_btn.is_visible():
                                submit_btn.click()
                                page.wait_for_load_state("networkidle")
                                print(f"✅ Submitted via {submit_selector}")
                                submit_success = True
                                break
                        except:
                            continue
                    
                    # Method 2: Submit form directly via JavaScript
                    if not submit_success:
                        try:
                            form = page.locator("form").first
                            if form.count() > 0:
                                form.evaluate("form => form.submit()")
                                page.wait_for_load_state("networkidle")
                                print("✅ Submitted form via JavaScript")
                                submit_success = True
                        except Exception as e:
                            print(f"JS form submit failed: {e}")
                    
                    # Method 3: Press Enter on the radio button
                    if not submit_success:
                        try:
                            agree_radio.press("Enter")
                            page.wait_for_load_state("networkidle")
                            print("✅ Submitted via Enter key")
                            submit_success = True
                        except Exception as e:
                            print(f"Enter key submit failed: {e}")
                    
                    if submit_success:
                        agree_clicked = True
                    else:
                        print("❌ All submit methods failed")
                        
                else:
                    print("❌ Could not find agree radio button")
            except Exception as e:
                print(f"Terms acceptance failed: {e}")
                
        print(f"\nStep 5: After T&C - URL: {page.url} | Title: {page.title()}")
        
        # Check if we need to login
        if "neoncrm.com" in page.url and "signIn" in page.url:
            print("✅ Reached Neon CRM login page")
            
            # Try to login with credentials
            try:
                # Look for username/email field
                username_field = None
                for selector in ["input[name*='user']", "input[name*='email']", "input[type='email']", "input[name*='login']"]:
                    field = page.locator(selector).first
                    if field.count() > 0:
                        username_field = field
                        break
                
                # Look for password field  
                password_field = page.locator("input[type='password']").first
                
                if username_field and password_field.count() > 0:
                    # Read credentials from .env
                    env_file = Path(".env")
                    username = ""
                    password = ""
                    
                    if env_file.exists():
                        for line in env_file.read_text().splitlines():
                            if line.startswith("MUFON_USERNAME="):
                                username = line.split("=", 1)[1].strip()
                            elif line.startswith("MUFON_PASSWORD="):
                                password = line.split("=", 1)[1].strip()
                    
                    if username and password:
                        print("✅ Found login fields, attempting login...")
                        username_field.fill(username)
                        password_field.fill(password)
                        
                        # Try multiple login submission methods
                        login_success = False
                        
                        # Method 1: Try visible submit buttons
                        for submit_selector in ["input[type='submit']", "button[type='submit']", "button:has-text('Login')", "button:has-text('Sign In')", "input[value*='Login']"]:
                            try:
                                login_btn = page.locator(submit_selector).first
                                if login_btn.count() > 0 and login_btn.is_visible():
                                    login_btn.click()
                                    page.wait_for_load_state("networkidle")
                                    print(f"✅ Submitted login via {submit_selector}")
                                    login_success = True
                                    break
                            except:
                                continue
                        
                        # Method 2: Press Enter on password field
                        if not login_success:
                            try:
                                password_field.press("Enter")
                                page.wait_for_load_state("networkidle")
                                print("✅ Submitted login via Enter")
                                login_success = True
                            except Exception as e:
                                print(f"Enter login failed: {e}")
                        
                        # Method 3: Submit form via JavaScript
                        if not login_success:
                            try:
                                form = page.locator("form").first
                                if form.count() > 0:
                                    form.evaluate("form => form.submit()")
                                    page.wait_for_load_state("networkidle")
                                    print("✅ Submitted login form via JavaScript")
                                    login_success = True
                            except Exception as e:
                                print(f"JS login submit failed: {e}")
                        
                        if not login_success:
                            print("❌ All login submission methods failed")
                    
            except Exception as e:
                print(f"Login attempt failed: {e}")
        
        print(f"\nStep 6: After login - URL: {page.url} | Title: {page.title()}")
        
        # NOW WE'RE AT THE SEARCH FORM! Let's search for recent cases
        print("\n=== EXECUTING DATABASE SEARCH ===")
        
        # Save screenshot and HTML of current search form  
        Path("current_search_form.html").write_text(page.content())
        page.screenshot(path="current_search_form.png", full_page=True)
        
        # The search form is in an IFRAME! Access it
        print("Accessing search form inside iframe...")
        try:
            iframe = page.locator("iframe").first
            if iframe.count() > 0:
                iframe_url = iframe.get_attribute("src")
                print(f"Found iframe: {iframe_url}")
                
                # Switch to iframe context
                frame = page.frame_locator("iframe").first
                
                # Click TODAY button to fill in today's date
                today_btn = frame.locator("input[value='TODAY']").first
                if today_btn.count() > 0:
                    today_btn.click()
                    time.sleep(1)
                    print("✅ Clicked TODAY button")
                
                # Now look for SUBMIT button inside iframe
                submit_btn = frame.locator("input[value='SUBMIT'], input[type='submit']").first
                if submit_btn.count() > 0:
                    submit_btn.click()
                    page.wait_for_load_state("networkidle")
                    print("✅ Search submitted via iframe!")
                else:
                    print("❌ Could not find SUBMIT button in iframe")
            else:
                print("❌ Could not find iframe")
        except Exception as e:
            print(f"Iframe search failed: {e}")
            
        time.sleep(5)  # Wait longer for results to load
        
        # Take screenshot of results
        page.screenshot(path="mufon_search_results.png", full_page=True)
        
        print(f"\nStep 7: Results page - URL: {page.url}")
        
        # Extract results from IFRAME (where the search results appear)
        results = []
        print("Looking for results in iframe...")
        
        try:
            frame = page.frame_locator("iframe").first
            tables = frame.locator("table")
            print(f"Found {tables.count()} tables in iframe")
        except:
            # Fallback to main page
            tables = page.locator("table")
            print(f"Found {tables.count()} tables on main page")
        
        for t in range(tables.count()):
            table = tables.nth(t)
            rows = table.locator("tr")
            
            print(f"\n--- Examining Table {t+1} ---")
            print(f"Rows: {rows.count()}")
            
            if rows.count() > 0:
                # Look at first few rows to understand structure
                for r in range(min(3, rows.count())):
                    row = rows.nth(r)
                    cells = row.locator("td, th")
                    cell_texts = []
                    for c in range(cells.count()):
                        text = cells.nth(c).inner_text().strip()
                        cell_texts.append(text[:50] + "..." if len(text) > 50 else text)
                    print(f"Row {r}: {cell_texts}")
                
                # If this looks like the main data table with case info
                if rows.count() > 2:  # Has header + multiple data rows
                    print(f"Processing as main case table...")
                    
                    # Extract proper headers from what we see in the image
                    headers = ["Case_Number", "Date_Submitted", "DateTime_Event", "Short_Description", "Location", "Long_Description", "Attachments"]
                
                # Get data rows - extract all columns exactly as they appear
                for r in range(1, rows.count()):
                    data_row = rows.nth(r)
                    cells = data_row.locator("td")
                    
                    if cells.count() > 1:  # Must have multiple columns to be a data row
                        row_data = {}
                        for c in range(cells.count()):
                            cell = cells.nth(c)
                            cell_text = cell.inner_text().strip()
                            
                            # Use proper header names or column indices
                            if c < len(headers) and headers[c]:
                                key = headers[c]
                            else:
                                key = f"column_{c+1}"
                            
                            row_data[key] = cell_text
                            
                            # Check for attachments/media links
                            links = cell.locator("a")
                            if links.count() > 0:
                                media_files = []
                                for l in range(links.count()):
                                    link = links.nth(l)
                                    href = link.get_attribute("href")
                                    link_text = link.inner_text().strip()
                                    if href and (link_text.endswith('.jpg') or link_text.endswith('.png') or link_text.endswith('.mov')):
                                        media_files.append({"url": href, "filename": link_text})
                                
                                if media_files:
                                    row_data[f"{key}_media"] = media_files
                        
                        if any(v for v in row_data.values() if v):  # Non-empty row
                            results.append(row_data)
                            print(f"Raw case data: {row_data}")
        
        # Save results
        output = {
            "timestamp": datetime.now().isoformat(),
            "url": page.url,
            "title": page.title(),
            "total_cases": len(results),
            "cases": results
        }
        
        Path("mufon_working_results.json").write_text(json.dumps(output, indent=2))
        print(f"\n✅ FINAL RESULT: Extracted {len(results)} UFO cases")
        print(f"Results saved to mufon_working_results.json")
        
        browser.close()

if __name__ == "__main__":
    main()