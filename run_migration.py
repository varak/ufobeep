#!/usr/bin/env python3
import asyncpg
import asyncio

async def run_migration():
    # Connect to the database
    conn = await asyncpg.connect(
        host="localhost",
        port=5432,
        user="ufobeep_user",
        password="ufopostpass",
        database="ufobeep_db"
    )
    
    try:
        # Read the migration file
        with open('api/migrations/20250901_add_feed_fields.sql', 'r') as f:
            sql = f.read()
        
        # Execute the migration
        await conn.execute(sql)
        print("✅ Migration completed successfully!")
        
    except Exception as e:
        print(f"❌ Migration failed: {e}")
    finally:
        await conn.close()

if __name__ == "__main__":
    asyncio.run(run_migration())