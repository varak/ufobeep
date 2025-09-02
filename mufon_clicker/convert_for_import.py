#!/usr/bin/env python3
"""
Convert extracted MUFON data to format expected by import_via_alerts.py
"""
import json
import sys
from datetime import datetime

def convert_mufon_data(input_file):
    """Convert our extraction format to importer format"""
    
    with open(input_file) as f:
        data = json.load(f)
    
    converted_cases = []
    
    for case in data['cases']:
        # Convert to expected format with proper field names
        converted_case = {
            "Case_Number": case['case_number'],
            "Date_Submitted": data['search_date'], 
            "DateTime_Event": case['date_time'],
            "Short_Description": case['short_description'],
            "Long_Description": case['long_description'],
            "Location": case['location'],
            "Attachments_media": case.get('media_files', [])
        }
        converted_cases.append(converted_case)
    
    # Create output in expected format
    output = {
        "search_date": data['search_date'],
        "timestamp": data['timestamp'],
        "total_cases": len(converted_cases),
        "cases": converted_cases
    }
    
    # Save as the filename the importer expects
    output_file = "mufon_classified_results.json"
    with open(output_file, 'w') as f:
        json.dump(output, f, indent=2)
    
    print(f"✅ Converted {len(converted_cases)} cases to {output_file}")
    return output_file

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python convert_for_import.py input_file.json")
        sys.exit(1)
    
    input_file = sys.argv[1]
    convert_mufon_data(input_file)