#!/usr/bin/env python3
"""
MUFON Nightly Pipeline - Complete automation for daily MUFON case imports
Handles auth expiration, extracts full day of sightings with media, imports to UFOBeep
"""
import os
import sys
import json
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
import time

# Add the mufon_clicker directory to path for imports
sys.path.append('/home/ufobeep/ufobeep/mufon_clicker')
sys.path.append('/home/ufobeep/ufobeep/api/feeds')

def log(message):
    """Log with timestamp"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def check_auth_expired():
    """Check if MUFON authentication has expired"""
    storage_path = Path("/home/ufobeep/ufobeep/mufon_clicker/mufon_artifacts/storage_state.json")
    
    if not storage_path.exists():
        log("⚠️  No storage_state.json - need fresh auth")
        return True
    
    try:
        with open(storage_path) as f:
            storage_data = json.load(f)
        
        # Check if any cookies are expired
        for cookie in storage_data.get('cookies', []):
            if cookie.get('expires', -1) > 0:  # Skip session cookies (expires: -1)
                expires_timestamp = cookie['expires']
                if expires_timestamp < time.time():
                    log(f"🔓 Cookie {cookie['name']} expired")
                    return True
        
        log("🔑 Auth cookies still valid")
        return False
        
    except Exception as e:
        log(f"⚠️  Error checking auth: {e}")
        return True

def refresh_mufon_auth():
    """Refresh MUFON authentication using headless login"""
    log("🔐 Refreshing MUFON authentication...")
    
    try:
        # Set environment variables from .env.mufon
        env = os.environ.copy()
        env_file = Path("/home/ufobeep/ufobeep/.env.mufon")
        if env_file.exists():
            with open(env_file) as f:
                for line in f:
                    if '=' in line and not line.strip().startswith('#'):
                        key, value = line.strip().split('=', 1)
                        env[key] = value
        
        # Run the production login script
        result = subprocess.run([
            'python3', '/home/ufobeep/ufobeep/mufon_clicker/production_mufon_login.py'
        ], capture_output=True, text=True, cwd='/home/ufobeep/ufobeep/mufon_clicker', env=env)
        
        if result.returncode == 0:
            log("✅ MUFON authentication refreshed successfully")
            return True
        else:
            log(f"❌ Auth refresh failed: {result.stderr}")
            return False
            
    except Exception as e:
        log(f"❌ Error refreshing auth: {e}")
        return False

def extract_mufon_cases(date_str):
    """Extract MUFON cases for given date"""
    log(f"🔍 Extracting MUFON cases for {date_str}...")
    
    try:
        # Set environment variables from .env.mufon
        env = os.environ.copy()
        env_file = Path("/home/ufobeep/ufobeep/.env.mufon")
        if env_file.exists():
            with open(env_file) as f:
                for line in f:
                    if '=' in line and not line.strip().startswith('#'):
                        key, value = line.strip().split('=', 1)
                        env[key] = value
        
        # Run the working simple extraction script
        result = subprocess.run([
            'python3', '/home/ufobeep/ufobeep/mufon_clicker/mufon_simple_extraction.py', date_str
        ], capture_output=True, text=True, cwd='/home/ufobeep/ufobeep/mufon_clicker', env=env)
        
        if result.returncode == 0:
            # Look for the correct output file (mufon_simple_* not mufon_working_*)
            output_file = f"/home/ufobeep/ufobeep/mufon_clicker/mufon_simple_{date_str.replace('-', '_')}.json"
            if os.path.exists(output_file):
                # Check how many cases were extracted
                with open(output_file) as f:
                    data = json.load(f)
                    case_count = data.get('total_cases', len(data.get('cases', [])))
                    media_count = sum(len(case.get('media_files', [])) for case in data.get('cases', []))
                
                log(f"✅ Extracted {case_count} cases with {media_count} media files")
                return output_file
            else:
                log(f"⚠️  No output file created at {output_file}")
                return None
        else:
            log(f"❌ Extraction failed: {result.stderr}")
            return None
            
    except Exception as e:
        log(f"❌ Error extracting cases: {e}")
        return None

def import_mufon_cases(json_file_path):
    """Import MUFON cases to UFOBeep with media"""
    log(f"📤 Importing MUFON cases from {json_file_path}...")
    
    try:
        # Run the fixed import script
        result = subprocess.run([
            'python3', '/home/ufobeep/ufobeep/api/feeds/import_mufon_fixed.py', json_file_path
        ], capture_output=True, text=True, cwd='/home/ufobeep/ufobeep')
        
        if result.returncode == 0:
            # Parse the output to count imports
            output_lines = result.stdout.split('\n')
            import_line = [line for line in output_lines if "Import completed:" in line]
            if import_line:
                log(f"✅ {import_line[0].split('Import completed: ')[1]}")
                return True
            else:
                log("✅ Import completed successfully")
                return True
        else:
            log(f"❌ Import failed: {result.stderr}")
            return False
            
    except Exception as e:
        log(f"❌ Error importing cases: {e}")
        return False

def cleanup_old_files(days_to_keep=7):
    """Clean up old extraction files"""
    log(f"🧹 Cleaning up files older than {days_to_keep} days...")
    
    try:
        mufon_dir = Path("/home/ufobeep/ufobeep/mufon_clicker")
        cutoff_time = time.time() - (days_to_keep * 24 * 60 * 60)
        
        # Clean up old JSON files (both simple and working formats)
        for json_file in mufon_dir.glob("mufon_simple_*.json"):
            if json_file.stat().st_mtime < cutoff_time:
                json_file.unlink()
                log(f"🗑️  Removed old file: {json_file.name}")
        
        for json_file in mufon_dir.glob("mufon_working_*.json"):
            if json_file.stat().st_mtime < cutoff_time:
                json_file.unlink()
                log(f"🗑️  Removed old file: {json_file.name}")
        
        # Clean up old media files
        media_dir = mufon_dir / "mufon_media"
        if media_dir.exists():
            for media_file in media_dir.iterdir():
                if media_file.stat().st_mtime < cutoff_time:
                    media_file.unlink()
                    log(f"🗑️  Removed old media: {media_file.name}")
                    
    except Exception as e:
        log(f"⚠️  Error during cleanup: {e}")

def run_nightly_mufon_pipeline(date_override=None):
    """Main nightly pipeline function"""
    log("🚀 Starting MUFON Nightly Pipeline...")
    
    # Determine date to process
    if date_override:
        target_date = date_override
        log(f"📅 Processing override date: {target_date}")
    else:
        # Process yesterday's sightings (gives time for reports to be submitted)
        yesterday = datetime.now() - timedelta(days=1)
        target_date = yesterday.strftime("%Y-%m-%d")
        log(f"📅 Processing yesterday's sightings: {target_date}")
    
    # Step 1: Check and refresh authentication if needed
    if check_auth_expired():
        log("🔄 Authentication expired, refreshing...")
        if not refresh_mufon_auth():
            log("❌ Failed to refresh auth - aborting pipeline")
            return False
        
        # Wait a bit after auth refresh
        time.sleep(5)
    
    # Step 2: Extract MUFON cases for target date
    json_file = extract_mufon_cases(target_date)
    if not json_file:
        log(f"❌ No cases extracted for {target_date} - pipeline complete")
        return False
    
    # Step 3: Import cases to UFOBeep with media
    if not import_mufon_cases(json_file):
        log("❌ Import failed - pipeline incomplete")
        return False
    
    # Step 4: Cleanup old files
    cleanup_old_files()
    
    log("🎉 MUFON Nightly Pipeline completed successfully!")
    return True

if __name__ == "__main__":
    # Allow manual date override for testing
    if len(sys.argv) == 2:
        date_arg = sys.argv[1]
        success = run_nightly_mufon_pipeline(date_arg)
    else:
        success = run_nightly_mufon_pipeline()
    
    # Exit with proper code for cron monitoring
    sys.exit(0 if success else 1)