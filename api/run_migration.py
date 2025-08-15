#!/usr/bin/env python3
"""
Database migration runner
"""
import asyncio
import asyncpg
from pathlib import Path

async def run_migration():
    """Run database migration"""
    print("Connecting to database...")
    
    # Connect to database
    conn = await asyncpg.connect(
        host="localhost",
        port=5432,
        user="ufobeep_user", 
        password="ufopostpass",
        database="ufobeep_db"
    )
    
    try:
        # Read migration file
        migration_path = Path("migrations/001_add_media_primary_fields.sql")
        migration_sql = migration_path.read_text()
        
        print(f"Running migration: {migration_path}")
        
        # Execute migration (split by semicolon to handle multiple statements)
        statements = [stmt.strip() for stmt in migration_sql.split(';') if stmt.strip()]
        
        for i, statement in enumerate(statements, 1):
            if statement.strip():
                print(f"Executing statement {i}/{len(statements)}...")
                await conn.execute(statement)
        
        print("✅ Migration completed successfully!")
        
        # Verify results
        print("\nVerifying migration results...")
        
        # Check if new columns exist
        columns_result = await conn.fetch("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'media_files' 
            AND column_name IN ('is_primary', 'uploaded_by_user_id', 'upload_order', 'display_priority', 'contributed_at')
            ORDER BY column_name;
        """)
        
        if columns_result:
            print("New columns added:")
            for row in columns_result:
                print(f"  - {row['column_name']}: {row['data_type']} (nullable: {row['is_nullable']})")
        else:
            print("❌ No new columns found")
            
        # Check indexes
        indexes_result = await conn.fetch("""
            SELECT indexname, indexdef
            FROM pg_indexes 
            WHERE tablename = 'media_files' 
            AND indexname LIKE '%primary%' OR indexname LIKE '%priority%'
            ORDER BY indexname;
        """)
        
        if indexes_result:
            print("\nIndexes created:")
            for row in indexes_result:
                print(f"  - {row['indexname']}")
        
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        raise
    finally:
        await conn.close()

if __name__ == "__main__":
    asyncio.run(run_migration())