#!/usr/bin/env python3
"""
Direct MUFON import script - takes the existing JSON and imports to production
"""
import json
import requests
import sys

def import_to_production():
    # Load the existing MUFON data
    with open('mufon_clicker/mufon_cases_2024_09_05.json', 'r') as f:
        data = json.load(f)
    
    cases = data['cases']
    print(f"📊 Found {len(cases)} MUFON cases to import")
    
    imported = 0
    
    for case in cases:
        case_number = case.get('case_number', '')
        print(f"\n--- Processing Case #{case_number} ---")
        
        # Build alert payload
        payload = {
            "source": "mufon",
            "source_id": case_number,
            "title": f"MUFON Case #{case_number}",
            "description": case.get('long_description', case.get('short_description', f'MUFON case #{case_number}')),
            "username": "MUFON Database"
        }
        
        # Add media if available
        media_files = case.get('media_files', [])
        if media_files:
            payload['media_urls'] = [m.get('url', '') for m in media_files if m.get('url')]
            print(f"   📎 Including {len(payload['media_urls'])} media files")
        
        print(f"   📋 Title: {payload['title']}")
        print(f"   📄 Description: {payload['description'][:100]}...")
        
        # Post to production alerts endpoint
        try:
            response = requests.post(
                'http://localhost:8000/alerts',
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            
            if response.status_code in [200, 201]:
                alert_data = response.json()
                alert_id = alert_data.get('id', 'unknown')
                print(f"   ✅ Created alert {alert_id}")
                imported += 1
            else:
                print(f"   ❌ Failed: {response.status_code} - {response.text[:200]}")
                
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    print(f"\n🎉 Successfully imported {imported}/{len(cases)} MUFON cases!")
    print("🌐 Check results at: ufobeep.com/alerts")

if __name__ == "__main__":
    import_to_production()