from fastapi import APIRouter, Response, HTTPException, Depends
from PIL import Image, ImageDraw, ImageFont
from pydantic import BaseModel
from typing import List, Optional
import io, datetime, httpx, json
from ..core.auth import require_current_user_id

router = APIRouter(prefix="/og", tags=["share-cards"])

class MCPShareRequest(BaseModel):
    beep_id: str
    platforms: List[str]  # ["twitter", "linkedin", "wechat", "telegram"]
    locale: Optional[str] = "en"

class MCPShareResponse(BaseModel):
    success: bool
    platforms_posted: List[str]
    failed_platforms: List[dict]
    share_urls: dict
    message: str

@router.get("/alerts/{aid}.png")
def og_alert_card(aid: str):
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

@router.post("/share", response_model=MCPShareResponse)
async def share_to_social_platforms(
    request: MCPShareRequest,
    user_id: str = Depends(require_current_user_id)
):
    """
    Share a beep to multiple social media platforms via MCP servers
    """
    try:
        # Get beep details for content generation
        # TODO: Import beep database and fetch beep details
        beep_data = {
            "id": request.beep_id,
            "title": f"UFO Sighting Report",
            "location": "Unknown Location",
            "created_at": datetime.datetime.utcnow().isoformat()
        }

        # Generate language-appropriate share content
        share_content = _generate_share_content(beep_data, request.locale)

        # Track successful and failed platform posts
        successful_platforms = []
        failed_platforms = []

        # Generate share URLs for each requested platform
        share_urls = {}
        for platform in request.platforms:
            try:
                result = await _post_via_url_scheme(platform, share_content, beep_data)
                if result["success"]:
                    successful_platforms.append(platform)
                    share_urls[platform] = result["share_url"]
                else:
                    failed_platforms.append({
                        "platform": platform,
                        "error": result.get("error", "Unknown error")
                    })
            except Exception as e:
                failed_platforms.append({
                    "platform": platform,
                    "error": str(e)
                })

        success = len(successful_platforms) > 0
        message = f"Posted to {len(successful_platforms)} platform(s)"
        if failed_platforms:
            message += f", {len(failed_platforms)} failed"

        return MCPShareResponse(
            success=success,
            platforms_posted=successful_platforms,
            failed_platforms=failed_platforms,
            share_urls=share_urls,
            message=message
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def _generate_share_content(beep_data: dict, locale: str) -> dict:
    """Generate language-appropriate content for sharing"""
    # Translation mapping for basic content
    translations = {
        "en": {
            "title": "UFO Sighting Alert",
            "description": "New UFO sighting reported on UFOBeep",
            "hashtags": ["#UFO", "#UFOBeep", "#Sighting", "#Anomaly"]
        },
        "es": {
            "title": "Alerta de Avistamiento OVNI",
            "description": "Nuevo avistamiento OVNI reportado en UFOBeep",
            "hashtags": ["#OVNI", "#UFOBeep", "#Avistamiento", "#Anomalía"]
        },
        "de": {
            "title": "UFO-Sichtungsalarm",
            "description": "Neue UFO-Sichtung auf UFOBeep gemeldet",
            "hashtags": ["#UFO", "#UFOBeep", "#Sichtung", "#Anomalie"]
        },
        "fr": {
            "title": "Alerte d'Observation OVNI",
            "description": "Nouvelle observation OVNI signalée sur UFOBeep",
            "hashtags": ["#OVNI", "#UFOBeep", "#Observation", "#Anomalie"]
        }
    }

    content = translations.get(locale, translations["en"])

    return {
        "text": f"{content['title']}: {content['description']}",
        "hashtags": " ".join(content["hashtags"]),
        "url": f"https://ufobeep.com/beep/{locale}/{beep_data['id']}",
        "image_url": f"https://ufobeep.com/og/alerts/{beep_data['id']}.png"
    }

async def _post_via_url_scheme(platform: str, content: dict, beep_data: dict) -> dict:
    """Generate share URLs for platforms that support URL-based sharing"""
    share_text = f"{content['text']} {content['hashtags']}"
    share_url = content["url"]

    share_urls = {
        "twitter": f"https://twitter.com/intent/tweet?text={share_text}&url={share_url}",
        "facebook": f"https://www.facebook.com/sharer/sharer.php?u={share_url}&quote={share_text}",
        "reddit": f"https://reddit.com/submit?url={share_url}&title={share_text}",
        "telegram": f"https://t.me/share/url?url={share_url}&text={share_text}",
        "whatsapp": f"https://wa.me/?text={share_text} {share_url}"
    }

    platform_url = share_urls.get(platform)
    if not platform_url:
        return {"success": False, "error": f"Platform {platform} not supported"}

    # For URL-based sharing, we return the URL for the frontend to open
    return {
        "success": True,
        "share_url": platform_url,
        "method": "url_scheme"
    }
