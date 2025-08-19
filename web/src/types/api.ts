/**
 * UFOBeep API Types - TypeScript/Next.js Client
 * Generated from shared API contracts
 */

// Enums
export enum SightingCategory {
  UFO = 'ufo',
  ANOMALY = 'anomaly',
  UNKNOWN = 'unknown'
}

export enum SightingStatus {
  PENDING = 'pending',
  VERIFIED = 'verified',
  EXPLAINED = 'explained',
  REJECTED = 'rejected'
}

export enum AlertLevel {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical'
}

export enum MediaType {
  PHOTO = 'photo',
  VIDEO = 'video',
  AUDIO = 'audio'
}

// Core data types
export interface GeoCoordinates {
  latitude: number
  longitude: number
  altitude?: number
  accuracy?: number
}

export interface SensorData {
  timestamp: string // ISO datetime
  location: GeoCoordinates
  azimuth_deg: number
  pitch_deg: number
  roll_deg?: number
  hfov_deg?: number
  vfov_deg?: number
  device_id?: string
  app_version?: string
}

export interface WeatherData {
  temperature_c?: number
  humidity_percent?: number
  pressure_hpa?: number
  wind_speed_ms?: number
  wind_direction_deg?: number
  visibility_km?: number
  cloud_cover_percent?: number
  conditions?: string
  precipitation_mm?: number
}

export interface CelestialData {
  moon_phase?: string
  moon_illumination_percent?: number
  moon_altitude_deg?: number
  moon_azimuth_deg?: number
  sun_altitude_deg?: number
  sun_azimuth_deg?: number
  visible_planets: string[]
  satellite_passes: Record<string, any>[]
}

export interface MediaFile {
  id: string
  type: MediaType
  filename: string
  url: string
  thumbnail_url?: string
  web_url?: string
  preview_url?: string
  size_bytes: number
  duration_seconds?: number
  width?: number
  height?: number
  created_at: string
  metadata: Record<string, any>
  
  // Multi-media support fields
  is_primary: boolean
  uploaded_by_user_id?: string
  upload_order: number
  display_priority: number
  contributed_at?: string
}

export interface PlaneMatchResult {
  is_likely_aircraft: boolean
  confidence: number
  matched_aircraft?: Record<string, any>
  reason: string
  checked_at: string
}

export interface EnrichmentData {
  weather?: WeatherData
  celestial?: CelestialData
  plane_match?: PlaneMatchResult
  nearby_airports: Record<string, any>[]
  military_activity?: Record<string, any>
  processed_at: string
}

export interface SightingSubmission {
  title: string
  description: string
  category: SightingCategory
  sensor_data: SensorData
  media_files: string[]
  reporter_id?: string
  duration_seconds?: number
  witness_count: number
  tags: string[]
  is_public: boolean
  submitted_at: string
}

export interface Sighting {
  id: string
  title: string
  description: string
  category: SightingCategory
  sensor_data: SensorData
  media_files: MediaFile[]
  status: SightingStatus
  enrichment?: EnrichmentData
  jittered_location: GeoCoordinates
  alert_level: AlertLevel
  reporter_id?: string
  witness_count: number
  view_count: number
  verification_score: number
  matrix_room_id?: string
  submitted_at: string
  processed_at?: string
  verified_at?: string
  created_at: string
  updated_at: string
}

export interface AlertsQuery {
  center_lat?: number
  center_lng?: number
  radius_km?: number
  category?: SightingCategory
  status?: SightingStatus
  min_alert_level?: AlertLevel
  verified_only?: boolean
  offset?: number
  limit?: number
  since?: string
  until?: string
}

export interface AlertsFeed {
  sightings: Sighting[]
  total_count: number
  has_more: boolean
  query: AlertsQuery
  generated_at: string
}

