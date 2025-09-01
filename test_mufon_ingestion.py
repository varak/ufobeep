#!/usr/bin/env python3
import asyncio
import asyncpg
import sys
import os

# Add api to path
sys.path.append('api')

from api.feeds.ingest_alert_events import ingest_mufon

async def test_mufon_ingestion():
    """Test MUFON authenticated ingestion"""
    
    # Connect to production database
    try:
        pool = await asyncpg.create_pool(
            host="localhost",
            port=5432,
            user="ufobeep_user", 
            password="ufopostpass",
            database="ufobeep_db",
            min_size=1,
            max_size=3
        )
        
        print("🔄 Starting MUFON authenticated ingestion...")
        
        # Run the ingestion
        inserted_count = await ingest_mufon(pool)
        
        print(f"✅ Successfully inserted {inserted_count} MUFON reports")
        
        # Show some sample data
        async with pool.acquire() as conn:
            recent_mufon = await conn.fetch("""
                SELECT event_id, source, description, latitude, longitude, 
                       created_at, ingested_at, external_url
                FROM alert_events 
                WHERE source = 'mufon_auth'
                ORDER BY ingested_at DESC 
                LIMIT 5
            """)
            
            print(f"\n📊 Sample MUFON reports added:")
            for i, record in enumerate(recent_mufon, 1):
                print(f"\n--- Report {i} ---")
                print(f"ID: {record['event_id']}")
                print(f"Description: {record['description'][:100]}...")
                print(f"Location: {record['latitude']}, {record['longitude']}")
                print(f"Sighting Date: {record['created_at']}")
                print(f"Added to DB: {record['ingested_at']}")
                if record['external_url']:
                    print(f"Source: {record['external_url']}")
        
        await pool.close()
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_mufon_ingestion())