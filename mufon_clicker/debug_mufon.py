#!/usr/bin/env python3
# Debug version of MUFON script to see what's happening

import json, re, time
from pathlib import Path
from playwright.sync_api import sync_playwright

# === CONFIG ===
RESULTS_URL = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&"
STORAGE_STATE = "mufon_artifacts/storage_state.json"
# ==============

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)  # Non-headless to see what's happening
        context = browser.new_context(storage_state=STORAGE_STATE)
        context.tracing.start(screenshots=True, snapshots=True, sources=True)
        
        page = context.new_page()
        print(f"Navigating to: {RESULTS_URL}")
        page.goto(RESULTS_URL, wait_until="domcontentloaded", timeout=45000)
        
        # Take a screenshot to see the page
        page.screenshot(path="debug_screenshot.png")
        print("Screenshot saved as debug_screenshot.png")
        
        # Check for iframes
        iframes = page.locator("iframe")
        iframe_count = iframes.count()
        print(f"Found {iframe_count} iframes on the page")
        
        if iframe_count > 0:
            # Try to access the first iframe
            try:
                results_frame = page.frame_locator("iframe").first
                
                # Take screenshot of iframe content
                results_frame.locator("body").screenshot(path="iframe_screenshot.png")
                print("Iframe screenshot saved as iframe_screenshot.png")
                
                # Check what's inside the iframe
                try:
                    tables = results_frame.locator("table")
                    table_count = tables.count()
                    print(f"Found {table_count} tables in iframe")
                    
                    if table_count > 0:
                        rows = results_frame.locator("table tbody tr, table tr")
                        row_count = rows.count()
                        print(f"Found {row_count} rows in tables")
                    
                except Exception as e:
                    print(f"Error checking iframe content: {e}")
                    
            except Exception as e:
                print(f"Error accessing iframe: {e}")
        else:
            print("No iframes found - checking main page for tables")
            tables = page.locator("table")
            table_count = tables.count()
            print(f"Found {table_count} tables on main page")
        
        # Wait a bit so we can see the browser
        print("Waiting 10 seconds so you can inspect the page...")
        time.sleep(10)
        
        context.tracing.stop(path="debug_trace.zip")
        browser.close()

if __name__ == "__main__":
    main()