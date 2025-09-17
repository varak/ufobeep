from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from app.services.websocket_manager import websocket_manager
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.websocket("/ws/beep/{beep_id}")
async def websocket_beep_comments(websocket: WebSocket, beep_id: str):
    """WebSocket endpoint for real-time beep comment updates"""
    await websocket_manager.connect_to_beep(websocket, beep_id)
    try:
        while True:
            # Keep connection alive - we only send data, don't receive
            await websocket.receive_text()
    except WebSocketDisconnect:
        websocket_manager.disconnect_from_beep(websocket, beep_id)
    except Exception as e:
        logger.error(f"WebSocket error for beep {beep_id}: {e}")
        websocket_manager.disconnect_from_beep(websocket, beep_id)

@router.websocket("/ws/beeps")
async def websocket_global_beeps(websocket: WebSocket):
    """WebSocket endpoint for real-time new beep updates (for map)"""
    await websocket_manager.connect_global(websocket)
    try:
        while True:
            # Keep connection alive - we only send data, don't receive
            await websocket.receive_text()
    except WebSocketDisconnect:
        websocket_manager.disconnect_global(websocket)
    except Exception as e:
        logger.error(f"WebSocket global error: {e}")
        websocket_manager.disconnect_global(websocket)