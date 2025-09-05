#!/usr/bin/env python3
"""
Clean alert deletion script - handles cascading deletes for alerts and associated data
Usage: 
  python delete_alerts.py --source mufon                    # Delete all MUFON alerts
  python delete_alerts.py --before 2025-08-01              # Delete alerts before date
  python delete_alerts.py --alert-id uuid                   # Delete specific alert
  python delete_alerts.py --dry-run --source mufon         # Preview what would be deleted
"""

import asyncio
import asyncpg
import argparse
import os
import sys
from datetime import datetime
from pathlib import Path
import uuid
import shutil

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'ufobeep_db',
    'user': 'ufobeep_user',
    'password': 'ufopostpass'
}

MEDIA_BASE_PATH = '/home/ufobeep/ufobeep/media'

class AlertCleaner:
    def __init__(self, dry_run=False, verbose=True):
        self.dry_run = dry_run
        self.verbose = verbose
        self.pool = None
        
    async def init_db(self):
        """Initialize database connection pool"""
        self.pool = await asyncpg.create_pool(**DB_CONFIG)
        
    async def close_db(self):
        """Close database connection pool"""
        if self.pool:
            await self.pool.close()
    
    def log(self, message, force=False):
        """Log message if verbose or forced"""
        if self.verbose or force:
            print(f"{'[DRY RUN] ' if self.dry_run else ''}{message}")
    
    async def get_alert_media_files(self, alert_id):
        """Get all media files associated with an alert"""
        async with self.pool.acquire() as conn:
            # Get media files from media_files table
            media_files = await conn.fetch("""
                SELECT id, url, filename 
                FROM media_files 
                WHERE sighting_id = $1
            """, alert_id)
            
            # Get photo metadata files
            photo_files = await conn.fetch("""
                SELECT id, file_path 
                FROM photo_metadata 
                WHERE sighting_id = $1
            """, alert_id)
            
            return media_files, photo_files
    
    async def delete_media_files(self, alert_id):
        """Delete media files from filesystem and database"""
        media_files, photo_files = await self.get_alert_media_files(alert_id)
        deleted_files = 0
        deleted_size = 0
        
        # Delete media files
        for file_record in media_files:
            url = file_record['url']
            filename = file_record['filename']
            # URL is typically just the filename for local files
            file_path = os.path.join(MEDIA_BASE_PATH, str(alert_id), filename) if filename else None
            if file_path and os.path.exists(file_path):
                try:
                    file_size = os.path.getsize(file_path)
                    if not self.dry_run:
                        os.remove(file_path)
                    self.log(f"  Deleted media file: {file_path} ({file_size} bytes)")
                    deleted_files += 1
                    deleted_size += file_size
                except Exception as e:
                    self.log(f"  Error deleting {file_path}: {e}")
        
        # Delete photo files
        for photo_record in photo_files:
            file_path = photo_record['file_path']
            if file_path and os.path.exists(file_path):
                try:
                    file_size = os.path.getsize(file_path)
                    if not self.dry_run:
                        os.remove(file_path)
                    self.log(f"  Deleted photo file: {file_path} ({file_size} bytes)")
                    deleted_files += 1
                    deleted_size += file_size
                except Exception as e:
                    self.log(f"  Error deleting {file_path}: {e}")
        
        # Check for alert media directory
        media_dir = os.path.join(MEDIA_BASE_PATH, str(alert_id))
        if os.path.exists(media_dir):
            try:
                # Calculate directory size
                dir_size = sum(os.path.getsize(os.path.join(dirpath, filename))
                             for dirpath, dirnames, filenames in os.walk(media_dir)
                             for filename in filenames)
                
                if not self.dry_run:
                    shutil.rmtree(media_dir)
                self.log(f"  Deleted media directory: {media_dir} ({dir_size} bytes)")
                deleted_size += dir_size
            except Exception as e:
                self.log(f"  Error deleting directory {media_dir}: {e}")
        
        return deleted_files, deleted_size
    
    async def delete_alert_cascade(self, alert_id):
        """Delete an alert and all associated data"""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                # Get alert info first
                alert = await conn.fetchrow("SELECT * FROM sightings WHERE id = $1", alert_id)
                if not alert:
                    self.log(f"Alert {alert_id} not found")
                    return False
                
                self.log(f"Deleting alert: {alert_id}")
                self.log(f"  Title: {alert.get('title', 'N/A')}")
                self.log(f"  Source: {alert.get('source', 'N/A')}")
                self.log(f"  Created: {alert.get('created_at', 'N/A')}")
                
                if not self.dry_run:
                    # Delete associated records in order (respecting foreign keys)
                    sighting_id_tables = [
                        'media_files',
                        'comments',
                        'follows',
                        'photo_metadata',
                        'photo_analysis_results'
                    ]
                    
                    # Delete records with sighting_id
                    for table in sighting_id_tables:
                        try:
                            deleted = await conn.execute(f"DELETE FROM {table} WHERE sighting_id = $1", alert_id)
                            count = int(deleted.split()[-1])
                            if count > 0:
                                self.log(f"  Deleted {count} records from {table}")
                        except Exception as e:
                            # Table might not exist or have different schema
                            pass
                    
                    # Delete the main sighting record
                    await conn.execute("DELETE FROM sightings WHERE id = $1", alert_id)
                    self.log(f"  Deleted main sighting record")
                
                # Delete media files
                deleted_files, deleted_size = await self.delete_media_files(alert_id)
                
                return True
    
    async def delete_alerts_by_source(self, source):
        """Delete all alerts from a specific source"""
        async with self.pool.acquire() as conn:
            alerts = await conn.fetch("SELECT id, title, created_at FROM sightings WHERE source = $1", source)
            
        if not alerts:
            self.log(f"No alerts found with source '{source}'")
            return 0, 0, 0
        
        self.log(f"Found {len(alerts)} alerts with source '{source}'")
        
        deleted_count = 0
        total_files = 0
        total_size = 0
        
        for alert in alerts:
            alert_id = alert['id']
            success = await self.delete_alert_cascade(alert_id)
            if success:
                deleted_count += 1
                # Note: file counting happens inside delete_alert_cascade
        
        return deleted_count, total_files, total_size
    
    async def delete_alerts_before_date(self, before_date):
        """Delete all alerts created before a specific date"""
        async with self.pool.acquire() as conn:
            alerts = await conn.fetch(
                "SELECT id, title, created_at FROM sightings WHERE created_at < $1", 
                before_date
            )
        
        if not alerts:
            self.log(f"No alerts found before {before_date}")
            return 0, 0, 0
        
        self.log(f"Found {len(alerts)} alerts before {before_date}")
        
        deleted_count = 0
        total_files = 0  
        total_size = 0
        
        for alert in alerts:
            alert_id = alert['id']
            success = await self.delete_alert_cascade(alert_id)
            if success:
                deleted_count += 1
        
        return deleted_count, total_files, total_size
    
    async def delete_alert_by_id(self, alert_id):
        """Delete a specific alert by ID"""
        try:
            alert_uuid = uuid.UUID(alert_id)
        except ValueError:
            self.log(f"Invalid alert ID format: {alert_id}", force=True)
            return 0, 0, 0
        
        success = await self.delete_alert_cascade(alert_uuid)
        return 1 if success else 0, 0, 0

