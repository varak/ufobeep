#!/usr/bin/env python3
# Simple MUFON script - manual interaction with automated extraction

import json, re, time
from pathlib import Path
from playwright.sync_api import sync_playwright
from datetime import datetime

JSON_PATH = "mufon_working_results.json"

def load_cases():
    p = Path(JSON_PATH)
    if not p.exists():
        return {"cases": []}
    with p.open("r", encoding="utf-8") as f:
        return json.load(f)

def save_cases(data):
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def case_id_from_row_text(s: str) -> str:
    m = re.search(r"\b(\d{5,7})\b", s)
    return m.group(1) if m else None

def extract_long_description(page) -> str:
    candidates = [
        "#longDescription",
        "#description", 
        ".long-description",
        ".description",
        "textarea",
        "[name*='description']"
    ]
    
    for sel in candidates:
        elements = page.locator(sel)
        count = elements.count()
        for i in range(count):
            el = elements.nth(i)
            if el.is_visible(timeout=1000):
                text = el.inner_text().strip()
                if len(text) > 25:
                    return text
    
    # Fallback to paragraphs
    paras = page.locator("p")
    best = ""
    count = paras.count()
    for i in range(min(count, 15)):
        text = paras.nth(i).inner_text().strip()
        if len(text) > len(best):
            best = text
    return best if len(best) > 25 else "(No description found)"

def main():
    data = load_cases()
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        context.tracing.start(screenshots=True, snapshots=True, sources=True)
        
        page = context.new_page()
        
        print("Opening MUFON website...")
        page.goto("https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&", timeout=30000)
        
        print("\n=== MANUAL STEPS ===")
        print("1. Fill in username/password if prompted")
        print("2. Click any terms/conditions radio button")
        print("3. Click 'SEARCH DATABASE'")
        print("4. Enter today's date:", datetime.now().strftime("%m/%d/%Y"))
        print("5. Click search/submit")
        print("6. Wait for results table to load")
        print("Press ENTER when results table is visible...")
        input()
        
        # Find table rows
        print("Looking for table rows...")
        tables = page.locator("table")
        table_count = tables.count()
        print(f"Found {table_count} tables")
        
        if table_count == 0:
            print("No tables found!")
            browser.close()
            return
        
        # Try different row selectors
        possible_selectors = [
            "table tbody tr",
            "table tr:not(:first-child)",
            "table tr",
            "[role='row']"
        ]
        
        rows = None
        for selector in possible_selectors:
            test_rows = page.locator(selector)
            count = test_rows.count()
            if count > 0:
                print(f"Using selector '{selector}' - found {count} rows")
                rows = test_rows
                break
        
        if not rows or rows.count() == 0:
            print("No rows found in any table!")
            browser.close()
            return
        
        row_count = rows.count()
        visited = set()
        
        print(f"Processing {row_count} rows...")
        
        for i in range(row_count):
            row = rows.nth(i)
            text = row.inner_text(timeout=3000).strip()
            cid = case_id_from_row_text(text) or f"row{i+1}"
            
            if cid in visited:
                continue
            visited.add(cid)
            
            print(f"\nProcessing case {cid}...")
            print(f"Row text preview: {text[:100]}...")
            
            # Find clickable elements in row
            clickables = row.locator("a, button, input[type='button'], td:last-child *")
            click_count = clickables.count()
            
            clicked = False
            for j in range(click_count):
                element = clickables.nth(j)
                if element.is_visible(timeout=1000):
                    print(f"Clicking element {j+1} of {click_count}...")
                    element.click(timeout=5000)
                    
                    # Wait and check if page changed
                    page.wait_for_timeout(2000)
                    if "detail" in page.url.lower() or page.locator("#description, #longDescription, textarea").count() > 0:
                        clicked = True
                        break
                    else:
                        print("No detail page detected, trying next element...")
            
            if not clicked:
                print(f"[WARN] {cid}: Could not find working VIEW button")
                continue
            
            # Extract description
            print("Extracting description...")
            long_desc = extract_long_description(page)
            print(f"Found description: {len(long_desc)} characters")
            
            # Save to JSON
            found = False
            for c in data.get("cases", []):
                existing_id = str(c.get("case_id", "")) or str(c.get("Case_Number", ""))
                if existing_id == str(cid):
                    c["long_description"] = long_desc
                    found = True
                    break
            
            if not found:
                data.setdefault("cases", []).append({
                    "case_id": cid,
                    "long_description": long_desc
                })
            
            save_cases(data)
            print(f"[OK] {cid}: Saved")
            
            # Go back to results
            print("Going back to results...")
            page.go_back()
            page.wait_for_timeout(3000)
            
            # Refresh row references
            rows = page.locator("table tbody tr") if page.locator("table tbody tr").count() > 0 else page.locator("table tr")
        
        print("\n=== EXTRACTION COMPLETE ===")
        context.tracing.stop(path="trace.zip")
        
        print("Browser will close in 10 seconds...")
        time.sleep(10)
        browser.close()
        
        # Show results
        print(f"\nResults saved to {JSON_PATH}")
        final_data = load_cases()
        case_count = len(final_data.get("cases", []))
        print(f"Total cases: {case_count}")
        
        for case in final_data.get("cases", []):
            cid = case.get("case_id", "unknown")
            desc_len = len(case.get("long_description", ""))
            print(f"  - Case {cid}: {desc_len} chars")

if __name__ == "__main__":
    main()