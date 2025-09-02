#!/usr/bin/env python3
"""
Extend MUFON with Views - Use the exact working URL to get VIEW links and long descriptions
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def extend_mufon_cases_with_views():
    """Navigate directly to the working MUFON results URL and extract VIEW links"""
    
    # Load existing successful results
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON working results found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    # Use the exact URL that worked
    working_url = mufon_data.get('url')
    print(f"Using working URL: {working_url}")
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("Step 1: Navigating directly to working MUFON results URL...")
            page.goto(working_url, wait_until="domcontentloaded")
            time.sleep(3)  # Wait for page to fully load
            
            # Take screenshot to see what we got
            page.screenshot(path="mufon_working_url_page.png", full_page=True)
            
            print("Step 2: Looking for iframe with results...")
            
            # Look for iframe
            iframe = page.locator("iframe").first
            if iframe.count() > 0:
                print("Found iframe, switching to iframe content...")
                iframe_content = iframe.content_frame()
                time.sleep(2)
                
                # Take screenshot of iframe content
                iframe_content.screenshot(path="mufon_iframe_results.png", full_page=True)
                
                # Save the iframe HTML for analysis
                html_content = iframe_content.content()
                with open("mufon_iframe_content.html", "w") as f:
                    f.write(html_content)
                
                print("Step 3: Extracting VIEW elements...")
                
                # Look for all VIEW elements
                view_selectors = [
                    "text=VIEW",
                    "button:has-text('VIEW')",
                    "a:has-text('VIEW')",
                    "input[value*='VIEW']",
                    "[onclick*='view_long_desc']",
                    "[href*='view_long_desc']"
                ]
                
                view_data = []
                
                for selector in view_selectors:
                    elements = iframe_content.locator(selector).all()
                    print(f"Found {len(elements)} elements with selector: {selector}")
                    
                    for i, element in enumerate(elements):
                        try:
                            # Get attributes
                            href = element.get_attribute("href")
                            onclick = element.get_attribute("onclick") 
                            value = element.get_attribute("value")
                            text = element.inner_text()
                            
                            # Extract VIEW URL
                            view_url = None
                            if href and "view_long_desc" in href:
                                view_url = href
                            elif onclick and "view_long_desc" in onclick:
                                url_match = re.search(r'(https?://[^"\']+view_long_desc[^"\']*)', onclick)
                                if url_match:
                                    view_url = url_match.group(1)
                            
                            if view_url:
                                # Extract case ID
                                id_match = re.search(r'id=(\d+)', view_url)
                                case_id = id_match.group(1) if id_match else None
                                
                                view_item = {
                                    "selector": selector,
                                    "index": len(view_data),
                                    "case_id": case_id,
                                    "view_url": view_url,
                                    "element_text": text[:50] if text else "",
                                    "href": href,
                                    "onclick": onclick,
                                    "value": value
                                }
                                
                                view_data.append(view_item)
                                print(f"  VIEW {len(view_data)}: Case {case_id} -> {view_url}")
                        
                        except Exception as e:
                            print(f"  Error processing element {i}: {e}")
                            continue
                
                # Save VIEW data
                view_output = {
                    "timestamp": time.time(),
                    "source_url": working_url,
                    "total_view_links": len(view_data),
                    "view_links": view_data
                }
                
                with open("mufon_view_links_from_working_url.json", "w") as f:
                    json.dump(view_output, f, indent=2)
                
                print(f"\n📋 Found {len(view_data)} VIEW links from working URL")
                
                # Now click each VIEW link to get long descriptions
                print("Step 4: Clicking VIEW links to get long descriptions...")
                
                enhanced_cases = []
                cases = mufon_data.get('cases', [])
                
                for i, case in enumerate(cases):
                    try:
                        print(f"\nProcessing case {i+1}/{len(cases)}: {case.get('Case_Number')}")
                        
                        # Find matching VIEW link
                        if i < len(view_data):
                            view_item = view_data[i]
                            view_url = view_item.get('view_url')
                            real_case_id = view_item.get('case_id')
                            
                            if view_url and real_case_id:
                                print(f"  Real case ID: {real_case_id}")
                                print(f"  VIEW URL: {view_url}")
                                
                                # Navigate directly to the VIEW URL
                                try:
                                    print(f"  Navigating to VIEW URL...")
                                    iframe_content.goto(view_url)
                                    time.sleep(3)
                                    
                                    # Extract long description
                                    long_description = ""
                                    
                                    # Get all text content from the page
                                    page_text = iframe_content.inner_text()
                                    
                                    # Look for substantial text blocks
                                    text_blocks = page_text.split('\n')
                                    for block in text_blocks:
                                        block = block.strip()
                                        if (len(block) > 100 and 
                                            not re.match(r'^[\d\-\s:APMapm]+$', block) and
                                            'case' not in block.lower()[:20] and
                                            'report' not in block.lower()[:20]):
                                            if len(block) > len(long_description):
                                                long_description = block
                                    
                                    if long_description:
                                        case['Long_Description'] = long_description
                                        case['Real_Case_Number'] = real_case_id
                                        print(f"  ✅ Found long description: {len(long_description)} chars")
                                    else:
                                        print(f"  ❌ No substantial long description found")
                                        case['Real_Case_Number'] = real_case_id  # Still save the real case number
                                    
                                    # Go back to results
                                    page.go_back()
                                    time.sleep(2)
                                    
                                except Exception as e:
                                    print(f"  ❌ Error navigating to VIEW URL: {e}")
                            
                        enhanced_cases.append(case)
                        
                    except Exception as e:
                        print(f"  ❌ Error processing case {i+1}: {e}")
                        enhanced_cases.append(case)
                
                # Save enhanced results
                enhanced_data = {
                    "timestamp": mufon_data.get('timestamp'),
                    "url": mufon_data.get('url'),
                    "title": mufon_data.get('title'),
                    "total_cases": len(enhanced_cases),
                    "cases": enhanced_cases
                }
                
                with open("mufon_enhanced_with_views.json", "w") as f:
                    json.dump(enhanced_data, f, indent=2)
                
                enhanced_count = sum(1 for case in enhanced_cases if case.get('Long_Description'))
                print(f"\n🎉 Enhanced {enhanced_count}/{len(enhanced_cases)} cases with long descriptions")
                print(f"📄 Results saved to mufon_enhanced_with_views.json")
                
            else:
                print("❌ No iframe found on working URL")
                page.screenshot(path="mufon_working_url_no_iframe.png", full_page=True)
                
        except Exception as e:
            print(f"❌ Error: {e}")
            page.screenshot(path="mufon_extend_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    extend_mufon_cases_with_views()