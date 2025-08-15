// UFOBeep API Models - Flutter/Dart Client
// Generated from shared API contracts

import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

// Enums
enum SightingCategory {
  @JsonValue('ufo')
  ufo,
  @JsonValue('anomaly')
  anomaly,
  @JsonValue('unknown')
  unknown,
}

enum SightingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('explained')
  explained,
  @JsonValue('rejected')
  rejected,
}

enum AlertLevel {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum MediaType {
  @JsonValue('photo')
  photo,
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
}

// Core data models
@JsonSerializable()
class GeoCoordinates {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;

  const GeoCoordinates({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
  });

  factory GeoCoordinates.fromJson(Map<String, dynamic> json) =>
      _$GeoCoordinatesFromJson(json);
  Map<String, dynamic> toJson() => _$GeoCoordinatesToJson(this);
}

@JsonSerializable()
class SensorDataApi {
  final DateTime timestamp;
  final GeoCoordinates location;
  @JsonKey(name: 'azimuth_deg')
  final double azimuthDeg;
  @JsonKey(name: 'pitch_deg')
  final double pitchDeg;
  @JsonKey(name: 'roll_deg')
  final double? rollDeg;
  @JsonKey(name: 'hfov_deg')
  final double? hfovDeg;
  @JsonKey(name: 'vfov_deg')
  final double? vfovDeg;
  @JsonKey(name: 'device_id')
  final String? deviceId;
  @JsonKey(name: 'app_version')
  final String? appVersion;

  const SensorDataApi({
    required this.timestamp,
    required this.location,
    required this.azimuthDeg,
    required this.pitchDeg,
    this.rollDeg,
    this.hfovDeg,
    this.vfovDeg,
    this.deviceId,
    this.appVersion,
  });

  factory SensorDataApi.fromJson(Map<String, dynamic> json) =>
      _$SensorDataApiFromJson(json);
  Map<String, dynamic> toJson() => _$SensorDataApiToJson(this);
}

@JsonSerializable()
class WeatherData {
  @JsonKey(name: 'temperature_c')
  final double? temperatureC;
  @JsonKey(name: 'humidity_percent')
  final double? humidityPercent;
  @JsonKey(name: 'pressure_hpa')
  final double? pressureHpa;
  @JsonKey(name: 'wind_speed_ms')
  final double? windSpeedMs;
  @JsonKey(name: 'wind_direction_deg')
  final double? windDirectionDeg;
  @JsonKey(name: 'visibility_km')
  final double? visibilityKm;
  @JsonKey(name: 'cloud_cover_percent')
  final double? cloudCoverPercent;
  final String? conditions;
  @JsonKey(name: 'precipitation_mm')
  final double? precipitationMm;

  const WeatherData({
    this.temperatureC,
    this.humidityPercent,
    this.pressureHpa,
    this.windSpeedMs,
    this.windDirectionDeg,
    this.visibilityKm,
    this.cloudCoverPercent,
    this.conditions,
    this.precipitationMm,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);
}

@JsonSerializable()
class CelestialData {
  @JsonKey(name: 'moon_phase')
  final String? moonPhase;
  @JsonKey(name: 'moon_illumination_percent')
  final double? moonIlluminationPercent;
  @JsonKey(name: 'moon_altitude_deg')
  final double? moonAltitudeDeg;
  @JsonKey(name: 'moon_azimuth_deg')
  final double? moonAzimuthDeg;
  @JsonKey(name: 'sun_altitude_deg')
  final double? sunAltitudeDeg;
  @JsonKey(name: 'sun_azimuth_deg')
  final double? sunAzimuthDeg;
  @JsonKey(name: 'visible_planets')
  final List<String> visiblePlanets;
  @JsonKey(name: 'satellite_passes')
  final List<Map<String, dynamic>> satellitePasses;

  const CelestialData({
    this.moonPhase,
    this.moonIlluminationPercent,
    this.moonAltitudeDeg,
    this.moonAzimuthDeg,
    this.sunAltitudeDeg,
    this.sunAzimuthDeg,
    this.visiblePlanets = const [],
    this.satellitePasses = const [],
  });

  factory CelestialData.fromJson(Map<String, dynamic> json) =>
      _$CelestialDataFromJson(json);
  Map<String, dynamic> toJson() => _$CelestialDataToJson(this);
}

@JsonSerializable()
class MediaFile {
  final String id;
  final MediaType type;
  final String filename;
  final String url;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'size_bytes')
  final int sizeBytes;
  @JsonKey(name: 'duration_seconds')
  final double? durationSeconds;
  final int? width;
  final int? height;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  
  // Multi-media support fields
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @JsonKey(name: 'uploaded_by_user_id')
  final String? uploadedByUserId;
  @JsonKey(name: 'upload_order')
  final int uploadOrder;
  @JsonKey(name: 'display_priority')
  final int displayPriority;
  @JsonKey(name: 'contributed_at')
  final DateTime? contributedAt;

