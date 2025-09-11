#!/usr/bin/env python3
"""
Populate short_url column for existing sightings
"""
import asyncpg
import asyncio

def get_short_hash_py(input_str):
    if not input_str:
        return ''
    SAFE_CHARS = '23456789abcdefghjkmnpqrstuvwxyz'
    hash_val = 0
    for char in input_str:
        hash_val = ((hash_val << 5) - hash_val) + ord(char)
        hash_val = hash_val & 0xFFFFFFFF  # Keep as 32-bit
    
    short_id = ''
    num = abs(hash_val)
    for i in range(5):
        short_id = SAFE_CHARS[num % len(SAFE_CHARS)] + short_id
        num = num // len(SAFE_CHARS)
    return short_id

async def populate_short_urls():
    # Connect to database
    conn = await asyncpg.connect(
        host='localhost',
        database='ufobeep_db',
        user='ufobeep_user',
        password='ufopostpass'
    )
    
    try:
        # Get all sightings without short_url
        rows = await conn.fetch("SELECT id FROM sightings WHERE short_url IS NULL")
        print(f"Found {len(rows)} sightings to update")
        
        # Update each one
        for row in rows:
            sighting_id = str(row['id'])
            short_url = get_short_hash_py(sighting_id)
            await conn.execute(
                "UPDATE sightings SET short_url = $1 WHERE id = $2",
                short_url, row['id']
            )
            print(f"Updated {sighting_id} -> {short_url}")
        
        print(f"Successfully updated {len(rows)} sightings")
        
    finally:
        await conn.close()

if __name__ == '__main__':
    asyncio.run(populate_short_urls())