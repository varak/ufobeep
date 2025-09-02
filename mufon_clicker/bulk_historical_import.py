#!/usr/bin/env python3
"""
Bulk historical MUFON import - runs pipeline for 365 days starting from 365 days ago
Usage: python bulk_historical_import.py [start_days_ago] [total_days]
Example: python bulk_historical_import.py 365 365  # Import last 365 days
Example: python bulk_historical_import.py 30 7     # Import 7 days starting from 30 days ago
"""

import sys
import subprocess
import time
from datetime import datetime, timedelta

def run_daily_import(date_str):
    """Run the daily pipeline for a specific date"""
    print(f"\n{'='*60}")
    print(f"📅 Processing {date_str}")
    print(f"{'='*60}")
    
    cmd = f"python daily_mufon_pipeline.py {date_str}"
    result = subprocess.run(cmd, shell=True)
    
    if result.returncode == 0:
        print(f"✅ Successfully processed {date_str}")
        return True
    else:
        print(f"❌ Failed to process {date_str}")
        return False

def main():
    # Default: Import last 365 days
    start_days_ago = int(sys.argv[1]) if len(sys.argv) > 1 else 365
    total_days = int(sys.argv[2]) if len(sys.argv) > 2 else 365
    
    print(f"🚀 Starting bulk MUFON historical import")
    print(f"📊 Processing {total_days} days starting from {start_days_ago} days ago")
    
    successful_imports = 0
    failed_imports = 0
    
    # Calculate start date
    start_date = datetime.now() - timedelta(days=start_days_ago)
    
    for day_offset in range(total_days):
        current_date = start_date + timedelta(days=day_offset)
        date_str = current_date.strftime("%Y-%m-%d")
        
        try:
            if run_daily_import(date_str):
                successful_imports += 1
            else:
                failed_imports += 1
                
        except KeyboardInterrupt:
            print(f"\n⚠️ Interrupted by user at {date_str}")
            break
        except Exception as e:
            print(f"❌ Unexpected error for {date_str}: {e}")
            failed_imports += 1
        
        # Brief pause between days to avoid overwhelming systems
        time.sleep(2)
        
        # Progress update every 10 days
        if (day_offset + 1) % 10 == 0:
            progress = ((day_offset + 1) / total_days) * 100
            print(f"\n📈 Progress: {day_offset + 1}/{total_days} days ({progress:.1f}%)")
            print(f"✅ Successful: {successful_imports} | ❌ Failed: {failed_imports}")
    
    print(f"\n🏁 Bulk import complete!")
    print(f"📊 Final results:")
    print(f"   ✅ Successful imports: {successful_imports}")
    print(f"   ❌ Failed imports: {failed_imports}")
    print(f"   📈 Success rate: {(successful_imports/(successful_imports+failed_imports)*100):.1f}%")

if __name__ == "__main__":
    main()