  const MediaFile({
    required this.id,
    required this.type,
    required this.filename,
    required this.url,
    this.thumbnailUrl,
    required this.sizeBytes,
    this.durationSeconds,
    this.width,
    this.height,
    required this.createdAt,
    this.metadata = const {},
    this.isPrimary = false,
    this.uploadedByUserId,
    this.uploadOrder = 0,
    this.displayPriority = 0,
    this.contributedAt,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) =>
      _$MediaFileFromJson(json);
  Map<String, dynamic> toJson() => _$MediaFileToJson(this);
}

@JsonSerializable()
class PlaneMatchResult {
  @JsonKey(name: 'is_likely_aircraft')
  final bool isLikelyAircraft;
  final double confidence;
  @JsonKey(name: 'matched_aircraft')
  final Map<String, dynamic>? matchedAircraft;
  final String reason;
  @JsonKey(name: 'checked_at')
  final DateTime checkedAt;

  const PlaneMatchResult({
    required this.isLikelyAircraft,
    required this.confidence,
    this.matchedAircraft,
    required this.reason,
    required this.checkedAt,
  });

  factory PlaneMatchResult.fromJson(Map<String, dynamic> json) =>
      _$PlaneMatchResultFromJson(json);
  Map<String, dynamic> toJson() => _$PlaneMatchResultToJson(this);
}

@JsonSerializable()
class EnrichmentData {
  final WeatherData? weather;
  final CelestialData? celestial;
  @JsonKey(name: 'plane_match')
  final PlaneMatchResult? planeMatch;
  @JsonKey(name: 'nearby_airports')
  final List<Map<String, dynamic>> nearbyAirports;
  @JsonKey(name: 'military_activity')
  final Map<String, dynamic>? militaryActivity;
  @JsonKey(name: 'processed_at')
  final DateTime processedAt;

  const EnrichmentData({
    this.weather,
    this.celestial,
    this.planeMatch,
    this.nearbyAirports = const [],
    this.militaryActivity,
    required this.processedAt,
  });

  factory EnrichmentData.fromJson(Map<String, dynamic> json) =>
      _$EnrichmentDataFromJson(json);
  Map<String, dynamic> toJson() => _$EnrichmentDataToJson(this);
}

@JsonSerializable()
class SightingSubmission {
  final String title;
  final String description;
  final SightingCategory category;
  @JsonKey(name: 'sensor_data')
  final SensorDataApi? sensorData;
  @JsonKey(name: 'media_files')
  final List<String> mediaFiles;
  @JsonKey(name: 'reporter_id')
  final String? reporterId;
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @JsonKey(name: 'witness_count')
  final int witnessCount;
  final List<String> tags;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'submitted_at')
  final DateTime submittedAt;

  const SightingSubmission({
    required this.title,
    required this.description,
    required this.category,
    this.sensorData,
    this.mediaFiles = const [],
    this.reporterId,
    this.durationSeconds,
    this.witnessCount = 1,
    this.tags = const [],
    this.isPublic = true,
    required this.submittedAt,
  });

