#!/usr/bin/env python3
"""
Extract VIEW URLs from MUFON Results Page - Get the actual VIEW URLs from the same page we scraped
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time
import re

def extract_view_urls_from_results():
    """Extract VIEW URLs from the same MUFON results page where we got the case data"""
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            print("Step 1: Navigating to MUFON...")
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            
            # Follow the same navigation flow as mufon_authenticated_client.py
            page.locator("text=Track UFOs").first.click()
            time.sleep(1)
            
            page.locator("text=Search Database").first.click()
            page.wait_for_load_state("networkidle")
            
            # Handle terms and conditions
            page.locator("input[type='radio'][value*='agree']").first.check()
            page.locator("button:has-text('Submit')").first.click()
            page.wait_for_load_state("networkidle")
            
            print("Step 2: Looking for iframe...")
            
            # Find the iframe that contains the search results
            iframe = page.locator("iframe").first
            if iframe.count() > 0:
                print("Found iframe, switching to iframe content...")
                iframe_content = iframe.content_frame()
                
                # Wait for content to load
                time.sleep(2)
                
                # Take screenshot for debugging
                page.screenshot(path="mufon_iframe_content.png", full_page=True)
                
                # Extract all VIEW-related elements
                view_data = []
                
                print("Step 3: Extracting VIEW elements...")
                
                # Look for all possible VIEW button/link formats
                view_selectors = [
                    "input[value='VIEW']",
                    "button:has-text('VIEW')",
                    "a:has-text('VIEW')", 
                    "[onclick*='view_long_desc']",
                    "[href*='view_long_desc']"
                ]
                
                for selector in view_selectors:
                    try:
                        elements = iframe_content.locator(selector).all()
                        print(f"Found {len(elements)} elements with selector: {selector}")
                        
                        for i, element in enumerate(elements):
                            try:
                                # Get various attributes that might contain the VIEW URL
                                href = element.get_attribute("href")
                                onclick = element.get_attribute("onclick")
                                value = element.get_attribute("value")
                                
                                view_url = None
                                
                                # Extract URL from href
                                if href and "view_long_desc" in href:
                                    view_url = href
                                
                                # Extract URL from onclick JavaScript
                                elif onclick and "view_long_desc" in onclick:
                                    url_match = re.search(r'(https?://[^"\']+view_long_desc[^"\']*)', onclick)
                                    if url_match:
                                        view_url = url_match.group(1)
                                
                                if view_url:
                                    # Extract case ID from URL
                                    id_match = re.search(r'id=(\d+)', view_url)
                                    case_id = id_match.group(1) if id_match else None
                                    
                                    view_data.append({
                                        "index": len(view_data),
                                        "selector_used": selector,
                                        "case_id": case_id,
                                        "view_url": view_url,
                                        "element_tag": element.evaluate("el => el.tagName.toLowerCase()"),
                                        "element_text": element.inner_text()[:50] if element.inner_text() else "",
                                        "href": href,
                                        "onclick": onclick,
                                        "value": value
                                    })
                                    
                                    print(f"  Found VIEW URL {len(view_data)}: Case {case_id} -> {view_url}")
                                
                            except Exception as e:
                                print(f"  Error processing element {i}: {e}")
                                continue
                                
                    except Exception as e:
                        print(f"Error with selector {selector}: {e}")
                        continue
                
                # Also try to extract from the raw HTML 
                print("Step 4: Extracting from raw HTML...")
                html_content = iframe_content.content()
                
                # Find all view_long_desc URLs in the HTML
                url_matches = re.findall(r'(https?://[^"\'>\s]+view_long_desc[^"\'>\s]*)', html_content)
                
                for url in url_matches:
                    id_match = re.search(r'id=(\d+)', url)
                    case_id = id_match.group(1) if id_match else None
                    
                    # Check if we already have this URL
                    if not any(item['view_url'] == url for item in view_data):
                        view_data.append({
                            "index": len(view_data),
                            "selector_used": "html_regex",
                            "case_id": case_id,
                            "view_url": url,
                            "source": "raw_html"
                        })
                        print(f"  Found in HTML: Case {case_id} -> {url}")
                
                # Save the extracted VIEW URLs
                output_data = {
                    "timestamp": time.time(),
                    "total_view_urls": len(view_data),
                    "view_urls": view_data,
                    "extraction_method": "iframe_content_analysis"
                }
                
                with open("mufon_view_urls_extracted.json", "w") as f:
                    json.dump(output_data, f, indent=2)
                
                print(f"\n🎉 Found {len(view_data)} VIEW URLs saved to mufon_view_urls_extracted.json")
                
                # Save a sample of the HTML for debugging
                with open("mufon_iframe_html_sample.html", "w") as f:
                    f.write(html_content[:10000])  # First 10KB
                
            else:
                print("❌ No iframe found")
                page.screenshot(path="mufon_no_iframe_debug.png", full_page=True)
                
        except Exception as e:
            print(f"❌ Error: {e}")
            page.screenshot(path="mufon_extraction_error.png", full_page=True)
        finally:
            browser.close()

if __name__ == "__main__":
    extract_view_urls_from_results()