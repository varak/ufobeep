#!/usr/bin/env python3
"""
Update MUFON Cases with Real Case IDs
"""
import json
from pathlib import Path

def update_with_real_case_ids():
    """Update MUFON cases with the real case IDs we extracted"""
    
    # Load existing MUFON data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON working results found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    cases = mufon_data.get('cases', [])
    print(f"📊 Updating {len(cases)} MUFON cases with real case IDs...")
    
    # Known mappings from media URL analysis
    real_case_mappings = {
        "143948": None,  # Case with media files containing 143948
        "143946": None   # Case with media files containing 143946
    }
    
    enhanced_cases = []
    
    for i, case in enumerate(cases):
        case_copy = case.copy()
        
        # Check if this case has media with known real IDs
        media_attachments = case.get('Attachments_media', [])
        
        real_case_id = None
        for media in media_attachments:
            url = media.get('url', '')
            if '143948' in url:
                real_case_id = '143948'
                real_case_mappings['143948'] = i + 1
                break
            elif '143946' in url:
                real_case_id = '143946'
                real_case_mappings['143946'] = i + 1
                break
        
        if real_case_id:
            case_copy['Real_Case_Number'] = real_case_id
            # Add placeholder long description indicating we have the real case ID
            case_copy['Long_Description'] = f"[MUFON Case #{real_case_id}] {case.get('Short_Description', '')} - Full details available in MUFON database with authenticated access."
            print(f"✅ Case {case.get('Case_Number')} -> Real MUFON Case #{real_case_id}")
        
        enhanced_cases.append(case_copy)
    
    # Update the data
    enhanced_data = {
        "timestamp": mufon_data.get('timestamp'),
        "url": mufon_data.get('url'),
        "title": mufon_data.get('title'),
        "total_cases": len(enhanced_cases),
        "cases": enhanced_cases,
        "real_case_mappings": real_case_mappings
    }
    
    # Save enhanced results
    with open("mufon_enhanced_final.json", "w") as f:
        json.dump(enhanced_data, f, indent=2)
    
    real_id_count = sum(1 for c in enhanced_cases if c.get('Real_Case_Number'))
    print(f"\n🎉 Enhanced {real_id_count} cases with real MUFON case IDs")
    print(f"📄 Results saved to mufon_enhanced_final.json")
    print(f"🔗 Case mappings: {real_case_mappings}")

if __name__ == "__main__":
    update_with_real_case_ids()