#!/usr/bin/env python3
"""
Simple VIEW Extractor - Just get VIEW data from whatever results MUFON shows
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def simple_view_extraction():
    """Simple extraction - navigate like the working client and click any VIEW buttons found"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file))
        page = context.new_page()
        
        try:
            print("🎯 Step 1: Going to MUFON research page...")
            page.goto("https://mufon.com/research/", wait_until="domcontentloaded")
            
            print("🔍 Step 2: Looking for Member Login...")
            login_links = page.locator("a:has-text('Member Login')").all()
            if login_links:
                print(f"  Found {len(login_links)} login links")
                login_links[0].click()
                page.wait_for_load_state("networkidle")
                time.sleep(2)
                
                print("🔍 Step 3: Looking for SEARCH DATABASE...")
                # Try multiple variations
                search_selectors = [
                    "text=SEARCH DATABASE",
                    "text=Search Database", 
                    "a:has-text('SEARCH DATABASE')",
                    "a:has-text('Search Database')",
                    "link:has-text('database')"
                ]
                
                search_link = None
                for selector in search_selectors:
                    elements = page.locator(selector).all()
                    if elements:
                        search_link = elements[0]
                        print(f"  Found search link with selector: {selector}")
                        break
                
                if search_link:
                    search_link.click()
                    page.wait_for_load_state("networkidle")
                    time.sleep(2)
                    
                    print("🔍 Step 4: Looking for choice dropdown...")
                    choice_dropdown = page.locator("select[name='choice']")
                    if choice_dropdown.count() > 0:
                        print("  Found choice dropdown")
                        
                        # List all options for debugging
                        options = choice_dropdown.locator("option").all()
                        print(f"  Found {len(options)} options:")
                        for i, option in enumerate(options):
                            value = option.get_attribute("value")
                            text = option.inner_text()
                            print(f"    {i+1}. '{value}' = '{text}'")
                        
                        # Select Last 20 Reports
                        choice_dropdown.select_option("https://mufoncms.com/last_20_public.html?orgId=mufon")
                        
                        # Submit form
                        submit_btn = page.locator("input[type='submit']").first
                        if submit_btn.count() > 0:
                            submit_btn.click()
                            page.wait_for_load_state("networkidle")
                            time.sleep(3)
                            
                            print("✅ Submitted form - now looking for results...")
                            
                            # Take screenshot of current page
                            page.screenshot(path="simple_results_page.png", full_page=True)
                            
                            print("🔍 Step 5: Looking for iframes...")
                            iframes = page.locator("iframe").all()
                            print(f"  Found {len(iframes)} iframes")
                            
                            working_context = None
                            
                            if iframes:
                                # Try each iframe to find one with case data
                                for i, iframe in enumerate(iframes):
                                    try:
                                        iframe_content = iframe.content_frame()
                                        iframe_content.screenshot(path=f"simple_iframe_{i}.png")
                                        
                                        # Look for table or VIEW elements
                                        tables = iframe_content.locator("table").all()
                                        rows = iframe_content.locator("tr").all()
                                        view_elements = iframe_content.locator("text=VIEW").all()
                                        
                                        print(f"    Iframe {i}: {len(tables)} tables, {len(rows)} rows, {len(view_elements)} VIEW elements")
                                        
                                        if len(view_elements) > 0 or (len(tables) > 0 and len(rows) > 3):
                                            print(f"    ✅ Using iframe {i} - has content")
                                            working_context = iframe_content
                                            break
                                            
                                    except Exception as e:
                                        print(f"    ❌ Error checking iframe {i}: {e}")
                                        continue
                            else:
                                # No iframes, use main page
                                print("  No iframes found, using main page")
                                working_context = page
                            
                            if working_context:
                                print("🎯 Step 6: Extracting VIEW data...")
                                
                                # Look for VIEW elements in the working context
                                view_selectors = [
                                    "text=VIEW",
                                    "input[value='VIEW']",
                                    "button:has-text('VIEW')",
                                    "a:has-text('VIEW')",
                                    "[onclick*='view_long_desc']"
                                ]
                                
                                all_view_elements = []
                                for selector in view_selectors:
                                    elements = working_context.locator(selector).all()
                                    print(f"  Found {len(elements)} elements with selector: {selector}")
                                    for elem in elements:
                                        all_view_elements.append({"element": elem, "selector": selector})
                                
                                print(f"🎯 Total VIEW elements: {len(all_view_elements)}")
                                
                                extracted_data = []
                                
                                for i, view_info in enumerate(all_view_elements[:10]):  # Limit to 10 for safety
                                    try:
                                        print(f"\n  Processing VIEW element {i+1}/{len(all_view_elements)}...")
                                        
                                        element = view_info["element"]
                                        selector = view_info["selector"]
                                        
                                        # Get attributes
                                        onclick = element.get_attribute("onclick")
                                        href = element.get_attribute("href")
                                        value = element.get_attribute("value")
                                        
                                        print(f"    Selector: {selector}")
                                        print(f"    OnClick: {onclick[:50] if onclick else 'None'}...")
                                        print(f"    Href: {href[:50] if href else 'None'}...")
                                        print(f"    Value: {value if value else 'None'}")
                                        
                                        case_data = {
                                            "index": i + 1,
                                            "selector": selector,
                                            "onclick": onclick,
                                            "href": href,
                                            "value": value
                                        }
                                        
                                        # Try to click and extract
                                        try:
                                            element.click()
                                            time.sleep(3)
                                            
                                            current_url = working_context.url
                                            print(f"    After click URL: {current_url}")
                                            
                                            # Extract case ID from URL
                                            case_id_match = re.search(r'id=(\d+)', current_url)
                                            if case_id_match:
                                                case_data["real_case_id"] = case_id_match.group(1)
                                                print(f"    ✅ Real case ID: {case_id_match.group(1)}")
                                                
                                                # Try to get description
                                                page_text = working_context.locator("body").inner_text()
                                                
                                                # Save raw text for debugging
                                                with open(f"simple_case_{case_id_match.group(1)}.txt", "w") as f:
                                                    f.write(page_text)
                                                
                                                # Find longest substantial text block
                                                lines = page_text.split('\n')
                                                best_desc = ""
                                                for line in lines:
                                                    line = line.strip()
                                                    if (len(line) > 100 and 
                                                        not line.startswith('Case #') and
                                                        'mufon' not in line.lower() and
                                                        'copyright' not in line.lower()):
                                                        if len(line) > len(best_desc):
                                                            best_desc = line
                                                
                                                if best_desc:
                                                    case_data["long_description"] = best_desc
                                                    print(f"    ✅ Long description: {len(best_desc)} chars")
                                                    print(f"    Preview: {best_desc[:80]}...")
                                            
                                            # Go back
                                            working_context.go_back()
                                            time.sleep(2)
                                            
                                        except Exception as e:
                                            print(f"    ❌ Error clicking VIEW: {e}")
                                        
                                        extracted_data.append(case_data)
                                        
                                    except Exception as e:
                                        print(f"  ❌ Error processing VIEW element {i}: {e}")
                                        continue
                                
                                # Save results
                                output = {
                                    "timestamp": time.time(),
                                    "total_view_elements": len(all_view_elements),
                                    "extracted_cases": extracted_data
                                }
                                
                                with open("simple_view_extraction.json", "w") as f:
                                    json.dump(output, f, indent=2)
                                
                                success_count = sum(1 for case in extracted_data if case.get("long_description"))
                                real_id_count = sum(1 for case in extracted_data if case.get("real_case_id"))
                                
                                print(f"\n🎉 Simple extraction results:")
                                print(f"📊 Total VIEW elements found: {len(all_view_elements)}")
                                print(f"🆔 Cases with real IDs: {real_id_count}")
                                print(f"📝 Cases with descriptions: {success_count}")
                                print(f"💾 Saved to simple_view_extraction.json")
                                
                            else:
                                print("❌ No working context found")
                        else:
                            print("❌ No submit button found")
                    else:
                        print("❌ No choice dropdown found")
                        page.screenshot(path="simple_no_dropdown.png", full_page=True)
                else:
                    print("❌ No SEARCH DATABASE link found")
                    page.screenshot(path="simple_no_search_link.png", full_page=True)
            else:
                print("❌ No Member Login link found")
                
        except Exception as e:
            print(f"❌ Error during simple extraction: {e}")
            page.screenshot(path="simple_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    simple_view_extraction()