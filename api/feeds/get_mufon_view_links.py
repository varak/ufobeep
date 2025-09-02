#!/usr/bin/env python3
"""
Get MUFON VIEW Links - Extract the actual VIEW link URLs from search results
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time

def get_view_links():
    """Get the actual VIEW links from MUFON search results"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)  # Headless mode for server
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("Step 1: Navigating to MUFON...")
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            
            # Use the same flow as working scraper
            page.locator("text=Track UFOs").first.click()
            time.sleep(1)
            
            page.locator("text=Search Database").first.click()
            page.wait_for_load_state("networkidle")
            
            # Handle terms and conditions
            page.locator("input[type='radio'][value*='agree']").first.check()
            page.locator("button:has-text('Submit')").first.click()
            page.wait_for_load_state("networkidle")
            
            print("Step 2: Getting to search results...")
            
            # Look for iframe with search results
            iframe = page.locator("iframe").first
            if iframe.count() > 0:
                print("Found iframe, extracting VIEW links...")
                iframe_content = iframe.content_frame()
                
                # Get all VIEW links from the page
                view_links = []
                
                # Look for VIEW buttons/links in various formats
                view_elements = iframe_content.locator("text=VIEW").all()
                print(f"Found {len(view_elements)} VIEW elements")
                
                for i, view_elem in enumerate(view_elements):
                    try:
                        # Get the href or onclick attribute
                        href = view_elem.get_attribute("href") 
                        onclick = view_elem.get_attribute("onclick")
                        
                        view_url = None
                        if href and "view_long_desc" in href:
                            view_url = href
                        elif onclick and "view_long_desc" in onclick:
                            # Extract URL from onclick JavaScript
                            import re
                            url_match = re.search(r'(https?://[^"\']+view_long_desc[^"\']*)', onclick)
                            if url_match:
                                view_url = url_match.group(1)
                        
                        if view_url:
                            # Extract case ID from URL
                            id_match = re.search(r'id=(\d+)', view_url)
                            case_id = id_match.group(1) if id_match else f"unknown_{i}"
                            
                            view_links.append({
                                "case_id": case_id,
                                "view_url": view_url,
                                "index": i
                            })
                            print(f"  VIEW link {i+1}: Case {case_id} -> {view_url}")
                    
                    except Exception as e:
                        print(f"  Error extracting VIEW link {i+1}: {e}")
                        continue
                
                # Save VIEW links
                with open("mufon_view_links.json", "w") as f:
                    json.dump({
                        "timestamp": time.time(),
                        "total_links": len(view_links), 
                        "view_links": view_links
                    }, f, indent=2)
                
                print(f"\n🎉 Found {len(view_links)} VIEW links saved to mufon_view_links.json")
                
                # Take screenshot for debugging
                page.screenshot(path="mufon_view_links_page.png", full_page=True)
                
        except Exception as e:
            print(f"❌ Error: {e}")
        finally:
            browser.close()

if __name__ == "__main__":
    get_view_links()