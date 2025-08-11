from fastapi import FastAPI, HTTPException, Form
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
from psycopg2.extras import RealDictCursor
from pydantic import BaseModel, EmailStr

app = FastAPI(title="UFOBeep Email Interest API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

def get_db_connection():
    """Get database connection"""
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

@app.get("/")
def root():
    return {"message": "UFOBeep Email Interest API"}

@app.post("/api/v1/emails/interest", response_class=HTMLResponse)
async def submit_email_interest_form(
    email: str = Form(...),
    source: str = Form(default="app_download_page")
):
    """
    Handle form submission for email interest
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
        
        # Return success HTML page
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Thanks for Your Interest!</title>
            <style>
                body {{
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: #0a0a0a;
                    color: #e5e5e5;
                    margin: 0;
                    padding: 0;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }}
                .container {{
                    text-align: center;
                    max-width: 500px;
                    padding: 40px 20px;
                }}
                .icon {{
                    font-size: 64px;
                    margin-bottom: 20px;
                }}
                h1 {{
                    color: #3b82f6;
                    margin-bottom: 16px;
                    font-size: 2rem;
                }}
                p {{
                    color: #9ca3af;
                    margin-bottom: 20px;
                    line-height: 1.6;
                }}
                .email {{
                    color: #3b82f6;
                    font-weight: 600;
                }}
                .back-link {{
                    display: inline-block;
                    margin-top: 20px;
                    color: #3b82f6;
                    text-decoration: none;
                    padding: 10px 20px;
                    border: 1px solid #3b82f6;
                    border-radius: 8px;
                    transition: all 0.3s ease;
                }}
                .back-link:hover {{
                    background: #3b82f6;
                    color: white;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="icon">🎉</div>
                <h1>Thanks for Your Interest!</h1>
                <p>We've successfully added <span class="email">{email}</span> to our notification list.</p>
                <p>You'll be among the first to know when the UFOBeep mobile app launches!</p>
                <a href="/app" class="back-link">← Back to App Page</a>
            </div>
        </body>
        </html>
        """, status_code=200)
        
    except psycopg2.errors.UniqueViolation:
        # Email already exists
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Already Registered!</title>
            <style>
                body {{
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: #0a0a0a;
                    color: #e5e5e5;
                    margin: 0;
                    padding: 0;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }}
                .container {{
                    text-align: center;
                    max-width: 500px;
                    padding: 40px 20px;
                }}
                .icon {{
                    font-size: 64px;
                    margin-bottom: 20px;
                }}
                h1 {{
                    color: #f59e0b;
                    margin-bottom: 16px;
                    font-size: 2rem;
                }}
                p {{
                    color: #9ca3af;
                    margin-bottom: 20px;
                    line-height: 1.6;
                }}
                .email {{
                    color: #f59e0b;
                    font-weight: 600;
                }}
                .back-link {{
                    display: inline-block;
                    margin-top: 20px;
                    color: #3b82f6;
                    text-decoration: none;
                    padding: 10px 20px;
                    border: 1px solid #3b82f6;
                    border-radius: 8px;
                    transition: all 0.3s ease;
                }}
                .back-link:hover {{
                    background: #3b82f6;
                    color: white;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="icon">✅</div>
                <h1>You're Already on the List!</h1>
                <p>The email <span class="email">{email}</span> is already registered for notifications.</p>
                <p>We'll make sure to notify you when the UFOBeep app launches!</p>
                <a href="/app" class="back-link">← Back to App Page</a>
            </div>
        </body>
        </html>
        """, status_code=200)
        
    except Exception as e:
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Error</title>
            <style>
                body {{
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: #0a0a0a;
                    color: #e5e5e5;
                    margin: 0;
                    padding: 0;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }}
                .container {{
                    text-align: center;
                    max-width: 500px;
                    padding: 40px 20px;
                }}
                .icon {{
                    font-size: 64px;
                    margin-bottom: 20px;
                }}
                h1 {{
                    color: #ef4444;
                    margin-bottom: 16px;
                    font-size: 2rem;
                }}
                p {{
                    color: #9ca3af;
                    margin-bottom: 20px;
                    line-height: 1.6;
                }}
                .back-link {{
                    display: inline-block;
                    margin-top: 20px;
                    color: #3b82f6;
                    text-decoration: none;
                    padding: 10px 20px;
                    border: 1px solid #3b82f6;
                    border-radius: 8px;
                    transition: all 0.3s ease;
                }}
                .back-link:hover {{
                    background: #3b82f6;
                    color: white;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="icon">❌</div>
                <h1>Something Went Wrong</h1>
                <p>We couldn't save your email right now. Please try again later.</p>
                <a href="/app" class="back-link">← Back to Try Again</a>
            </div>
        </body>
        </html>
        """, status_code=500)

@app.get("/api/v1/emails/count")
async def get_interest_count():
    """Get count of interested users"""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("SELECT COUNT(*) FROM email_interests")
        count = cur.fetchone()[0]
        
        cur.close()
        conn.close()
        
        return {"count": count}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get count: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)