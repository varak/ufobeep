#!/usr/bin/env python3
"""
Proper API-based admin deletion tool
Replaces the sloppy delete_user_beeps.py that used direct database manipulation
"""
import requests
import argparse
import sys
from getpass import getpass
import time

class AdminDeletionTool:
    def __init__(self, base_url="http://localhost:8000", username="admin", password=None):
        self.base_url = base_url.rstrip('/')
        self.auth = (username, password) if password else None
        self.session = requests.Session()
        
    def authenticate(self):
        """Prompt for admin password if not provided"""
        if not self.auth:
            username = input("Admin username (default: admin): ") or "admin"
            password = getpass("Admin password: ")
            self.auth = (username, password)
    
    def delete_sighting(self, sighting_id, dry_run=False):
        """Delete a single sighting via API"""
        if dry_run:
            print(f"[DRY RUN] Would delete sighting: {sighting_id}")
            return {"success": True, "dry_run": True}
        
        try:
            url = f"{self.base_url}/admin/sighting/{sighting_id}"
            response = self.session.delete(url, auth=self.auth)
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    details = result.get('details', {})
                    print(f"✅ Deleted sighting {sighting_id}")
                    print(f"   Records: {details.get('deleted_records', {})}")
                    print(f"   Files: {details.get('deleted_files', 0)}")
                    print(f"   Space freed: {details.get('freed_mb', 0)} MB")
                    return result
                else:
                    print(f"❌ Failed to delete sighting {sighting_id}: {result}")
                    return {"success": False, "error": result}
            else:
                error_msg = response.text
                print(f"❌ API error deleting sighting {sighting_id}: {response.status_code} - {error_msg}")
                return {"success": False, "error": f"HTTP {response.status_code}: {error_msg}"}
                
        except Exception as e:
            print(f"❌ Exception deleting sighting {sighting_id}: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def delete_reporter_sightings(self, reporter_id, dry_run=False):
        """Delete all sightings from a reporter via API"""
        if dry_run:
            print(f"[DRY RUN] Would delete all sightings from reporter: {reporter_id}")
            return {"success": True, "dry_run": True}
        
        try:
            url = f"{self.base_url}/admin/reporter/{reporter_id}"
            response = self.session.delete(url, auth=self.auth)
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    details = result.get('details', {})
                    print(f"✅ Processed reporter {reporter_id}")
                    print(f"   Found sightings: {details.get('found_sightings', 0)}")
                    print(f"   Deleted count: {details.get('deleted_count', 0)}")
                    print(f"   Total records: {details.get('deleted_records', {})}")
                    print(f"   Files deleted: {details.get('deleted_files', 0)}")
                    print(f"   Space freed: {details.get('freed_mb', 0)} MB")
                    return result
                else:
                    print(f"❌ Failed to delete reporter {reporter_id} sightings: {result}")
                    return {"success": False, "error": result}
            else:
                error_msg = response.text
                print(f"❌ API error deleting reporter {reporter_id}: {response.status_code} - {error_msg}")
                return {"success": False, "error": f"HTTP {response.status_code}: {error_msg}"}
                
        except Exception as e:
            print(f"❌ Exception deleting reporter {reporter_id}: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def test_connection(self):
        """Test API connection and authentication"""
        try:
            url = f"{self.base_url}/admin/"
            response = self.session.get(url, auth=self.auth)
            
            if response.status_code == 200:
                print(f"✅ Connected to API at {self.base_url}")
                return True
            else:
                print(f"❌ Connection failed: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Connection error: {str(e)}")
            return False

def main():
    parser = argparse.ArgumentParser(description='Admin deletion tool using proper API endpoints')
    parser.add_argument('--reporter-id', help='Delete all sightings from specific reporter')
    parser.add_argument('--sighting-id', help='Delete specific sighting by ID')
    parser.add_argument('--dry-run', action='store_true', help='Preview what would be deleted')
    parser.add_argument('--api-url', default='http://localhost:8000', help='API base URL')
    parser.add_argument('--username', default='admin', help='Admin username')
    parser.add_argument('--password', help='Admin password (will prompt if not provided)')
    
    args = parser.parse_args()
    
    if not any([args.reporter_id, args.sighting_id]):
        parser.error('Must specify either --reporter-id or --sighting-id')
    
    # Create deletion tool
    tool = AdminDeletionTool(
        base_url=args.api_url,
        username=args.username,
        password=args.password
    )
    
    # Authenticate if needed
    tool.authenticate()
    
    # Test connection
    print(f"🔧 Testing connection to {args.api_url}...")
    if not tool.test_connection():
        print("❌ Cannot connect to API. Please check URL and credentials.")
        sys.exit(1)
    
    # Perform deletion
    if args.dry_run:
        print("🔍 DRY RUN MODE - No actual deletions will be performed")
    
    success = True
    
    if args.reporter_id:
        print(f"🗑️ Deleting all sightings from reporter: {args.reporter_id}")
        result = tool.delete_reporter_sightings(args.reporter_id, dry_run=args.dry_run)
        success = result.get('success', False)
        
    elif args.sighting_id:
        print(f"🗑️ Deleting sighting: {args.sighting_id}")
        result = tool.delete_sighting(args.sighting_id, dry_run=args.dry_run)
        success = result.get('success', False)
    
    if success:
        print("✅ Operation completed successfully")
        sys.exit(0)
    else:
        print("❌ Operation failed")
        sys.exit(1)

if __name__ == '__main__':
    main()