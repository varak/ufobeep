#!/usr/bin/env python3
"""
Get Long Descriptions for Known Case IDs
"""
from playwright.sync_api import sync_playwright
import json
from pathlib import Path
import time

def get_descriptions_for_known_ids():
    """Get long descriptions for the known real case IDs"""
    
    # Known real case IDs from media URLs
    real_case_ids = ["143946", "143948"]
    
    # Load existing MUFON data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON working results found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            descriptions = {}
            
            for case_id in real_case_ids:
                print(f"Getting long description for case ID {case_id}...")
                
                # Use the VIEW URL pattern
                view_url = f"https://mufoncms.com/cgi-bin/public_report_handler.pl?req=view_long_desc&id={case_id}&rnd="
                
                try:
                    page.goto(view_url, wait_until="domcontentloaded")
                    time.sleep(2)
                    
                    # Extract the long description
                    page_text = page.locator("body").inner_text()
                    
                    # Save the raw page content for debugging
                    with open(f"case_{case_id}_content.txt", "w") as f:
                        f.write(page_text)
                    
                    # Also save HTML for analysis
                    page_html = page.content()
                    with open(f"case_{case_id}_page.html", "w") as f:
                        f.write(page_html)
                    
                    # Find the longest substantial text block
                    long_description = ""
                    text_lines = page_text.split('\n')
                    
                    for line in text_lines:
                        line = line.strip()
                        if (len(line) > 50 and  # Substantial length
                            not line.isdigit() and  # Not just numbers
                            not line.startswith('Case #') and  # Not header
                            'mufon' not in line.lower()):  # Not footer
                            if len(line) > len(long_description):
                                long_description = line
                    
                    if long_description:
                        descriptions[case_id] = long_description
                        print(f"  ✅ Found description: {len(long_description)} chars")
                        print(f"  Preview: {long_description[:100]}...")
                    else:
                        print(f"  ❌ No description found")
                    
                except Exception as e:
                    print(f"  ❌ Error for case {case_id}: {e}")
                
                time.sleep(1)
            
            # Now match these descriptions to the cases in our data
            cases = mufon_data.get('cases', [])
            enhanced_cases = []
            
            for case in cases:
                case_copy = case.copy()
                
                # Check if this case has media with one of our known IDs
                media_attachments = case.get('Attachments_media', [])
                
                for media in media_attachments:
                    url = media.get('url', '')
                    for known_id in real_case_ids:
                        if known_id in url:
                            case_copy['Real_Case_Number'] = known_id
                            if known_id in descriptions:
                                case_copy['Long_Description'] = descriptions[known_id]
                                print(f"✅ Matched case {case.get('Case_Number')} to real ID {known_id}")
                            break
                    if case_copy.get('Real_Case_Number'):
                        break
                
                enhanced_cases.append(case_copy)
            
            # Save enhanced results
            enhanced_data = {
                "timestamp": mufon_data.get('timestamp'),
                "url": mufon_data.get('url'),
                "title": mufon_data.get('title'),
                "total_cases": len(enhanced_cases),
                "cases": enhanced_cases
            }
            
            with open("mufon_with_known_descriptions.json", "w") as f:
                json.dump(enhanced_data, f, indent=2)
            
            desc_count = sum(1 for c in enhanced_cases if c.get('Long_Description'))
            print(f"\n🎉 Enhanced {desc_count} cases with long descriptions")
            print(f"📄 Results saved to mufon_with_known_descriptions.json")
            
        except Exception as e:
            print(f"❌ Error: {e}")
        finally:
            browser.close()

if __name__ == "__main__":
    get_descriptions_for_known_ids()