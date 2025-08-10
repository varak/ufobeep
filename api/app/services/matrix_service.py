"""
Matrix Service

Handles Matrix protocol integration for UFOBeep including:
- Room creation for sightings
- User authentication and SSO tokens
- Room management and invitations
- Message posting and event handling
"""

import asyncio
import logging
import json
import hashlib
import secrets
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, List
from urllib.parse import urljoin

import aiohttp
from app.config.environment import settings

logger = logging.getLogger(__name__)


class MatrixError(Exception):
    """Base exception for Matrix-related errors"""
    pass


class MatrixAuthError(MatrixError):
    """Matrix authentication error"""
    pass


class MatrixRoomError(MatrixError):
    """Matrix room operation error"""
    pass


class MatrixService:
    """Matrix client service for UFOBeep integration"""
    
    def __init__(self):
        self.base_url = settings.matrix_base_url
        self.server_name = settings.matrix_server_name
        self.access_token = settings.matrix_access_token
        self.bot_user_id = settings.matrix_bot_user_id
        self._session = None
        self._user_tokens = {}  # In-memory cache for user tokens
        
    async def __aenter__(self):
        """Async context manager entry"""
        self._session = aiohttp.ClientSession(
            timeout=aiohttp.ClientTimeout(total=30),
            headers={
                'Authorization': f'Bearer {self.access_token}',
                'Content-Type': 'application/json'
            }
        )
        return self
        
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit"""
        if self._session:
            await self._session.close()
            
    async def _make_request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict[str, Any]:
        """Make authenticated request to Matrix API"""
        if not self._session:
            raise MatrixError("Matrix service not initialized - use as async context manager")
            
        url = urljoin(self.base_url, endpoint)
        
        try:
            if method.upper() == 'GET':
                async with self._session.get(url, params=data) as response:
                    response_data = await response.json()
            elif method.upper() == 'POST':
                async with self._session.post(url, json=data) as response:
                    response_data = await response.json()
            elif method.upper() == 'PUT':
                async with self._session.put(url, json=data) as response:
                    response_data = await response.json()
            elif method.upper() == 'DELETE':
                async with self._session.delete(url, json=data) as response:
                    response_data = await response.json()
            else:
                raise MatrixError(f"Unsupported HTTP method: {method}")
                
            if not response.ok:
                error_code = response_data.get('errcode', 'UNKNOWN')
                error_msg = response_data.get('error', f'HTTP {response.status}')
                raise MatrixError(f"Matrix API error {error_code}: {error_msg}")
                
            return response_data
            
        except aiohttp.ClientError as e:
            raise MatrixError(f"Matrix API request failed: {e}")
        except json.JSONDecodeError as e:
            raise MatrixError(f"Invalid JSON response from Matrix API: {e}")
            
    async def create_sso_token(self, user_id: str, display_name: Optional[str] = None) -> Dict[str, Any]:
        """
        Create an SSO token for a user to join Matrix
        
        This generates a temporary access token that allows the user to authenticate
        with Matrix and join their sighting rooms automatically.
        """
        try:
            # Generate a unique token
            token_data = {
                'user_id': user_id,
                'server_name': self.server_name,
                'expires_at': (datetime.utcnow() + timedelta(hours=24)).isoformat(),
                'nonce': secrets.token_urlsafe(32)
            }
            
            # Create a hash-based token (simplified - in production use proper JWT/signing)
            token_string = json.dumps(token_data, sort_keys=True)
            token_hash = hashlib.sha256(token_string.encode()).hexdigest()
            
            # Store token temporarily (in production, use Redis or database)
            self._user_tokens[token_hash] = token_data
            
            # Try to create/register the user on Matrix if they don't exist
            matrix_user_id = f"@ufo_{user_id}:{self.server_name}"
            
            try:
                # Check if user exists
                await self._make_request('GET', f'/_matrix/client/v3/profile/{matrix_user_id}')
                logger.debug(f"Matrix user {matrix_user_id} already exists")
                
            except MatrixError:
                # User doesn't exist, try to register them
                logger.info(f"Creating Matrix user {matrix_user_id}")
                
                registration_data = {
                    'username': f'ufo_{user_id}',
                    'password': secrets.token_urlsafe(32),  # Random password
                    'auth': {'type': 'm.login.application_service'},
                    'inhibit_login': False
                }
                
                if display_name:
                    registration_data['initial_device_display_name'] = display_name
                
                # Note: This requires admin privileges or application service registration
                # In production, you'd use proper Matrix application service registration
                try:
                    user_response = await self._make_request('POST', '/_matrix/client/v3/register', registration_data)
                    logger.info(f"Successfully created Matrix user: {matrix_user_id}")
                    
                    # Set user profile
                    if display_name:
                        await self._make_request('PUT', f'/_matrix/client/v3/profile/{matrix_user_id}/displayname', {
                            'displayname': display_name
                        })
                        
                except MatrixError as e:
                    logger.warning(f"Failed to register Matrix user {matrix_user_id}: {e}")
                    # Continue anyway - user might be registered elsewhere
            
            return {
                'sso_token': token_hash,
                'matrix_user_id': matrix_user_id,
                'server_name': self.server_name,
                'expires_at': token_data['expires_at'],
                'login_url': f"{self.base_url}/_matrix/client/v3/login"
            }
            
        except Exception as e:
            logger.error(f"Failed to create SSO token for user {user_id}: {e}")
            raise MatrixAuthError(f"SSO token creation failed: {e}")
            
    async def validate_sso_token(self, token: str) -> Optional[Dict[str, Any]]:
        """Validate an SSO token and return user info if valid"""
        try:
            token_data = self._user_tokens.get(token)
            if not token_data:
                return None
                
            # Check if token has expired
            expires_at = datetime.fromisoformat(token_data['expires_at'])
            if datetime.utcnow() > expires_at:
                # Clean up expired token
                del self._user_tokens[token]
                return None
                
            return token_data
            
        except Exception as e:
            logger.error(f"Error validating SSO token: {e}")
            return None
            
    async def create_sighting_room(self, sighting_id: str, sighting_title: str, 
                                  reporter_user_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Create a Matrix room for a UFO sighting
        
        Args:
            sighting_id: Unique identifier for the sighting
            sighting_title: Title/description for the room
            reporter_user_id: ID of the user who reported the sighting
            
        Returns:
            Dict containing room_id, room_alias, and join information
        """
        try:
            # Create a unique room alias based on sighting ID
            room_alias = f"sighting_{sighting_id}_{secrets.token_urlsafe(8)}"
            full_room_alias = f"#{room_alias}:{self.server_name}"
            
            # Room creation parameters
            room_data = {
                'room_alias_name': room_alias,
                'name': f"UFO Sighting: {sighting_title}",
                'topic': f"Discussion for UFO sighting {sighting_id}",
                'preset': 'public_chat',  # Allow anyone to join
                'visibility': 'public',   # Make room discoverable
                'creation_content': {
                    'type': 'm.room.create',
                    'm.federate': True
                },
                'initial_state': [
                    {
                        'type': 'm.room.join_rules',
                        'content': {'join_rule': 'public'}
                    },
                    {
                        'type': 'm.room.history_visibility',
                        'content': {'history_visibility': 'shared'}  # Allow reading history
                    },
                    {
                        'type': 'm.room.guest_access',
                        'content': {'guest_access': 'can_join'}
                    },
                    {
                        'type': 'm.room.power_levels',
                        'content': {
                            'users_default': 0,
                            'events_default': 0,
                            'state_default': 50,
                            'ban': 50,
                            'kick': 50,
                            'redact': 0,
                            'invite': 0,
                            'users': {
                                self.bot_user_id: 100  # Bot has admin privileges
                            }
                        }
                    }
                ]
            }
            
            # Give reporter elevated permissions if provided
            if reporter_user_id:
                matrix_reporter_id = f"@ufo_{reporter_user_id}:{self.server_name}"
                room_data['initial_state'][-1]['content']['users'][matrix_reporter_id] = 50
            
            # Create the room
            response = await self._make_request('POST', '/_matrix/client/v3/createRoom', room_data)
            room_id = response['room_id']
            
            logger.info(f"Created Matrix room {room_id} for sighting {sighting_id}")
            
            # Send welcome message
            welcome_message = {
                'msgtype': 'm.text',
                'body': f"Welcome to the discussion for UFO sighting {sighting_id}!\n\n"
                        f"📍 {sighting_title}\n\n"
                        f"Share your thoughts, analysis, and similar experiences. "
                        f"Please keep discussions respectful and on-topic.",
                'format': 'org.matrix.custom.html',
                'formatted_body': f"<h3>Welcome to UFO Sighting Discussion</h3>"
                                f"<p><strong>📍 {sighting_title}</strong></p>"
                                f"<p>Share your thoughts, analysis, and similar experiences. "
                                f"Please keep discussions respectful and on-topic.</p>"
            }
            
            await self.send_message(room_id, welcome_message)
            
            return {
                'room_id': room_id,
                'room_alias': full_room_alias,
                'room_name': room_data['name'],
                'join_url': f"{self.base_url}/#/room/{room_id}",
                'matrix_to_url': f"https://matrix.to/#/{room_id}",
                'created_at': datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Failed to create Matrix room for sighting {sighting_id}: {e}")
            raise MatrixRoomError(f"Room creation failed: {e}")
            
    async def invite_user_to_room(self, room_id: str, user_id: str) -> bool:
        """Invite a user to a Matrix room"""
        try:
            matrix_user_id = f"@ufo_{user_id}:{self.server_name}"
            
            invite_data = {
                'user_id': matrix_user_id
            }
            
            await self._make_request('POST', f'/_matrix/client/v3/rooms/{room_id}/invite', invite_data)
            logger.info(f"Invited user {matrix_user_id} to room {room_id}")
            return True
            
        except MatrixError as e:
            logger.error(f"Failed to invite user {user_id} to room {room_id}: {e}")
            return False
            
    async def send_message(self, room_id: str, content: Dict[str, Any]) -> Optional[str]:
        """Send a message to a Matrix room"""
        try:
            # Generate unique transaction ID
            txn_id = secrets.token_urlsafe(16)
            
            response = await self._make_request(
                'PUT', 
                f'/_matrix/client/v3/rooms/{room_id}/send/m.room.message/{txn_id}',
                content
            )
            
            event_id = response.get('event_id')
            logger.debug(f"Sent message to room {room_id}: {event_id}")
            return event_id
            
        except MatrixError as e:
            logger.error(f"Failed to send message to room {room_id}: {e}")
            return None
            
    async def get_room_messages(self, room_id: str, limit: int = 100) -> List[Dict[str, Any]]:
        """Get recent messages from a Matrix room"""
        try:
            params = {
                'limit': min(limit, 1000),  # Cap at 1000 messages
                'dir': 'b'  # Backwards (newest first)
            }
            
            response = await self._make_request('GET', f'/_matrix/client/v3/rooms/{room_id}/messages', params)
            
            messages = []
            for event in response.get('chunk', []):
                if event.get('type') == 'm.room.message':
                    messages.append({
                        'event_id': event.get('event_id'),
                        'sender': event.get('sender'),
                        'timestamp': event.get('origin_server_ts'),
                        'content': event.get('content', {}),
                        'formatted_timestamp': datetime.fromtimestamp(
                            event.get('origin_server_ts', 0) / 1000
                        ).isoformat() if event.get('origin_server_ts') else None
                    })
            
            # Reverse to get chronological order (oldest first)
            messages.reverse()
            return messages
            
        except MatrixError as e:
            logger.error(f"Failed to get messages from room {room_id}: {e}")
            return []
            
    async def get_room_info(self, room_id: str) -> Optional[Dict[str, Any]]:
        """Get information about a Matrix room"""
        try:
            # Get room state
            state_response = await self._make_request('GET', f'/_matrix/client/v3/rooms/{room_id}/state')
            
            room_info = {
                'room_id': room_id,
                'name': None,
                'topic': None,
                'avatar_url': None,
                'member_count': 0,
                'creation_timestamp': None
            }
            
            # Parse state events
            for event in state_response:
                if event['type'] == 'm.room.name':
                    room_info['name'] = event['content'].get('name')
                elif event['type'] == 'm.room.topic':
                    room_info['topic'] = event['content'].get('topic')
                elif event['type'] == 'm.room.avatar':
                    room_info['avatar_url'] = event['content'].get('url')
                elif event['type'] == 'm.room.member' and event['content'].get('membership') == 'join':
                    room_info['member_count'] += 1
                elif event['type'] == 'm.room.create':
                    room_info['creation_timestamp'] = event.get('origin_server_ts')
            
            return room_info
            
        except MatrixError as e:
            logger.error(f"Failed to get room info for {room_id}: {e}")
            return None
            
    async def health_check(self) -> bool:
        """Check if Matrix server is accessible"""
        try:
            response = await self._make_request('GET', '/_matrix/client/versions')
            versions = response.get('versions', [])
            logger.debug(f"Matrix server versions: {versions}")
            return len(versions) > 0
            
        except Exception as e:
            logger.error(f"Matrix health check failed: {e}")
            return False


# Global Matrix service instance
matrix_service = MatrixService()


async def create_sighting_matrix_room(sighting_id: str, sighting_title: str, 
                                     reporter_user_id: Optional[str] = None) -> Optional[Dict[str, Any]]:
    """
    Convenience function to create a Matrix room for a sighting
    
    This function handles the async context management automatically.
    """
    try:
        async with matrix_service as matrix:
            return await matrix.create_sighting_room(sighting_id, sighting_title, reporter_user_id)
    except Exception as e:
        logger.error(f"Failed to create Matrix room: {e}")
        return None


async def generate_user_sso_token(user_id: str, display_name: Optional[str] = None) -> Optional[Dict[str, Any]]:
    """
    Convenience function to generate SSO token for user
    """
    try:
        async with matrix_service as matrix:
            return await matrix.create_sso_token(user_id, display_name)
    except Exception as e:
        logger.error(f"Failed to generate SSO token: {e}")
        return None


async def get_room_transcript(room_id: str, limit: int = 100) -> List[Dict[str, Any]]:
    """
    Convenience function to get room messages
    """
    try:
        async with matrix_service as matrix:
            return await matrix.get_room_messages(room_id, limit)
    except Exception as e:
        logger.error(f"Failed to get room transcript: {e}")
        return []