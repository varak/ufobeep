#!/usr/bin/env python3
"""
Click VIEW Buttons in Iframe - Navigate to results and click VIEW buttons in correct iframe context
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def click_view_buttons_in_iframe():
    """Navigate to MUFON results and click VIEW buttons in the correct iframe context"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("🎯 Step 1: Navigating through authenticated MUFON flow...")
            
            # Follow the exact same flow that gets us the 11 recent cases
            page.goto("https://mufon.com/research/", wait_until="domcontentloaded")
            
            # Find and click login link
            login_links = page.locator("text=Member Login").all()
            if login_links:
                login_links[0].click()
                page.wait_for_load_state("networkidle")
                
                # Fill login form
                page.fill("input[name='loginName']", "varak")
                page.fill("input[name='loginPassword']", "ufobeep123pass")
                page.click("input[type='submit']")
                page.wait_for_load_state("networkidle")
                
                print("✅ Logged in successfully")
                
                # Look for Track UFOs/Search Database in authenticated interface
                search_links = page.locator("text=SEARCH DATABASE").all()
                if search_links:
                    search_links[0].click()
                    page.wait_for_load_state("networkidle")
                    
                    print("✅ Navigated to search database page")
                    
                    # Look for the choice dropdown and select "Last 20 Reports"
                    choice_select = page.locator("select[name='choice']")
                    if choice_select.count() > 0:
                        choice_select.select_option("https://mufoncms.com/last_20_public.html?orgId=mufon")
                        
                        # Submit the form
                        page.locator("form").filter(has=choice_select).locator("input[type='submit']").click()
                        page.wait_for_load_state("networkidle")
                        time.sleep(3)
                        
                        print("✅ Submitted form to get Last 20 Reports")
                        
                        # Now we should be on the results page - look for iframe
                        print("📊 Step 2: Looking for iframe with case results...")
                        
                        iframe = page.locator("iframe").first
                        if iframe.count() > 0:
                            print("Found iframe! Switching to iframe context...")
                            iframe_content = iframe.content_frame()
                            time.sleep(2)
                            
                            # Take screenshot of iframe
                            iframe_content.screenshot(path="iframe_with_cases.png")
                            
                            # Save iframe HTML
                            iframe_html = iframe_content.content()
                            with open("iframe_cases.html", "w") as f:
                                f.write(iframe_html)
                            
                            print("🔍 Step 3: Looking for table with VIEW buttons...")
                            
                            # Look for table structure in iframe
                            tables = iframe_content.locator("table").all()
                            rows = iframe_content.locator("tr").all()
                            print(f"Found {len(tables)} tables, {len(rows)} rows in iframe")
                            
                            # Look specifically for VIEW buttons/links in table cells
                            view_elements = []
                            
                            # Look for clickable VIEW elements in table cells
                            view_buttons = iframe_content.locator("input[value='VIEW']").all()
                            view_links = iframe_content.locator("a:has-text('VIEW')").all()
                            view_onclick = iframe_content.locator("[onclick*='view_long_desc']").all()
                            
                            print(f"Found {len(view_buttons)} VIEW buttons")
                            print(f"Found {len(view_links)} VIEW links")  
                            print(f"Found {len(view_onclick)} onclick VIEW elements")
                            
                            # Collect all VIEW elements
                            for btn in view_buttons:
                                view_elements.append({"element": btn, "type": "button"})
                            for link in view_links:
                                view_elements.append({"element": link, "type": "link"})
                            for onclick in view_onclick:
                                view_elements.append({"element": onclick, "type": "onclick"})
                            
                            print(f"🎯 Total VIEW elements found: {len(view_elements)}")
                            
                            case_data = []
                            
                            print("🔍 Step 4: Clicking each VIEW element to get long descriptions...")
                            
                            for i, view_info in enumerate(view_elements):
                                try:
                                    print(f"\nProcessing VIEW element {i+1}/{len(view_elements)}...")
                                    
                                    element = view_info["element"]
                                    element_type = view_info["type"]
                                    
                                    print(f"  Type: {element_type}")
                                    
                                    # Get element attributes before clicking
                                    onclick = element.get_attribute("onclick")
                                    href = element.get_attribute("href")
                                    value = element.get_attribute("value")
                                    
                                    print(f"  OnClick: {onclick[:50] if onclick else 'None'}...")
                                    print(f"  Href: {href[:50] if href else 'None'}...")
                                    print(f"  Value: {value if value else 'None'}")
                                    
                                    # Click the VIEW element
                                    element.click()
                                    time.sleep(3)  # Wait for navigation
                                    
                                    # Get current URL to extract case ID
                                    current_url = iframe_content.url
                                    print(f"  After click URL: {current_url}")
                                    
                                    # Extract real case ID from URL
                                    case_id_match = re.search(r'id=(\d+)', current_url)
                                    real_case_id = case_id_match.group(1) if case_id_match else None
                                    
                                    case_info = {
                                        "view_index": i + 1,
                                        "element_type": element_type,
                                        "onclick": onclick,
                                        "href": href,
                                        "value": value,
                                        "real_case_id": real_case_id,
                                        "view_url": current_url
                                    }
                                    
                                    if real_case_id:
                                        print(f"  ✅ Real case ID: {real_case_id}")
                                        
                                        # Extract long description from the detail page
                                        detail_text = iframe_content.locator("body").inner_text()
                                        
                                        # Save detail page for debugging
                                        with open(f"case_detail_{real_case_id}.txt", "w") as f:
                                            f.write(detail_text)
                                        
                                        # Find substantial description text
                                        long_description = ""
                                        text_lines = detail_text.split('\n')
                                        
                                        for line in text_lines:
                                            line = line.strip()
                                            if (len(line) > 100 and  # Substantial length
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
                                    
                                    case_data.append(case_info)
                                    
                                    # Go back to results page
                                    iframe_content.go_back()
                                    time.sleep(2)
                                    
                                except Exception as e:
                                    print(f"  ❌ Error processing VIEW element {i}: {e}")
                                    continue
                            
                            # Save results
                            output = {
                                "timestamp": time.time(),
                                "extraction_method": "authenticated_iframe_view_clicks",
                                "total_view_elements": len(view_elements),
                                "cases": case_data
                            }
                            
                            with open("iframe_view_results.json", "w") as f:
                                json.dump(output, f, indent=2)
                            
                            success_count = sum(1 for case in case_data if case.get("long_description"))
                            real_id_count = sum(1 for case in case_data if case.get("real_case_id"))
                            
                            print(f"\n🎉 Iframe VIEW extraction results:")
                            print(f"📊 Total VIEW elements: {len(view_elements)}")
                            print(f"🆔 Cases with real IDs: {real_id_count}")
                            print(f"📝 Cases with long descriptions: {success_count}")
                            print(f"📄 Results saved to iframe_view_results.json")
                            
                        else:
                            print("❌ No iframe found on results page")
                            page.screenshot(path="no_iframe_results.png", full_page=True)
                            
                    else:
                        print("❌ Could not find choice dropdown")
                else:
                    print("❌ Could not find SEARCH DATABASE link")
            else:
                print("❌ Could not find Member Login link")
                
        except Exception as e:
            print(f"❌ Error during iframe VIEW extraction: {e}")
            page.screenshot(path="iframe_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    click_view_buttons_in_iframe()