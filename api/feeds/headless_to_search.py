#!/usr/bin/env python3
"""
Headless navigation: Login → Database Search → Accept T&C → Search Form
"""
import time, json
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
        
        # Look for search form elements
        date_inputs = page.locator("input[type='date'], input[name*='date'], input[name*='Date'], input[name*='start'], input[name*='end']").count()
        selects = page.locator("select").count()
        forms = page.locator("form").count()
        
        print(f"\nSearch form detection:")
        print(f"- Date inputs: {date_inputs}")
        print(f"- Select dropdowns: {selects}")  
        print(f"- Forms: {forms}")
        
        if date_inputs > 0 or selects > 0:
            print("✅ SUCCESS: Found search form elements!")
            
            # Save the search form page
            Path("mufon_search_form.html").write_text(page.content())
            page.screenshot(path="mufon_search_form.png", full_page=True)
            
            # Try to extract form structure
            print(f"\nAnalyzing form structure...")
            form_info = []
            
            if forms > 0:
                for i in range(forms):
                    form = page.locator("form").nth(i)
                    inputs = form.locator("input, select, textarea").count()
                    action = form.get_attribute("action") or "No action"
                    form_info.append({"form": i, "inputs": inputs, "action": action})
                    
            print(f"Form details: {form_info}")
            
        else:
            print("❌ No search form found - might need more navigation")
            Path("mufon_no_search_form.html").write_text(page.content())
        
        browser.close()

if __name__ == "__main__":
    main()