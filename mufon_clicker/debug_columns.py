#!/usr/bin/env python3
"""
Debug script to show all table columns and find the real location field
"""
from playwright.sync_api import sync_playwright
import time

def debug_mufon_table():
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
        
        # Go to search
        print("📍 Going to search page...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
        time.sleep(5)
        
        # Wait for iframe
        print("📊 Loading results...")
        time.sleep(3)
        iframe = page.frame_locator("iframe").first
        
        # Get rows
        rows = iframe.locator("table tbody tr").all()
        print(f"Found {len(rows)} rows")
        
        # Show first real data row (skip headers)
        for row_idx in range(min(10, len(rows))):
            print(f"\n=== ROW {row_idx+1} ===")
            row = rows[row_idx]
            cells = row.locator("td").all()
            
            print(f"Total columns: {len(cells)}")
            for col_idx, cell in enumerate(cells):
                cell_text = cell.inner_text().strip()
                if cell_text:  # Only show non-empty cells
                    print(f"  Column {col_idx}: '{cell_text[:80]}'")
            
            # Stop after we see some real data
            if len(cells) > 5 and any("20" in cell.inner_text() for cell in cells):
                break
        
        browser.close()

if __name__ == "__main__":
    debug_mufon_table()