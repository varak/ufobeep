#!/usr/bin/env python3
"""
Extract MUFON Long Descriptions - Get long descriptions and real case numbers from existing cases
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def extract_long_descriptions():
    """Extract long descriptions by clicking VIEW buttons for each case"""
    
    # Load existing case data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON data file found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    cases = mufon_data.get('cases', [])
    print(f"📊 Extracting long descriptions for {len(cases)} MUFON cases...")
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("Step 1: Navigating to MUFON search...")
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            
            # Follow the authentication flow
            page.locator("text=Track UFOs").first.click()
            time.sleep(1)
            
            page.locator("text=Search Database").first.click()
            page.wait_for_load_state("networkidle")
            
            # Handle terms and conditions
            page.locator("input[type='radio'][value*='agree']").first.check()
            page.locator("button:has-text('Submit')").first.click()
            page.wait_for_load_state("networkidle")
            
            print("Step 2: Getting to search results...")
            
            # Look for iframe with search results
            iframe = page.locator("iframe").first
            if iframe.count() > 0:
                print("Found iframe, extracting case details...")
                iframe_content = iframe.content_frame()
                
                # Take screenshot of current state
                page.screenshot(path="mufon_before_extraction.png", full_page=True)
                
                # Look for table rows or case containers
                table_rows = iframe_content.locator("table tr").all()
                if not table_rows:
                    table_rows = iframe_content.locator("tr").all()
                
                print(f"Found {len(table_rows)} table rows")
                
                enhanced_cases = []
                view_links_found = []
                
                # Process each case
                for i, case in enumerate(cases):
                    try:
                        print(f"\nProcessing case {i+1}/{len(cases)}: {case.get('Case_Number')}")
                        
                        # Look for VIEW elements in all possible formats
                        view_selectors = [
                            "text=VIEW",
                            "button:has-text('VIEW')", 
                            "a:has-text('VIEW')",
                            "input[value*='VIEW']",
                            "[onclick*='view_long_desc']",
                            "[href*='view_long_desc']"
                        ]
                        
                        view_element = None
                        view_url = None
                        
                        for selector in view_selectors:
                            elements = iframe_content.locator(selector).all()
                            if elements and len(elements) > i:
                                view_element = elements[i]
                                print(f"  Found VIEW element with selector: {selector}")
                                
                                # Try to get the URL from various attributes
                                href = view_element.get_attribute("href")
                                onclick = view_element.get_attribute("onclick")
                                
                                if href and "view_long_desc" in href:
                                    view_url = href
                                elif onclick and "view_long_desc" in onclick:
                                    # Extract URL from onclick JavaScript
                                    url_match = re.search(r'(https?://[^"\']+view_long_desc[^"\']*)', onclick)
                                    if url_match:
                                        view_url = url_match.group(1)
                                
                                if view_url:
                                    print(f"  Found VIEW URL: {view_url}")
                                    break
                        
                        if view_element and view_url:
                            # Extract case ID from URL
                            id_match = re.search(r'id=(\d+)', view_url)
                            real_case_id = id_match.group(1) if id_match else None
                            
                            view_links_found.append({
                                "original_case": case.get('Case_Number'),
                                "real_case_id": real_case_id,
                                "view_url": view_url,
                                "index": i
                            })
                            
                            # Click the VIEW button to get long description
                            try:
                                print(f"  Clicking VIEW button...")
                                view_element.click()
                                time.sleep(3)  # Wait for page to load
                                
                                # Extract long description from the detail page
                                long_description = ""
                                
                                # Try multiple selectors for the description content
                                desc_selectors = [
                                    "td:has-text('Description')",
                                    "div:has-text('Description')",
                                    "p",
                                    "div",
                                    "td"
                                ]
                                
                                for desc_selector in desc_selectors:
                                    elements = iframe_content.locator(desc_selector).all()
                                    for elem in elements:
                                        text = elem.inner_text().strip()
                                        if text and len(text) > 50 and "description" not in text.lower():
                                            if len(text) > len(long_description):
                                                long_description = text
                                
                                if long_description:
                                    case['Long_Description'] = long_description
                                    print(f"  ✅ Found long description: {len(long_description)} chars")
                                
                                if real_case_id:
                                    case['Real_Case_Number'] = real_case_id
                                    print(f"  ✅ Real case number: {real_case_id}")
                                
                                # Go back to results
                                iframe_content.go_back()
                                time.sleep(2)
                                
                            except Exception as e:
                                print(f"  ❌ Error clicking VIEW: {e}")
                        
                        else:
                            print(f"  No VIEW button found for case {i+1}")
                        
                        enhanced_cases.append(case)
                        
                    except Exception as e:
                        print(f"  ❌ Error processing case {i+1}: {e}")
                        enhanced_cases.append(case)  # Keep original
                        continue
                
                # Save VIEW links found
                if view_links_found:
                    with open("mufon_view_links.json", "w") as f:
                        json.dump({
                            "timestamp": time.time(),
                            "total_links": len(view_links_found),
                            "view_links": view_links_found
                        }, f, indent=2)
                    print(f"\n📋 Saved {len(view_links_found)} VIEW links to mufon_view_links.json")
                
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
                
                # Take final screenshot
                page.screenshot(path="mufon_after_extraction.png", full_page=True)
                
            else:
                print("❌ No iframe found - may not be on results page")
                page.screenshot(path="mufon_no_iframe.png", full_page=True)
                
        except Exception as e:
            print(f"❌ Error during extraction: {e}")
            page.screenshot(path="mufon_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    extract_long_descriptions()