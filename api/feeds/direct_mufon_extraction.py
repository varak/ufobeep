#!/usr/bin/env python3
"""
Direct MUFON Extraction - Go directly to the working URL and extract all VIEW data
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def direct_mufon_extraction():
    """Go directly to the working MUFON URL and extract all VIEW button data"""
    
    # Use the exact URL that worked before
    working_url = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&"
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print(f"🎯 Step 1: Navigating directly to working MUFON URL...")
            print(f"URL: {working_url}")
            
            page.goto(working_url, wait_until="domcontentloaded")
            time.sleep(3)  # Wait for page to fully load
            
            # Take screenshot
            page.screenshot(path="direct_mufon_page.png", full_page=True)
            
            print("📊 Step 2: Looking for iframe with case data...")
            
            # Look for iframe
            iframe = page.locator("iframe")
            if iframe.count() > 0:
                print("Found iframe, switching to iframe content...")
                iframe_content = iframe.first.content_frame()
                time.sleep(2)
                working_context = iframe_content
            else:
                print("No iframe found, working with main page...")
                working_context = page
            
            # Take screenshot of working context
            working_context.screenshot(path="direct_working_context.png")
            
            # Save HTML for analysis
            html_content = working_context.content()
            with open("direct_working_context.html", "w") as f:
                f.write(html_content)
            
            print("🔍 Step 3: Looking for case data and VIEW buttons...")
            
            # Look for table structure
            tables = working_context.locator("table").all()
            rows = working_context.locator("tr").all()
            print(f"Found {len(tables)} tables, {len(rows)} rows")
            
            # Look for VIEW elements using multiple methods
            view_elements = []
            
            # Method 1: Text "VIEW"
            text_views = working_context.locator("text=VIEW").all()
            print(f"Found {len(text_views)} text=VIEW elements")
            
            # Method 2: Buttons with VIEW
            button_views = working_context.locator("button:has-text('VIEW')").all()
            print(f"Found {len(button_views)} button VIEW elements")
            
            # Method 3: Links with VIEW
            link_views = working_context.locator("a:has-text('VIEW')").all()
            print(f"Found {len(link_views)} link VIEW elements")
            
            # Method 4: Elements with onclick containing view_long_desc
            onclick_views = working_context.locator("[onclick*='view_long_desc']").all()
            print(f"Found {len(onclick_views)} onclick view_long_desc elements")
            
            # Method 5: Input elements with VIEW value
            input_views = working_context.locator("input[value*='VIEW']").all()
            print(f"Found {len(input_views)} input VIEW elements")
            
            # Combine all VIEW elements
            all_views = []
            for elem in text_views:
                all_views.append({"element": elem, "method": "text=VIEW"})
            for elem in button_views:
                all_views.append({"element": elem, "method": "button:has-text('VIEW')"})
            for elem in link_views:
                all_views.append({"element": elem, "method": "a:has-text('VIEW')"})
            for elem in onclick_views:
                all_views.append({"element": elem, "method": "[onclick*='view_long_desc']"})
            for elem in input_views:
                all_views.append({"element": elem, "method": "input[value*='VIEW']"})
            
            print(f"Total VIEW elements found: {len(all_views)}")
            
            complete_cases = []
            
            print("🎯 Step 4: Processing each VIEW element...")
            
            for i, view_info in enumerate(all_views):
                try:
                    print(f"\nProcessing VIEW element {i+1}/{len(all_views)}...")
                    
                    element = view_info["element"]
                    method = view_info["method"]
                    
                    print(f"  Method: {method}")
                    
                    # Get onclick and href attributes
                    onclick = element.get_attribute("onclick")
                    href = element.get_attribute("href")
                    
                    print(f"  OnClick: {onclick[:100] if onclick else 'None'}")
                    print(f"  Href: {href[:100] if href else 'None'}")
                    
                    # Try to extract VIEW URL from attributes before clicking
                    view_url = None
                    if href and "view_long_desc" in href:
                        view_url = href
                    elif onclick and "view_long_desc" in onclick:
                        # Extract URL from onclick JavaScript
                        url_match = re.search(r'(https?://[^"\']+view_long_desc[^"\']*)', onclick)
                        if url_match:
                            view_url = url_match.group(1)
                    
                    case_data = {
                        "case_index": i + 1,
                        "method": method,
                        "onclick": onclick,
                        "href": href,
                        "view_url": view_url
                    }
                    
                    if view_url:
                        # Extract case ID from VIEW URL
                        case_id_match = re.search(r'id=(\d+)', view_url)
                        if case_id_match:
                            real_case_id = case_id_match.group(1)
                            case_data["real_case_id"] = real_case_id
                            print(f"  ✅ Found real case ID: {real_case_id}")
                            
                            # Now navigate to the VIEW URL to get long description
                            try:
                                print(f"  Navigating to VIEW URL: {view_url}")
                                working_context.goto(view_url)
                                time.sleep(3)
                                
                                # Extract long description
                                detail_text = working_context.locator("body").inner_text()
                                
                                # Save detail for debugging
                                with open(f"direct_case_{real_case_id}_detail.txt", "w") as f:
                                    f.write(detail_text)
                                
                                # Find substantial description
                                long_description = ""
                                text_lines = detail_text.split('\n')
                                
                                for line in text_lines:
                                    line = line.strip()
                                    if (len(line) > 50 and 
                                        not line.startswith('Case #') and
                                        not line.startswith('Report #') and
                                        not line.isdigit() and
                                        'mufon' not in line.lower() and
                                        'copyright' not in line.lower() and
                                        'forbidden' not in line.lower()):
                                        if len(line) > len(long_description):
                                            long_description = line
                                
                                if long_description:
                                    case_data["long_description"] = long_description
                                    print(f"  ✅ Long description: {len(long_description)} chars")
                                    print(f"  Preview: {long_description[:100]}...")
                                else:
                                    print(f"  ❌ No substantial description found")
                                
                                # Go back to results page
                                page.go_back()
                                time.sleep(2)
                                
                            except Exception as e:
                                print(f"  ❌ Error navigating to VIEW URL: {e}")
                    
                    complete_cases.append(case_data)
                    
                except Exception as e:
                    print(f"  ❌ Error processing VIEW element {i}: {e}")
                    continue
            
            # Save complete results
            output = {
                "timestamp": time.time(),
                "source_url": working_url,
                "extraction_method": "direct_authenticated_playwright",
                "total_view_elements": len(all_views),
                "cases": complete_cases
            }
            
            with open("direct_mufon_extraction.json", "w") as f:
                json.dump(output, f, indent=2)
            
            real_id_count = sum(1 for case in complete_cases if case.get("real_case_id"))
            desc_count = sum(1 for case in complete_cases if case.get("long_description"))
            
            print(f"\n🎉 Direct extraction results:")
            print(f"📊 Total VIEW elements: {len(all_views)}")
            print(f"🆔 Cases with real IDs: {real_id_count}")
            print(f"📝 Cases with long descriptions: {desc_count}")
            print(f"📄 Results saved to direct_mufon_extraction.json")
            
        except Exception as e:
            print(f"❌ Error during direct extraction: {e}")
            page.screenshot(path="direct_extraction_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    direct_mufon_extraction()