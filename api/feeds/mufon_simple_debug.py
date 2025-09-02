"""
Simple MUFON Debug - Go directly to z2systems page
"""
from playwright.sync_api import sync_playwright

def debug_z2systems():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        try:
            # Go directly to the z2systems page we know works
            print("Going directly to z2systems page...")
            page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
            page.wait_for_load_state("networkidle")
            
            print(f"Current URL: {page.url}")
            print(f"Page title: {page.title()}")
            
            # Look for forms
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
                    
                    # If it's the choice select, show all options
                    if name == 'choice' and tag == 'select':
                        print(f"      🎯 CHOICE FIELD OPTIONS:")
                        options = inp.locator('option').all()
                        for k, opt in enumerate(options):
                            opt_value = opt.get_attribute('value') or ''
                            opt_text = opt.text_content() or ''
                            print(f"        {k+1}. value='{opt_value}' text='{opt_text}'")
            
            print("\nDone!")
            browser.close()
            
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
            browser.close()

if __name__ == "__main__":
    debug_z2systems()