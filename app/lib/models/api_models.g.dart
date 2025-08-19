// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoCoordinates _$GeoCoordinatesFromJson(Map<String, dynamic> json) =>
    GeoCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$GeoCoordinatesToJson(GeoCoordinates instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'accuracy': instance.accuracy,
    };

SensorDataApi _$SensorDataApiFromJson(Map<String, dynamic> json) =>
    SensorDataApi(
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: GeoCoordinates.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      azimuthDeg: (json['azimuth_deg'] as num).toDouble(),
      pitchDeg: (json['pitch_deg'] as num).toDouble(),
      rollDeg: (json['roll_deg'] as num?)?.toDouble(),
      hfovDeg: (json['hfov_deg'] as num?)?.toDouble(),
      vfovDeg: (json['vfov_deg'] as num?)?.toDouble(),
      deviceId: json['device_id'] as String?,
      appVersion: json['app_version'] as String?,
    );

Map<String, dynamic> _$SensorDataApiToJson(SensorDataApi instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'location': instance.location,
      'azimuth_deg': instance.azimuthDeg,
      'pitch_deg': instance.pitchDeg,
      'roll_deg': instance.rollDeg,
      'hfov_deg': instance.hfovDeg,
      'vfov_deg': instance.vfovDeg,
      'device_id': instance.deviceId,
      'app_version': instance.appVersion,
    };

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) => WeatherData(
  temperatureC: (json['temperature_c'] as num?)?.toDouble(),
  humidityPercent: (json['humidity_percent'] as num?)?.toDouble(),
  pressureHpa: (json['pressure_hpa'] as num?)?.toDouble(),
  windSpeedMs: (json['wind_speed_ms'] as num?)?.toDouble(),
  windDirectionDeg: (json['wind_direction_deg'] as num?)?.toDouble(),
  visibilityKm: (json['visibility_km'] as num?)?.toDouble(),
  cloudCoverPercent: (json['cloud_cover_percent'] as num?)?.toDouble(),
  conditions: json['conditions'] as String?,
  precipitationMm: (json['precipitation_mm'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WeatherDataToJson(WeatherData instance) =>
    <String, dynamic>{
      'temperature_c': instance.temperatureC,
      'humidity_percent': instance.humidityPercent,
      'pressure_hpa': instance.pressureHpa,
      'wind_speed_ms': instance.windSpeedMs,
      'wind_direction_deg': instance.windDirectionDeg,
      'visibility_km': instance.visibilityKm,
      'cloud_cover_percent': instance.cloudCoverPercent,
      'conditions': instance.conditions,
      'precipitation_mm': instance.precipitationMm,
    };

CelestialData _$CelestialDataFromJson(Map<String, dynamic> json) =>
    CelestialData(
      moonPhase: json['moon_phase'] as String?,
      moonIlluminationPercent: (json['moon_illumination_percent'] as num?)
          ?.toDouble(),
      moonAltitudeDeg: (json['moon_altitude_deg'] as num?)?.toDouble(),
      moonAzimuthDeg: (json['moon_azimuth_deg'] as num?)?.toDouble(),
      sunAltitudeDeg: (json['sun_altitude_deg'] as num?)?.toDouble(),
      sunAzimuthDeg: (json['sun_azimuth_deg'] as num?)?.toDouble(),
      visiblePlanets:
          (json['visible_planets'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      satellitePasses:
          (json['satellite_passes'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CelestialDataToJson(CelestialData instance) =>
    <String, dynamic>{
      'moon_phase': instance.moonPhase,
      'moon_illumination_percent': instance.moonIlluminationPercent,
      'moon_altitude_deg': instance.moonAltitudeDeg,
      'moon_azimuth_deg': instance.moonAzimuthDeg,
      'sun_altitude_deg': instance.sunAltitudeDeg,
      'sun_azimuth_deg': instance.sunAzimuthDeg,
      'visible_planets': instance.visiblePlanets,
      'satellite_passes': instance.satellitePasses,
    };

MediaFile _$MediaFileFromJson(Map<String, dynamic> json) => MediaFile(
  id: json['id'] as String,
  type: $enumDecode(_$MediaTypeEnumMap, json['type']),
  filename: json['filename'] as String,
  url: json['url'] as String,
  thumbnailUrl: json['thumbnail_url'] as String?,
  webUrl: json['web_url'] as String?,
  previewUrl: json['preview_url'] as String?,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  isPrimary: json['is_primary'] as bool? ?? false,
  uploadedByUserId: json['uploaded_by_user_id'] as String?,
  uploadOrder: (json['upload_order'] as num?)?.toInt() ?? 0,
  displayPriority: (json['display_priority'] as num?)?.toInt() ?? 0,
  contributedAt: json['contributed_at'] == null
      ? null
      : DateTime.parse(json['contributed_at'] as String),
);

Map<String, dynamic> _$MediaFileToJson(MediaFile instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$MediaTypeEnumMap[instance.type]!,
  'filename': instance.filename,
  'url': instance.url,
  'thumbnail_url': instance.thumbnailUrl,
  'web_url': instance.webUrl,
  'preview_url': instance.previewUrl,
  'size_bytes': instance.sizeBytes,
  'duration_seconds': instance.durationSeconds,
  'width': instance.width,
  'height': instance.height,
  'created_at': instance.createdAt.toIso8601String(),
  'metadata': instance.metadata,
  'is_primary': instance.isPrimary,
  'uploaded_by_user_id': instance.uploadedByUserId,
  'upload_order': instance.uploadOrder,
  'display_priority': instance.displayPriority,
  'contributed_at': instance.contributedAt?.toIso8601String(),
};

const _$MediaTypeEnumMap = {
  MediaType.photo: 'photo',
  MediaType.video: 'video',
  MediaType.audio: 'audio',
};

PlaneMatchResult _$PlaneMatchResultFromJson(Map<String, dynamic> json) =>
    PlaneMatchResult(
      isLikelyAircraft: json['is_likely_aircraft'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      matchedAircraft: json['matched_aircraft'] as Map<String, dynamic>?,
      reason: json['reason'] as String,
      checkedAt: DateTime.parse(json['checked_at'] as String),
    );

Map<String, dynamic> _$PlaneMatchResultToJson(PlaneMatchResult instance) =>
    <String, dynamic>{
      'is_likely_aircraft': instance.isLikelyAircraft,
      'confidence': instance.confidence,
      'matched_aircraft': instance.matchedAircraft,
      'reason': instance.reason,
      'checked_at': instance.checkedAt.toIso8601String(),
    };

EnrichmentData _$EnrichmentDataFromJson(Map<String, dynamic> json) =>
    EnrichmentData(
      weather: json['weather'] == null
          ? null
          : WeatherData.fromJson(json['weather'] as Map<String, dynamic>),
      celestial: json['celestial'] == null
          ? null
          : CelestialData.fromJson(json['celestial'] as Map<String, dynamic>),
      planeMatch: json['plane_match'] == null
          ? null
          : PlaneMatchResult.fromJson(
              json['plane_match'] as Map<String, dynamic>,
            ),
      nearbyAirports:
          (json['nearby_airports'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      militaryActivity: json['military_activity'] as Map<String, dynamic>?,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );

Map<String, dynamic> _$EnrichmentDataToJson(EnrichmentData instance) =>
    <String, dynamic>{
      'weather': instance.weather,
      'celestial': instance.celestial,
      'plane_match': instance.planeMatch,
      'nearby_airports': instance.nearbyAirports,
      'military_activity': instance.militaryActivity,
      'processed_at': instance.processedAt.toIso8601String(),
    };

SightingSubmission _$SightingSubmissionFromJson(Map<String, dynamic> json) =>
    SightingSubmission(
      title: json['title'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$SightingCategoryEnumMap, json['category']),
      sensorData: json['sensor_data'] == null
          ? null
          : SensorDataApi.fromJson(json['sensor_data'] as Map<String, dynamic>),
      mediaFiles:
          (json['media_files'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      reporterId: json['reporter_id'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      witnessCount: (json['witness_count'] as num?)?.toInt() ?? 1,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      isPublic: json['is_public'] as bool? ?? true,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
    );

Map<String, dynamic> _$SightingSubmissionToJson(SightingSubmission instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': _$SightingCategoryEnumMap[instance.category]!,
      'sensor_data': instance.sensorData,
      'media_files': instance.mediaFiles,
      'reporter_id': instance.reporterId,
      'duration_seconds': instance.durationSeconds,
      'witness_count': instance.witnessCount,
      'tags': instance.tags,
      'is_public': instance.isPublic,
      'submitted_at': instance.submittedAt.toIso8601String(),
    };

const _$SightingCategoryEnumMap = {
  SightingCategory.ufo: 'ufo',
  SightingCategory.anomaly: 'anomaly',
  SightingCategory.unknown: 'unknown',
};

Sighting _$SightingFromJson(Map<String, dynamic> json) => Sighting(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$SightingCategoryEnumMap, json['category']),
  sensorData: SensorDataApi.fromJson(
    json['sensor_data'] as Map<String, dynamic>,
  ),
  mediaFiles:
      (json['media_files'] as List<dynamic>?)
          ?.map((e) => MediaFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status: $enumDecode(_$SightingStatusEnumMap, json['status']),
  enrichment: json['enrichment'] == null
      ? null
      : EnrichmentData.fromJson(json['enrichment'] as Map<String, dynamic>),
  jitteredLocation: GeoCoordinates.fromJson(
    json['jittered_location'] as Map<String, dynamic>,
  ),
  alertLevel: $enumDecode(_$AlertLevelEnumMap, json['alert_level']),
  reporterId: json['reporter_id'] as String?,
  witnessCount: (json['witness_count'] as num).toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  verificationScore: (json['verification_score'] as num).toDouble(),
  matrixRoomId: json['matrix_room_id'] as String?,
  submittedAt: DateTime.parse(json['submitted_at'] as String),
  processedAt: json['processed_at'] == null
      ? null
      : DateTime.parse(json['processed_at'] as String),
  verifiedAt: json['verified_at'] == null
      ? null
      : DateTime.parse(json['verified_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SightingToJson(Sighting instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': _$SightingCategoryEnumMap[instance.category]!,
  'sensor_data': instance.sensorData,
  'media_files': instance.mediaFiles,
  'status': _$SightingStatusEnumMap[instance.status]!,
  'enrichment': instance.enrichment,
  'jittered_location': instance.jitteredLocation,
  'alert_level': _$AlertLevelEnumMap[instance.alertLevel]!,
  'reporter_id': instance.reporterId,
  'witness_count': instance.witnessCount,
  'view_count': instance.viewCount,
  'verification_score': instance.verificationScore,
  'matrix_room_id': instance.matrixRoomId,
  'submitted_at': instance.submittedAt.toIso8601String(),
  'processed_at': instance.processedAt?.toIso8601String(),
  'verified_at': instance.verifiedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$SightingStatusEnumMap = {
  SightingStatus.pending: 'pending',
  SightingStatus.verified: 'verified',
  SightingStatus.explained: 'explained',
  SightingStatus.rejected: 'rejected',
};

const _$AlertLevelEnumMap = {
  AlertLevel.low: 'low',
  AlertLevel.medium: 'medium',
  AlertLevel.high: 'high',
  AlertLevel.critical: 'critical',
};

AlertsQuery _$AlertsQueryFromJson(Map<String, dynamic> json) => AlertsQuery(
  centerLat: (json['center_lat'] as num?)?.toDouble(),
  centerLng: (json['center_lng'] as num?)?.toDouble(),
  radiusKm: (json['radius_km'] as num?)?.toDouble(),
  category: $enumDecodeNullable(_$SightingCategoryEnumMap, json['category']),
  status: $enumDecodeNullable(_$SightingStatusEnumMap, json['status']),
  minAlertLevel: $enumDecodeNullable(
    _$AlertLevelEnumMap,
    json['min_alert_level'],
  ),
  verifiedOnly: json['verified_only'] as bool? ?? false,
  offset: (json['offset'] as num?)?.toInt() ?? 0,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
  since: json['since'] == null ? null : DateTime.parse(json['since'] as String),
  until: json['until'] == null ? null : DateTime.parse(json['until'] as String),
);

Map<String, dynamic> _$AlertsQueryToJson(AlertsQuery instance) =>
    <String, dynamic>{
      'center_lat': instance.centerLat,
      'center_lng': instance.centerLng,
      'radius_km': instance.radiusKm,
      'category': _$SightingCategoryEnumMap[instance.category],
      'status': _$SightingStatusEnumMap[instance.status],
      'min_alert_level': _$AlertLevelEnumMap[instance.minAlertLevel],
      'verified_only': instance.verifiedOnly,
      'offset': instance.offset,
      'limit': instance.limit,
      'since': instance.since?.toIso8601String(),
      'until': instance.until?.toIso8601String(),
    };

AlertsFeed _$AlertsFeedFromJson(Map<String, dynamic> json) => AlertsFeed(
  sightings: (json['sightings'] as List<dynamic>)
      .map((e) => Sighting.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['total_count'] as num).toInt(),
  hasMore: json['has_more'] as bool,
  query: AlertsQuery.fromJson(json['query'] as Map<String, dynamic>),
  generatedAt: DateTime.parse(json['generated_at'] as String),
);

Map<String, dynamic> _$AlertsFeedToJson(AlertsFeed instance) =>
    <String, dynamic>{
      'sightings': instance.sightings,
      'total_count': instance.totalCount,
      'has_more': instance.hasMore,
      'query': instance.query,
      'generated_at': instance.generatedAt.toIso8601String(),
    };

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  userId: json['user_id'] as String,
  alertRangeKm: (json['alert_range_km'] as num?)?.toDouble() ?? 50.0,
  minAlertLevel:
      $enumDecodeNullable(_$AlertLevelEnumMap, json['min_alert_level']) ??
      AlertLevel.low,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SightingCategoryEnumMap, e))
          .toList() ??
      const [
        SightingCategory.ufo,
        SightingCategory.anomaly,
        SightingCategory.unknown,
      ],
  pushNotifications: json['push_notifications'] as bool? ?? true,
  emailNotifications: json['email_notifications'] as bool? ?? false,
  quietHoursStart: json['quiet_hours_start'] as String?,
  quietHoursEnd: json['quiet_hours_end'] as String?,
  shareLocation: json['share_location'] as bool? ?? true,
  publicProfile: json['public_profile'] as bool? ?? false,
  preferredLanguage: json['preferred_language'] as String? ?? 'en',
  unitsMetric: json['units_metric'] as bool? ?? true,
  matrixUserId: json['matrix_user_id'] as String?,
  matrixDeviceId: json['matrix_device_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'alert_range_km': instance.alertRangeKm,
      'min_alert_level': _$AlertLevelEnumMap[instance.minAlertLevel]!,
      'categories': instance.categories
          .map((e) => _$SightingCategoryEnumMap[e]!)
          .toList(),
      'push_notifications': instance.pushNotifications,
      'email_notifications': instance.emailNotifications,
      'quiet_hours_start': instance.quietHoursStart,
      'quiet_hours_end': instance.quietHoursEnd,
      'share_location': instance.shareLocation,
      'public_profile': instance.publicProfile,
      'preferred_language': instance.preferredLanguage,
      'units_metric': instance.unitsMetric,
      'matrix_user_id': instance.matrixUserId,
      'matrix_device_id': instance.matrixDeviceId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

APIResponse _$APIResponseFromJson(Map<String, dynamic> json) => APIResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$APIResponseToJson(APIResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
    };

DataResponse<T> _$DataResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => DataResponse<T>(
  success: json['success'] as bool,
  message: json['message'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  data: fromJsonT(json['data']),
);

Map<String, dynamic> _$DataResponseToJson<T>(
  DataResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'timestamp': instance.timestamp.toIso8601String(),
  'data': toJsonT(instance.data),
};

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      message: json['message'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      errorCode: json['error_code'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'error_code': instance.errorCode,
      'details': instance.details,
    };

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedResponse<T>(
  success: json['success'] as bool,
  message: json['message'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
  totalCount: (json['total_count'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  hasMore: json['has_more'] as bool,
);

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'timestamp': instance.timestamp.toIso8601String(),
  'data': instance.data.map(toJsonT).toList(),
  'total_count': instance.totalCount,
  'offset': instance.offset,
  'limit': instance.limit,
  'has_more': instance.hasMore,
};

UpdateSightingRequest _$UpdateSightingRequestFromJson(
  Map<String, dynamic> json,
) => UpdateSightingRequest(
  title: json['title'] as String?,
  description: json['description'] as String?,
  category: $enumDecodeNullable(_$SightingCategoryEnumMap, json['category']),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isPublic: json['is_public'] as bool?,
);

Map<String, dynamic> _$UpdateSightingRequestToJson(
  UpdateSightingRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'category': _$SightingCategoryEnumMap[instance.category],
  'tags': instance.tags,
  'is_public': instance.isPublic,
};

PresignedUploadRequest _$PresignedUploadRequestFromJson(
  Map<String, dynamic> json,
) => PresignedUploadRequest(
  filename: json['filename'] as String,
  contentType: json['content_type'] as String,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  checksum: json['checksum'] as String?,
);

Map<String, dynamic> _$PresignedUploadRequestToJson(
  PresignedUploadRequest instance,
) => <String, dynamic>{
  'filename': instance.filename,
  'content_type': instance.contentType,
  'size_bytes': instance.sizeBytes,
  'checksum': instance.checksum,
};

PresignedUploadData _$PresignedUploadDataFromJson(Map<String, dynamic> json) =>
    PresignedUploadData(
      uploadId: json['upload_id'] as String,
      uploadUrl: json['upload_url'] as String,
      fields: Map<String, String>.from(json['fields'] as Map),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$PresignedUploadDataToJson(
  PresignedUploadData instance,
) => <String, dynamic>{
  'upload_id': instance.uploadId,
  'upload_url': instance.uploadUrl,
  'fields': instance.fields,
  'expires_at': instance.expiresAt.toIso8601String(),
};

MediaUploadCompleteRequest _$MediaUploadCompleteRequestFromJson(
  Map<String, dynamic> json,
) => MediaUploadCompleteRequest(
  uploadId: json['upload_id'] as String,
  mediaType: $enumDecode(_$MediaTypeEnumMap, json['media_type']),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MediaUploadCompleteRequestToJson(
  MediaUploadCompleteRequest instance,
) => <String, dynamic>{
  'upload_id': instance.uploadId,
  'media_type': _$MediaTypeEnumMap[instance.mediaType]!,
  'metadata': instance.metadata,
};

MatrixTokenRequest _$MatrixTokenRequestFromJson(Map<String, dynamic> json) =>
    MatrixTokenRequest(sightingId: json['sighting_id'] as String);

Map<String, dynamic> _$MatrixTokenRequestToJson(MatrixTokenRequest instance) =>
    <String, dynamic>{'sighting_id': instance.sightingId};

MatrixTokenData _$MatrixTokenDataFromJson(Map<String, dynamic> json) =>
    MatrixTokenData(
      accessToken: json['access_token'] as String,
      roomId: json['room_id'] as String,
      serverName: json['server_name'] as String,
      userId: json['user_id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$MatrixTokenDataToJson(MatrixTokenData instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'room_id': instance.roomId,
      'server_name': instance.serverName,
      'user_id': instance.userId,
      'expires_at': instance.expiresAt.toIso8601String(),
    };
