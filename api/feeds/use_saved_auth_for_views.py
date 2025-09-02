#!/usr/bin/env python3
"""
Use Saved Auth for Views - Use existing authenticated session to click VIEW buttons
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def use_saved_auth_for_views():
    """Use saved authenticated session to navigate to results and click VIEW buttons"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    if not state_file.exists():
        print("❌ No saved authentication state found")
        return
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file))
        page = context.new_page()
        
        try:
            print("🎯 Step 1: Using saved authentication to navigate to MUFON...")
            
            # Go directly to the authenticated member area
            page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", wait_until="domcontentloaded")
            time.sleep(3)
            
            # Take screenshot to see current state
            page.screenshot(path="saved_auth_page.png", full_page=True)
            
            print("🔍 Step 2: Looking for choice dropdown to select Last 20 Reports...")
            
            # Look for the choice dropdown that selects "Last 20 Reports"
            choice_dropdown = page.locator("select[name='choice']")
            if choice_dropdown.count() > 0:
                print("Found choice dropdown, selecting Last 20 Reports...")
                choice_dropdown.select_option("https://mufoncms.com/last_20_public.html?orgId=mufon")
                
                # Submit the form
                submit_button = page.locator("input[type='submit']").first
                if submit_button.count() > 0:
                    submit_button.click()
                    page.wait_for_load_state("networkidle")
                    time.sleep(3)
                    
                    print("✅ Submitted form for Last 20 Reports")
                    
                    # Now look for iframe with results
                    print("📊 Step 3: Looking for iframe with case results...")
                    
                    iframe = page.locator("iframe").first
                    if iframe.count() > 0:
                        print("Found iframe! Switching to iframe context...")
                        iframe_content = iframe.content_frame()
                        time.sleep(2)
                        
                        # Take screenshot of iframe
                        iframe_content.screenshot(path="results_iframe.png")
                        
                        # Save iframe HTML for analysis
                        iframe_html = iframe_content.content()
                        with open("results_iframe.html", "w") as f:
                            f.write(iframe_html)
                        
                        print("🔍 Step 4: Looking for VIEW elements in iframe...")
                        
                        # Look for all possible VIEW elements in the iframe
                        view_buttons = iframe_content.locator("input[value='VIEW']").all()
                        view_links = iframe_content.locator("a:has-text('VIEW')").all()
                        view_onclick = iframe_content.locator("[onclick*='view_long_desc']").all()
                        view_text = iframe_content.locator("text=VIEW").all()
                        
                        print(f"Found {len(view_buttons)} VIEW input buttons")
                        print(f"Found {len(view_links)} VIEW links")
                        print(f"Found {len(view_onclick)} onclick VIEW elements")
                        print(f"Found {len(view_text)} VIEW text elements")
                        
                        # Collect all VIEW elements
                        all_view_elements = []
                        
                        for btn in view_buttons:
                            all_view_elements.append({"element": btn, "type": "input_button"})
                        for link in view_links:
                            all_view_elements.append({"element": link, "type": "link"})
                        for onclick_elem in view_onclick:
                            all_view_elements.append({"element": onclick_elem, "type": "onclick"})
                        
                        print(f"🎯 Total clickable VIEW elements: {len(all_view_elements)}")
                        
                        if len(all_view_elements) == 0:
                            print("❌ No clickable VIEW elements found. Let me check the HTML structure...")
                            # Save full iframe text for analysis
                            iframe_text = iframe_content.locator("body").inner_text()
                            with open("results_iframe_text.txt", "w") as f:
                                f.write(iframe_text)
                            print("  Saved iframe text to results_iframe_text.txt for analysis")
                            return
                        
                        case_results = []
                        
                        print("🎯 Step 5: Clicking each VIEW element...")
                        
                        for i, view_info in enumerate(all_view_elements):
                            try:
                                print(f"\nProcessing VIEW element {i+1}/{len(all_view_elements)}...")
                                
                                element = view_info["element"]
                                element_type = view_info["type"]
                                
                                print(f"  Type: {element_type}")
                                
                                # Get element attributes
                                onclick = element.get_attribute("onclick")
                                href = element.get_attribute("href")
                                value = element.get_attribute("value")
                                
                                print(f"  OnClick: {onclick[:100] if onclick else 'None'}...")
                                print(f"  Href: {href[:100] if href else 'None'}...")
                                print(f"  Value: {value if value else 'None'}")
                                
                                # Try to click the element
                                element.click()
                                time.sleep(3)
                                
                                # Check if we navigated to a detail page
                                current_url = iframe_content.url
                                print(f"  After click URL: {current_url}")
                                
                                # Extract case ID from URL
                                case_id_match = re.search(r'id=(\d+)', current_url)
                                real_case_id = case_id_match.group(1) if case_id_match else None
                                
                                case_info = {
                                    "view_index": i + 1,
                                    "element_type": element_type,
                                    "real_case_id": real_case_id,
                                    "view_url": current_url
                                }
                                
                                if real_case_id:
                                    print(f"  ✅ Real case ID: {real_case_id}")
                                    
                                    # Extract long description
                                    detail_text = iframe_content.locator("body").inner_text()
                                    
                                    # Save detail for debugging
                                    with open(f"case_{real_case_id}_detail.txt", "w") as f:
                                        f.write(detail_text)
                                    
                                    # Find the longest substantial text block
                                    long_description = ""
                                    text_lines = detail_text.split('\n')
                                    
                                    for line in text_lines:
                                        line = line.strip()
                                        if (len(line) > 100 and
                                            not line.startswith('Case #') and
                                            not line.startswith('Report #') and
                                            not line.isdigit() and
                                            'mufon' not in line.lower() and
                                            'copyright' not in line.lower() and
                                            'forbidden' not in line.lower()):
                                            if len(line) > len(long_description):
                                                long_description = line
                                    
                                    if long_description:
                                        case_info["long_description"] = long_description
                                        print(f"  ✅ Long description: {len(long_description)} chars")
                                        print(f"  Preview: {long_description[:100]}...")
                                    else:
                                        print(f"  ❌ No substantial description found")
                                else:
                                    print(f"  ❌ No case ID found in URL")
                                
                                case_results.append(case_info)
                                
                                # Go back to results
                                iframe_content.go_back()
                                time.sleep(2)
                                
                            except Exception as e:
                                print(f"  ❌ Error processing VIEW element {i}: {e}")
                                continue
                        
                        # Save final results
                        output = {
                            "timestamp": time.time(),
                            "extraction_method": "saved_auth_iframe_views",
                            "total_view_elements": len(all_view_elements),
                            "cases": case_results
                        }
                        
                        with open("saved_auth_view_results.json", "w") as f:
                            json.dump(output, f, indent=2)
                        
                        success_count = sum(1 for case in case_results if case.get("long_description"))
                        real_id_count = sum(1 for case in case_results if case.get("real_case_id"))
                        
                        print(f"\n🎉 Saved auth VIEW extraction results:")
                        print(f"📊 Total VIEW elements processed: {len(all_view_elements)}")
                        print(f"🆔 Cases with real IDs: {real_id_count}")
                        print(f"📝 Cases with long descriptions: {success_count}")
                        print(f"📄 Results saved to saved_auth_view_results.json")
                        
                    else:
                        print("❌ No iframe found on results page")
                        page.screenshot(path="no_iframe_saved_auth.png", full_page=True)
                else:
                    print("❌ No submit button found")
            else:
                print("❌ No choice dropdown found")
                page.screenshot(path="no_dropdown_saved_auth.png", full_page=True)
                
        except Exception as e:
            print(f"❌ Error during saved auth VIEW extraction: {e}")
            page.screenshot(path="saved_auth_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    use_saved_auth_for_views()