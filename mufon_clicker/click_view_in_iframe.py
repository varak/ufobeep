#!/usr/bin/env python3
"""
Click VIEW buttons in the search results iframe to get long descriptions
"""
from playwright.sync_api import sync_playwright
import time
import json

def main():
    cases = []
    
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
        
        # Set Feb 1-2, 2025 using proven coordinate method
        print("📅 Setting date range: Feb 1-2, 2025")
        page.mouse.click(360, 405); page.keyboard.press("ArrowDown"); page.keyboard.press("ArrowDown"); page.keyboard.press("Enter"); time.sleep(0.5)
        page.mouse.click(440, 405); page.keyboard.press("ArrowDown"); page.keyboard.press("Enter"); time.sleep(0.5)
        page.mouse.click(520, 405); page.keyboard.type("2025"); page.keyboard.press("Enter"); time.sleep(1)
        page.mouse.click(590, 405); page.keyboard.press("ArrowDown"); page.keyboard.press("ArrowDown"); page.keyboard.press("Enter"); time.sleep(0.5)
        page.mouse.click(670, 405); page.keyboard.press("ArrowDown"); page.keyboard.press("ArrowDown"); page.keyboard.press("Enter"); time.sleep(0.5)
        page.mouse.click(750, 405); page.keyboard.type("2025"); page.keyboard.press("Enter"); time.sleep(1)
        page.mouse.click(633, 341); time.sleep(10)
        
        print("📊 Results loaded, looking for iframe...")
        
        # Look for iframe containing the results
        iframes = page.frames
        print(f"Found {len(iframes)} frames")
        
        results_frame = None
        for frame in iframes:
            try:
                frame_url = frame.url
                print(f"Frame URL: {frame_url}")
                if "search" in frame_url.lower() or "result" in frame_url.lower():
                    results_frame = frame
                    break
            except:
                continue
        
        if not results_frame:
            # Try the main frame locator approach
            print("🔍 Trying frame locator...")
            iframe_locator = page.frame_locator("iframe")
            
            # Look for VIEW buttons in iframe
            view_buttons = iframe_locator.locator("input[value='VIEW'], button:has-text('VIEW'), a:has-text('VIEW')").all()
            print(f"Found {len(view_buttons)} VIEW buttons in iframe")
            
            if view_buttons:
                print("✅ Clicking first VIEW button in iframe...")
                view_buttons[0].click()
                time.sleep(5)
                
                # Check for popup or navigation
                if len(page.context.pages) > 1:
                    print("📱 Popup detected - switching to popup")
                    popup = page.context.pages[-1]
                    popup.wait_for_load_state()
                    detail_content = popup.locator("body").inner_text()
                else:
                    print("📄 Same frame navigation")
                    detail_content = iframe_locator.locator("body").inner_text()
                
                # Save the detail content
                with open("first_view_detail.txt", "w") as f:
                    f.write(detail_content)
                print("💾 Saved first_view_detail.txt")
                
                # Look for long description
                lines = [line.strip() for line in detail_content.split('\n') if len(line.strip()) > 30]
                long_desc = ""
                for line in lines:
                    if any(word in line.lower() for word in ['observed', 'saw', 'witnessed', 'light', 'object', 'hovering', 'moving', 'sky', 'appeared', 'noticed']):
                        long_desc = line
                        break
                
                if long_desc:
                    print(f"🎉 SUCCESS! Found long description: {long_desc[:100]}...")
                else:
                    print("⚠️ Clicked VIEW but no clear description found")
                    print("First few lines of detail page:")
                    for line in lines[:5]:
                        print(f"  {line}")
            else:
                print("❌ No VIEW buttons found in iframe")
                
                # Debug: show iframe content
                iframe_content = iframe_locator.locator("body").inner_text()
                with open("iframe_debug.txt", "w") as f:
                    f.write(iframe_content)
                print("🐛 Saved iframe_debug.txt")
        else:
            print(f"📍 Working with results frame: {results_frame.url}")
            
            # Look for VIEW buttons in the results frame
            view_buttons = results_frame.locator("input[value='VIEW'], button:has-text('VIEW'), a:has-text('VIEW')").all()
            print(f"Found {len(view_buttons)} VIEW buttons in results frame")
            
            if view_buttons:
                view_buttons[0].click()
                time.sleep(5)
                print("✅ Clicked first VIEW button")
                
                detail_content = results_frame.locator("body").inner_text()
                with open("frame_view_detail.txt", "w") as f:
                    f.write(detail_content)
                print("💾 Saved frame_view_detail.txt")
        
        browser.close()

if __name__ == "__main__":
    main()