from fastapi import APIRouter, HTTPException, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel, EmailStr
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from typing import Optional

router = APIRouter(prefix="/v1/emails", tags=["emails"])

class EmailInterestRequest(BaseModel):
    email: EmailStr
    source: Optional[str] = "app_download_page"

class EmailInterestResponse(BaseModel):
    success: bool
    message: str
    id: Optional[int] = None

def get_db_connection():
    """Get database connection using environment settings"""
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="ufobeep_db",
            user="ufobeep_user",
            password="ufopostpass"
        )
        return conn
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")

@router.post("/interest")
async def submit_email_interest_form(
    email: str = Form(...),
    source: str = Form(default="app_download_page")
):
    """
    Handle form submission for email interest - returns JSON for frontend
    """
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Try to insert the email
        cur.execute(
            """
            INSERT INTO email_interests (email, source) 
            VALUES (%s, %s) 
            RETURNING id
            """,
            (email, source)
        )
        
        result = cur.fetchone()
        conn.commit()
        
        cur.close()
        conn.close()
        
        return JSONResponse(content={
            "success": True,
            "message": "Thanks! We'll notify you when the app launches.",
            "id": result['id']
        })
        
    except psycopg2.errors.UniqueViolation:
        # Email already exists
        return JSONResponse(content={
            "success": True,
            "message": "You're already on our list! We'll notify you when the app launches."
        })
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "success": False,
                "error": f"Failed to save email interest: {str(e)}"
            }
        )

@router.get("/interest/count")
async def get_interest_count():
    """
    Get count of interested users (for admin use)
    """
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("SELECT COUNT(*) FROM email_interests")
        count = cur.fetchone()[0]
        
        cur.close()
        conn.close()
        
        return {"count": count}
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get interest count: {str(e)}"
        )