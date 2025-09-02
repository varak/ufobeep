#!/usr/bin/env python3
"""
Show all table columns to identify the correct location field
"""
from playwright.sync_api import sync_playwright
import time

def show_mufon_table():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
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
        
        # Go to search
        print("📍 Going to search page...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # Try to get results
        try:
            submit_btn = page.locator("input[value='SUBMIT']").first
            submit_btn.click()
            time.sleep(8)
        except:
            print("⚠️ Submit button not found")
        
        # Get iframe
        print("📊 Reading table structure...")
        time.sleep(3)
        iframe = page.frame_locator("iframe").first
        
        # Get table headers
        try:
            headers = iframe.locator("table thead th").all()
            print(f"\n📝 Found {len(headers)} table columns:")
            for i, header in enumerate(headers):
                header_text = header.inner_text().strip()
                print(f"  Column {i+1}: '{header_text}'")
        except Exception as e:
            print(f"❌ Error getting headers: {e}")
        
        # Get first few data rows
        try:
            rows = iframe.locator("table tbody tr").all()
            print(f"\n📊 Found {len(rows)} data rows")
            
            for row_idx, row in enumerate(rows[:3]):  # Just first 3 rows
                print(f"\n--- Row {row_idx+1} ---")
                cells = row.locator("td").all()
                for cell_idx, cell in enumerate(cells):
                    cell_text = cell.inner_text().strip()[:100]  # Limit text length
                    print(f"  Col {cell_idx+1}: {cell_text}")
                    
        except Exception as e:
            print(f"❌ Error getting rows: {e}")
        
        browser.close()

if __name__ == "__main__":
    show_mufon_table()