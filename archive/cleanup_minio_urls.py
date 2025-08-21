#!/usr/bin/env python3
"""
Script to clean up old MinIO URLs from the database.
Either updates them to new format or removes alerts with old URLs.
"""

import psycopg2
import json
from urllib.parse import urlparse

# Database connection
conn = psycopg2.connect(
    host="localhost",
    database="ufobeep_db", 
    user="ufobeep_user",
    password="ufopostpass"
)
cur = conn.cursor()

print("🔍 Finding alerts with old MinIO URLs...")

# Find alerts with old MinIO URLs
cur.execute("""
    SELECT s.id, s.title, s.created_at, ap.id as photo_id, ap.url, ap.thumbnail_url
    FROM sightings s
    JOIN alert_photos ap ON s.id = ap.sighting_id
    WHERE ap.url LIKE '%ufobeep.com:9000%' OR ap.url LIKE '%minio%'
    ORDER BY s.created_at DESC
""")

old_alerts = cur.fetchall()

print(f"📊 Found {len(old_alerts)} media files with old MinIO URLs")

if len(old_alerts) == 0:
    print("✅ No old MinIO URLs found!")
    conn.close()
    exit(0)

print("\n🗑️ Old alerts found:")
for alert in old_alerts:
    sighting_id, title, created_at, media_id, url, thumbnail_url = alert
    print(f"  - {created_at}: {title[:50]}...")
    print(f"    URL: {url[:80]}...")

# Ask user what to do
print(f"\n❓ What would you like to do with these {len(old_alerts)} old alerts?")
print("1. Delete alerts with old MinIO URLs (recommended)")
print("2. Show details and decide individually") 
print("3. Cancel")

choice = input("Enter choice (1-3): ").strip()

if choice == "1":
    print(f"\n🗑️ Deleting {len(old_alerts)} alerts with old MinIO URLs...")
    
    # Get unique sighting IDs
    sighting_ids = list(set(alert[0] for alert in old_alerts))
    
    for sighting_id in sighting_ids:
        # Delete alert photos first (foreign key constraint)
        cur.execute("DELETE FROM alert_photos WHERE sighting_id = %s", (sighting_id,))
        # Delete sighting
        cur.execute("DELETE FROM sightings WHERE id = %s", (sighting_id,))
        print(f"  ✅ Deleted sighting {sighting_id}")
    
    conn.commit()
    print(f"\n✅ Successfully deleted {len(sighting_ids)} alerts with old MinIO URLs")
    
elif choice == "2":
    print("\n📋 Detailed view:")
    for i, alert in enumerate(old_alerts, 1):
        sighting_id, title, created_at, media_id, url, thumbnail_url = alert
        print(f"\n{i}. Sighting ID: {sighting_id}")
        print(f"   Title: {title}")
        print(f"   Created: {created_at}")
        print(f"   URL: {url}")
        
        delete = input(f"   Delete this alert? (y/N): ").strip().lower()
        if delete == 'y':
            cur.execute("DELETE FROM alert_photos WHERE sighting_id = %s", (sighting_id,))
            cur.execute("DELETE FROM sightings WHERE id = %s", (sighting_id,))
            print(f"   ✅ Deleted sighting {sighting_id}")
        else:
            print(f"   ⏭️ Skipped sighting {sighting_id}")
    
    conn.commit()
    print("\n✅ Cleanup completed")
    
else:
    print("❌ Cancelled")

# Show remaining count
cur.execute("""
    SELECT COUNT(*)
    FROM sightings s
    JOIN alert_photos ap ON s.id = ap.sighting_id
    WHERE ap.url LIKE '%ufobeep.com:9000%' OR ap.url LIKE '%minio%'
""")
remaining = cur.fetchone()[0]

print(f"\n📊 Remaining alerts with old URLs: {remaining}")

conn.close()
print("🎉 Database cleanup completed!")