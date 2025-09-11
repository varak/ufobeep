import { env } from './environment';

export const apiConfig = {
  baseUrl: env.apiBaseUrl,
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
    alerts: '/beep',
    createAlert: '/beep',
    alertDetail: '/beep',
    uploadRequest: '/upload/request',
    
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
  // No required environment variables for basic operation
  return true;
}

// Log configuration in development
if (env.isDevelopment) {
  console.log('API Configuration:', {
    baseUrl: apiConfig.baseUrl,
    fullUrl: apiConfig.fullUrl,
  });
}