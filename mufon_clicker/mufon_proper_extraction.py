#!/usr/bin/env python3

import sys
import time
import json
from datetime import datetime
from playwright.sync_api import sync_playwright

def extract_mufon_date(date_str):
    """Extract MUFON data with proper HTML parsing"""
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    year = date_obj.year
    month = date_obj.month
    day = date_obj.day
    
    print(f"🎯 MUFON Proper Extraction for {date_str}")
    print(f"📅 Target: {month}/{day}/{year}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, slow_mo=500)
        context = browser.new_context(storage_state="storage_state.json")
        page = context.new_page()
        
        print("🔍 Going to search page...")
        page.goto("https://mufoncms.com/cgi-bin/report_handler.pl?req=search_page")
        page.wait_for_load_state()
        time.sleep(3)
        
        # Find the iframe
        iframe = page.frame_locator("iframe")
        
        # Set date fields using exact selectors  
        print("📅 Setting date fields...")
        iframe.locator("select[name='event_date_lo__month']").select_option(str(month))
        iframe.locator("select[name='event_date_lo__day']").select_option(str(day)) 
        iframe.locator("select[name='event_date_lo__year']").select_option(str(year))
        iframe.locator("select[name='event_date_hi__month']").select_option(str(month))
        iframe.locator("select[name='event_date_hi__day']").select_option(str(day))
        iframe.locator("select[name='event_date_hi__year']").select_option(str(year))
        
        print(f"✅ Date fields set to {month}/{day}/{year}")
        
        # Submit search
        print("🚀 Submitting search...")
        iframe.locator("input[type='submit'][value='SUBMIT']").first.click()
        time.sleep(10)
        
        # Parse table headers to identify column positions
        header_row = iframe.locator("table thead tr").first
        if not header_row.count():
            header_row = iframe.locator("table tr").first  # Sometimes no thead
        
        headers = []
        if header_row.count():
            header_cells = header_row.locator("th, td").all()
            for cell in header_cells:
                header_text = cell.inner_text().strip()
                headers.append(header_text)
                print(f"📋 Header: '{header_text}'")
        
        # Map header names to expected field names
        field_map = {}
        for i, header in enumerate(headers):
            header_lower = header.lower()
            if 'case' in header_lower or '#' in header_lower:
                field_map['case_number'] = i
            elif 'date' in header_lower and 'time' in header_lower:
                field_map['date_time'] = i
            elif 'description' in header_lower and 'short' in header_lower:
                field_map['short_description'] = i
            elif 'location' in header_lower:
                field_map['location'] = i
            elif 'attach' in header_lower or 'media' in header_lower or 'file' in header_lower:
                field_map['attachments'] = i
        
        print(f"🗺️  Field mapping: {field_map}")
        
        # Extract data rows
        rows = iframe.locator("table tbody tr").all()
        if not rows:
            rows = iframe.locator("table tr").all()[1:]  # Skip header if no tbody
        
        result_count = len(rows)
        print(f"📊 Found {result_count} results")
        
        cases = []
        visited_cases = set()
        
        for i, row in enumerate(rows, 1):
            try:
                cells = row.locator("td").all()
                if len(cells) < len(field_map):
                    print(f"   ⚠️  Skipping row {i}: insufficient cells")
                    continue
                
                # Extract fields using proper mapping
                case_data = {}
                
                if 'case_number' in field_map:
                    case_data['case_number'] = cells[field_map['case_number']].inner_text().strip()
                else:
                    case_data['case_number'] = f"row_{i}"
                
                if 'date_time' in field_map:
                    case_data['date_time'] = cells[field_map['date_time']].inner_text().strip()
                
                if 'short_description' in field_map:
                    case_data['short_description'] = cells[field_map['short_description']].inner_text().strip()
                
                if 'location' in field_map:
                    case_data['location'] = cells[field_map['location']].inner_text().strip()
                
                # Skip duplicates
                case_id = case_data['case_number']
                if case_id in visited_cases:
                    continue
                visited_cases.add(case_id)
                
                print(f"\n--- Processing Case {i}: #{case_id} ---")
                print(f"   📅 Date/Time: {case_data.get('date_time', 'N/A')}")
                print(f"   📄 Description: {case_data.get('short_description', 'N/A')[:50]}...")
                print(f"   📍 Location: {case_data.get('location', 'N/A')}")
                
                # Extract media files from attachments column
                media_files = []
                if 'attachments' in field_map:
                    attachments_cell = cells[field_map['attachments']]
                    attachment_links = attachments_cell.locator("a").all()
                    
                    if attachment_links:
                        print(f"   📎 Found attachments: {len(attachment_links)}")
                        
                        for link in attachment_links:
                            try:
                                filename = link.inner_text().strip()
                                href = link.get_attribute('href')
                                
                                if filename and href:
                                    file_type = "video" if any(ext in filename.lower() for ext in ['.mp4', '.mov', '.avi']) else "image"
                                    media_files.append({
                                        "filename": filename,
                                        "url": href,
                                        "type": file_type
                                    })
                                    print(f"   ✅ Found {file_type}: {filename}")
                                    
                            except Exception as e:
                                print(f"   ❌ Media error: {e}")
                                continue
                
                case_data['media_files'] = media_files
                
                # Get long description by clicking VIEW button
                long_description = ""
                view_button = row.locator("input[value='VIEW']")
                
                if view_button.count() > 0:
                    print(f"   🔍 Clicking VIEW for long description...")
                    try:
                        view_button.click()
                        time.sleep(3)
                        
                        # Check for popup window
                        if len(page.context.pages) > 1:
                            popup = page.context.pages[-1]
                            popup.wait_for_load_state()
                            
                            # Extract long description from popup
                            detail_content = popup.locator("body").inner_text()
                            popup.close()
                            
                            # Parse long description - look for substantial content
                            lines = [line.strip() for line in detail_content.split('\n') if len(line.strip()) > 20]
                            if lines:
                                # Find the longest line as likely description
                                long_description = max(lines, key=len)
                                print(f"   📖 Long description: {long_description[:100]}...")
                                
                        else:
                            print(f"   ⚠️  No popup opened for VIEW")
                            
                    except Exception as e:
                        print(f"   ❌ VIEW error: {e}")
                
                case_data['long_description'] = long_description
                case_data['row_index'] = i
                
                cases.append(case_data)
                print(f"   ✅ Complete: #{case_id}, Media: {len(media_files)}")
                
            except Exception as e:
                print(f"   ❌ Row {i} error: {e}")
                continue
        
        # Save results
        output_file = f"mufon_proper_{date_str.replace('-', '_')}.json"
        result_data = {
            "search_date": date_str,
            "timestamp": datetime.now().isoformat(),
            "total_cases": len(cases),
            "field_mapping": field_map,
            "headers": headers,
            "cases": cases
        }
        
        with open(output_file, 'w') as f:
            json.dump(result_data, f, indent=2)
        
        print(f"💾 Results saved to {output_file}")
        print(f"🎉 Successfully extracted data for {date_str} - {len(cases)} total results")
        
        print("⏸️ Browser will close in 5 seconds...")
        time.sleep(5)
        browser.close()

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 mufon_proper_extraction.py YYYY-MM-DD")
        sys.exit(1)
    
    date_str = sys.argv[1]
    extract_mufon_date(date_str)

if __name__ == "__main__":
    main()