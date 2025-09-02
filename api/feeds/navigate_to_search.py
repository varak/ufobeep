#!/usr/bin/env python3
"""
Navigate from MUFON member dashboard to actual database search form
"""
import time
from pathlib import Path
from playwright.sync_api import sync_playwright

def main():
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=500)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        # Go to MUFON member portal
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        print(f"Current URL: {page.url}")
        print(f"Page title: {page.title()}")
        
        # Look for navigation options from "What would you like to do?"
        print("\nLooking for search/database options...")
        
        # Try to find and click database/search related links
        search_options = [
            "Database Search",
            "Search Database", 
            "Case Search",
            "UFO Database",
            "Search Cases",
            "Search",
            "Database",
            "Cases"
        ]
        
        for option in search_options:
            try:
                element = page.locator(f"text={option}").first
                if element.count() > 0:
                    print(f"Found option: {option}")
                    element.click()
                    time.sleep(2)
                    page.wait_for_load_state("networkidle")
                    
                    print(f"After click - URL: {page.url}")
                    print(f"After click - Title: {page.title()}")
                    
                    # Save the page to examine
                    Path("search_form_page.html").write_text(page.content())
                    page.screenshot(path="search_form_page.png", full_page=True)
                    
                    # Check for date inputs (sign we reached search form)
                    date_inputs = page.locator("input[type='date'], input[name*='date'], input[name*='Date']").count()
                    if date_inputs > 0:
                        print(f"✅ Found {date_inputs} date inputs - we reached the search form!")
                        break
                    else:
                        print("No date inputs found, continuing search...")
                        
            except Exception as e:
                print(f"Failed to click {option}: {e}")
        
        print("\n=== MANUAL NAVIGATION ===")
        print("Browser window is open. Please manually navigate to the database search form.")
        print("Look for date range inputs and click to reach the actual search interface.")
        print("Press ENTER when you're on the search form with date inputs...")
        input()
        
        # Examine final page
        print(f"\nFinal URL: {page.url}")
        print(f"Final Title: {page.title()}")
        
        # Look for form elements
        forms = page.locator("form").count()
        inputs = page.locator("input").count() 
        selects = page.locator("select").count()
        
        print(f"Found {forms} forms, {inputs} inputs, {selects} selects")
        
        # Save final state
        Path("final_search_page.html").write_text(page.content())
        page.screenshot(path="final_search_page.png", full_page=True)
        
        browser.close()

if __name__ == "__main__":
    main()