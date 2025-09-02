#!/usr/bin/env python3
"""
MUFON with VIEW clicks - Extend the working authenticated client with VIEW button clicks
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def get_mufon_with_view_clicks():
    """Use the same working flow but add VIEW button clicks to get long descriptions"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("Step 1: Following the exact working navigation flow...")
            
            # Follow the same exact flow that worked before
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            page.locator("text=Track UFOs").first.click()
            time.sleep(1)
            
            page.locator("text=Search Database").first.click()
            page.wait_for_load_state("networkidle")
            
            # Accept terms
            page.locator("input[type='radio'][value*='agree']").first.check()
            page.locator("button:has-text('Submit')").first.click()
            page.wait_for_load_state("networkidle")
            
            print("Step 2: Looking for results in iframe...")
            
            # Wait longer for everything to load
            time.sleep(5)
            
            # Take screenshot to see current state
            page.screenshot(path="mufon_current_state.png", full_page=True)
            
            # Look for iframe
            iframe = page.locator("iframe")
            print(f"Found {iframe.count()} iframes")
            
            if iframe.count() > 0:
                print("Found iframe, switching context...")
                iframe_content = iframe.first.content_frame()
                
                # Take screenshot of iframe content
                iframe_content.screenshot(path="mufon_iframe_screenshot.png")
                
                print("Step 3: Looking for table rows with case data...")
                
                # Look for table rows (this is where the case data is)
                rows = iframe_content.locator("table tr").all()
                print(f"Found {len(rows)} table rows")
                
                # Also look for any clickable elements
                all_links = iframe_content.locator("a").all()
                all_buttons = iframe_content.locator("button").all()
                all_inputs = iframe_content.locator("input").all()
                
                print(f"Found {len(all_links)} links, {len(all_buttons)} buttons, {len(all_inputs)} inputs")
                
                # Look specifically for VIEW elements
                view_elements = iframe_content.locator("text=VIEW").all()
                print(f"Found {len(view_elements)} VIEW text elements")
                
                cases_with_views = []
                
                # Process each row
                for i, row in enumerate(rows):
                    if i == 0:  # Skip header
                        continue
                        
                    try:
                        print(f"\nProcessing row {i}...")
                        
                        # Get row text
                        row_text = row.inner_text()
                        print(f"  Row text: {row_text[:100]}...")
                        
                        # Look for VIEW elements in this specific row
                        row_view_elements = row.locator("text=VIEW").all()
                        if not row_view_elements:
                            row_view_elements = row.locator("button").all()
                        if not row_view_elements:
                            row_view_elements = row.locator("input[value*='VIEW']").all()
                        
                        case_data = {
                            "row_index": i,
                            "row_text": row_text
                        }
                        
                        if row_view_elements:
                            view_element = row_view_elements[0]
                            print(f"  Found VIEW element in row {i}")
                            
                            try:
                                # Click the VIEW element
                                print(f"  Clicking VIEW element...")
                                view_element.click()
                                time.sleep(3)  # Wait for navigation
                                
                                # Get the current URL to extract case ID
                                current_url = iframe_content.url
                                print(f"  After click URL: {current_url}")
                                
                                # Extract case ID from URL
                                case_id_match = re.search(r'id=(\d+)', current_url)
                                if case_id_match:
                                    real_case_id = case_id_match.group(1)
                                    case_data["real_case_id"] = real_case_id
                                    case_data["view_url"] = current_url
                                    print(f"  Real case ID: {real_case_id}")
                                
                                # Extract long description from the detail page
                                detail_text = iframe_content.inner_text()
                                
                                # Look for substantial description text
                                text_lines = detail_text.split('\n')
                                long_description = ""
                                
                                for line in text_lines:
                                    line = line.strip()
                                    if (len(line) > 100 and 
                                        not re.match(r'^[\d\-\s:APMapm]+$', line) and
                                        'case' not in line.lower()[:10] and
                                        'report' not in line.lower()[:10]):
                                        if len(line) > len(long_description):
                                            long_description = line
                                
                                if long_description:
                                    case_data["long_description"] = long_description
                                    print(f"  Found long description: {len(long_description)} chars")
                                
                                # Go back to results
                                iframe_content.go_back()
                                time.sleep(2)
                                
                            except Exception as e:
                                print(f"  Error clicking VIEW: {e}")
                        
                        else:
                            print(f"  No VIEW element found in row {i}")
                        
                        cases_with_views.append(case_data)
                        
                        # Limit for now
                        if len(cases_with_views) >= 11:
                            break
                            
                    except Exception as e:
                        print(f"  Error processing row {i}: {e}")
                        continue
                
                # Save results
                output = {
                    "timestamp": time.time(),
                    "total_cases": len(cases_with_views),
                    "cases": cases_with_views
                }
                
                with open("mufon_with_view_clicks.json", "w") as f:
                    json.dump(output, f, indent=2)
                
                print(f"\n🎉 Processed {len(cases_with_views)} cases with VIEW clicks")
                
            else:
                print("❌ No iframe found")
                
                # Debug: look for any forms on main page
                forms = page.locator("form").all()
                print(f"Found {len(forms)} forms on main page")
                
                # Look for any search-related elements
                search_elements = page.locator("text=search").all()
                print(f"Found {len(search_elements)} search elements")
                
        except Exception as e:
            print(f"❌ Error: {e}")
            page.screenshot(path="mufon_error_debug.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    get_mufon_with_view_clicks()