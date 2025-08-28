#!/usr/bin/env python3
"""Delete corrupted user from database"""
from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv()

# Use the production database URL
DATABASE_URL = "postgresql://postgres:Beeper2023!@107.152.35.6:5432/ufobeep"

engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    # First check if user exists
    result = conn.execute(text("""
        SELECT id, username, email, google_id 
        FROM users 
        WHERE LOWER(email) = LOWER(:email)
    """), {"email": "wipodotcom@gmail.com"})
    
    user = result.fetchone()
    
    if user:
        print(f"Found user: {dict(user)}")
        
        # Delete the user
        conn.execute(text("""
            DELETE FROM users 
            WHERE LOWER(email) = LOWER(:email)
        """), {"email": "wipodotcom@gmail.com"})
        
        conn.commit()
        print("✅ User deleted successfully!")
    else:
        print("❌ No user found with email wipodotcom@gmail.com")