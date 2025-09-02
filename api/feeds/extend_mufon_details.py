#!/usr/bin/env python3
"""
Extend MUFON Details - Use existing auth to click VIEW buttons and get long descriptions
NO re-auth, NO navigation recreation - just extend the working session
"""
import json
import re
import time
from pathlib import Path
from typing import Optional, Dict, Any

from playwright.sync_api import sync_playwright, Page, Frame

# CONFIG - using the EXACT URL from our working 11 cases 
RESULTS_URL = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&"  # The URL that has our 11 cases
STORAGE_STATE = "mufon_artifacts/storage_state.json"  # Existing working auth
JSON_PATH = "mufon_working_results.json"  # Existing 11 cases

def load_existing() -> Dict[str, Any]:
    """Load existing MUFON case data"""
    p = Path(JSON_PATH)
    if p.exists():
        with p.open("r", encoding="utf-8") as f:
            return json.load(f)
    return {"cases": []}

def save_existing(data: Dict[str, Any]):
    """Save enhanced MUFON case data"""
    with open("mufon_enhanced_final.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def find_results_iframe(page: Page) -> Optional[Frame]:
    """Find iframe containing the MUFON results table"""
    print("  🔍 Looking for results iframe...")
    
    # Try direct iframe access
    iframes = page.locator("iframe").all()
    print(f"  Found {len(iframes)} iframes")
    
    for i, iframe in enumerate(iframes):
        try:
            frame = iframe.content_frame()
            
            # Look for table with rows
            tables = frame.locator("table").all()
            rows = frame.locator("tr").all()
            view_elements = frame.locator("text=VIEW").all()
            
            print(f"    Iframe {i}: {len(tables)} tables, {len(rows)} rows, {len(view_elements)} VIEW elements")
            
            if len(view_elements) > 0 or (len(tables) > 0 and len(rows) > 3):
                print(f"    ✅ Using iframe {i} - has case data")
                return frame
                
        except Exception as e:
            print(f"    ❌ Error checking iframe {i}: {e}")
            continue
    
    return None

def extract_long_description(container) -> Optional[str]:
    """Extract long description from MUFON detail page"""
    print("        🔍 Extracting long description...")
    
    # MUFON-specific selectors
    selectors = [
        "#longDescription",
        "#description", 
        ".description",
        "td:has-text('Description') + td",
        "xpath=//*[contains(text(),'Description')]/following-sibling::*[1]",
        "xpath=//*[contains(text(),'Description')]/parent::*/following-sibling::*[1]"
    ]
    
    for i, sel in enumerate(selectors):
        try:
            print(f"          Trying selector {i+1}: {sel[:40]}...")
            el = container.locator(sel).first
            el.wait_for(timeout=2000)
            txt = el.inner_text().strip()
            if txt and len(txt) > 20:
                print(f"          ✅ Found description: {len(txt)} chars")
                return txt
        except Exception:
            continue
    
    # Fallback: find largest text block
    print("        🔍 Trying largest text block fallback...")
    try:
        all_text = container.locator("body").inner_text()
        lines = all_text.split('\n')
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
            print(f"        ✅ Found description via fallback: {len(best_desc)} chars")
            return best_desc
            
    except Exception:
        pass
    
    print("        ❌ No description found")
    return None

def click_view_in_row(frame: Frame, row_idx: int):
    """Click VIEW button in specific row"""
    print(f"      🔍 Clicking VIEW in row {row_idx + 1}...")
    
    # Get the row
    rows = frame.locator("table tr")
    if rows.count() <= row_idx:
        raise RuntimeError(f"Row {row_idx + 1} not found")
    
    row = rows.nth(row_idx)
    
    # Try different VIEW button selectors
    view_selectors = [
        row.locator("input[value='VIEW']"),
        row.locator("button:has-text('VIEW')"),
        row.locator("a:has-text('VIEW')"),
        row.locator("text=VIEW"),
        row.locator("td").last.locator("input"),
        row.locator("td").last.locator("button"),
        row.locator("td").last.locator("a")
    ]
    
    for i, selector in enumerate(view_selectors):
        try:
            if selector.count() > 0:
                print(f"        Trying selector {i+1}...")
                
                # Check for popup
                with frame.page.context.expect_page(timeout=3000) as popup_info:
                    selector.first.click(timeout=2000, force=True)
                
                # Popup opened
                new_page = popup_info.value
                print(f"      ✅ Popup opened: {new_page.url}")
                return ("popup", new_page)
                
        except Exception:
            # Try in-frame navigation
            try:
                before_url = frame.url
                selector.first.click(timeout=2000, force=True)
                
                # Wait for URL change or content
                try:
                    frame.wait_for_url(lambda url: url != before_url, timeout=4000)
                except Exception:
                    frame.wait_for_selector("text=Description", timeout=3000)
                
                print(f"      ✅ In-frame navigation: {frame.url}")
                return ("inframe", frame)
                
            except Exception:
                continue
    
    raise RuntimeError(f"Could not click VIEW in row {row_idx + 1}")

def go_back_or_close(mode: str, container):
    """Navigate back to results"""
    print("        🔄 Going back...")
    
    if mode == "popup":
        try:
            container.close()
            print("        ✅ Closed popup")
        except Exception:
            pass
    else:
        try:
            container.go_back()
            print("        ✅ Went back")
        except Exception:
            pass

def main():
    """Main extraction function"""
    print("🎯 Starting MUFON VIEW extraction (direct approach)...")
    
    # Load existing cases
    existing = load_existing()
    cases = existing.get('cases', [])
    print(f"📊 Loaded {len(cases)} existing cases")
    
    if not Path(STORAGE_STATE).exists():
        raise RuntimeError(f"Auth state not found: {STORAGE_STATE}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=STORAGE_STATE)
        page = context.new_page()
        
        try:
            print(f"🌐 Going directly to results URL...")
            page.goto(RESULTS_URL, wait_until="domcontentloaded", timeout=30000)
            time.sleep(3)
            
            # Take screenshot for debugging
            page.screenshot(path="direct_results_page.png", full_page=True)
            
            # Find results iframe
            frame = find_results_iframe(page)
            if not frame:
                print("❌ No results iframe found")
                return
            
            # Take iframe screenshot
            frame.screenshot(path="direct_results_iframe.png")
            
            # Get table rows
            rows = frame.locator("table tr").all()
            print(f"📊 Found {len(rows)} table rows")
            
            # Skip header row, process data rows
            enhanced_cases = cases.copy()
            descriptions_added = 0
            
            for i in range(1, min(len(rows), 12)):  # Skip header, max 11 cases
                try:
                    print(f"\n🔍 Processing row {i} (case {i})...")
                    
                    # Get row text
                    row = rows[i]
                    row_text = row.inner_text()
                    print(f"    Row: {row_text[:80]}...")
                    
                    # Click VIEW
                    mode, container = click_view_in_row(frame, i)
                    
                    # Wait for load
                    if mode == "popup":
                        container.wait_for_load_state("domcontentloaded", timeout=8000)
                    else:
                        time.sleep(2)
                    
                    # Extract description
                    src = container if mode == "popup" else frame
                    long_desc = extract_long_description(src)
                    
                    # Extract case ID from URL
                    current_url = src.url
                    case_id_match = re.search(r'id=(\d+)', current_url)
                    real_case_id = case_id_match.group(1) if case_id_match else None
                    
                    # Update corresponding case
                    case_index = i - 1  # Adjust for header row
                    if case_index < len(enhanced_cases):
                        if long_desc:
                            enhanced_cases[case_index]["Long_Description"] = long_desc
                            descriptions_added += 1
                            print(f"    ✅ Added description ({len(long_desc)} chars)")
                        
                        if real_case_id:
                            enhanced_cases[case_index]["Real_Case_Number"] = real_case_id
                            print(f"    ✅ Real case ID: {real_case_id}")
                    
                    # Go back
                    go_back_or_close(mode, container)
                    time.sleep(1)
                    
                except Exception as e:
                    print(f"    ❌ Error processing row {i}: {e}")
                    continue
            
            # Save enhanced data
            enhanced_data = existing.copy()
            enhanced_data["cases"] = enhanced_cases
            enhanced_data["extraction_timestamp"] = time.time()
            enhanced_data["descriptions_extracted"] = descriptions_added
            save_existing(enhanced_data)
            
            print(f"\n🎉 Extraction complete!")
            print(f"📝 Added descriptions to {descriptions_added}/{len(cases)} cases")
            print(f"💾 Saved to mufon_enhanced_final.json")
            
            # Keep auth fresh
            context.storage_state(path=STORAGE_STATE)
            
        except Exception as e:
            print(f"❌ Fatal error: {e}")
            page.screenshot(path="direct_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    main()