#!/usr/bin/env python3
"""
Actually use the database search form that's right there
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta

def main():
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%m/%d/%Y")
    today = datetime.now().strftime("%m/%d/%Y")
    
    print(f"🎯 Searching database for: {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
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
        
        # Go to search database
        print("📍 Going to database search...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # I can see the form in the screenshot
        # Click PAST 7 DAYS button for Date Submitted
        print("🔘 Clicking PAST 7 DAYS for Date Submitted...")
        page.locator("input[value='PAST 7 DAYS']").first.click()
        time.sleep(1)
        
        # Click PAST 7 DAYS button for Date of Event  
        print("🔘 Clicking PAST 7 DAYS for Date of Event...")
        page.locator("input[value='PAST 7 DAYS']").nth(1).click()
        time.sleep(1)
        
        # Now click SUBMIT
        print("🚀 Clicking SUBMIT...")
        page.click("input[value='SUBMIT']")
        
        # Wait for results
        print("⏳ Waiting for search results...")
        time.sleep(10)
        
        # Save results
        page.screenshot(path="database_search_results.png", full_page=True)
        
        text = page.locator("body").inner_text()
        with open("database_search_results.txt", "w") as f:
            f.write(f"Search: {yesterday} to {today}\n")
            f.write(f"URL: {page.url}\n\n")
            f.write(text)
        
        print(f"📍 Results URL: {page.url}")
        
        # Parse results
        if "no records" in text.lower():
            print("❌ No records found")
        else:
            print("✅ Got search results!")
            
            # Extract case data
            import re
            case_nums = re.findall(r'\b\d{6}\b', text)
            if case_nums:
                print(f"🎯 Found cases: {case_nums}")
        
        print("💾 Saved: database_search_results.png and .txt")
        
        browser.close()

if __name__ == "__main__":
    main()