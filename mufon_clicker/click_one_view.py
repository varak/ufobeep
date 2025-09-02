#!/usr/bin/env python3
"""
Focus on clicking ONE VIEW button to see what happens
Based on feedback: VIEW is in "Long Description" column, not far right "Attachments"
"""
from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False, slow_mo=1000)
    context = browser.new_context()
    page = context.new_page()
    
    # Login
    page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp")
    time.sleep(2)
    page.fill("input[name='loginName']", "varak")
    page.fill("input[name='loginPassword']", "ufobeep123pass")
    page.click("text=Log In")
    time.sleep(5)
    
    # Go to search page
    page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&")
    time.sleep(5)
    
    # Set Feb 1, 2025 using proven coordinate method
    print("📅 Setting FROM date: Feb 1, 2025")
    page.mouse.click(360, 405)  # Month
    page.keyboard.press("ArrowDown")  # February
    page.keyboard.press("ArrowDown")
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(440, 405)  # Day
    page.keyboard.press("ArrowDown")  # Day 1
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(520, 405)  # Year
    page.keyboard.type("2025")
    page.keyboard.press("Enter")
    time.sleep(1)
    
    # Set Feb 2, 2025 TO date
    print("📅 Setting TO date: Feb 2, 2025")
    page.mouse.click(590, 405)  # TO Month
    page.keyboard.press("ArrowDown")  # February
    page.keyboard.press("ArrowDown")
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(670, 405)  # TO Day
    page.keyboard.press("ArrowDown")  # Day 2
    page.keyboard.press("ArrowDown")
    page.keyboard.press("Enter")
    time.sleep(0.5)
    
    page.mouse.click(750, 405)  # TO Year
    page.keyboard.type("2025")
    page.keyboard.press("Enter")
    time.sleep(1)
    
    # Submit search
    print("🚀 Submitting search...")
    page.mouse.click(633, 341)  # SUBMIT
    time.sleep(10)
    
    # Take screenshot of results
    page.screenshot(path="search_results_before_view.png")
    print("📸 Saved search_results_before_view.png")
    
    # Look for VIEW links - try multiple approaches
    print("🔍 Looking for VIEW links...")
    
    # Method 1: Look for text="VIEW" links
    view_links = page.locator("a:has-text('VIEW')").all()
    print(f"Found {len(view_links)} VIEW links with text search")
    
    # Method 2: Look in table cells for VIEW
    table_cells = page.locator("table td").all()
    view_cells = []
    for cell in table_cells:
        try:
            if "VIEW" in cell.inner_text():
                view_cells.append(cell)
        except:
            continue
    print(f"Found {len(view_cells)} cells containing VIEW text")
    
    # Method 3: Look for any clickable elements with VIEW
    clickable_views = page.locator("button:has-text('VIEW'), input[value*='VIEW'], a[href*='view'], *[onclick*='view']").all()
    print(f"Found {len(clickable_views)} clickable VIEW elements")
    
    # Try clicking the first available VIEW element
    if view_links:
        print("✅ Clicking first VIEW link...")
        view_links[0].click()
        time.sleep(5)
        
        page.screenshot(path="after_view_click.png")
        print("📸 Saved after_view_click.png")
        print(f"📍 URL after click: {page.url}")
        
        # Look for description content
        page_text = page.locator("body").inner_text()
        with open("view_detail_content.txt", "w") as f:
            f.write(page_text)
        print("💾 Saved view_detail_content.txt")
        
        # Look for long description indicators
        if any(word in page_text.lower() for word in ['description', 'observed', 'witnessed', 'details']):
            print("🎉 SUCCESS! Found description content on detail page")
        else:
            print("⚠️ Clicked VIEW but no clear description found")
            
    elif view_cells:
        print("✅ Trying to click VIEW from table cell...")
        # Try to find a link within the cell
        for cell in view_cells[:1]:  # Just try first one
            try:
                link = cell.locator("a").first
                if link.count() > 0:
                    link.click()
                    print("Clicked link in VIEW cell")
                    time.sleep(5)
                    page.screenshot(path="cell_view_click.png")
                    break
                else:
                    # Try clicking the cell itself
                    cell.click()
                    print("Clicked VIEW cell directly")
                    time.sleep(5)
                    page.screenshot(path="cell_direct_click.png")
                    break
            except Exception as e:
                print(f"Error clicking VIEW cell: {e}")
                continue
    else:
        print("❌ No VIEW elements found - taking screenshot for analysis")
        page.screenshot(path="no_view_found.png")
        
        # Debug: show all table content
        table_text = page.locator("table").inner_text() if page.locator("table").count() > 0 else "No table found"
        with open("table_debug.txt", "w") as f:
            f.write(table_text)
        print("🐛 Saved table_debug.txt for analysis")
    
    browser.close()