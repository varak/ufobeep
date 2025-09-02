#!/usr/bin/env python3
"""
Debug the exact date selection process
"""
from playwright.sync_api import sync_playwright
import time

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=1000)
        context = browser.new_context()
        page = context.new_page()
        
        # Login
        print("🔐 Logging in...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        time.sleep(2)
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("text=Log In")
        time.sleep(5)
        
        # Go to search page
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # Get iframe
        iframe = page.frame_locator("iframe")
        
        # Target: January 27, 2025
        target_month = 1
        target_day = 27
        target_year = 2025
        
        print(f"🎯 Target date: {target_month}/{target_day}/{target_year}")
        
        # Get the exact selectors
        event_month_from = iframe.locator("select[name='event_date_lo__month']")
        event_day_from = iframe.locator("select[name='event_date_lo__day']")
        event_year_from = iframe.locator("select[name='event_date_lo__year']")
        
        # Debug month selection
        print("\n🔍 MONTH SELECTOR DEBUG:")
        month_options = event_month_from.locator("option").all()
        print(f"Found {len(month_options)} month options:")
        for i, opt in enumerate(month_options):
            try:
                value = opt.get_attribute('value')
                text = opt.inner_text()
                print(f"  Option {i}: value='{value}', text='{text}'")
            except:
                print(f"  Option {i}: Error reading")
        
        # Try selecting January (value=1)
        print(f"\n📝 Trying to select month {target_month}...")
        try:
            event_month_from.select_option(str(target_month))
            print("✅ Month selection successful")
        except Exception as e:
            print(f"❌ Month selection failed: {e}")
            
        time.sleep(1)
        
        # Debug day selection
        print("\n🔍 DAY SELECTOR DEBUG:")
        day_options = event_day_from.locator("option").all()
        print(f"Found {len(day_options)} day options:")
        for i, opt in enumerate(day_options[:10]):  # First 10
            try:
                value = opt.get_attribute('value')
                text = opt.inner_text()
                print(f"  Option {i}: value='{value}', text='{text}'")
            except:
                print(f"  Option {i}: Error reading")
        
        # Try selecting day 27
        print(f"\n📝 Trying to select day {target_day}...")
        try:
            event_day_from.select_option(str(target_day))
            print("✅ Day selection successful")
        except Exception as e:
            print(f"❌ Day selection failed: {e}")
            
        time.sleep(1)
        
        # Debug year selection
        print("\n🔍 YEAR SELECTOR DEBUG:")
        year_options = event_year_from.locator("option").all()
        print(f"Found {len(year_options)} year options:")
        for i, opt in enumerate(year_options[:10]):  # First 10
            try:
                value = opt.get_attribute('value')
                text = opt.inner_text()
                print(f"  Option {i}: value='{value}', text='{text}'")
            except:
                print(f"  Option {i}: Error reading")
        
        # Try selecting year 2025
        print(f"\n📝 Trying to select year {target_year}...")
        try:
            event_year_from.select_option(str(target_year))
            print("✅ Year selection successful")
        except Exception as e:
            print(f"❌ Year selection failed: {e}")
            
        time.sleep(2)
        
        # Take final screenshot
        page.screenshot(path="date_selection_debug.png")
        
        # Check what was actually selected
        print("\n🔍 FINAL VERIFICATION:")
        try:
            # Check which option is currently selected
            selected_month_option = event_month_from.locator("option[selected]")
            selected_day_option = event_day_from.locator("option[selected]") 
            selected_year_option = event_year_from.locator("option[selected]")
            
            if selected_month_option.count() > 0:
                print(f"Selected month: {selected_month_option.inner_text()}")
            else:
                print("No month selected")
                
            if selected_day_option.count() > 0:
                print(f"Selected day: {selected_day_option.inner_text()}")
            else:
                print("No day selected")
                
            if selected_year_option.count() > 0:
                print(f"Selected year: {selected_year_option.inner_text()}")
            else:
                print("No year selected")
                
        except Exception as e:
            print(f"Verification error: {e}")
        
        print("\n📸 Screenshot saved: date_selection_debug.png")
        print("Press Enter to close...")
        input()
        
        browser.close()

if __name__ == "__main__":
    main()