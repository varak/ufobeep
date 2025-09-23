#!/usr/bin/env python3
"""
GDPR User Data Export Script
Exports comprehensive user data for legal compliance

Production Usage:
  ssh -p 322 ufobeep@ufobeep.com
  cd /home/ufobeep/ufobeep
  python3 export_user_data.py <username_or_user_id>

Examples:
  python3 export_user_data.py "vibrant.passage.2705"
  python3 export_user_data.py "49b60afc-284b-4c7b-aa2b-519d5aa2bf58"

Output: Creates comprehensive JSON and CSV exports for GDPR compliance
"""

import asyncpg
import asyncio
import json
import csv
import sys
import os
from datetime import datetime

async def export_user_data(target):
    """Export comprehensive user data following GDPR requirements"""

    # Database connection
    conn = await asyncpg.connect(
        host='localhost',
        port=5432,
        database='ufobeep_db',
        user='ufobeep_user',
        password='ufopostpass'
    )

    try:
        # Find user by username or ID
        if len(target) == 36 and '-' in target:  # Looks like UUID
            user_query = "SELECT * FROM users WHERE id = $1"
        else:
            user_query = "SELECT * FROM users WHERE username = $1"

        user_data = await conn.fetchrow(user_query, target)

        if not user_data:
            print(f"❌ User not found: {target}")
            return

        user_id = user_data['id']
        username = user_data['username']

        print(f"📊 Exporting comprehensive data for user: {username}")

        # Get user's sightings
        sightings = await conn.fetch("""
            SELECT id, title, description, category, witness_count, is_public,
                   tags, media_info, sensor_data, alert_level, status,
                   created_at, updated_at, enrichment_data, reporter_id,
                   firebase_uid, source
            FROM sightings WHERE reporter_id = $1
        """, user_id)

        # Get user's comments
        comments = await conn.fetch("""
            SELECT c.id, c.body, c.created_at, c.sighting_id, c.media_url,
                   s.title as sighting_title
            FROM comments c
            LEFT JOIN sightings s ON c.sighting_id = s.id
            WHERE c.user_id = $1
        """, user_id)

        # Get user's devices
        devices = await conn.fetch("""
            SELECT device_id, platform, push_token, app_version, os_version,
                   device_model, manufacturer, push_enabled, is_active,
                   last_seen, timezone, locale, created_at, updated_at,
                   lat, lon, alert_range_km
            FROM devices WHERE user_id = $1
        """, user_id)

        # Get user's follows
        follows = await conn.fetch("""
            SELECT f.sighting_id, f.created_at, s.title as sighting_title
            FROM follows f
            LEFT JOIN sightings s ON f.sighting_id = s.id
            WHERE f.user_id = $1
        """, user_id)

        # Get user's media files
        media_files = await conn.fetch("""
            SELECT id, filename, file_type, file_size, s3_key, sighting_id, created_at
            FROM media_files WHERE uploaded_by = $1
        """, user_id)

        # Prepare comprehensive export
        export_data = {
            "export_metadata": {
                "generated_at": datetime.now().isoformat(),
                "user_id": str(user_id),
                "username": username,
                "export_version": "1.0",
                "export_type": "comprehensive_gdpr",
                "total_beeps": len(sightings),
                "total_comments": len(comments),
                "total_follows": len(follows),
                "total_devices": len(devices),
                "total_media_files": len(media_files)
            },
            "user_profile": dict(user_data),
            "beeps": [dict(s) for s in sightings],
            "comments": [dict(c) for c in comments],
            "devices": [dict(d) for d in devices],
            "follows": [dict(f) for f in follows],
            "media_files": [dict(m) for m in media_files]
        }

        # Convert datetime objects to strings for JSON serialization
        def serialize_datetime(obj):
            if hasattr(obj, 'isoformat'):
                return obj.isoformat()
            return str(obj)

        # Create JSON export
        json_filename = f"user_export_{username}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(json_filename, 'w') as f:
            json.dump(export_data, f, indent=2, default=serialize_datetime)

        # Create CSV export
        csv_filename = f"user_export_{username}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
        with open(csv_filename, 'w', newline='') as f:
            writer = csv.writer(f)

            # Export metadata
            writer.writerow(["=== EXPORT METADATA ==="])
            for key, value in export_data["export_metadata"].items():
                writer.writerow([key, str(value)])

            writer.writerow([])
            writer.writerow(["=== USER PROFILE ==="])
            for key, value in export_data["user_profile"].items():
                writer.writerow([key, str(value) if value is not None else ""])

            writer.writerow([])
            writer.writerow(["=== BEEPS/SIGHTINGS ==="])
            if export_data["beeps"]:
                headers = list(export_data["beeps"][0].keys())
                writer.writerow(headers)
                for beep in export_data["beeps"]:
                    writer.writerow([serialize_datetime(beep[h]) if beep[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== COMMENTS ==="])
            if export_data["comments"]:
                headers = list(export_data["comments"][0].keys())
                writer.writerow(headers)
                for comment in export_data["comments"]:
                    writer.writerow([serialize_datetime(comment[h]) if comment[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== DEVICES ==="])
            if export_data["devices"]:
                headers = list(export_data["devices"][0].keys())
                writer.writerow(headers)
                for device in export_data["devices"]:
                    writer.writerow([serialize_datetime(device[h]) if device[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== FOLLOWS ==="])
            if export_data["follows"]:
                headers = list(export_data["follows"][0].keys())
                writer.writerow(headers)
                for follow in export_data["follows"]:
                    writer.writerow([serialize_datetime(follow[h]) if follow[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== MEDIA FILES ==="])
            if export_data["media_files"]:
                headers = list(export_data["media_files"][0].keys())
                writer.writerow(headers)
                for media in export_data["media_files"]:
                    writer.writerow([serialize_datetime(media[h]) if media[h] is not None else "" for h in headers])

        # Summary
        print(f"✅ Export completed for user {username}")
        print(f"📄 JSON export: {json_filename}")
        print(f"📊 CSV export: {csv_filename}")
        print(f"📋 Summary:")
        print(f"   • {len(sightings)} sightings/beeps")
        print(f"   • {len(comments)} comments")
        print(f"   • {len(devices)} devices")
        print(f"   • {len(follows)} follows")
        print(f"   • {len(media_files)} media files")

    finally:
        await conn.close()

async def main():
    if len(sys.argv) != 2:
        print("Usage: python3 export_user_data.py <username_or_user_id>")
        print("Examples:")
        print("  python3 export_user_data.py 'vibrant.passage.2705'")
        print("  python3 export_user_data.py '49b60afc-284b-4c7b-aa2b-519d5aa2bf58'")
        sys.exit(1)

    target = sys.argv[1]
    await export_user_data(target)

if __name__ == '__main__':
    asyncio.run(main())