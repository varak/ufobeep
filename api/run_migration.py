#!/usr/bin/env python3
"""
Database migration runner for UFOBeep
Runs Alembic migrations for schema updates
"""
import os
import sys
import asyncio
from pathlib import Path

# Add app directory to Python path
sys.path.insert(0, str(Path(__file__).parent / 'app'))

async def run_migration():
    """Run database migration using Alembic"""
    print("🔄 UFOBeep Database Migration Runner")
    print("=====================================")
    
    try:
        # Change to api directory
        api_dir = Path(__file__).parent
        os.chdir(api_dir)
        
        # Check if alembic is available
        try:
            import alembic
            from alembic.config import Config
            from alembic import command
            print("✅ Alembic found")
        except ImportError:
            print("❌ Alembic not found, trying to install...")
            os.system("pip install alembic")
            try:
                import alembic
                from alembic.config import Config
                from alembic import command
                print("✅ Alembic installed successfully")
            except ImportError:
                print("❌ Failed to install Alembic")
                return False
        
        # Check for alembic.ini
        alembic_ini = api_dir / "alembic.ini"
        if not alembic_ini.exists():
            print(f"❌ alembic.ini not found at {alembic_ini}")
            print("Creating basic alembic.ini...")
            
            alembic_ini_content = f"""[alembic]
script_location = alembic
sqlalchemy.url = postgresql://ufobeep_user:ufopostpass@localhost/ufobeep_db
file_template = %%(year)d%%(month).2d%%(day).2d_%%H%%M%%S_%%(rev)s_%%(slug)s
timezone = UTC

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
"""
            alembic_ini.write_text(alembic_ini_content)
            print("✅ alembic.ini created")
        
        # Run migration
        print("\n🚀 Running Alembic migration...")
        
        alembic_cfg = Config(str(alembic_ini))
        command.upgrade(alembic_cfg, "head")
        
        print("✅ Migration completed successfully!")
        
        # Verify magic_links table structure
        print("\n🔍 Verifying magic_links table structure...")
        
        try:
            import asyncpg
            
            conn = await asyncpg.connect(
                host="localhost",
                port=5432,
                user="ufobeep_user", 
                password="ufopostpass",
                database="ufobeep_db"
            )
            
            # Check magic_links columns
            columns_result = await conn.fetch("""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'magic_links' 
                ORDER BY ordinal_position;
            """)
            
            if columns_result:
                print("Magic links table columns:")
                for row in columns_result:
                    print(f"  - {row['column_name']}: {row['data_type']} (nullable: {row['is_nullable']})")
            
            await conn.close()
            
        except Exception as e:
            print(f"⚠️  Could not verify table structure: {e}")
        
        return True
        
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = asyncio.run(run_migration())
    sys.exit(0 if success else 1)