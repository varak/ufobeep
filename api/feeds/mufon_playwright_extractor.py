#!/usr/bin/env python3
"""
MUFON Playwright Extractor - Extend authenticated session to get VIEW links and long descriptions
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def extract_with_view_calls():
    """Use authenticated Playwright session to get case data AND VIEW links/long descriptions"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("Step 1: Navigating to MUFON...")
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            
            # Follow the established navigation flow
            page.locator("text=Track UFOs").first.click()
            time.sleep(1)
            
            page.locator("text=Search Database").first.click()
            page.wait_for_load_state("networkidle")
            
            # Handle terms and conditions
            page.locator("input[type='radio'][value*='agree']").first.check()
            page.locator("button:has-text('Submit')").first.click()
            page.wait_for_load_state("networkidle")
            
            print("Step 2: Looking for results table...")
            
            # Wait for page to fully load
            time.sleep(3)
            
            # Take initial screenshot
            page.screenshot(path="mufon_search_results.png", full_page=True)
            
            # Look for iframe containing results
            iframe = page.locator("iframe").first
            if iframe.count() > 0:
                print("Found iframe, switching to iframe content...")
                iframe_content = iframe.content_frame()
                
                # Wait for iframe content to load
                time.sleep(2)
                
                # Find table rows or containers with case data
                table_rows = iframe_content.locator("table tr").all()
                if not table_rows:
                    # Try alternative selectors
                    table_rows = iframe_content.locator("tr").all()
                
                print(f"Found {len(table_rows)} table rows")
                
                cases_with_views = []
                
                # Process each row to extract basic case data AND VIEW links
                for i, row in enumerate(table_rows):
                    try:
                        if i == 0:  # Skip header row
                            continue
                            
                        print(f"\nProcessing row {i}/{len(table_rows)}...")
                        
                        # Extract basic case data from the row
                        row_text = row.inner_text()
                        cells = row.locator("td").all()
                        
                        if not cells or len(cells) < 2:
                            print(f"  Skipping row {i}: insufficient cells")
                            continue
                        
                        # Parse case data from cells
                        case_data = {
                            "row_index": i,
                            "raw_row_text": row_text
                        }
                        
                        # Extract case number, date, location from cells
                        cell_texts = []
                        for cell in cells:
                            cell_text = cell.inner_text().strip()
                            cell_texts.append(cell_text)
                        
                        case_data["cell_texts"] = cell_texts
                        
                        # Look for case number pattern in cells
                        for cell_text in cell_texts:
                            case_match = re.search(r'(\d+)', cell_text)
                            if case_match and len(case_match.group(1)) >= 3:
                                case_data["case_number"] = case_match.group(1)
                                break
                        
                        # Look for VIEW button/link in this row
                        view_elements = row.locator("text=VIEW").all()
                        if not view_elements:
                            view_elements = row.locator("button:has-text('VIEW')").all()
                        if not view_elements:
                            view_elements = row.locator("a:has-text('VIEW')").all()
                        if not view_elements:
                            view_elements = row.locator("[onclick*='view_long_desc']").all()
                        if not view_elements:
                            view_elements = row.locator("[href*='view_long_desc']").all()
                        
                        if view_elements:
                            view_element = view_elements[0]
                            print(f"  Found VIEW element in row {i}")
                            
                            # Extract VIEW URL
                            href = view_element.get_attribute("href")
                            onclick = view_element.get_attribute("onclick")
                            
                            view_url = None
                            if href and "view_long_desc" in href:
                                view_url = href
                            elif onclick and "view_long_desc" in onclick:
                                url_match = re.search(r'(https?://[^"\']+view_long_desc[^"\']*)', onclick)
                                if url_match:
                                    view_url = url_match.group(1)
                            
                            if view_url:
                                # Extract real case ID from URL
                                id_match = re.search(r'id=(\d+)', view_url)
                                real_case_id = id_match.group(1) if id_match else None
                                
                                case_data["view_url"] = view_url
                                case_data["real_case_id"] = real_case_id
                                
                                print(f"  VIEW URL: {view_url}")
                                print(f"  Real case ID: {real_case_id}")
                                
                                # Click the VIEW button to get long description
                                try:
                                    print(f"  Clicking VIEW button...")
                                    view_element.click()
                                    time.sleep(3)  # Wait for detail page to load
                                    
                                    # Extract long description from detail page
                                    long_description = ""
                                    
                                    # Try various selectors for description content
                                    desc_selectors = [
                                        "td",  # Table cells often contain description
                                        "div", 
                                        "p"
                                    ]
                                    
                                    for selector in desc_selectors:
                                        elements = iframe_content.locator(selector).all()
                                        for elem in elements:
                                            text = elem.inner_text().strip()
                                            # Look for substantial text that looks like a description
                                            if (text and len(text) > 100 and 
                                                not re.match(r'^[\d\-\s:APMapm]+$', text) and
                                                'description' not in text.lower()[:20]):
                                                if len(text) > len(long_description):
                                                    long_description = text
                                    
                                    if long_description:
                                        case_data["long_description"] = long_description
                                        print(f"  ✅ Found long description: {len(long_description)} chars")
                                    else:
                                        print(f"  ❌ No long description found")
                                    
                                    # Go back to results page
                                    iframe_content.go_back()
                                    time.sleep(2)
                                    
                                except Exception as e:
                                    print(f"  ❌ Error clicking VIEW: {e}")
                                    # Continue with next case
                        
                        else:
                            print(f"  No VIEW element found in row {i}")
                        
                        cases_with_views.append(case_data)
                        
                        # Limit processing for now
                        if len(cases_with_views) >= 11:  # Match our existing 11 cases
                            break
                            
                    except Exception as e:
                        print(f"  ❌ Error processing row {i}: {e}")
                        continue
                
                # Save the extracted data
                output_data = {
                    "timestamp": time.time(),
                    "total_cases": len(cases_with_views),
                    "extraction_method": "playwright_authenticated_with_views",
                    "cases": cases_with_views
                }
                
                with open("mufon_cases_with_views.json", "w") as f:
                    json.dump(output_data, f, indent=2)
                
                print(f"\n🎉 Extracted {len(cases_with_views)} cases with VIEW data")
                print(f"📄 Results saved to mufon_cases_with_views.json")
                
                # Take final screenshot
                page.screenshot(path="mufon_extraction_complete.png", full_page=True)
                
            else:
                print("❌ No iframe found")
                page.screenshot(path="mufon_no_iframe_final.png", full_page=True)
                
        except Exception as e:
            print(f"❌ Error during extraction: {e}")
            page.screenshot(path="mufon_error_final.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    extract_with_view_calls()