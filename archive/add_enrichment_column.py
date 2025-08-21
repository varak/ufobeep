#!/usr/bin/env python3
"""
Database migration script to add enrichment_data column to production database
"""
import asyncpg
import asyncio

async def add_enrichment_column():
    """Add enrichment_data column to sightings table"""
    try:
        # Connect to production database
        conn = await asyncpg.connect(
            host="localhost",
            port=5432,
            user="ufobeep_user",
            password="ufopostpass",
            database="ufobeep_db"
        )
        
        print("Connected to database successfully")
        
        # Check if column already exists
        column_exists = await conn.fetchval("""
            SELECT COUNT(*) 
            FROM information_schema.columns 
            WHERE table_name = 'sightings' 
            AND column_name = 'enrichment_data'
        """)
        
        if column_exists > 0:
            print("enrichment_data column already exists")
        else:
            # Add the enrichment_data column
            await conn.execute("""
                ALTER TABLE sightings 
                ADD COLUMN enrichment_data JSONB
            """)
            print("Successfully added enrichment_data column")
        
        # Verify the column was added
        columns = await conn.fetch("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'sightings'
            ORDER BY ordinal_position
        """)
        
        print("\nCurrent sightings table structure:")
        for col in columns:
            print(f"  {col['column_name']}: {col['data_type']}")
        
        await conn.close()
        print("\nDatabase migration completed successfully!")
        
    except Exception as e:
        print(f"Error during migration: {e}")
        return False
    
    return True

if __name__ == "__main__":
    result = asyncio.run(add_enrichment_column())
    if result:
        print("Migration successful!")
    else:
        print("Migration failed!")