  factory SightingSubmission.fromJson(Map<String, dynamic> json) =>
      _$SightingSubmissionFromJson(json);
  Map<String, dynamic> toJson() => _$SightingSubmissionToJson(this);
}

@JsonSerializable()
class Sighting {
  final String id;
  final String title;
  final String description;
  final SightingCategory category;
  @JsonKey(name: 'sensor_data')
  final SensorDataApi sensorData;
  @JsonKey(name: 'media_files')
  final List<MediaFile> mediaFiles;
  final SightingStatus status;
  final EnrichmentData? enrichment;
  @JsonKey(name: 'jittered_location')
  final GeoCoordinates jitteredLocation;
  @JsonKey(name: 'alert_level')
  final AlertLevel alertLevel;
  @JsonKey(name: 'reporter_id')
  final String? reporterId;
  @JsonKey(name: 'witness_count')
  final int witnessCount;
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'verification_score')
  final double verificationScore;
  @JsonKey(name: 'matrix_room_id')
  final String? matrixRoomId;
  @JsonKey(name: 'submitted_at')
  final DateTime submittedAt;
  @JsonKey(name: 'processed_at')
  final DateTime? processedAt;
  @JsonKey(name: 'verified_at')
  final DateTime? verifiedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Sighting({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.sensorData,
    this.mediaFiles = const [],
    required this.status,
    this.enrichment,
    required this.jitteredLocation,
    required this.alertLevel,
    this.reporterId,
    required this.witnessCount,
    required this.viewCount,
    required this.verificationScore,
    this.matrixRoomId,
    required this.submittedAt,
    this.processedAt,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sighting.fromJson(Map<String, dynamic> json) =>
      _$SightingFromJson(json);
  Map<String, dynamic> toJson() => _$SightingToJson(this);
}

@JsonSerializable()
class AlertsQuery {
  @JsonKey(name: 'center_lat')
  final double? centerLat;
  @JsonKey(name: 'center_lng')
  final double? centerLng;
  @JsonKey(name: 'radius_km')
  final double? radiusKm;
  final SightingCategory? category;
  final SightingStatus? status;
  @JsonKey(name: 'min_alert_level')
  final AlertLevel? minAlertLevel;
  @JsonKey(name: 'verified_only')
  final bool verifiedOnly;
  final int offset;
  final int limit;
  final DateTime? since;
  final DateTime? until;

  const AlertsQuery({
    this.centerLat,
    this.centerLng,
    this.radiusKm,
    this.category,
    this.status,
    this.minAlertLevel,
    this.verifiedOnly = false,
    this.offset = 0,
    this.limit = 20,
    this.since,
    this.until,
  });

  factory AlertsQuery.fromJson(Map<String, dynamic> json) =>
      _$AlertsQueryFromJson(json);
  Map<String, dynamic> toJson() => _$AlertsQueryToJson(this);
}

@JsonSerializable()
class AlertsFeed {
  final List<Sighting> sightings;
  @JsonKey(name: 'total_count')
  final int totalCount;
  @JsonKey(name: 'has_more')
  final bool hasMore;
  final AlertsQuery query;
  @JsonKey(name: 'generated_at')
  final DateTime generatedAt;

  const AlertsFeed({
    required this.sightings,
    required this.totalCount,
    required this.hasMore,
    required this.query,
    required this.generatedAt,
  });

  factory AlertsFeed.fromJson(Map<String, dynamic> json) =>
      _$AlertsFeedFromJson(json);
  Map<String, dynamic> toJson() => _$AlertsFeedToJson(this);
}

@JsonSerializable()
class UserProfile {
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'alert_range_km')
  final double alertRangeKm;
  @JsonKey(name: 'min_alert_level')
  final AlertLevel minAlertLevel;
  final List<SightingCategory> categories;
  @JsonKey(name: 'push_notifications')
  final bool pushNotifications;
  @JsonKey(name: 'email_notifications')
  final bool emailNotifications;
  @JsonKey(name: 'quiet_hours_start')
  final String? quietHoursStart;
  @JsonKey(name: 'quiet_hours_end')
  final String? quietHoursEnd;
  @JsonKey(name: 'share_location')
  final bool shareLocation;
  @JsonKey(name: 'public_profile')
  final bool publicProfile;
  @JsonKey(name: 'preferred_language')
  final String preferredLanguage;
  @JsonKey(name: 'units_metric')
  final bool unitsMetric;
  @JsonKey(name: 'matrix_user_id')
  final String? matrixUserId;
  @JsonKey(name: 'matrix_device_id')
  final String? matrixDeviceId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const UserProfile({
    required this.userId,
    this.alertRangeKm = 50.0,
    this.minAlertLevel = AlertLevel.low,
    this.categories = const [SightingCategory.ufo, SightingCategory.anomaly, SightingCategory.unknown],
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.shareLocation = true,
    this.publicProfile = false,
    this.preferredLanguage = 'en',
    this.unitsMetric = true,
    this.matrixUserId,
    this.matrixDeviceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

// API Response types
@JsonSerializable()
class APIResponse {
  final bool success;
  final String? message;
  final DateTime timestamp;

  const APIResponse({
    required this.success,
    this.message,
    required this.timestamp,
  });

  factory APIResponse.fromJson(Map<String, dynamic> json) =>
      _$APIResponseFromJson(json);
  Map<String, dynamic> toJson() => _$APIResponseToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
class DataResponse<T> extends APIResponse {
  final T data;

  const DataResponse({
    required bool success,
    String? message,
    required DateTime timestamp,
    required this.data,
  }) : super(success: success, message: message, timestamp: timestamp);

  factory DataResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$DataResponseFromJson(json, fromJsonT);

  @override
  Map<String, dynamic> toJson() => _$DataResponseToJson(this, (value) => value);
}

@JsonSerializable()
class ErrorResponse extends APIResponse {
  @override
  final bool success = false;
  @JsonKey(name: 'error_code')
  final String? errorCode;
  final Map<String, dynamic>? details;

  const ErrorResponse({
    String? message,
    required DateTime timestamp,
    this.errorCode,
    this.details,
  }) : super(success: false, message: message, timestamp: timestamp);

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> extends APIResponse {
  final List<T> data;
  @JsonKey(name: 'total_count')
  final int totalCount;
  final int offset;
  final int limit;
  @JsonKey(name: 'has_more')
  final bool hasMore;

  const PaginatedResponse({
    required bool success,
    String? message,
    required DateTime timestamp,
    required this.data,
    required this.totalCount,
    required this.offset,
    required this.limit,
    required this.hasMore,
  }) : super(success: success, message: message, timestamp: timestamp);

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  @override
  Map<String, dynamic> toJson() => _$PaginatedResponseToJson(this, (value) => value);
}

// API Client helper types
typedef CreateSightingRequest = SightingSubmission;

@JsonSerializable()
class UpdateSightingRequest {
  final String? title;
  final String? description;
  final SightingCategory? category;
  final List<String>? tags;
  @JsonKey(name: 'is_public')
  final bool? isPublic;

  const UpdateSightingRequest({
    this.title,
    this.description,
    this.category,
    this.tags,
    this.isPublic,
  });

  factory UpdateSightingRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSightingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateSightingRequestToJson(this);
}

// Specialized response types
typedef GetSightingResponse = DataResponse<Sighting>;
typedef CreateSightingResponse = DataResponse<Map<String, String>>;
typedef GetAlertsResponse = DataResponse<AlertsFeed>;
typedef GetUserProfileResponse = DataResponse<UserProfile>;

// Upload/Media types
@JsonSerializable()
class PresignedUploadRequest {
  final String filename;
  @JsonKey(name: 'content_type')
  final String contentType;
  @JsonKey(name: 'size_bytes')
  final int sizeBytes;
  final String? checksum;

  const PresignedUploadRequest({
    required this.filename,
    required this.contentType,
    required this.sizeBytes,
    this.checksum,
  });

  factory PresignedUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$PresignedUploadRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PresignedUploadRequestToJson(this);
}

@JsonSerializable()
class PresignedUploadData {
  @JsonKey(name: 'upload_id')
  final String uploadId;
  @JsonKey(name: 'upload_url')
  final String uploadUrl;
  final Map<String, String> fields;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  const PresignedUploadData({
    required this.uploadId,
    required this.uploadUrl,
    required this.fields,
    required this.expiresAt,
  });

  factory PresignedUploadData.fromJson(Map<String, dynamic> json) =>
      _$PresignedUploadDataFromJson(json);
  Map<String, dynamic> toJson() => _$PresignedUploadDataToJson(this);
}

typedef PresignedUploadResponse = DataResponse<PresignedUploadData>;

@JsonSerializable()
class MediaUploadCompleteRequest {
  @JsonKey(name: 'upload_id')
  final String uploadId;
  @JsonKey(name: 'media_type')
  final MediaType mediaType;
  final Map<String, dynamic>? metadata;

  const MediaUploadCompleteRequest({
    required this.uploadId,
    required this.mediaType,
    this.metadata,
  });

  factory MediaUploadCompleteRequest.fromJson(Map<String, dynamic> json) =>
      _$MediaUploadCompleteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MediaUploadCompleteRequestToJson(this);
}

typedef MediaUploadCompleteResponse = DataResponse<MediaFile>;

// Matrix/Chat types
@JsonSerializable()
class MatrixTokenRequest {
  @JsonKey(name: 'sighting_id')
  final String sightingId;

  const MatrixTokenRequest({
    required this.sightingId,
  });

  factory MatrixTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$MatrixTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MatrixTokenRequestToJson(this);
}

@JsonSerializable()
class MatrixTokenData {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'room_id')
  final String roomId;
  @JsonKey(name: 'server_name')
  final String serverName;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  const MatrixTokenData({
    required this.accessToken,
    required this.roomId,
    required this.serverName,
    required this.userId,
    required this.expiresAt,
  });

  factory MatrixTokenData.fromJson(Map<String, dynamic> json) =>
      _$MatrixTokenDataFromJson(json);
  Map<String, dynamic> toJson() => _$MatrixTokenDataToJson(this);
}

typedef MatrixTokenResponse = DataResponse<MatrixTokenData>;