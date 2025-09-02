#!/usr/bin/env python3
"""
Extend MUFON Views - Robust extraction of long descriptions from VIEW buttons
Adapted from the provided solution to work with our MUFON setup
"""
import json
import re
import time
from pathlib import Path
from typing import Optional, Dict, Any, List

from playwright.sync_api import sync_playwright, Page, Frame, TimeoutError as PWTimeout

# ==== CONFIG for our MUFON setup ====
RESULTS_URL = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&"  # From our working results
STORAGE_STATE = "mufon_artifacts/storage_state.json"  # Our working saved session
JSON_PATH = "mufon_working_results.json"  # Our existing 11 cases
IFRAME_TEXT_HINTS = [
    "VIEW", "Case", "ID", "Shape", "Date", "Location", "Report", "Event"
]  # Content hints to find the right iframe
VIEW_LABELS = ["VIEW", "View", "View Details", "Details"]  # Possible button texts

def load_existing() -> Dict[str, Any]:
    """Load our existing MUFON case data"""
    p = Path(JSON_PATH)
    if p.exists():
        with p.open("r", encoding="utf-8") as f:
            return json.load(f)
    return {"cases": []}

def save_existing(data: Dict[str, Any]):
    """Save enhanced MUFON case data"""
    with open("mufon_enhanced_with_long_descriptions.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def find_results_iframe(page: Page, timeout_ms: int = 15000) -> Frame:
    """
    Robustly find the iframe that contains the MUFON results table.
    Strategy:
      1) Prefer iframe(s) whose URL suggests search/results/cms
      2) Else probe each iframe for known text hints (like 'VIEW')
    """
    print("  🔍 Looking for results iframe...")
    
    # Quick pass: any iframe with likely URL patterns
    likely = [f for f in page.frames if re.search(r"search|result|report|case|cms", (f.url or ""), re.I)]
    print(f"  Found {len(likely)} iframes with likely URLs")
    
    for fr in likely:
        try:
            fr.get_by_text("VIEW", exact=False).first.wait_for(timeout=1500)
            print(f"  ✅ Found iframe with VIEW elements: {fr.url}")
            return fr
        except Exception:
            pass

    # General pass: probe every child frame for hints
    print("  Probing all frames for content hints...")
    deadline = time.time() + (timeout_ms / 1000)
    tried = set()
    
    while time.time() < deadline:
        for fr in page.frames:
            if fr in tried:
                continue
            tried.add(fr)
            try:
                hints_found = 0
                for hint in IFRAME_TEXT_HINTS:
                    try:
                        el = fr.get_by_text(hint, exact=False).first
                        el.wait_for(timeout=1000)
                        hints_found += 1
                    except Exception:
                        pass
                
                if hints_found >= 2:  # Found multiple hints - likely the right frame
                    print(f"  ✅ Found iframe with {hints_found} content hints: {fr.url}")
                    return fr
                    
            except Exception:
                continue
        time.sleep(0.2)

    # Last chance: if there is exactly one child frame, return it
    child_frames = [f for f in page.frames if f != page.main_frame]
    if len(child_frames) == 1:
        print(f"  ⚠️ Using only child frame as fallback: {child_frames[0].url}")
        return child_frames[0]

    raise RuntimeError("Could not find the results iframe reliably.")

def get_rows(frame: Frame):
    """
    Locate the table rows inside the frame for our MUFON case table
    """
    print("  🔍 Looking for table rows...")
    
    table_candidates = [
        "table tbody tr",  # Standard table with tbody
        "table tr:not(:first-child)",  # Table rows excluding header
        "table tr",  # All table rows (we'll handle header later)
        "[role='row']",  # ARIA table rows
        "div.table-responsive table tbody tr"  # Bootstrap table
    ]
    
    for sel in table_candidates:
        try:
            rows = frame.locator(sel)
            count = rows.count()
            if count > 0:
                print(f"  ✅ Found {count} table rows with selector: {sel}")
                return rows
        except PWTimeout:
            pass
    
    raise RuntimeError("No table rows found in iframe.")

def click_view_in_row(frame: Frame, row_idx: int):
    """
    Click the VIEW control in a given row.
    Handle both in-frame navigation and popup windows.
    """
    print(f"    🔍 Looking for VIEW button in row {row_idx + 1}...")
    
    # Get the specific row
    try:
        rows = frame.locator("table tbody tr")
        if rows.count() == 0:
            rows = frame.locator("table tr")
        row = rows.nth(row_idx)
    except Exception:
        try:
            row = frame.locator("[role='row']").nth(row_idx)
        except Exception:
            raise RuntimeError(f"Could not locate row {row_idx + 1}")

    # Candidate locators for the VIEW button
    candidates = []
    
    # Try different VIEW button patterns
    for label in VIEW_LABELS:
        candidates.extend([
            row.get_by_role("button", name=re.compile(label, re.I)),
            row.get_by_role("link", name=re.compile(label, re.I)),
            row.locator(f"text={label}"),
            row.locator(f"input[value='{label}']"),
            row.locator(f"button:has-text('{label}')"),
            row.locator(f"a:has-text('{label}')"),
        ])

    # Also try: last cell button/link
    candidates.append(row.locator("td").last.get_by_role("button"))
    candidates.append(row.locator("td").last.locator("a"))
    candidates.append(row.locator("td").last.locator("input[type='button']"))

    # Try clicking with popup capture fallback
    for i, cand in enumerate(candidates):
        try:
            print(f"      Trying candidate {i + 1}: {cand}")
            
            # Check if element exists first
            if cand.count() == 0:
                continue
                
            # Some sites open detail in a popup window
            with frame.page.context.expect_page(timeout=3000) as popup_info:
                try:
                    cand.first.click(timeout=1500, force=True)
                    print(f"      ✅ Clicked candidate {i + 1}")
                except Exception as e:
                    print(f"      ❌ Click failed: {e}")
                    continue
            
            # If we get here, a popup/new page opened
            new_page = popup_info.value
            print(f"    ✅ Popup window opened: {new_page.url}")
            return ("popup", new_page)

        except Exception:
            # If no popup, it might navigate *within the iframe*
            try:
                print(f"      Trying in-frame navigation...")
                before_url = frame.url
                cand.first.click(timeout=1500, force=True)
                
                # Wait for either URL change or a recognizable selector on detail page
                changed = False
                try:
                    frame.wait_for_url(lambda url: url != before_url, timeout=4000)
                    changed = True
                    print(f"      ✅ URL changed to: {frame.url}")
                except Exception:
                    pass
                    
                if not changed:
                    # Sometimes URL doesn't change; wait for detail content to appear
                    try:
                        frame.wait_for_selector("text=Description", timeout=3000)
                        print(f"      ✅ Description content appeared")
                    except Exception:
                        pass
                
                print(f"    ✅ In-frame navigation successful")
                return ("inframe", frame)
                
            except Exception as e:
                print(f"      ❌ In-frame click failed: {e}")
                continue

    raise RuntimeError(f"Could not click VIEW in row {row_idx+1} with any strategy.")

def extract_long_description(container) -> Optional[str]:
    """
    Extract the long description from a MUFON detail page
    """
    print("      🔍 Extracting long description...")
    
    candidates = [
        # MUFON-specific patterns
        "xpath=//*[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'long description')]/following::*[1]",
        "xpath=//*[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'description of event')]/following::*[1]",
        "xpath=//*[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'witness description')]/following::*[1]",
        
        # Common IDs/classes
        "#longDescription",
        "#description",
        "#witnessDescription",
        ".description",
        ".long-description",
        ".witness-description",
        
        # Generic content blocks
        "div:has-text('Description')",
        "section:has-text('Description')",
        "article:has-text('Description')",
        "td:has-text('Description')",
        
        # Table cell patterns (MUFON often uses tables)
        "table td:nth-child(2)",  # Second column often has descriptions
    ]

    for i, sel in enumerate(candidates):
        try:
            print(f"        Trying selector {i + 1}: {sel[:50]}...")
            el = container.locator(sel).first
            el.wait_for(timeout=1500)
            txt = el.inner_text().strip()
            if txt and len(txt) > 20:
                print(f"        ✅ Found description: {len(txt)} chars")
                return txt
        except Exception as e:
            print(f"        ❌ Selector failed: {e}")
            continue

    # Last-ditch: grab the largest text block on the page
    print("        🔍 Trying largest text block fallback...")
    try:
        # Try paragraphs first
        paras = container.locator("p")
        n = paras.count()
        best_txt = ""
        
        for i in range(min(n, 20)):  # Check up to 20 paragraphs
            try:
                t = paras.nth(i).inner_text().strip()
                if len(t) > len(best_txt) and len(t) > 50:  # Substantial text
                    best_txt = t
            except Exception:
                continue
                
        if best_txt:
            print(f"        ✅ Found description via paragraph fallback: {len(best_txt)} chars")
            return best_txt
            
        # Try table cells as fallback
        cells = container.locator("td")
        n = cells.count()
        
        for i in range(min(n, 20)):  # Check up to 20 cells
            try:
                t = cells.nth(i).inner_text().strip()
                if len(t) > len(best_txt) and len(t) > 50:
                    best_txt = t
            except Exception:
                continue
                
        if best_txt:
            print(f"        ✅ Found description via table cell fallback: {len(best_txt)} chars")
            return best_txt
            
    except Exception:
        pass

    print("        ❌ No substantial description found")
    return None

def go_back_or_close(mode: str, container):
    """Navigate back to the results page"""
    print("      🔄 Going back to results...")
    
    if mode == "popup":
        try:
            container.close()
            print("      ✅ Closed popup window")
        except Exception as e:
            print(f"      ❌ Error closing popup: {e}")
    else:
        # in-frame: try to go back
        fr: Frame = container
        try:
            fr.page.go_back(timeout=1500)
            print("      ✅ Navigated back via page history")
        except Exception:
            try:
                fr.evaluate("history.back()")
                print("      ✅ Navigated back via JavaScript")
            except Exception as e:
                print(f"      ❌ Error going back: {e}")

def extract_case_id_from_row(row_text: str) -> Optional[str]:
    """Try to extract a MUFON case ID from the row text"""
    # Look for 6-digit MUFON case numbers (like 143948)
    m = re.search(r"\b(1\d{5})\b", row_text)  # MUFON case IDs typically start with 1
    if m:
        return m.group(1)
    
    # Fallback: any 5-7 digit number
    m = re.search(r"\b(\d{5,7})\b", row_text)
    return m.group(1) if m else None

def main():
    """Main extraction function"""
    print("🎯 Starting MUFON VIEW extraction...")
    
    # Load existing case data
    existing = load_existing()
    print(f"📊 Loaded {len(existing.get('cases', []))} existing cases")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        
        # Load our saved authentication state
        if not Path(STORAGE_STATE).exists():
            raise RuntimeError(f"Authentication state file not found: {STORAGE_STATE}")
            
        context = browser.new_context(storage_state=STORAGE_STATE)
        page = context.new_page()

        try:
            print(f"🌐 Following the same navigation flow as working auth client...")
            
            # Follow the exact same flow as mufon_authenticated_client.py
            page.goto("https://mufon.com/research/", wait_until="domcontentloaded")
            
            # Find login link
            login_links = page.locator("text=Member Login").all()
            if login_links:
                login_links[0].click()
                page.wait_for_load_state("networkidle")
                time.sleep(2)
            
            # Look for authenticated interface and Search Database
            search_links = page.locator("text=SEARCH DATABASE").all()
            if search_links:
                search_links[0].click()
                page.wait_for_load_state("networkidle")
                time.sleep(2)
                
                # Look for choice dropdown
                choice_select = page.locator("select[name='choice']")
                if choice_select.count() > 0:
                    # Select "Last 20 Reports" option
                    choice_select.select_option("https://mufoncms.com/last_20_public.html?orgId=mufon")
                    
                    # Submit form
                    page.locator("input[type='submit']").first.click()
                    page.wait_for_load_state("networkidle")
                    time.sleep(3)
                    
                    print("✅ Navigated to search results")
                else:
                    print("❌ Could not find choice dropdown")
                    page.screenshot(path="no_choice_dropdown.png", full_page=True)
                    return
            else:
                print("❌ Could not find SEARCH DATABASE link")
                page.screenshot(path="no_search_database.png", full_page=True)
                return

            # Find the iframe containing the results table
            frame = find_results_iframe(page)

            # Get table rows
            rows = get_rows(frame)
            total = rows.count()
            
            print(f"📊 Found {total} rows to process")

            enhanced_cases = existing.get('cases', []).copy()
            descriptions_added = 0

            # Process each row
            for i in range(min(total, 15)):  # Safety limit
                try:
                    print(f"\n🔍 Processing row {i+1}/{total}")
                    
                    # Get row text for debugging
                    row = rows.nth(i)
                    row_text = row.inner_text().strip()
                    print(f"  Row text: {row_text[:100]}...")
                    
                    # Extract potential case ID
                    potential_case_id = extract_case_id_from_row(row_text)
                    if potential_case_id:
                        print(f"  Potential case ID: {potential_case_id}")

                    # Click VIEW button
                    mode, container = click_view_in_row(frame, i)

                    # Wait for detail page to load
                    try:
                        if mode == "popup":
                            container.wait_for_load_state("domcontentloaded", timeout=10000)
                        else:
                            time.sleep(2)  # Give iframe time to load content
                    except Exception:
                        pass

                    # Extract long description
                    src = container if mode == "popup" else frame
                    long_desc = extract_long_description(src)
                    
                    if not long_desc:
                        long_desc = f"[No detailed description available for this case]"

                    # Update the corresponding case in our data
                    case_index = i if i < len(enhanced_cases) else None
                    if case_index is not None:
                        enhanced_cases[case_index]["Long_Description"] = long_desc
                        if potential_case_id:
                            enhanced_cases[case_index]["Real_Case_Number"] = potential_case_id
                        
                        descriptions_added += 1
                        print(f"  ✅ Added description to case {case_index + 1} ({len(long_desc)} chars)")
                    
                    # Save incrementally
                    enhanced_data = existing.copy()
                    enhanced_data["cases"] = enhanced_cases
                    enhanced_data["extraction_timestamp"] = time.time()
                    save_existing(enhanced_data)

                    # Return to results list
                    go_back_or_close(mode, container)
                    time.sleep(1)  # Brief pause between cases

                except Exception as e:
                    print(f"  ❌ Error processing row {i+1}: {e}")
                    continue

            # Save final results
            enhanced_data = existing.copy()
            enhanced_data["cases"] = enhanced_cases
            enhanced_data["extraction_timestamp"] = time.time()
            enhanced_data["descriptions_extracted"] = descriptions_added
            save_existing(enhanced_data)

            print(f"\n🎉 Extraction complete!")
            print(f"📊 Processed {total} rows")
            print(f"📝 Added descriptions to {descriptions_added} cases")
            print(f"💾 Saved to mufon_enhanced_with_long_descriptions.json")

            # Keep session fresh for next use
            context.storage_state(path=STORAGE_STATE)

        finally:
            browser.close()

if __name__ == "__main__":
    main()