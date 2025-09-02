#!/usr/bin/env python3
# MUFON script with proper login form handling

import json, re, time
from pathlib import Path
from playwright.sync_api import sync_playwright
from datetime import datetime

JSON_PATH = "mufon_working_results.json"
LOGIN_URL = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&"

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
        "textarea[name*='description']",
        "[name='longDescription']",
        "[name='description']"
    ]
    
    for sel in candidates:
        el = page.locator(sel).first
        if el.is_visible(timeout=2000):
            text = el.inner_text().strip()
            if len(text) > 25:
                return text
    
    # Fallback to largest paragraph
    paras = page.locator("p")
    best = ""
    count = paras.count()
    for i in range(min(count, 20)):
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
        
        print("Navigating to MUFON...")
        page.goto(LOGIN_URL, wait_until="domcontentloaded", timeout=30000)
        
        # Fill out login form
        print("Looking for login form fields...")
        
        # Try common username/email field names
        username_field = page.locator("input[name*='user'], input[name*='email'], input[type='email'], input[id*='user'], input[id*='email']").first
        if username_field.is_visible(timeout=5000):
            print("Found username field, please enter your login info...")
            # Let user enter credentials manually
            time.sleep(10)  # Give time to enter info
        
        # Look for password field
        password_field = page.locator("input[type='password']").first
        if password_field.is_visible(timeout=3000):
            print("Password field found...")
            time.sleep(5)  # Give time to enter password
        
        # Look for login/submit button
        login_btn = page.locator("input[type='submit'], button[type='submit'], button:has-text('login'), input[value*='login']").first
        if login_btn.is_visible(timeout=5000):
            print("Clicking login button...")
            login_btn.click()
            page.wait_for_load_state("domcontentloaded", timeout=15000)
        
        # Now handle the search flow
        print("Looking for search options...")
        
        # Click terms radio if present
        terms_radio = page.locator("input[type='radio']").first
        if terms_radio.is_visible(timeout=5000):
            print("Clicking terms radio...")
            terms_radio.click()
            time.sleep(1)
        
        # Click SEARCH DATABASE
        search_btn = page.locator("text=/search database/i, a:has-text('search database')").first
        if search_btn.is_visible(timeout=5000):
            print("Clicking SEARCH DATABASE...")
            search_btn.click()
            page.wait_for_load_state("domcontentloaded", timeout=10000)
        
        # Enter today's date
        today = datetime.now().strftime("%m/%d/%Y")
        print(f"Entering today's date: {today}")
        
        date_inputs = page.locator("input[type='date'], input[name*='date'], input[placeholder*='date']")
        count = date_inputs.count()
        for i in range(count):
            date_input = date_inputs.nth(i)
            if date_input.is_visible(timeout=2000):
                date_input.fill(today)
                time.sleep(0.5)
        
        # Click search
        submit_btn = page.locator("input[type='submit'], button[type='submit'], input[value*='search']").first
        if submit_btn.is_visible(timeout=5000):
            print("Clicking search...")
            submit_btn.click()
            page.wait_for_load_state("domcontentloaded", timeout=15000)
        
        # Find results table
        print("Looking for results table...")
        page.wait_for_selector("table", timeout=15000)
        
        rows = page.locator("table tbody tr, table tr:not(:first-child)")
        row_count = rows.count()
        print(f"Found {row_count} rows in results")
        
        if row_count == 0:
            print("No results found!")
            context.tracing.stop(path="trace.zip")
            browser.close()
            return
        
        visited = set()
        
        # Process each row
        for i in range(row_count):
            row = rows.nth(i)
            text = row.inner_text(timeout=3000).strip()
            cid = case_id_from_row_text(text) or f"row{i+1}"
            
            if cid in visited:
                continue
            visited.add(cid)
            
            print(f"Processing case {cid}...")
            
            # Click VIEW button
            view_elements = row.locator("a, button, input[type='button']")
            view_count = view_elements.count()
            
            clicked = False
            for j in range(view_count):
                element = view_elements.nth(j)
                if element.is_visible(timeout=2000):
                    element.click(timeout=5000)
                    page.wait_for_load_state("domcontentloaded", timeout=10000)
                    clicked = True
                    break
            
            if not clicked:
                print(f"[WARN] {cid}: No clickable element found")
                continue
            
            # Extract description
            long_desc = extract_long_description(page)
            
            # Update JSON
            found = False
            for c in data.get("cases", []):
                case_key = str(c.get("case_id", "")) or str(c.get("Case_Number", ""))
                if case_key == str(cid):
                    c["long_description"] = long_desc
                    found = True
                    break
            
            if not found:
                data.setdefault("cases", []).append({
                    "case_id": cid,
                    "long_description": long_desc
                })
            
            save_cases(data)
            print(f"[OK] {cid}: Saved {len(long_desc)} chars")
            
            # Go back
            page.go_back()
            page.wait_for_load_state("domcontentloaded", timeout=5000)
            
            # Refresh row locators
            rows = page.locator("table tbody tr, table tr:not(:first-child)")
        
        print("Extraction complete!")
        context.tracing.stop(path="trace.zip")
        
        # Keep browser open briefly
        time.sleep(5)
        browser.close()

if __name__ == "__main__":
    main()