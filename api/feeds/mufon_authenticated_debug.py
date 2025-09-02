"""
MUFON Authenticated Debug - Login first, then check z2systems form
"""
from playwright.sync_api import sync_playwright

USERNAME = "varak" 
PASSWORD = "ufobeep123pass"

def debug_authenticated():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        try:
            # Step 1: Go directly to z2systems login page
            print("1. Going to MUFON z2systems login...")
            page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp", wait_until="networkidle")
            
            print("2. Filling login form...")
            page.fill('input[name="loginName"]', USERNAME)
            page.fill('input[name="loginPassword"]', PASSWORD)
            
            print("3. Submitting login...")
            # Find and click the submit button in the login form
            login_form = page.locator('form[action="/np/security/signIn.do"]')
            login_form.locator('input[type="submit"], button[type="submit"]').click()
            page.wait_for_load_state("networkidle")
            
            print(f"After login URL: {page.url}")
            
            # Step 2: Now go to the search page
            print("3. Going to search page...")
            page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
            page.wait_for_load_state("networkidle")
            
            print(f"Search page URL: {page.url}")
            print(f"Page title: {page.title()}")
            
            # Step 3: Examine forms
            forms = page.locator('form').all()
            print(f"\nFound {len(forms)} forms:")
            
            for i, form in enumerate(forms):
                action = form.get_attribute('action')
                print(f"\nForm {i+1}: action='{action}'")
                
                inputs = form.locator('input, select, textarea').all()
                print(f"  {len(inputs)} inputs:")
                
                for j, inp in enumerate(inputs):
                    name = inp.get_attribute('name')
                    tag = inp.evaluate('el => el.tagName.toLowerCase()')
                    inp_type = inp.get_attribute('type')
                    value = inp.get_attribute('value')
                    
                    print(f"    {j+1}. {tag}({inp_type}): {name} = '{value}'")
                    
                    # Show choice field options
                    if name == 'choice' and tag == 'select':
                        print(f"      🎯 CHOICE FIELD OPTIONS:")
                        options = inp.locator('option').all()
                        for k, opt in enumerate(options):
                            opt_value = opt.get_attribute('value') or ''
                            opt_text = opt.text_content() or ''
                            selected = opt.get_attribute('selected')
                            mark = ' [SELECTED]' if selected else ''
                            print(f"        {k+1}. value='{opt_value}' text='{opt_text}'{mark}")
            
            # Step 4: Try submitting with different choice values
            choice_form = None
            for form in forms:
                if '/np/constituent/link.do' in (form.get_attribute('action') or ''):
                    choice_form = form
                    break
            
            if choice_form:
                print(f"\n4. Found choice form! Testing submissions...")
                choice_select = choice_form.locator('select[name="choice"]')
                options = choice_select.locator('option').all()
                
                for i, opt in enumerate(options):
                    opt_value = opt.get_attribute('value') or ''
                    opt_text = opt.text_content() or ''
                    
                    if opt_value:  # Skip empty values
                        print(f"\n--- Testing option {i+1}: '{opt_value}' = '{opt_text}' ---")
                        
                        # Select this option
                        choice_select.select_option(opt_value)
                        
                        # Submit form
                        choice_form.locator('button[type="submit"], input[type="submit"]').first.click()
                        page.wait_for_load_state("networkidle")
                        
                        # Check results
                        result_url = page.url
                        result_title = page.title()
                        print(f"Result URL: {result_url}")
                        print(f"Result title: {result_title}")
                        
                        # Look for case data indicators
                        content = page.content()
                        case_indicators = ['case', 'sighting', 'ufo', 'report', 'witness']
                        found_indicators = [ind for ind in case_indicators if ind.lower() in content.lower()]
                        print(f"Found indicators: {found_indicators}")
                        
                        # Show first 500 chars of content
                        text_content = page.evaluate('() => document.body.innerText')[:500]
                        print(f"Content preview: {text_content}")
                        
                        # Go back to form for next test
                        if i < len(options) - 1:  # Don't go back on last iteration
                            page.go_back()
                            page.wait_for_load_state("networkidle")
            
            browser.close()
            
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
            browser.close()

if __name__ == "__main__":
    debug_authenticated()