async def main():
    parser = argparse.ArgumentParser(description='Clean alert deletion tool')
    parser.add_argument('--source', help='Delete alerts from specific source (e.g., mufon)')
    parser.add_argument('--before', help='Delete alerts before date (YYYY-MM-DD)')
    parser.add_argument('--alert-id', help='Delete specific alert by ID')
    parser.add_argument('--dry-run', action='store_true', help='Preview what would be deleted')
    parser.add_argument('--quiet', action='store_true', help='Minimize output')
    
    args = parser.parse_args()
    
    if not any([args.source, args.before, args.alert_id]):
        parser.error('Must specify one of: --source, --before, or --alert-id')
    
    cleaner = AlertCleaner(dry_run=args.dry_run, verbose=not args.quiet)
    
    try:
        await cleaner.init_db()
        
        deleted_count = 0
        total_files = 0
        total_size = 0
        
        if args.source:
            deleted_count, total_files, total_size = await cleaner.delete_alerts_by_source(args.source)
        elif args.before:
            try:
                before_date = datetime.strptime(args.before, '%Y-%m-%d')
                deleted_count, total_files, total_size = await cleaner.delete_alerts_before_date(before_date)
            except ValueError:
                cleaner.log(f"Invalid date format: {args.before}. Use YYYY-MM-DD", force=True)
                sys.exit(1)
        elif args.alert_id:
            deleted_count, total_files, total_size = await cleaner.delete_alert_by_id(args.alert_id)
        
        # Summary
        action = "Would delete" if args.dry_run else "Deleted"
        cleaner.log(f"\n{action}: {deleted_count} alerts", force=True)
        if total_size > 0:
            cleaner.log(f"Freed space: {total_size / (1024*1024):.1f} MB", force=True)
        
        if args.dry_run:
            cleaner.log("\nUse --dry-run=false to actually delete the data", force=True)
            
    except Exception as e:
        cleaner.log(f"Error: {e}", force=True)
        sys.exit(1)
    finally:
        await cleaner.close_db()

if __name__ == '__main__':
    asyncio.run(main())