export interface UserProfile {
  user_id: string
  alert_range_km: number
  min_alert_level: AlertLevel
  categories: SightingCategory[]
  push_notifications: boolean
  email_notifications: boolean
  quiet_hours_start?: string
  quiet_hours_end?: string
  share_location: boolean
  public_profile: boolean
  preferred_language: string
  units_metric: boolean
  matrix_user_id?: string
  matrix_device_id?: string
  created_at: string
  updated_at: string
}

// API Response types
export interface APIResponse {
  success: boolean
  message?: string
  timestamp: string
}

export interface DataResponse<T = any> extends APIResponse {
  data: T
}

export interface ErrorResponse extends APIResponse {
  success: false
  error_code?: string
  details?: Record<string, any>
}

export interface PaginatedResponse<T = any> extends APIResponse {
  data: T[]
  total_count: number
  offset: number
  limit: number
  has_more: boolean
}

// API Client types
export interface APIClientConfig {
  baseURL: string
  apiVersion: string
  timeout?: number
  headers?: Record<string, string>
}

export interface CreateSightingRequest extends SightingSubmission {}

export interface UpdateSightingRequest {
  title?: string
  description?: string
  category?: SightingCategory
  tags?: string[]
  is_public?: boolean
}

export interface GetSightingResponse extends DataResponse<Sighting> {}
export interface CreateSightingResponse extends DataResponse<{ sighting_id: string }> {}
export interface GetAlertsResponse extends DataResponse<AlertsFeed> {}
export interface GetUserProfileResponse extends DataResponse<UserProfile> {}

// Plane Match API types (existing)
export interface PlaneMatchRequest {
  sensor_data: {
    utc: string
    latitude: number
    longitude: number
    azimuth_deg: number
    pitch_deg: number
    roll_deg?: number
    hfov_deg?: number
    accuracy?: number
    altitude?: number
  }
  photo_path?: string
  description?: string
}

export interface PlaneMatchResponse extends APIResponse {
  data: {
    is_plane: boolean
    matched_flight?: {
      callsign?: string
      icao24?: string
      aircraft_type?: string
      origin?: string
      destination?: string
      altitude?: number
      velocity?: number
      angular_error: number
      display_name: string
      display_route: string
    }
    confidence: number
    reason: string
    timestamp: string
  }
}

// Upload/Media types
export interface PresignedUploadRequest {
  filename: string
  content_type: string
  size_bytes: number
  checksum?: string
}

export interface PresignedUploadResponse extends DataResponse<{
  upload_id: string
  upload_url: string
  fields: Record<string, string>
  expires_at: string
}> {}

export interface MediaUploadCompleteRequest {
  upload_id: string
  media_type: MediaType
  metadata?: Record<string, any>
}

export interface MediaUploadCompleteResponse extends DataResponse<MediaFile> {}

// Matrix/Chat types
export interface MatrixTokenRequest {
  sighting_id: string
}

export interface MatrixTokenResponse extends DataResponse<{
  access_token: string
  room_id: string
  server_name: string
  user_id: string
  expires_at: string
}> {}

export interface MatrixMessage {
  event_id: string
  sender: string
  timestamp: number
  content: {
    body: string
    msgtype: string
    [key: string]: any
  }
  formatted_timestamp?: string
}

export interface MatrixRoomInfo {
  room_id: string
  room_alias?: string
  room_name?: string
  topic?: string
  member_count: number
  join_url: string
  matrix_to_url: string
}

export interface MatrixTranscriptResponse extends DataResponse<{
  room_id: string
  messages: MatrixMessage[]
  total_messages: number
}> {}

export interface MatrixRoomInfoResponse extends DataResponse<MatrixRoomInfo> {}

// Utility types
export type APIError = ErrorResponse
export type APISuccess<T = any> = DataResponse<T> | PaginatedResponse<T>

// Type guards
export function isErrorResponse(response: APIResponse): response is ErrorResponse {
  return !response.success
}

export function isDataResponse<T>(response: APIResponse): response is DataResponse<T> {
  return response.success && 'data' in response
}

export function isPaginatedResponse<T>(response: APIResponse): response is PaginatedResponse<T> {
  return response.success && 'data' in response && 'total_count' in response
}