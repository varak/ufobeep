#!/usr/bin/env python3
"""
MUFON Detail Extractor - Click into case details to get long descriptions and real case numbers
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time

def extract_case_details():
    """Extract detailed case information by clicking into each case"""
    
    # Load existing case data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON data file found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    cases = mufon_data.get('cases', [])
    print(f"📊 Enhancing {len(cases)} MUFON cases with detailed data...")
    
    # Use existing authenticated session
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            # Navigate to MUFON search results
            print("Step 1: Going to MUFON search...")
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            
            # Click Track UFOs
            page.locator("text=Track UFOs").first.click()
            time.sleep(1)
            
            # Click Database Search  
            page.locator("text=Search Database").first.click()
            page.wait_for_load_state("networkidle")
            
            # Agree to terms
            page.locator("input[type='radio'][value*='agree']").first.check()
            page.locator("button:has-text('Submit')").first.click()
            page.wait_for_load_state("networkidle")
            
            print("Step 2: Getting to search results...")
            # Navigate through login and search to get to results
            # This uses the existing authenticated session
            
            # Look for case table or list
            iframe = page.locator("iframe").first
            if iframe.count() > 0:
                print("Found iframe, switching context...")
                iframe_content = iframe.content_frame()
                
                # Find case rows in the table
                rows = iframe_content.locator("table tr").all()
                print(f"Found {len(rows)} table rows")
                
                enhanced_cases = []
                for i, case in enumerate(cases):
                    try:
                        print(f"\nProcessing case {i+1}/{len(cases)}: {case.get('Case_Number')}")
                        
                        # Look for clickable link in the corresponding row
                        row_index = i + 1  # Skip header row
                        if row_index < len(rows):
                            row = rows[row_index]
                            # Look specifically for VIEW button/link
                            view_elements = row.locator("text=VIEW").all()
                            if not view_elements:
                                view_elements = row.locator("button:has-text('VIEW')").all()
                            if not view_elements:
                                view_elements = row.locator("a:has-text('VIEW')").all()
                            if not view_elements:
                                view_elements = row.locator("[value*='VIEW']").all()
                            
                            if view_elements:
                                print(f"  Found VIEW button/link")
                                view_element = view_elements[0]
                                
                                # Click the VIEW button
                                view_element.click()
                                time.sleep(2)
                                
                                # Extract real case number from URL
                                detail_url = iframe_content.url
                                print(f"  Detail URL: {detail_url}")
                                
                                import re
                                case_num_match = re.search(r'case[=/](\d+)', detail_url) 
                                if case_num_match:
                                    real_case_number = case_num_match.group(1)
                                    case['Real_Case_Number'] = real_case_number
                                    print(f"  ✅ Real case number: {real_case_number}")
                                
                                # Extract long description
                                long_desc_text = ""
                                for selector in ["div:has-text('Description')", ".description", "div", "p"]:
                                    try:
                                        elements = iframe_content.locator(selector).all()
                                        for element in elements:
                                            text = element.inner_text()
                                            if text and len(text) > 100 and 'description' not in text.lower():
                                                long_desc_text = text
                                                print(f"  ✅ Found long description: {len(text)} chars")
                                                break
                                        if long_desc_text:
                                            break
                                    except:
                                        continue
                                
                                if long_desc_text:
                                    case['Long_Description'] = long_desc_text
                                
                                # Go back to results
                                iframe_content.go_back()
                                time.sleep(1)
                            else:
                                print(f"  No clickable links found in row")
                        
                        enhanced_cases.append(case)
                        
                    except Exception as e:
                        print(f"  ❌ Error processing case {i+1}: {e}")
                        enhanced_cases.append(case)  # Keep original
                        continue
                
                # Save enhanced data
                enhanced_data = {
                    "timestamp": mufon_data.get('timestamp'),
                    "url": mufon_data.get('url'),
                    "title": mufon_data.get('title'),
                    "total_cases": len(enhanced_cases),
                    "cases": enhanced_cases
                }
                
                with open("mufon_enhanced_results.json", "w") as f:
                    json.dump(enhanced_data, f, indent=2)
                
                print(f"\n🎉 Enhanced {len(enhanced_cases)} cases saved to mufon_enhanced_results.json")
                
        except Exception as e:
            print(f"❌ Error during extraction: {e}")
        finally:
            browser.close()

if __name__ == "__main__":
    extract_case_details()