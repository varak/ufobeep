from typing import Dict, Set
from fastapi import WebSocket
import logging
import json

logger = logging.getLogger(__name__)

class WebSocketManager:
    def __init__(self):
        # Active connections per beep ID
        self.beep_connections: Dict[str, Set[WebSocket]] = {}
        # Global connections for new beeps (map updates)
        self.global_connections: Set[WebSocket] = set()

    async def connect_to_beep(self, websocket: WebSocket, beep_id: str):
        """Connect to updates for a specific beep"""
        await websocket.accept()
        if beep_id not in self.beep_connections:
            self.beep_connections[beep_id] = set()
        self.beep_connections[beep_id].add(websocket)
        logger.info(f"WebSocket connected to beep {beep_id}. Total connections: {len(self.beep_connections[beep_id])}")

    async def connect_global(self, websocket: WebSocket):
        """Connect to global updates (new beeps for map)"""
        await websocket.accept()
        self.global_connections.add(websocket)
        logger.info(f"WebSocket connected to global updates. Total connections: {len(self.global_connections)}")

    def disconnect_from_beep(self, websocket: WebSocket, beep_id: str):
        """Disconnect from beep updates"""
        if beep_id in self.beep_connections:
            self.beep_connections[beep_id].discard(websocket)
            if not self.beep_connections[beep_id]:
                del self.beep_connections[beep_id]
        logger.info(f"WebSocket disconnected from beep {beep_id}")

    def disconnect_global(self, websocket: WebSocket):
        """Disconnect from global updates"""
        self.global_connections.discard(websocket)
        logger.info(f"WebSocket disconnected from global updates")

    async def broadcast_to_beep(self, beep_id: str, message: dict):
        """Broadcast message to all connections for a specific beep"""
        if beep_id not in self.beep_connections:
            return

        connections = self.beep_connections[beep_id].copy()
        if not connections:
            return

        message_str = json.dumps(message)
        dead_connections = []

        for websocket in connections:
            try:
                await websocket.send_text(message_str)
            except Exception as e:
                logger.warning(f"Failed to send message to WebSocket: {e}")
                dead_connections.append(websocket)

        # Clean up dead connections
        for websocket in dead_connections:
            self.disconnect_from_beep(websocket, beep_id)

        logger.info(f"Broadcasted {message['type']} to {len(connections) - len(dead_connections)} connections for beep {beep_id}")

    async def broadcast_global(self, message: dict):
        """Broadcast message to all global connections"""
        if not self.global_connections:
            return

        connections = self.global_connections.copy()
        message_str = json.dumps(message)
        dead_connections = []

        for websocket in connections:
            try:
                await websocket.send_text(message_str)
            except Exception as e:
                logger.warning(f"Failed to send global message to WebSocket: {e}")
                dead_connections.append(websocket)

        # Clean up dead connections
        for websocket in dead_connections:
            self.disconnect_global(websocket)

        logger.info(f"Broadcasted {message['type']} to {len(connections) - len(dead_connections)} global connections")

# Global WebSocket manager instance
websocket_manager = WebSocketManager()