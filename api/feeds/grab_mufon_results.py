#!/usr/bin/env python3
"""
Quick MUFON results grabber - assumes you're on search results page
"""
import json, re
from pathlib import Path
from playwright.sync_api import sync_playwright

def parse_results_anywhere(page):
    """Parse any tables, lists, or case data we can find"""
    rows = []
    
    # Check for tables
    tables = page.locator("table")
    print(f"Found {tables.count()} tables")
    
    for t in range(tables.count()):
        tbl = tables.nth(t)
        trs = tbl.locator("tr")
        if trs.count() < 2:
            continue
            
        print(f"Table {t+1} has {trs.count()} rows")
        
        # Get headers
        headers = []
        header_row = trs.nth(0)
        header_cells = header_row.locator("th,td")
        for i in range(header_cells.count()):
            headers.append(header_cells.nth(i).inner_text().strip())
        
        print(f"Headers: {headers}")
        
        # Get data rows
        for r in range(1, min(trs.count(), 10)):  # Limit to first 10 rows
            tds = trs.nth(r).locator("td")
            if tds.count() < 2:
                continue
                
            row = {}
            for c in range(min(len(headers), tds.count())):
                key = headers[c] or f"col_{c}"
                value = re.sub(r"\s+", " ", tds.nth(c).inner_text()).strip()
                row[key] = value
            
            if row:
                rows.append(row)
    
    # Also check for any case-like content
    case_pattern = r"case\s*#?\s*\d+|report\s*#?\s*\d+"
    content = page.content()
    case_matches = re.findall(case_pattern, content, re.IGNORECASE)
    if case_matches:
        print(f"Found case references: {case_matches[:5]}")
    
    return rows

def main():
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        # Go to MUFON search page (you should already be logged in)
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        print(f"Current URL: {page.url}")
        print(f"Page title: {page.title()}")
        
        # Save current page
        Path("current_mufon_page.html").write_text(page.content())
        
        # Parse whatever is on the current page
        rows = parse_results_anywhere(page)
        
        # Save results
        results = {
            "timestamp": "2025-09-01T21:30:00",
            "url": page.url,
            "title": page.title(),
            "total_rows": len(rows),
            "rows": rows
        }
        
        Path("results_mufon_final.json").write_text(json.dumps(results, indent=2))
        print(f"\nSaved {len(rows)} results to results_mufon_final.json")
        
        browser.close()

if __name__ == "__main__":
    main()