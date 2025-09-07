#!/usr/bin/env python3
"""
Fix occurred_at field for existing MUFON records.
This script extracts the actual sighting datetime from enrichment_data
and updates the occurred_at column in the database.
"""

import asyncio
import asyncpg
import json
from datetime import datetime, timezone

async def main():
    # Connect to database
    conn = await asyncpg.connect(
        host="localhost",
        database="ufobeep_db", 
        user="ufobeep_user",
        password="ufopostpass"
    )
    
    # Get all MUFON records with their enrichment data
    records = await conn.fetch("""
        SELECT id, enrichment_data 
        FROM sightings 
        WHERE source = 'mufon' AND is_public = true
    """)
    
    print(f"Found {len(records)} MUFON records to process")
    
    updated_count = 0
    failed_count = 0
    
    for record in records:
        sighting_id = record['id']
        enrichment_raw = record['enrichment_data']
        
        # Parse enrichment_data JSON
        try:
            enrichment_data = json.loads(enrichment_raw) if enrichment_raw else {}
        except (json.JSONDecodeError, TypeError):
            enrichment_data = {}
        
        # Extract sighting_datetime from enrichment_data
        sighting_datetime = enrichment_data.get('sighting_datetime')
        
        if not sighting_datetime:
            print(f"⚠️ Skipping {sighting_id}: no sighting_datetime in enrichment_data")
            failed_count += 1
            continue
            
        try:
            # Parse the sighting datetime - MUFON format: "2025-09-07\n6:48AM"
            clean_datetime = sighting_datetime.replace('\n', ' ').strip()
            
            # Try different parsing approaches
            parsed_dt = None
            try:
                # Try "YYYY-MM-DD HH:MMAM/PM" format
                parsed_dt = datetime.strptime(clean_datetime, "%Y-%m-%d %I:%M%p")
            except ValueError:
                try:
                    # Try "YYYY-MM-DD H:MMAM/PM" format (single digit hour)
                    parsed_dt = datetime.strptime(clean_datetime, "%Y-%m-%d %I:%M%p") 
                except ValueError:
                    try:
                        # Try just the date if time parsing fails
                        parsed_dt = datetime.strptime(clean_datetime.split()[0], "%Y-%m-%d")
                    except ValueError:
                        print(f"⚠️ Failed to parse datetime '{sighting_datetime}' for {sighting_id}")
                        failed_count += 1
                        continue
            
            # Convert to UTC timezone
            occurred_at_utc = parsed_dt.replace(tzinfo=timezone.utc)
            
            # Update the occurred_at column
            await conn.execute("""
                UPDATE sightings 
                SET occurred_at = $1
                WHERE id = $2
            """, occurred_at_utc, sighting_id)
            
            # Also update enrichment_data to include the proper occurred_at ISO timestamp
            enrichment_data['occurred_at'] = occurred_at_utc.isoformat()
            await conn.execute("""
                UPDATE sightings 
                SET enrichment_data = $1
                WHERE id = $2
            """, json.dumps(enrichment_data), sighting_id)
            
            print(f"✅ Updated {sighting_id}: '{sighting_datetime}' -> {occurred_at_utc.isoformat()}")
            updated_count += 1
            
        except Exception as e:
            print(f"❌ Error processing {sighting_id}: {e}")
            failed_count += 1
    
    await conn.close()
    
    print(f"\n📊 RESULTS:")
    print(f"   ✅ Updated: {updated_count} records")
    print(f"   ❌ Failed: {failed_count} records")
    print(f"   📈 Total: {len(records)} records")

if __name__ == "__main__":
    asyncio.run(main())