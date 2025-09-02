#!/usr/bin/env python3
"""
Complete MUFON Extraction - Get all case data with VIEW links and long descriptions in one go
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def complete_mufon_extraction():
    """Complete extraction of all MUFON cases with VIEW button clicks for long descriptions"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("🎯 Step 1: Navigating through authenticated MUFON flow...")
            
            # Navigate to MUFON
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            time.sleep(1)
            
            # Click Track UFOs
            page.locator("text=Track UFOs").first.click()
            time.sleep(1)
            
            # Click Search Database
            page.locator("text=Search Database").first.click()
            page.wait_for_load_state("networkidle")
            
            # Accept terms
            page.locator("input[type='radio'][value*='agree']").first.check()
            page.locator("button:has-text('Submit')").first.click()
            page.wait_for_load_state("networkidle")
            time.sleep(3)
            
            print("📊 Step 2: Looking for results iframe and case data...")
            
            # Try multiple ways to find the results
            iframe = page.locator("iframe").first
            if iframe.count() > 0:
                print("Found iframe, switching to iframe content...")
                iframe_content = iframe.content_frame()
                time.sleep(2)
                working_context = iframe_content
            else:
                print("No iframe found, working with main page...")
                working_context = page
            
            # Take screenshot for debugging
            working_context.screenshot(path="complete_results_page.png")
            
            # Save HTML content for analysis
            html_content = working_context.content()
            with open("complete_results_page.html", "w") as f:
                f.write(html_content)
            
            print("🔍 Step 3: Looking for all case rows and VIEW elements...")
            
            # Look for table structure
            rows = working_context.locator("tr").all()
            print(f"Found {len(rows)} table rows")
            
            # Look for any VIEW elements
            all_view_elements = []
            
            # Method 1: Text containing "VIEW"
            view_text_elements = working_context.locator("text=VIEW").all()
            for elem in view_text_elements:
                all_view_elements.append({"element": elem, "method": "text=VIEW"})
            
            # Method 2: Elements with onclick containing view_long_desc
            onclick_elements = working_context.locator("[onclick*='view_long_desc']").all()
            for elem in onclick_elements:
                all_view_elements.append({"element": elem, "method": "onclick*=view_long_desc"})
            
            # Method 3: Links with href containing view_long_desc
            href_elements = working_context.locator("[href*='view_long_desc']").all()
            for elem in href_elements:
                all_view_elements.append({"element": elem, "method": "href*=view_long_desc"})
            
            print(f"Found {len(all_view_elements)} total VIEW elements")
            
            complete_cases = []
            
            print("🎯 Step 4: Extracting case data and clicking VIEW buttons...")
            
            for i, view_info in enumerate(all_view_elements):
                try:
                    print(f"\nProcessing VIEW element {i+1}/{len(all_view_elements)}...")
                    
                    element = view_info["element"]
                    method = view_info["method"]
                    
                    # Get the row context - try to find the parent row
                    try:
                        parent_row = element.locator("xpath=ancestor::tr[1]")
                        if parent_row.count() > 0:
                            row_text = parent_row.inner_text()
                        else:
                            # Fallback: get surrounding context
                            row_text = element.locator("xpath=..").inner_text()
                    except:
                        row_text = "Could not extract row context"
                    
                    print(f"  Row context: {row_text[:100]}...")
                    
                    case_data = {
                        "case_number": str(i + 1),  # Sequential case number
                        "extraction_method": method,
                        "row_text": row_text
                    }
                    
                    # Try to click the VIEW element
                    try:
                        print(f"  Clicking VIEW element...")
                        element.click()
                        time.sleep(3)
                        
                        # Get current URL to extract real case ID
                        current_url = working_context.url
                        print(f"  After click URL: {current_url}")
                        
                        case_id_match = re.search(r'id=(\d+)', current_url)
                        if case_id_match:
                            real_case_id = case_id_match.group(1)
                            case_data["real_case_id"] = real_case_id
                            case_data["view_url"] = current_url
                            print(f"  ✅ Real case ID: {real_case_id}")
                            
                            # Extract long description from detail page
                            detail_text = working_context.locator("body").inner_text()
                            
                            # Save raw detail for debugging
                            with open(f"complete_case_{real_case_id}_detail.txt", "w") as f:
                                f.write(detail_text)
                            
                            # Find substantial description text
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
                                    'report' not in line.lower()[:10]):
                                    if len(line) > len(long_description):
                                        long_description = line
                            
                            if long_description:
                                case_data["long_description"] = long_description
                                print(f"  ✅ Long description: {len(long_description)} chars")
                                print(f"  Preview: {long_description[:100]}...")
                            else:
                                print(f"  ❌ No substantial description found")
                        
                        # Go back to results
                        working_context.go_back()
                        time.sleep(2)
                        
                    except Exception as e:
                        print(f"  ❌ Error clicking VIEW: {e}")
                    
                    complete_cases.append(case_data)
                    
                    # Limit to reasonable number for testing
                    if len(complete_cases) >= 11:
                        break
                        
                except Exception as e:
                    print(f"  ❌ Error processing VIEW element {i}: {e}")
                    continue
            
            # Save complete extraction results
            output = {
                "timestamp": time.time(),
                "extraction_method": "complete_authenticated_playwright",
                "total_cases": len(complete_cases),
                "cases": complete_cases
            }
            
            with open("complete_mufon_extraction.json", "w") as f:
                json.dump(output, f, indent=2)
            
            success_count = sum(1 for case in complete_cases if case.get("long_description"))
            real_id_count = sum(1 for case in complete_cases if case.get("real_case_id"))
            
            print(f"\n🎉 Complete extraction results:")
            print(f"📊 Total cases processed: {len(complete_cases)}")
            print(f"🆔 Cases with real IDs: {real_id_count}")
            print(f"📝 Cases with long descriptions: {success_count}")
            print(f"📄 Results saved to complete_mufon_extraction.json")
            
        except Exception as e:
            print(f"❌ Error during complete extraction: {e}")
            page.screenshot(path="complete_extraction_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    complete_mufon_extraction()