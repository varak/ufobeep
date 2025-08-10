import { faker } from 'faker';

export interface TestUser {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phone: string;
  preferredLanguage: 'en' | 'es' | 'de';
}

export interface TestSighting {
  title: string;
  description: string;
  location: {
    latitude: number;
    longitude: number;
    address: string;
  };
  category: 'ufo' | 'light' | 'formation' | 'other';
  timestamp: string;
  compass: number;
  elevation: number;
}

export class TestDataGenerator {
  static generateUser(): TestUser {
    return {
      email: faker.internet.email(),
      password: 'TestPassword123!',
      firstName: faker.person.firstName(),
      lastName: faker.person.lastName(),
      phone: faker.phone.number('+1##########'),
      preferredLanguage: faker.helpers.arrayElement(['en', 'es', 'de']),
    };
  }

  static generateSighting(): TestSighting {
    return {
      title: `UFO Sighting - ${faker.lorem.words(3)}`,
      description: faker.lorem.paragraphs(2),
      location: {
        latitude: faker.location.latitude({ min: 30, max: 50 }),
        longitude: faker.location.longitude({ min: -125, max: -70 }),
        address: faker.location.streetAddress(),
      },
      category: faker.helpers.arrayElement(['ufo', 'light', 'formation', 'other']),
      timestamp: faker.date.recent().toISOString(),
      compass: faker.number.int({ min: 0, max: 359 }),
      elevation: faker.number.int({ min: -10, max: 90 }),
    };
  }

  static generateTestSightings(count: number = 10): TestSighting[] {
    return Array.from({ length: count }, () => this.generateSighting());
  }

  // Predefined test data for consistent testing
  static readonly FIXED_USER: TestUser = {
    email: 'test@ufobeep.com',
    password: 'TestPassword123!',
    firstName: 'John',
    lastName: 'Doe',
    phone: '+15551234567',
    preferredLanguage: 'en',
  };

  static readonly FIXED_SIGHTING: TestSighting = {
    title: 'Disc-shaped Object over Golden Gate',
    description: 'Observed a bright, disc-shaped object moving silently across the evening sky. The object displayed unusual flight characteristics, including rapid acceleration and sudden directional changes.',
    location: {
      latitude: 37.8199,
      longitude: -122.4783,
      address: 'Golden Gate Bridge, San Francisco, CA',
    },
    category: 'ufo',
    timestamp: '2024-01-10T19:30:00Z',
    compass: 245,
    elevation: 35,
  };

  // Locations for testing
  static readonly TEST_LOCATIONS = {
    SAN_FRANCISCO: { lat: 37.7749, lng: -122.4194, name: 'San Francisco, CA' },
    NEW_YORK: { lat: 40.7128, lng: -74.0060, name: 'New York, NY' },
    LONDON: { lat: 51.5074, lng: -0.1278, name: 'London, UK' },
    MADRID: { lat: 40.4168, lng: -3.7038, name: 'Madrid, Spain' },
    BERLIN: { lat: 52.5200, lng: 13.4050, name: 'Berlin, Germany' },
  };

  // Test scenarios
  static readonly SCENARIOS = {
    SUCCESSFUL_REGISTRATION: 'User successfully registers and sets up profile',
    SIGHTING_CAPTURE: 'User captures and submits a sighting',
    BROWSE_ALERTS: 'User browses and filters alerts',
    JOIN_DISCUSSION: 'User joins sighting discussion',
    COMPASS_NAVIGATION: 'User uses compass for navigation',
    PILOT_MODE: 'User switches to pilot mode for advanced navigation',
  };
}

export const MOCK_ENRICHMENT_DATA = {
  weather: {
    temperature: 18.5,
    humidity: 65,
    visibility: 10000,
    conditions: 'Clear',
    windSpeed: 5.2,
    windDirection: 220,
  },
  celestial: {
    sunAltitude: -12.5,
    moonAltitude: 45.2,
    moonPhase: 0.75,
    twilightType: 'nautical',
  },
  satellites: {
    issVisible: false,
    starlink: [
      { name: 'Starlink-1234', altitude: 550, brightness: 3.2 },
    ],
  },
};

export const API_RESPONSES = {
  SUCCESS: { status: 'success', data: {} },
  ERROR: { status: 'error', message: 'Test error' },
  UNAUTHORIZED: { status: 'error', message: 'Unauthorized' },
  NOT_FOUND: { status: 'error', message: 'Not found' },
};