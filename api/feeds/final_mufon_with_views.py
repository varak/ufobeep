#!/usr/bin/env python3
"""
Final MUFON with Views - Properly extend authenticated session to click VIEW buttons
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def final_mufon_extraction():
    """Complete MUFON extraction with authenticated navigation and VIEW button clicks"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("🎯 Step 1: Following complete authenticated navigation flow...")
            
            # Start from MUFON home
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            time.sleep(2)
            
            # Navigate to Track UFOs
            track_elements = page.locator("text=Track UFOs").all()
            if track_elements:
                print("  Clicking Track UFOs...")
                track_elements[0].click()
                time.sleep(2)
            
            # Navigate to Search Database
            search_elements = page.locator("text=Search Database").all()
            if search_elements:
                print("  Clicking Search Database...")
                search_elements[0].click()
                page.wait_for_load_state("networkidle")
                time.sleep(2)
            
            # Handle terms and conditions
            agree_elements = page.locator("input[type='radio'][value*='agree']").all()
            if agree_elements:
                print("  Accepting terms...")
                agree_elements[0].check()
                
                submit_elements = page.locator("button:has-text('Submit')").all()
                if submit_elements:
                    submit_elements[0].click()
                    page.wait_for_load_state("networkidle")
                    time.sleep(3)
            
            print("🔍 Step 2: Looking for results iframe...")
            
            # Find iframe containing results
            iframes = page.locator("iframe").all()
            print(f"  Found {len(iframes)} iframes")
            
            if iframes:
                iframe_content = iframes[0].content_frame()
                time.sleep(2)
                
                print("📊 Step 3: Analyzing iframe content...")
                
                # Take screenshot of iframe content for debugging
                iframe_content.screenshot(path="final_iframe_content.png")
                
                # Look for table structure
                tables = iframe_content.locator("table").all()
                rows = iframe_content.locator("tr").all()
                
                print(f"  Found {len(tables)} tables, {len(rows)} rows")
                
                # Look for all possible VIEW elements
                view_text = iframe_content.locator("text=VIEW").all()
                view_buttons = iframe_content.locator("button").all()  # Any buttons
                view_links = iframe_content.locator("a").all()  # Any links
                view_inputs = iframe_content.locator("input").all()  # Any inputs
                
                print(f"  Found {len(view_text)} VIEW text, {len(view_buttons)} buttons, {len(view_links)} links, {len(view_inputs)} inputs")
                
                # Get page HTML for analysis
                iframe_html = iframe_content.content()
                with open("final_iframe_content.html", "w") as f:
                    f.write(iframe_html)
                
                print("🎯 Step 4: Looking for clickable VIEW elements...")
                
                # Try to find VIEW elements by different methods
                all_elements = []
                
                # Method 1: Look for text "VIEW"
                for elem in view_text:
                    try:
                        tag_name = elem.evaluate("el => el.tagName")
                        onclick = elem.get_attribute("onclick")
                        href = elem.get_attribute("href")
                        all_elements.append({
                            "element": elem,
                            "method": "text=VIEW",
                            "tag": tag_name,
                            "onclick": onclick,
                            "href": href
                        })
                    except:
                        continue
                
                # Method 2: Look for elements with onclick containing view_long_desc
                onclick_elements = iframe_content.locator("[onclick*='view_long_desc']").all()
                for elem in onclick_elements:
                    try:
                        onclick = elem.get_attribute("onclick")
                        all_elements.append({
                            "element": elem,
                            "method": "onclick*=view_long_desc",
                            "onclick": onclick
                        })
                    except:
                        continue
                
                print(f"  Found {len(all_elements)} potential VIEW elements")
                
                # Try to click VIEW elements and extract descriptions
                enhanced_cases = []
                
                for i, elem_info in enumerate(all_elements):
                    try:
                        print(f"\n📋 Processing VIEW element {i+1}/{len(all_elements)}...")
                        
                        element = elem_info["element"]
                        method = elem_info["method"]
                        
                        print(f"  Method: {method}")
                        if elem_info.get("onclick"):
                            print(f"  OnClick: {elem_info['onclick'][:100]}...")
                        
                        # Try to click the element
                        element.click()
                        time.sleep(3)  # Wait for navigation
                        
                        # Check if we navigated to a detail page
                        current_url = iframe_content.url
                        print(f"  After click URL: {current_url}")
                        
                        # Extract case ID from URL
                        case_id_match = re.search(r'id=(\d+)', current_url)
                        real_case_id = case_id_match.group(1) if case_id_match else None
                        
                        case_data = {
                            "view_element_index": i,
                            "click_method": method,
                            "real_case_id": real_case_id,
                            "view_url": current_url
                        }
                        
                        if real_case_id:
                            print(f"  ✅ Real case ID: {real_case_id}")
                            
                            # Extract long description from detail page
                            detail_text = iframe_content.locator("body").inner_text()
                            
                            # Save raw detail page for debugging
                            with open(f"case_detail_{real_case_id}.txt", "w") as f:
                                f.write(detail_text)
                            
                            # Find the longest meaningful text block
                            long_description = ""
                            text_lines = detail_text.split('\n')
                            
                            for line in text_lines:
                                line = line.strip()
                                if (len(line) > 50 and 
                                    not line.startswith('Case #') and
                                    not line.isdigit() and
                                    'mufon' not in line.lower() and
                                    'copyright' not in line.lower()):
                                    if len(line) > len(long_description):
                                        long_description = line
                            
                            if long_description:
                                case_data["long_description"] = long_description
                                print(f"  ✅ Long description: {len(long_description)} chars")
                                print(f"  Preview: {long_description[:100]}...")
                            
                        enhanced_cases.append(case_data)
                        
                        # Go back to results
                        iframe_content.go_back()
                        time.sleep(2)
                        
                    except Exception as e:
                        print(f"  ❌ Error processing element {i}: {e}")
                        continue
                
                # Save results
                output = {
                    "timestamp": time.time(),
                    "extraction_method": "authenticated_playwright_with_view_clicks",
                    "total_view_elements": len(all_elements),
                    "enhanced_cases": enhanced_cases
                }
                
                with open("final_mufon_with_view_details.json", "w") as f:
                    json.dump(output, f, indent=2)
                
                success_count = sum(1 for case in enhanced_cases if case.get("long_description"))
                print(f"\n🎉 Successfully extracted {success_count} long descriptions")
                print(f"📄 Results saved to final_mufon_with_view_details.json")
                
            else:
                print("❌ No iframe found in results page")
                page.screenshot(path="final_no_iframe.png", full_page=True)
            
        except Exception as e:
            print(f"❌ Error during extraction: {e}")
            page.screenshot(path="final_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    final_mufon_extraction()