# Wire routers
Edit `api/app/main.py`:
from app.routers import comments, share_cards
app.include_router(comments.router)
app.include_router(share_cards.router)

Add to `requirements.txt`:
Pillow
