#!/usr/bin/env python3
"""
Use authenticated session to access MUFON SEARCH DATABASE
"""
from playwright.sync_api import sync_playwright
import time
from datetime import datetime, timedelta
import json

def main():
    # Target date (one day backwards)
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
    today = datetime.now().strftime("%Y-%m-%d")
    
    print(f"🎯 Target dates: {yesterday} to {today}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        # Use the authenticated session we just saved
        context = browser.new_context(storage_state="mufon_artifacts/member_storage_state.json")
        page = context.new_page()
        
        print("🔑 Loading authenticated MUFON member portal...")
        
        # Start from the member portal
        page.goto("https://mufon.app.neoncrm.com/np/constituent/accountHome.do", wait_until="domcontentloaded")
        time.sleep(3)
        
        # Click on "SEARCH DATABASE" - I saw this in the dropdown
        print("🔍 Clicking SEARCH DATABASE...")
        try:
            page.click("text=SEARCH DATABASE")
            time.sleep(5)
            
            # Take screenshot after clicking
            page.screenshot(path="search_database_page.png", full_page=True)
            
            # Get page content
            page_text = page.locator("body").inner_text()
            print("\n📝 SEARCH DATABASE PAGE:")
            print("=" * 50)
            print(page_text[:2000] + ("..." if len(page_text) > 2000 else ""))
            print("=" * 50)
            
            # Look for search forms and date fields
            inputs = page.locator("input").all()
            print(f"\n🔍 FOUND {len(inputs)} INPUT FIELDS:")
            
            date_fields = []
            for i, input_field in enumerate(inputs):
                try:
                    field_type = input_field.get_attribute('type') or 'text'
                    field_name = input_field.get_attribute('name') or f'unnamed_{i}'
                    field_id = input_field.get_attribute('id') or 'no_id'
                    field_placeholder = input_field.get_attribute('placeholder') or 'no_placeholder'
                    
                    # Look for date-related fields
                    if any(word in field_name.lower() for word in ['date', 'from', 'to', 'start', 'end']):
                        date_fields.append((field_name, field_type, input_field))
                        print(f"  ✅ DATE FIELD {i+1}: {field_name} ({field_type})")
                    else:
                        print(f"  Input {i+1}: {field_name} ({field_type})")
                        
                except Exception as e:
                    print(f"  Input {i+1}: Error reading - {e}")
            
            # Try to perform a date-based search if we found date fields
            if date_fields:
                print(f"\n🎯 Found {len(date_fields)} date fields, trying to search...")
                
                for field_name, field_type, field_element in date_fields:
                    try:
                        if 'from' in field_name.lower() or 'start' in field_name.lower():
                            print(f"  Setting {field_name} = {yesterday}")
                            field_element.fill(yesterday)
                        elif 'to' in field_name.lower() or 'end' in field_name.lower():
                            print(f"  Setting {field_name} = {today}")
                            field_element.fill(today)
                        else:
                            print(f"  Setting {field_name} = {today}")
                            field_element.fill(today)
                    except Exception as e:
                        print(f"  Error filling {field_name}: {e}")
                
                # Look for submit button
                submit_buttons = page.locator("input[type='submit'], button[type='submit'], button:has-text('Search')").all()
                if submit_buttons:
                    print(f"\n🔍 Found {len(submit_buttons)} submit buttons, clicking first...")
                    submit_buttons[0].click()
                    time.sleep(10)
                    
                    # Take screenshot of results
                    page.screenshot(path="search_results.png", full_page=True)
                    
                    # Get results
                    results_text = page.locator("body").inner_text()
                    print("\n📊 SEARCH RESULTS:")
                    print("=" * 50)
                    print(results_text[:2000] + ("..." if len(results_text) > 2000 else ""))
                    print("=" * 50)
                    
                    # Look for case data in tables
                    rows = page.locator("table tr, .case-row, .result-row").all()
                    print(f"\n📋 Found {len(rows)} potential result rows")
                    
                    if len(rows) > 1:  # Has results
                        print("✅ Found search results! Processing...")
                        
                        cases = []
                        for i, row in enumerate(rows[1:], 1):  # Skip header
                            try:
                                row_text = row.inner_text().strip()
                                print(f"  Row {i}: {row_text[:100]}...")
                                
                                # Try to extract case data
                                cells = row.locator("td").all()
                                if len(cells) >= 3:
                                    case_data = {
                                        "row_index": i,
                                        "row_text": row_text,
                                        "cells": [cell.inner_text().strip() for cell in cells]
                                    }
                                    cases.append(case_data)
                                    
                            except Exception as e:
                                print(f"  Row {i}: Error - {e}")
                        
                        # Save results
                        output = {
                            "timestamp": datetime.now().isoformat(),
                            "search_dates": f"{yesterday} to {today}",
                            "url": page.url,
                            "total_cases": len(cases),
                            "cases": cases
                        }
                        
                        with open("database_search_results.json", "w") as f:
                            json.dump(output, f, indent=2)
                        
                        print(f"\n🎉 Extracted {len(cases)} cases!")
                        print("💾 Saved to database_search_results.json")
                    
                else:
                    print("❌ No submit button found")
            else:
                print("❌ No date fields found")
                
        except Exception as e:
            print(f"❌ Error clicking SEARCH DATABASE: {e}")
        
        print(f"\n📍 Final URL: {page.url}")
        print("📸 Check search_database_page.png and search_results.png")
        
        # Keep browser open for manual exploration
        input("Press Enter to continue or Ctrl+C to exit...")
        
        browser.close()

if __name__ == "__main__":
    main()