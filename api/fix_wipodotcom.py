#!/usr/bin/env python3
"""
Fix corrupted wipodotcom@gmail.com user by deleting it
so it can be recreated properly on next login
"""
import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://postgres:Beeper2023!@107.152.35.6:5432/ufobeep')

async def fix_user():
    print("Connecting to database...")
    conn = await asyncpg.connect(DATABASE_URL)
    
    try:
        # Check if user exists
        print("Checking for wipodotcom@gmail.com user...")
        user = await conn.fetchrow("""
            SELECT id, username, email, google_id, created_at 
            FROM users 
            WHERE LOWER(email) = LOWER('wipodotcom@gmail.com')
        """)
        
        if user:
            print(f"Found user:")
            print(f"  ID: {user['id']}")
            print(f"  Username: {user['username']}")
            print(f"  Email: {user['email']}")
            print(f"  Google ID: {user['google_id']}")
            print(f"  Created: {user['created_at']}")
            
            # Delete the user
            print("\nDeleting corrupted user...")
            await conn.execute("""
                DELETE FROM users 
                WHERE LOWER(email) = LOWER('wipodotcom@gmail.com')
            """)
            print("✅ User deleted successfully!")
            print("The user will be recreated with proper username on next login.")
        else:
            print("❌ No user found with email wipodotcom@gmail.com")
            
    finally:
        await conn.close()
        print("Database connection closed.")

if __name__ == "__main__":
    asyncio.run(fix_user())