#!/usr/bin/env python3
"""
MUFON VIEW Button Extractor - GET THE CAT INSIDE! 🐱

Direct approach: Use existing auth session, go straight to results, click VIEW buttons.
No more 8+ hour authentication loops!
"""
from playwright.sync_api import sync_playwright
import json
import time
import re
from pathlib import Path

# Use exact URL from working results
RESULTS_URL = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&"
STORAGE_STATE = "mufon_artifacts/storage_state.json"
WORKING_RESULTS = "mufon_working_results.json"

def load_working_results():
    """Load existing MUFON case data with empty long descriptions"""
    with open(WORKING_RESULTS, 'r') as f:
        return json.load(f)

def extract_long_description(frame):
    """Extract long description from MUFON case detail page"""
    try:
        # Try multiple description selectors
        selectors = [
            "text=Description",
            "#description",
            ".description", 
            "td:has-text('Description')",
            "[id*='description']",
            "[class*='description']"
        ]
        
        for selector in selectors:
            try:
                desc_elem = frame.locator(selector).first
                if desc_elem.count() > 0:
                    desc_text = desc_elem.inner_text().strip()
                    if len(desc_text) > 50:  # Substantial description
                        return desc_text
            except:
                continue
        
        # Fallback: find longest text block
        body_text = frame.locator("body").inner_text()
        lines = body_text.split('\n')
        best_desc = ""
        
        for line in lines:
            line = line.strip()
            if (len(line) > 100 and 
                not line.startswith('Case #') and
                'mufon' not in line.lower() and
                'copyright' not in line.lower()):
                if len(line) > len(best_desc):
                    best_desc = line
        
        return best_desc if best_desc else None
        
    except Exception as e:
        print(f"      ❌ Error extracting description: {e}")
        return None

