#!/usr/bin/env python3
# MUFON script with login flow

import json, re, time
from pathlib import Path
from playwright.sync_api import sync_playwright

# === CONFIG ===
BASE_URL = "https://mufon.app.neoncrm.com"
LOGIN_URL = f"{BASE_URL}/np/publicaccess/neonPage.do?pageId=19&"
JSON_PATH = "mufon_working_results.json"
# ==============

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
    # Try common selectors for long description
    candidates = [
        "#longDescription",
        "#description", 
        ".long-description",
        ".description",
        "textarea[name*='description']",
        "textarea[name*='Description']",
        "[name='longDescription']",
        "[name='description']"
    ]
    
    for sel in candidates:
        try:
            el = page.locator(sel).first
            if el.is_visible(timeout=2000):
                text = el.inner_text().strip()
                if len(text) > 25:
                    return text
        except Exception:
            pass
    
    # Fallback to largest paragraph
    try:
        paras = page.locator("p")
        best = ""
        for i in range(min(paras.count(), 20)):
            text = paras.nth(i).inner_text().strip()
            if len(text) > len(best):
                best = text
        return best if len(best) > 25 else "(No description found)"
    except Exception:
        return "(No description found)"

def login_and_search(page):
    print("Navigating to MUFON login page...")
    page.goto(LOGIN_URL, wait_until="domcontentloaded", timeout=30000)
    
    # Handle terms and conditions radio button
    try:
        # Look for terms/conditions radio button or checkbox
        terms_radio = page.locator("input[type='radio']:near(text*='terms'), input[type='checkbox']:near(text*='terms'), input[type='radio']:near(text*='condition'), input[type='checkbox']:near(text*='condition')").first
        if terms_radio.is_visible(timeout=5000):
            print("Found terms and conditions radio button, clicking...")
            terms_radio.click()
            time.sleep(1)
    except Exception as e:
        print(f"No terms radio button found: {e}")
    
    # Look for "SEARCH DATABASE" button
    try:
        search_btn = page.locator("text=/search database/i, input[value*='search' i], button:has-text('search')").first
        if search_btn.is_visible(timeout=5000):
            print("Found search button, clicking...")
            search_btn.click()
            page.wait_for_load_state("domcontentloaded", timeout=10000)
            
            # Handle date input if required
            try:
                from datetime import datetime
                today = datetime.now().strftime("%m/%d/%Y")
                
                date_inputs = page.locator("input[type='date'], input[name*='date'], input[placeholder*='date']")
                date_count = date_inputs.count()
                if date_count > 0:
                    print(f"Found {date_count} date input(s), entering today's date: {today}")
                    for i in range(date_count):
                        date_input = date_inputs.nth(i)
                        if date_input.is_visible(timeout=2000):
                            date_input.fill(today)
                            time.sleep(0.5)
                
                # Look for submit/search button after date entry
                submit_btn = page.locator("input[type='submit'], button[type='submit'], button:has-text('search'), input[value*='search']").first
                if submit_btn.is_visible(timeout=3000):
                    print("Clicking submit/search button...")
                    submit_btn.click()
                    page.wait_for_load_state("domcontentloaded", timeout=15000)
                    
            except Exception as e:
                print(f"Date handling error: {e}")
            
            return True
    except Exception:
        pass
    
    print("Manual interaction required:")
    print("1. Click terms and conditions radio button if present")
    print("2. Click SEARCH DATABASE button")
    print("3. Search for cases")
    print("Press Enter when you see the results table...")
    input()
    return True

def click_view_in_row(page, row):
    # Try to find VIEW button/link in the row
    try:
        view_btn = row.locator("text=/view/i, a:has-text('view'), button:has-text('view')").first
        if view_btn.is_visible(timeout=2000):
            view_btn.click(timeout=5000)
            page.wait_for_load_state("domcontentloaded", timeout=10000)
            return True
    except Exception:
        pass
    
    # Try last cell button/link
    try:
        last_cell_btn = row.locator("td:last-child a, td:last-child button").first
        if last_cell_btn.is_visible(timeout=2000):
            last_cell_btn.click(timeout=5000) 
            page.wait_for_load_state("domcontentloaded", timeout=10000)
            return True
    except Exception:
        pass
        
    return False

def main():
    data = load_cases()
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)  # Keep visible for manual login
        context = browser.new_context()
        context.tracing.start(screenshots=True, snapshots=True, sources=True)
        
        page = context.new_page()
        
        # Login and get to results
        if not login_and_search(page):
            print("Login failed!")
            return
            
        # Find table rows
        try:
            rows = page.locator("table tbody tr, table tr:not(:first-child)")
            row_count = rows.count()
            print(f"Found {row_count} rows in results table")
            
            if row_count == 0:
                print("No rows found! Make sure you're on the results page.")
                input("Press Enter to continue...")
                return
                
        except Exception as e:
            print(f"Error finding table: {e}")
            return
        
        visited = set()
        
        for i in range(row_count):
            row = rows.nth(i)
            try:
                text = row.inner_text(timeout=3000).strip()
            except Exception:
                text = f"row{i+1}"
                
            cid = case_id_from_row_text(text) or f"row{i+1}"
            if cid in visited:
                print(f"Skip {cid} (already visited)")
                continue
            visited.add(cid)
            
            print(f"Processing case {cid}...")
            
            # Click VIEW button
            if not click_view_in_row(page, row):
                print(f"[WARN] {cid}: Could not click VIEW button")
                continue
                
            # Extract description
            long_desc = extract_long_description(page)
            
            # Update JSON
            found = False
            for c in data.get("cases", []):
                if str(c.get("case_id")) == str(cid) or str(c.get("Case_Number")) == str(cid):
                    c["long_description"] = long_desc
                    found = True
                    break
            if not found:
                data.setdefault("cases", []).append({
                    "case_id": cid,
                    "long_description": long_desc
                })
            
            save_cases(data)
            print(f"[OK] {cid}: {len(long_desc)} chars saved")
            
            # Go back to results
            try:
                back_btn = page.locator("text=/back/i, text=/return/i, text=/results/i").first
                if back_btn.is_visible(timeout=3000):
                    back_btn.click()
                    page.wait_for_load_state("domcontentloaded", timeout=5000)
                else:
                    page.go_back()
                    page.wait_for_load_state("domcontentloaded", timeout=5000)
            except Exception:
                print("Could not go back - manual navigation required")
                input("Please navigate back to results and press Enter...")
                
            # Refresh row locators
            rows = page.locator("table tbody tr, table tr:not(:first-child)")
            
        print("Extraction complete!")
        context.tracing.stop(path="trace.zip")
        
        print("Keeping browser open for 30 seconds...")
        time.sleep(30)
        browser.close()

if __name__ == "__main__":
    main()