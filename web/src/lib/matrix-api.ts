/**
 * Matrix API client for server-side data fetching (SSR)
 * Handles Matrix room transcripts and room information
 */

import { apiConfig, buildApiUrl } from '@/config/api';
import { 
  MatrixTranscriptResponse, 
  MatrixRoomInfoResponse, 
  MatrixMessage,
  MatrixRoomInfo,
  APIResponse
} from '@/types/api';

export class MatrixAPIClient {
  private baseUrl: string;
  private defaultHeaders: Record<string, string>;

  constructor() {
    this.baseUrl = apiConfig.fullUrl;
    this.defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /**
   * Fetch Matrix room transcript (last 100 messages)
   * Used for server-side rendering of chat history
   */
  async getRoomTranscript(roomId: string, limit: number = 100): Promise<MatrixMessage[]> {
    try {
      const url = buildApiUrl(`/matrix/room/${roomId}/messages`, { limit });
      
      const response = await fetch(url, {
        method: 'GET',
        headers: this.defaultHeaders,
        // Enable caching for SSR - cache for 1 minute
        next: {
          revalidate: 60,
        }
      });

      if (!response.ok) {
        console.error(`Matrix transcript fetch failed: ${response.status} ${response.statusText}`);
        return [];
      }

      const data: MatrixTranscriptResponse = await response.json();
      
      if (!data.success) {
        console.error('Matrix transcript API returned error:', data);
        return [];
      }

      return data.data.messages || [];
    } catch (error) {
      console.error('Error fetching Matrix room transcript:', error);
      return [];
    }
  }

  /**
   * Fetch Matrix room information
   */
  async getRoomInfo(roomId: string): Promise<MatrixRoomInfo | null> {
    try {
      const url = buildApiUrl(`/matrix/room/${roomId}/info`);
      
      const response = await fetch(url, {
        method: 'GET',
        headers: this.defaultHeaders,
        // Cache room info for 5 minutes since it changes less frequently
        next: {
          revalidate: 300,
        }
      });

      if (!response.ok) {
        console.error(`Matrix room info fetch failed: ${response.status} ${response.statusText}`);
        return null;
      }

      const data: MatrixRoomInfoResponse = await response.json();
      
      if (!data.success) {
        console.error('Matrix room info API returned error:', data);
        return null;
      }

      return data.data;
    } catch (error) {
      console.error('Error fetching Matrix room info:', error);
      return null;
    }
  }

  /**
   * Check if Matrix service is healthy
   */
  async checkHealth(): Promise<boolean> {
    try {
      const url = buildApiUrl('/matrix/health');
      
      const response = await fetch(url, {
        method: 'GET',
        headers: this.defaultHeaders,
        // No caching for health checks
        cache: 'no-store',
      });

      if (!response.ok) {
        return false;
      }

      const data: APIResponse = await response.json();
      return data.success;
    } catch (error) {
      console.error('Error checking Matrix health:', error);
      return false;
    }
  }

  /**
   * Format Matrix message for display
   */
  formatMessage(message: MatrixMessage): {
    id: string;
    sender: string;
    senderDisplayName: string;
    content: string;
    timestamp: Date;
    messageType: string;
  } {
    // Extract sender display name from Matrix user ID
    let displayName = message.sender;
    if (displayName.startsWith('@')) {
      // Remove @ and server part, keep only local part
      displayName = displayName.substring(1).split(':')[0];
    }

    const timestamp = message.formatted_timestamp
      ? new Date(message.formatted_timestamp)
      : new Date(message.timestamp);

    return {
      id: message.event_id,
      sender: message.sender,
      senderDisplayName: displayName,
      content: message.content.body || '',
      timestamp,
      messageType: message.content.msgtype || 'm.text',
    };
  }

  /**
   * Format Matrix room info for display
   */
  formatRoomInfo(roomInfo: MatrixRoomInfo): {
    id: string;
    name: string;
    memberCount: number;
    joinUrl: string;
    matrixToUrl: string;
  } {
    return {
      id: roomInfo.room_id,
      name: roomInfo.room_name || 'UFO Sighting Chat',
      memberCount: roomInfo.member_count,
      joinUrl: roomInfo.join_url,
      matrixToUrl: roomInfo.matrix_to_url,
    };
  }
}

// Global instance
export const matrixAPI = new MatrixAPIClient();

// Utility functions for server-side components
export async function getMatrixRoomData(roomId: string | null) {
  if (!roomId) {
    return {
      messages: [],
      roomInfo: null,
      hasMatrixRoom: false,
    };
  }

  try {
    // Fetch room info and messages concurrently
    const [messages, roomInfo] = await Promise.all([
      matrixAPI.getRoomTranscript(roomId, 100),
      matrixAPI.getRoomInfo(roomId),
    ]);

    return {
      messages: messages.map(msg => matrixAPI.formatMessage(msg)),
      roomInfo: roomInfo ? matrixAPI.formatRoomInfo(roomInfo) : null,
      hasMatrixRoom: true,
    };
  } catch (error) {
    console.error('Error fetching Matrix room data:', error);
    return {
      messages: [],
      roomInfo: null,
      hasMatrixRoom: false,
    };
  }
}

// Mock data generator for development (when Matrix is not available)
export function generateMockMatrixData() {
  const mockMessages = [
    {
      id: '$event1:example.com',
      sender: '@witness_sf_2024:ufobeep.com',
      senderDisplayName: 'witness_sf_2024',
      content: 'I saw the same formation from Crissy Field! The objects were definitely in a perfect triangle pattern.',
      timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
      messageType: 'm.text',
    },
    {
      id: '$event2:example.com',
      sender: '@verified_observer:ufobeep.com',
      senderDisplayName: 'verified_observer',
      content: 'Flight tracking confirms no conventional aircraft in that airspace during the timeframe. Intriguing sighting.',
      timestamp: new Date(Date.now() - 1 * 60 * 60 * 1000), // 1 hour ago
      messageType: 'm.text',
    },
    {
      id: '$event3:example.com',
      sender: '@bay_area_watcher:ufobeep.com',
      senderDisplayName: 'bay_area_watcher',
      content: 'Got some video footage from my balcony. Same time, same direction. Uploading now...',
      timestamp: new Date(Date.now() - 45 * 60 * 1000), // 45 min ago
      messageType: 'm.text',
    },
    {
      id: '$event4:example.com',
      sender: '@sky_observer_12:ufobeep.com',
      senderDisplayName: 'sky_observer_12',
      content: 'Weather was perfect for observation - clear skies, minimal light pollution. This was definitely something unusual.',
      timestamp: new Date(Date.now() - 30 * 60 * 1000), // 30 min ago
      messageType: 'm.text',
    },
  ];

  const mockRoomInfo = {
    id: '!example123:ufobeep.com',
    name: 'UFO Sighting Chat',
    memberCount: 12,
    joinUrl: 'https://matrix.ufobeep.com/#/room/!example123:ufobeep.com',
    matrixToUrl: 'https://matrix.to/#/!example123:ufobeep.com',
  };

  return {
    messages: mockMessages,
    roomInfo: mockRoomInfo,
    hasMatrixRoom: true,
  };
}