def main():
    """Main extraction - LET THE CAT IN!"""
    print("🐱 Starting MUFON VIEW button extraction - Direct approach!")
    print("🚀 Authenticating fresh session...")
    
    # Load existing results
    working_data = load_working_results()
    cases = working_data.get('cases', [])
    print(f"📊 Loaded {len(cases)} existing cases")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()
        
        # Quick authentication to get fresh session
        print("🔐 Quick login to get fresh session...")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
        page.fill("input[name='loginName']", "varak")
        page.fill("input[name='loginPassword']", "ufobeep123pass")
        page.click("input[type='submit']")
        page.wait_for_load_state("domcontentloaded")
        print("✅ Fresh authentication complete!")
        
        try:
            print(f"🎯 Going directly to results URL...")
            page.goto(RESULTS_URL, wait_until="domcontentloaded", timeout=15000)
            time.sleep(3)
            
            # Take screenshot for debugging
            page.screenshot(path="direct_results.png", full_page=True)
            print("📸 Screenshot saved: direct_results.png")
            
            # Look for iframe with case data
            print("🔍 Looking for results iframe...")
            iframes = page.locator("iframe").all()
            print(f"Found {len(iframes)} iframes")
            
            results_frame = None
            if iframes:
                frame = iframes[0].content_frame()
                
                # Check for case table/VIEW elements
                tables = frame.locator("table").count()
                rows = frame.locator("tr").count()
                view_elements = frame.locator("text=VIEW").count()
                
                print(f"  Iframe content: {tables} tables, {rows} rows, {view_elements} VIEW elements")
                
                if view_elements > 0 or (tables > 0 and rows > 3):
                    results_frame = frame
                    print("✅ Found iframe with case data!")
                else:
                    print("❌ Iframe doesn't contain case data")
            else:
                print("❌ No iframes found")
                # Check main page
                tables = page.locator("table").count()
                rows = page.locator("tr").count()
                view_elements = page.locator("text=VIEW").count()
                
                print(f"  Main page: {tables} tables, {rows} rows, {view_elements} VIEW elements")
                
                if view_elements > 0 or (tables > 0 and rows > 3):
                    results_frame = page
                    print("✅ Using main page for case data!")
            
            if not results_frame:
                print("❌ No case data found on page")
                page.screenshot(path="no_results_debug.png", full_page=True)
                return
            
            # Take iframe screenshot
            results_frame.screenshot(path="iframe_results.png")
            print("📸 Iframe screenshot: iframe_results.png")
            
            # Find all case rows with VIEW buttons
            print("🔍 Looking for case rows with VIEW buttons...")
            table_rows = results_frame.locator("table tr").all()
            print(f"Found {len(table_rows)} table rows")
            
            enhanced_cases = []
            descriptions_extracted = 0
            
            # Process each row (skip header row)
            for i in range(1, min(len(table_rows), 12)):  # Max 11 cases + header
                try:
                    print(f"\n🔍 Processing row {i}...")
                    row = table_rows[i]
                    row_text = row.inner_text()
                    print(f"  Row preview: {row_text[:80]}...")
                    
                    # Initialize case data
                    case_data = {
                        "row_index": i,
                        "row_text": row_text
                    }
                    
                    # Copy existing data if available
                    if i-1 < len(cases):
                        case_data.update(cases[i-1])
                    
                    # Look for VIEW button in this row
                    view_selectors = [
                        row.locator("input[value='VIEW']"),
                        row.locator("button:has-text('VIEW')"),
                        row.locator("a:has-text('VIEW')"),
                        row.locator("text=VIEW"),
                        row.locator("td").last.locator("input"),
                        row.locator("td").last.locator("button"),
                        row.locator("td").last.locator("a")
                    ]
                    
                    view_clicked = False
                    
                    for j, view_selector in enumerate(view_selectors):
                        try:
                            if view_selector.count() > 0:
                                print(f"    🎯 Trying VIEW selector {j+1}...")
                                
                                # Click VIEW button
                                view_selector.first.click(timeout=5000)
                                time.sleep(2)
                                
                                # Check for navigation or popup
                                current_url = results_frame.url
                                print(f"    📍 After click URL: {current_url}")
                                
                                # Extract case ID from URL
                                case_id_match = re.search(r'id=(\d+)', current_url)
                                if case_id_match:
                                    real_case_id = case_id_match.group(1)
                                    case_data["Real_Case_Number"] = real_case_id
                                    print(f"    ✅ Real case ID: {real_case_id}")
                                    
                                    # Extract long description
                                    long_desc = extract_long_description(results_frame)
                                    if long_desc:
                                        case_data["Long_Description"] = long_desc
                                        descriptions_extracted += 1
                                        print(f"    ✅ Description extracted: {len(long_desc)} chars")
                                        print(f"    📖 Preview: {long_desc[:60]}...")
                                    
                                    # Save debug file
                                    with open(f"case_{real_case_id}_debug.txt", "w") as f:
                                        f.write(results_frame.locator("body").inner_text())
                                    
                                    # Go back to results
                                    results_frame.go_back()
                                    time.sleep(2)
                                    view_clicked = True
                                    break
                        except Exception as e:
                            print(f"    ❌ Error with selector {j+1}: {e}")
                            continue
                    
                    if not view_clicked:
                        print(f"    ⚠️ No VIEW button clicked in row {i}")
                    
                    enhanced_cases.append(case_data)
                    
                except Exception as e:
                    print(f"  ❌ Error processing row {i}: {e}")
                    continue
            
            # Save enhanced results
            enhanced_data = {
                "timestamp": time.time(),
                "original_url": RESULTS_URL,
                "extraction_method": "direct_playwright_view_extraction",
                "total_cases": len(enhanced_cases),
                "descriptions_extracted": descriptions_extracted,
                "cases": enhanced_cases
            }
            
            with open("mufon_enhanced_final.json", "w") as f:
                json.dump(enhanced_data, f, indent=2, ensure_ascii=False)
            
            print(f"\n🎉 EXTRACTION COMPLETE!")
            print(f"📊 Processed {len(enhanced_cases)} cases")  
            print(f"📝 Extracted {descriptions_extracted} long descriptions")
            print(f"💾 Saved to: mufon_enhanced_final.json")
            print(f"🐱 THE CAT CAN COME INSIDE NOW!")
            
        except Exception as e:
            print(f"❌ Fatal error: {e}")
            page.screenshot(path="fatal_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    main()