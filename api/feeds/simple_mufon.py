#!/usr/bin/env python3
import json
from pathlib import Path
from playwright.sync_api import sync_playwright

STATE = Path("mufon_artifacts/storage_state.json")

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(STATE))
        page = context.new_page()
        
        # Go directly to what we think is the search results page
        print("Going to database search...")
        page.goto("https://mufon.com/search_database-terms-and-conditions/")
        page.wait_for_load_state("networkidle")
        
        # Accept terms if form exists
        try:
            agree_radio = page.locator("input[type='radio'][value*='agree']").first
            if agree_radio.count() > 0:
                agree_radio.check()
                page.locator("button[type='submit']").first.click()
                page.wait_for_load_state("networkidle")
                print("Terms accepted")
        except:
            pass
        
        # Try to find any recent cases or data
        print(f"Current URL: {page.url}")
        print(f"Page title: {page.title()}")
        
        # Look for any table or list data
        tables = page.locator("table")
        if tables.count() > 0:
            print(f"Found {tables.count()} tables")
            
        # Save what we found
        content = page.content()
        Path("results_mufon.html").write_text(content)
        print("Saved page content to results_mufon.html")
        
        browser.close()

if __name__ == "__main__":
    main()