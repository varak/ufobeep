from fastapi import APIRouter, Response
from PIL import Image, ImageDraw, ImageFont
import io, datetime

router = APIRouter(prefix="/og", tags=["share-cards"])

@router.get("/alerts/{aid}.png")
def og_alert_card(aid: int):
    W, H = 1200, 630
    img = Image.new("RGB", (W, H), (10, 14, 22))
    draw = ImageDraw.Draw(img)
    title = f"UFOBeep Alert #{aid}"
    subtitle = "See details in the app • ufobeep.com"
    try:
        font_big = ImageFont.truetype("DejaVuSans-Bold.ttf", 64)
        font_small = ImageFont.truetype("DejaVuSans.ttf", 36)
    except:
        font_big = ImageFont.load_default(); font_small = ImageFont.load_default()
    tw, th = draw.textsize(title, font=font_big)
    draw.text(((W - tw)//2, H//3 - th//2), title, fill=(220,240,255), font=font_big)
    sw, sh = draw.textsize(subtitle, font=font_small)
    draw.text(((W - sw)//2, H//3 + th), subtitle, fill=(160,175,190), font=font_small)
    ts = datetime.datetime.utcnow().strftime("Generated %Y-%m-%d %H:%M UTC")
    draw.text((40, H - 60), ts, fill=(120,130,145), font=font_small)
    buf = io.BytesIO(); img.save(buf, format="PNG")
    return Response(content=buf.getvalue(), media_type="image/png")
