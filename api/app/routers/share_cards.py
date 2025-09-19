from fastapi import APIRouter, Response, HTTPException, Depends
from PIL import Image, ImageDraw, ImageFont
from pydantic import BaseModel
from typing import List, Optional
import io, datetime, httpx, json
from ..auth import require_current_user_id

router = APIRouter(prefix="/og", tags=["share-cards"])

class MCPShareRequest(BaseModel):
    beep_id: str
    platforms: List[str]  # ["twitter", "linkedin", "wechat", "telegram"]
    locale: Optional[str] = "en"

class MCPShareResponse(BaseModel):
    success: bool
    platforms_posted: List[str]
    failed_platforms: List[dict]
    message: str

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

        # Post to each requested platform via MCP
        for platform in request.platforms:
            try:
                result = await _post_via_mcp(platform, share_content, beep_data)
                if result["success"]:
                    successful_platforms.append(platform)
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

async def _post_via_mcp(platform: str, content: dict, beep_data: dict) -> dict:
    """Post content to a platform via MCP server"""
    # MCP server endpoints mapping for all available platforms
    mcp_endpoints = {
        # Western platforms
        "twitter": "http://localhost:3001/mcp/twitter",
        "linkedin": "http://localhost:3001/mcp/linkedin",
        "facebook": "http://localhost:3001/mcp/facebook",
        "instagram": "http://localhost:3001/mcp/instagram",
        "reddit": "http://localhost:3001/mcp/reddit",
        "youtube": "http://localhost:3001/mcp/youtube",
        "tiktok": "http://localhost:3001/mcp/tiktok",
        "mastodon": "http://localhost:3001/mcp/mastodon",

        # Asian platforms
        "wechat": "http://localhost:3002/mcp/wechat",
        "weibo": "http://localhost:3002/mcp/weibo",
        "qq": "http://localhost:3002/mcp/qq",
        "douyin": "http://localhost:3002/mcp/douyin",
        "xiaohongshu": "http://localhost:3002/mcp/xiaohongshu",
        "bilibili": "http://localhost:3002/mcp/bilibili",
        "line": "http://localhost:3002/mcp/line",

        # Russian/Eastern European platforms
        "vkontakte": "http://localhost:3003/mcp/vkontakte",
        "odnoklassniki": "http://localhost:3003/mcp/odnoklassniki",

        # Global messaging platforms
        "telegram": "http://localhost:3004/mcp/telegram",
        "whatsapp": "http://localhost:3004/mcp/whatsapp",
        "discord": "http://localhost:3004/mcp/discord",

        # Regional platforms
        "mixi": "http://localhost:3005/mcp/mixi",        # Japan
        "xing": "http://localhost:3005/mcp/xing",        # Germany
        "naver": "http://localhost:3005/mcp/naver",      # Korea
        "orkut": "http://localhost:3005/mcp/orkut"       # Brazil/India
    }

    endpoint = mcp_endpoints.get(platform)
    if not endpoint:
        return {"success": False, "error": f"Platform {platform} not supported"}

    try:
        async with httpx.AsyncClient() as client:
            payload = {
                "text": f"{content['text']} {content['hashtags']}",
                "media_url": content.get("image_url"),
                "link_url": content["url"]
            }

            response = await client.post(endpoint, json=payload, timeout=30.0)

            if response.status_code == 200:
                return {"success": True, "response": response.json()}
            else:
                return {
                    "success": False,
                    "error": f"HTTP {response.status_code}: {response.text}"
                }

    except Exception as e:
        return {"success": False, "error": str(e)}
