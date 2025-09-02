#!/usr/bin/env python3
"""
Quick import of existing MUFON data to production
"""
import json
import requests
import os
import sys

def main():
    # Use the existing MUFON data we already have
    with open('../mufon_clicker/mufon_cases_2024_09_05.json', 'r') as f:
        data = json.load(f)
    
    cases = data.get('cases', [])
    print(f"📊 Importing {len(cases)} MUFON cases to production...")
    
    imported = 0
    
    for case in cases[:3]:  # Just import first 3 to test
        case_number = case.get('case_number', '')
        long_desc = case.get('long_description', '')
        media_files = case.get('media_files', [])
        
        print(f"\n--- Case #{case_number} ---")
        
        # Build alert payload
        payload = {
            "device_id": f"mufon_case_{case_number}",
            "source": "mufon", 
            "source_id": str(case_number),
            "title": f"MUFON Case #{case_number}",
            "description": long_desc or f"MUFON case #{case_number}",
            "username": "MUFON Database",
            "location": {
                "latitude": 39.0,  # Center of USA as placeholder
                "longitude": -98.0,
                "accuracy": 1000000.0  # Very low accuracy to indicate uncertainty
            }
        }
        
        # Add media URLs if available
        if media_files:
            media_urls = [m.get('url', '') for m in media_files if m.get('url')]
            if media_urls:
                payload['media_urls'] = media_urls
                print(f"   📎 {len(media_urls)} media files")
        
        print(f"   📄 {len(payload['description'])} chars")
        
        # Post to alerts endpoint
        try:
            response = requests.post(
                'http://localhost:8000/alerts',
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            
            if response.status_code in [200, 201]:
                result = response.json()
                alert_id = result.get('id', 'unknown')
                print(f"   ✅ Created alert {alert_id}")
                imported += 1
            else:
                print(f"   ❌ Failed: {response.status_code} - {response.text[:100]}")
                
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    print(f"\n🎉 Imported {imported} MUFON cases!")
    print("🌐 View at: http://localhost:3000/alerts or ufobeep.com/alerts")

if __name__ == "__main__":
    main()