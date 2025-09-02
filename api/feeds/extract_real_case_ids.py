#!/usr/bin/env python3
"""
Extract Real Case IDs from Media URLs and Get Long Descriptions
"""
import json
import re
from pathlib import Path
from playwright.sync_api import sync_playwright
import time

def extract_case_ids_and_get_descriptions():
    """Extract real case IDs from media URLs and fetch long descriptions"""
    
    # Load existing MUFON data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON working results found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    cases = mufon_data.get('cases', [])
    print(f"📊 Processing {len(cases)} MUFON cases to extract real case IDs...")
    
    # Extract real case IDs from media URLs
    cases_with_real_ids = []
    
    for case in cases:
        case_copy = case.copy()
        real_case_id = None
        
        # Look for real case ID in media attachments
        media_attachments = case.get('Attachments_media', [])
        if media_attachments:
            for media in media_attachments:
                url = media.get('url', '')
                # Extract case ID from URLs like: http://mufoncms.com/cgi-bin/ffplay.pl?file=143948_submitter_file1__IMG4989.mov
                case_id_match = re.search(r'/(\d{6})_submitter_file', url)
                if case_id_match:
                    real_case_id = case_id_match.group(1)
                    break
        
        if real_case_id:
            case_copy['Real_Case_Number'] = real_case_id
            print(f"Case {case.get('Case_Number')}: Found real ID {real_case_id}")
        
        cases_with_real_ids.append(case_copy)
    
    print(f"\n🎯 Found real case IDs for {sum(1 for c in cases_with_real_ids if c.get('Real_Case_Number'))} cases")
    
    # Now use Playwright to fetch long descriptions using the real case IDs
    state_file = Path("mufon_artifacts/storage_state.json")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(state_file) if state_file.exists() else None)
        page = context.new_page()
        
        try:
            enhanced_cases = []
            
            for case in cases_with_real_ids:
                real_case_id = case.get('Real_Case_Number')
                
                if real_case_id:
                    print(f"\nProcessing case {case.get('Case_Number')} with real ID {real_case_id}...")
                    
                    # Build VIEW URL using the pattern you provided
                    view_url = f"https://mufoncms.com/cgi-bin/public_report_handler.pl?req=view_long_desc&id={real_case_id}&rnd="
                    
                    try:
                        print(f"  Navigating to: {view_url}")
                        page.goto(view_url, wait_until="domcontentloaded")
                        time.sleep(2)
                        
                        # Extract long description from the page
                        page_text = page.inner_text()
                        
                        # Look for substantial description text
                        long_description = ""
                        text_lines = page_text.split('\n')
                        
                        for line in text_lines:
                            line = line.strip()
                            if (len(line) > 100 and 
                                not re.match(r'^[\d\-\s:APMapm]+$', line) and
                                'case' not in line.lower()[:10] and
                                'report' not in line.lower()[:10] and
                                'description' not in line.lower()[:10]):
                                if len(line) > len(long_description):
                                    long_description = line
                        
                        if long_description:
                            case['Long_Description'] = long_description
                            print(f"  ✅ Found long description: {len(long_description)} chars")
                        else:
                            print(f"  ❌ No long description found")
                            
                    except Exception as e:
                        print(f"  ❌ Error fetching long description: {e}")
                    
                    time.sleep(1)  # Be respectful
                
                enhanced_cases.append(case)
            
            # Save enhanced results
            enhanced_data = {
                "timestamp": mufon_data.get('timestamp'),
                "url": mufon_data.get('url'),
                "title": mufon_data.get('title'),
                "total_cases": len(enhanced_cases),
                "cases": enhanced_cases
            }
            
            with open("mufon_with_real_ids_and_descriptions.json", "w") as f:
                json.dump(enhanced_data, f, indent=2)
            
            real_id_count = sum(1 for c in enhanced_cases if c.get('Real_Case_Number'))
            long_desc_count = sum(1 for c in enhanced_cases if c.get('Long_Description'))
            
            print(f"\n🎉 Enhanced {real_id_count} cases with real IDs")
            print(f"📝 Got long descriptions for {long_desc_count} cases")
            print(f"📄 Results saved to mufon_with_real_ids_and_descriptions.json")
            
        except Exception as e:
            print(f"❌ Error during enhancement: {e}")
        finally:
            browser.close()

if __name__ == "__main__":
    extract_case_ids_and_get_descriptions()