#!/usr/bin/env python3
"""
Fetch MUFON Long Descriptions - Use direct HTTP requests to get long descriptions
"""
import requests
import json
from pathlib import Path
import time
from bs4 import BeautifulSoup
import re

def fetch_long_descriptions():
    """Fetch long descriptions using direct HTTP requests to VIEW URLs"""
    
    # Load existing case data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON data file found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    cases = mufon_data.get('cases', [])
    print(f"📊 Fetching long descriptions for {len(cases)} MUFON cases...")
    
    # Set up headers to mimic browser
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1'
    }
    
    enhanced_cases = []
    view_links_tried = []
    
    # The pattern we discovered: https://mufoncms.com/cgi-bin/public_report_handler.pl?req=view_long_desc&id=143963&rnd=
    # We need to guess/try case IDs around the range we expect
    
    # Start with a reasonable base case ID and try sequential IDs
    base_case_id = 143960  # From the example URL provided by user
    
    for i, case in enumerate(cases):
        try:
            print(f"\nProcessing case {i+1}/{len(cases)}: {case.get('Case_Number')}")
            
            # Try a few case IDs around our estimated range
            candidate_ids = [
                base_case_id + i,
                base_case_id + i + 10,
                base_case_id + i + 20,
                base_case_id + i - 10,
                base_case_id + i + 100,
                base_case_id + i + 1000
            ]
            
            long_description = None
            real_case_id = None
            
            for candidate_id in candidate_ids:
                view_url = f"https://mufoncms.com/cgi-bin/public_report_handler.pl?req=view_long_desc&id={candidate_id}&rnd="
                
                try:
                    print(f"  Trying VIEW URL: {view_url}")
                    response = requests.get(view_url, headers=headers, timeout=10)
                    
                    view_links_tried.append({
                        "original_case": case.get('Case_Number'),
                        "candidate_id": candidate_id,
                        "view_url": view_url,
                        "status_code": response.status_code,
                        "success": response.status_code == 200
                    })
                    
                    if response.status_code == 200:
                        soup = BeautifulSoup(response.text, 'html.parser')
                        
                        # Extract long description from various possible locations
                        description_text = ""
                        
                        # Look for table cells with description data
                        cells = soup.find_all('td')
                        for cell in cells:
                            text = cell.get_text().strip()
                            if text and len(text) > 100 and not re.match(r'^[\d\-\s:APMapm]+$', text):
                                # This looks like a description (long text, not just dates/times)
                                if len(text) > len(description_text):
                                    description_text = text
                        
                        # Also try paragraphs and divs
                        if not description_text:
                            for tag in ['p', 'div']:
                                elements = soup.find_all(tag)
                                for elem in elements:
                                    text = elem.get_text().strip()
                                    if text and len(text) > 100:
                                        if len(text) > len(description_text):
                                            description_text = text
                        
                        if description_text and len(description_text) > 50:
                            long_description = description_text
                            real_case_id = str(candidate_id)
                            print(f"  ✅ Found long description for case {candidate_id}: {len(description_text)} chars")
                            break
                        else:
                            print(f"  No substantial description found for case {candidate_id}")
                    else:
                        print(f"  Failed to fetch case {candidate_id}: {response.status_code}")
                        
                except Exception as e:
                    print(f"  Error fetching case {candidate_id}: {e}")
                    continue
                
                time.sleep(1)  # Be respectful
            
            # Update the case with any found data
            if long_description:
                case['Long_Description'] = long_description
                print(f"  ✅ Added long description: {len(long_description)} chars")
            
            if real_case_id:
                case['Real_Case_Number'] = real_case_id
                print(f"  ✅ Real case number: {real_case_id}")
            
            enhanced_cases.append(case)
            
        except Exception as e:
            print(f"  ❌ Error processing case {i+1}: {e}")
            enhanced_cases.append(case)  # Keep original
            continue
    
    # Save VIEW links attempted for debugging
    with open("mufon_view_attempts.json", "w") as f:
        json.dump({
            "timestamp": time.time(),
            "total_attempts": len(view_links_tried),
            "attempts": view_links_tried
        }, f, indent=2)
    
    # Save enhanced data
    enhanced_data = {
        "timestamp": mufon_data.get('timestamp'),
        "url": mufon_data.get('url'),
        "title": mufon_data.get('title'),
        "total_cases": len(enhanced_cases),
        "cases": enhanced_cases
    }
    
    with open("mufon_enhanced_results.json", "w") as f:
        json.dump(enhanced_data, f, indent=2)
    
    # Count how many got enhanced
    enhanced_count = sum(1 for case in enhanced_cases if case.get('Long_Description') or case.get('Real_Case_Number'))
    
    print(f"\n🎉 Enhanced {enhanced_count}/{len(enhanced_cases)} cases with long descriptions")
    print(f"📄 Results saved to mufon_enhanced_results.json")
    print(f"🔍 View attempts logged to mufon_view_attempts.json")

if __name__ == "__main__":
    fetch_long_descriptions()