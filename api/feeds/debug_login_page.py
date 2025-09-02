"""
Debug what's actually on the login page to fix field detection
"""
from playwright.sync_api import sync_playwright

def debug_login_page():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        try:
            print("1. Going to MUFON homepage...")
            page.goto("https://mufon.com", wait_until="networkidle")
            
            print("2. Looking for login links...")
            # Find all links with login-related text
            login_links = page.locator('a').all()
            found_login_links = []
            
            for link in login_links:
                text = link.text_content() or ''
                href = link.get_attribute('href') or ''
                if any(word in text.lower() for word in ['login', 'sign in', 'member']):
                    found_login_links.append({
                        'text': text.strip(),
                        'href': href
                    })
            
            print(f"Found {len(found_login_links)} login-related links:")
            for i, link in enumerate(found_login_links):
                print(f"  {i+1}. '{link['text']}' → {link['href']}")
            
            # Try to click the first z2systems login link
            z2_login = None
            for link in found_login_links:
                if 'z2systems' in link['href']:
                    z2_login = link
                    break
            
            if z2_login:
                print(f"\n3. Clicking z2systems login: {z2_login['text']} → {z2_login['href']}")
                page.goto(z2_login['href'])
                page.wait_for_load_state("networkidle")
            else:
                print("No z2systems login link found")
            
            print(f"Login page URL: {page.url}")
            print(f"Login page title: {page.title()}")
            
            print("\n3. Examining login page forms...")
            forms = page.locator('form').all()
            print(f"Found {len(forms)} forms")
            
            for i, form in enumerate(forms):
                action = form.get_attribute('action')
                print(f"\nForm {i+1}: action='{action}'")
                
                inputs = form.locator('input, select, textarea').all()
                print(f"  {len(inputs)} inputs:")
                
                for j, inp in enumerate(inputs):
                    name = inp.get_attribute('name')
                    inp_type = inp.get_attribute('type')
                    value = inp.get_attribute('value')
                    placeholder = inp.get_attribute('placeholder')
                    
                    print(f"    {j+1}. type='{inp_type}' name='{name}' value='{value}' placeholder='{placeholder}'")
            
            browser.close()
            
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
            browser.close()

if __name__ == "__main__":
    debug_login_page()