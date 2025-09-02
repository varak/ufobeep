#!/usr/bin/env python3
"""
Upload media files to existing MUFON alerts
"""
import json
import requests
from pathlib import Path

def upload_media():
    """Download and upload MUFON media to existing alerts"""
    
    # Mapping of case numbers to alert IDs from the successful import
    case_to_alert = {
        "9": "4511b6a5-329f-473e-b15c-d37fa5f4dcbb",
        "11": "e5e2aead-c13c-45bc-92eb-570d832ef2be"
    }
    
    # Load MUFON data
    with open("mufon_working_results.json") as f:
        mufon_data = json.load(f)
    
    base_url = "https://api.ufobeep.com"
    
    for case in mufon_data['cases']:
        case_num = case.get('Case_Number')
        if case_num not in case_to_alert:
            continue
            
        alert_id = case_to_alert[case_num]
        media_files = case.get('Attachments_media', [])
        
        if media_files:
            print(f"\n📎 Processing media for Case #{case_num} (Alert: {alert_id})")
            
            for media in media_files:
                try:
                    print(f"   Downloading {media['filename']}...")
                    
                    # Download the media file
                    media_response = requests.get(media['url'], timeout=30)
                    if media_response.status_code == 200:
                        
                        # Upload to alert using multipart form data
                        files = {
                            'files': (media['filename'], media_response.content)
                        }
                        
                        upload_response = requests.post(
                            f"{base_url}/alerts/{alert_id}/media",
                            files=files
                        )
                        
                        if upload_response.status_code in [200, 201]:
                            print(f"   ✅ Uploaded {media['filename']}")
                        else:
                            print(f"   ❌ Failed to upload {media['filename']}: {upload_response.status_code}")
                            print(f"      Response: {upload_response.text}")
                    else:
                        print(f"   ❌ Failed to download {media['filename']}: {media_response.status_code}")
                        
                except Exception as e:
                    print(f"   ❌ Error processing {media['filename']}: {e}")
    
    print("\n✅ Media upload complete!")

if __name__ == "__main__":
    upload_media()