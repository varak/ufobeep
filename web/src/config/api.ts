import { env } from './environment';

export const apiConfig = {
  baseUrl: env.apiBaseUrl,
  version: env.apiVersion,
  fullUrl: env.apiFullUrl,
  timeout: 30000,
  
  endpoints: {
    // Auth endpoints
    register: '/auth/register',
    login: '/auth/login',
    logout: '/auth/logout',
    refreshToken: '/auth/refresh',
    
    // User endpoints
    profile: '/users/profile',
    updateProfile: '/users/profile',
    
    // Unified alerts endpoints (replaces sightings)
    alerts: '/alerts',
    createAlert: '/alerts',
    alertDetail: '/alerts',
    uploadRequest: '/upload/request',
    
    // Matrix endpoints
    matrixToken: '/matrix/token',
    matrixRoom: '/matrix/room',
  },
  
  // Request headers
  defaultHeaders: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  
  // File upload configuration
  upload: {
    maxSize: 10 * 1024 * 1024, // 10MB
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'video/quicktime'],
    allowedExtensions: ['.jpg', '.jpeg', '.png', '.webp', '.mp4', '.mov'],
  },
};

export const matrixConfig = {
  baseUrl: env.matrixBaseUrl,
  serverName: env.matrixServerName,
  
  // Matrix client configuration
  client: {
    baseUrl: env.matrixBaseUrl,
    accessToken: '', // Will be set dynamically
    userId: '', // Will be set dynamically
  },
  
  // Default room settings
  room: {
    visibility: 'public',
    preset: 'public_chat',
    powerLevelContentOverride: {
      users_default: 0,
      events_default: 0,
      state_default: 50,
    },
  },
};

// Helper function to build API URLs
export function buildApiUrl(endpoint: string, params?: Record<string, string | number>): string {
  let url = `${apiConfig.fullUrl}${endpoint}`;
  
  if (params) {
    const searchParams = new URLSearchParams();
    Object.entries(params).forEach(([key, value]) => {
      searchParams.append(key, String(value));
    });
    url += `?${searchParams.toString()}`;
  }
  
  return url;
}

// Helper function to build Matrix URLs
export function buildMatrixUrl(endpoint: string): string {
  return `${matrixConfig.baseUrl}${endpoint}`;
}

// API error handling
export interface ApiError {
  message: string;
  code?: string;
  status?: number;
  details?: any;
}

export class ApiException extends Error {
  public readonly code?: string;
  public readonly status?: number;
  public readonly details?: any;

  constructor(error: ApiError) {
    super(error.message);
    this.name = 'ApiException';
    this.code = error.code;
    this.status = error.status;
    this.details = error.details;
  }
}

// Request/Response types
export interface ApiResponse<T = any> {
  data: T;
  message?: string;
  status: number;
}

export interface PaginatedResponse<T = any> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// Configuration validation
export function validateApiConfig(): boolean {
  const requiredEnvVars = [
    'NEXT_PUBLIC_API_BASE_URL',
    'NEXT_PUBLIC_MATRIX_BASE_URL',
  ];
  
  const missing = requiredEnvVars.filter(envVar => !process.env[envVar]);
  
  if (missing.length > 0) {
    console.error('Missing required environment variables:', missing);
    return false;
  }
  
  return true;
}

// Log configuration in development
if (env.isDevelopment) {
  console.log('API Configuration:', {
    baseUrl: apiConfig.baseUrl,
    fullUrl: apiConfig.fullUrl,
    matrixBaseUrl: matrixConfig.baseUrl,
    matrixServerName: matrixConfig.serverName,
  });
}