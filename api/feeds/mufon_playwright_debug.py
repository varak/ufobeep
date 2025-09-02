"""
MUFON Playwright Debugger - See what's actually happening in the browser
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta

USERNAME = "varak"
PASSWORD = "ufobeep123pass"

def debug_mufon_flow():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)  # Headless for server environment
        page = browser.new_page()
        
        try:
            print("1. Going to MUFON homepage...")
            page.goto("https://mufon.com", wait_until="networkidle")
            
            print("2. Looking for login link...")
            # Try different login link selectors
            login_selectors = [
                'text="Login"',
                'text="Member Login"', 
                'a[href*="login"]',
                'text="Sign In"'
            ]
            
            login_clicked = False
            for selector in login_selectors:
                try:
                    if page.locator(selector).first.is_visible():
                        print(f"Found login with selector: {selector}")
                        page.click(selector)
                        login_clicked = True
                        break
                except:
                    continue
            
            if not login_clicked:
                print("❌ Could not find login link")
                return
            
            page.wait_for_load_state("networkidle")
            
            print("3. Filling login form...")
            # Try different username field selectors
            username_selectors = [
                'input[name="loginName"]',
                'input[name="username"]', 
                'input[name="email"]',
                'input[type="text"]'
            ]
            
            for selector in username_selectors:
                try:
                    if page.locator(selector).first.is_visible():
                        print(f"Found username field: {selector}")
                        page.fill(selector, USERNAME)
                        break
                except:
                    continue
            
            # Try different password field selectors  
            password_selectors = [
                'input[name="loginPassword"]',
                'input[name="password"]',
                'input[type="password"]'
            ]
            
            for selector in password_selectors:
                try:
                    if page.locator(selector).first.is_visible():
                        print(f"Found password field: {selector}")
                        page.fill(selector, PASSWORD)
                        break
                except:
                    continue
            
            # Submit login
            submit_selectors = [
                'button[type="submit"]',
                'input[type="submit"]',
                'text="Sign In"',
                'text="Login"'
            ]
            
            for selector in submit_selectors:
                try:
                    if page.locator(selector).first.is_visible():
                        print(f"Clicking submit: {selector}")
                        page.click(selector)
                        break
                except:
                    continue
            
            page.wait_for_load_state("networkidle")
            print("✅ Login submitted, waiting for authenticated page...")
            
            time.sleep(2)
            
            print("4. Looking for Track UFOs / Search Database...")
            
            # Look for database search links
            search_selectors = [
                'text="Search Database"',
                'text="Track UFOs"', 
                'a[href*="search"]',
                'a[href*="database"]',
                'a[href*="z2systems"]'
            ]
            
            for selector in search_selectors:
                try:
                    elements = page.locator(selector).all()
                    for i, element in enumerate(elements):
                        if element.is_visible():
                            text = element.text_content()
                            href = element.get_attribute('href')
                            print(f"Found search link {i}: '{text}' → {href}")
                            
                            if 'z2systems' in (href or '') or 'database' in text.lower():
                                print(f"✅ Clicking: {text}")
                                element.click()
                                page.wait_for_load_state("networkidle")
                                time.sleep(2)
                                goto_search = True
                                break
                    if 'goto_search' in locals():
                        break
                except Exception as e:
                    print(f"Error with selector {selector}: {e}")
                    continue
            
            print("5. Examining the search page...")
            current_url = page.url
            print(f"Current URL: {current_url}")
            
            # Look for forms
            forms = page.locator('form').all()
            print(f"Found {len(forms)} forms on page")
            
            for i, form in enumerate(forms):
                print(f"\nForm {i+1}:")
                action = form.get_attribute('action')
                print(f"  Action: {action}")
                
                # Look for inputs in this form
                inputs = form.locator('input, select, textarea').all()
                print(f"  {len(inputs)} inputs:")
                
                for j, inp in enumerate(inputs):
                    name = inp.get_attribute('name')
                    inp_type = inp.get_attribute('type') or inp.evaluate('el => el.tagName.toLowerCase()')
                    value = inp.get_attribute('value')
                    
                    print(f"    {j+1}. {inp_type}: {name} = '{value}'")
                    
                    # If it's a select, show options
                    if inp.evaluate('el => el.tagName.toLowerCase()') == 'select':
                        options = inp.locator('option').all()
                        print(f"      SELECT OPTIONS:")
                        for k, opt in enumerate(options):
                            opt_value = opt.get_attribute('value')
                            opt_text = opt.text_content()
                            print(f"        {k+1}. '{opt_value}' = '{opt_text}'")
                
                # If this looks like a search form, try to use it
                if action and 'link.do' in action and any(inp.get_attribute('name') == 'choice' for inp in inputs):
                    print(f"\n🎯 This looks like the search form! Trying to use it...")
                    
                    # Fill out the form for recent cases
                    choice_select = form.locator('select[name="choice"]')
                    if choice_select.is_visible():
                        # Get all options
                        options = choice_select.locator('option').all()
                        print("Choice options:")
                        for opt in options:
                            val = opt.get_attribute('value')
                            text = opt.text_content()
                            print(f"  - '{val}' = '{text}'")
                        
                        # Try to select a search-related option
                        for opt in options:
                            text = opt.text_content().lower()
                            val = opt.get_attribute('value')
                            if any(word in text for word in ['search', 'database', 'recent', 'case']):
                                print(f"✅ Selecting option: '{val}' = '{opt.text_content()}'")
                                choice_select.select_option(val)
                                break
                    
                    # Submit the form
                    submit_btn = form.locator('button[type="submit"], input[type="submit"]')
                    if submit_btn.count() > 0:
                        print("Submitting search form...")
                        submit_btn.first.click()
                        page.wait_for_load_state("networkidle")
                        time.sleep(3)
                        
                        # Check results
                        print("\n📊 SEARCH RESULTS:")
                        result_url = page.url
                        print(f"Results URL: {result_url}")
                        
                        # Look for case data
                        page_text = page.content()
                        print(f"Page content preview (first 1000 chars):")
                        print(page_text[:1000])
                        
                        break
            
            print("Debug complete!")
            
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
        finally:
            browser.close()

if __name__ == "__main__":
    debug_mufon_flow()