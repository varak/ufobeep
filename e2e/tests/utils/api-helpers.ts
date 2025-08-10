import { APIRequestContext, expect } from '@playwright/test';
import { TestUser, TestSighting } from './test-data';

export class APIHelpers {
  constructor(private request: APIRequestContext) {}

  async createTestUser(user: TestUser): Promise<{ id: string; token: string }> {
    const response = await this.request.post('/api/auth/register', {
      data: {
        email: user.email,
        password: user.password,
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        preferredLanguage: user.preferredLanguage,
      },
    });

    expect(response.ok()).toBeTruthy();
    const data = await response.json();
    return {
      id: data.user.id,
      token: data.token,
    };
  }

  async loginUser(email: string, password: string): Promise<string> {
    const response = await this.request.post('/api/auth/login', {
      data: { email, password },
    });

    expect(response.ok()).toBeTruthy();
    const data = await response.json();
    return data.token;
  }

  async createTestSighting(
    sighting: TestSighting,
    token: string
  ): Promise<{ id: string }> {
    const response = await this.request.post('/api/sightings', {
      headers: { Authorization: `Bearer ${token}` },
      data: {
        title: sighting.title,
        description: sighting.description,
        latitude: sighting.location.latitude,
        longitude: sighting.location.longitude,
        compass_heading: sighting.compass,
        elevation_angle: sighting.elevation,
        category: sighting.category,
        timestamp: sighting.timestamp,
      },
    });

    expect(response.ok()).toBeTruthy();
    const data = await response.json();
    return { id: data.sighting.id };
  }

  async getSightings(
    token?: string,
    filters?: {
      radius?: number;
      timeframe?: string;
      category?: string;
    }
  ): Promise<any[]> {
    const params = new URLSearchParams();
    if (filters?.radius) params.append('radius', filters.radius.toString());
    if (filters?.timeframe) params.append('timeframe', filters.timeframe);
    if (filters?.category) params.append('category', filters.category);

    const headers = token ? { Authorization: `Bearer ${token}` } : {};
    const response = await this.request.get(`/api/sightings?${params}`, {
      headers,
    });

    expect(response.ok()).toBeTruthy();
    const data = await response.json();
    return data.sightings;
  }

  async getSightingById(id: string, token?: string): Promise<any> {
    const headers = token ? { Authorization: `Bearer ${token}` } : {};
    const response = await this.request.get(`/api/sightings/${id}`, {
      headers,
    });

    expect(response.ok()).toBeTruthy();
    return await response.json();
  }

  async joinMatrixRoom(sightingId: string, token: string): Promise<string> {
    const response = await this.request.post(
      `/api/matrix/join-sighting-room`,
      {
        headers: { Authorization: `Bearer ${token}` },
        data: { sighting_id: sightingId },
      }
    );

    expect(response.ok()).toBeTruthy();
    const data = await response.json();
    return data.room_id;
  }

  async sendMatrixMessage(
    roomId: string,
    message: string,
    token: string
  ): Promise<void> {
    const response = await this.request.post(`/api/matrix/send-message`, {
      headers: { Authorization: `Bearer ${token}` },
      data: {
        room_id: roomId,
        message,
      },
    });

    expect(response.ok()).toBeTruthy();
  }

  async triggerPlaneMatch(
    sightingId: string,
    token: string
  ): Promise<any> {
    const response = await this.request.post(
      `/api/sightings/${sightingId}/plane-match`,
      {
        headers: { Authorization: `Bearer ${token}` },
      }
    );

    expect(response.ok()).toBeTruthy();
    return await response.json();
  }

  async getEnrichmentData(sightingId: string, token?: string): Promise<any> {
    const headers = token ? { Authorization: `Bearer ${token}` } : {};
    const response = await this.request.get(
      `/api/sightings/${sightingId}/enrichment`,
      { headers }
    );

    expect(response.ok()).toBeTruthy();
    return await response.json();
  }

  async cleanupTestData(token: string, userIds: string[] = []): Promise<void> {
    // Delete test sightings
    const sightings = await this.getSightings(token);
    for (const sighting of sightings) {
      if (sighting.title.includes('Test') || sighting.title.includes('E2E')) {
        await this.request.delete(`/api/sightings/${sighting.id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
      }
    }

    // Delete test users (admin only)
    for (const userId of userIds) {
      await this.request.delete(`/api/admin/users/${userId}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
    }
  }
}