import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/environment.dart';
import '../models/api_models.dart' as api;
import '../models/sensor_data.dart';
import '../models/sighting_submission.dart' as local;
import '../utils/type_safe_json.dart';
import 'beep_service.dart';
import 'auth_interceptor.dart';

class ApiClientException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  ApiClientException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiClientException: $message';
}

class ApiClient {
  static ApiClient? _instance;
  String? _authToken;
  
  // ChatGPT: Static dio access for AuthRepository and AuthInterceptor
  static final Dio dio = Dio(BaseOptions(
    baseUrl: AppEnvironment.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static void init() {
    // ChatGPT: Ensure interceptor is installed once.
    if (!dio.interceptors.any((i) => i is AuthInterceptor)) {
      dio.interceptors.add(AuthInterceptor());
    }
  }

  static void setBearer(String access) {
    dio.options.headers['Authorization'] = 'Bearer $access';
  }

  static void clearBearer() {
    dio.options.headers.remove('Authorization');
  }

  // Singleton pattern
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal();


  // Authentication
  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  bool get isAuthenticated => _authToken != null;

  // Helper method to handle API responses with type safety
  T _handleResponse<T>(Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      try {
        // Use type-safe parsing to prevent index casting errors
        final safeData = TypeSafeJson.asMap(response.data, context: "api_response");
        
        if (TypeSafeJson.isConvertedList(safeData)) {
          TypeSafeJson.logTypeMismatch("Map", response.data, "api_response");
          throw ApiClientException('API returned unexpected List instead of object', statusCode: response.statusCode);
        }
        
        final success = safeData.safeBool('success', defaultValue: false);
        if (success == true) {
          return fromJson(safeData);
        } else {
          final message = safeData.safeString('message') ?? 'API request failed';
          throw ApiClientException(
            message,
            statusCode: response.statusCode,
            details: safeData,
          );
        }
      } catch (e) {
        if (e is ApiClientException) {
          rethrow;
        }
        // Catch any type casting errors and provide better context
        debugPrint('🔴 API Response parsing error: $e');
        debugPrint('🔴 Response data type: ${response.data.runtimeType}');
        debugPrint('🔴 Response data: ${response.data}');
        throw ApiClientException(
          'Failed to parse API response: ${e.toString()}',
          statusCode: response.statusCode,
        );
      }
    } else {
      throw ApiClientException(
        'HTTP ${response.statusCode}: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle API errors
  ApiClientException _handleError(DioException error) {
    if (error.response != null) {
      final responseData = error.response!.data;
      String message = 'API request failed';
      Map<String, dynamic>? details;

      if (responseData is Map<String, dynamic>) {
        message = responseData['message'] ?? responseData['detail']?['message'] ?? message;
        details = responseData['detail'] ?? responseData;
      }

      return ApiClientException(
        message,
        statusCode: error.response!.statusCode,
        details: details,
      );
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiClientException('Connection timeout. Please check your internet connection.');
        case DioExceptionType.connectionError:
          return ApiClientException('Connection error. Please check your internet connection.');
        case DioExceptionType.cancel:
          return ApiClientException('Request was cancelled');
        default:
          return ApiClientException('Network error: ${error.message}');
      }
    }
  }

  // Safe response parsing to handle different response types
  Map<String, dynamic> _safeResponseToMap(dynamic responseData, {String context = 'API response'}) {
    debugPrint('=== SAFE RESPONSE PARSING ===');
    debugPrint('Context: $context');
    debugPrint('Response type: ${responseData.runtimeType}');
    debugPrint('Response value: $responseData');

    if (responseData is Map<String, dynamic>) {
      debugPrint('✅ Response is already a Map');
      return responseData;
    } else if (responseData is List && responseData.isNotEmpty) {
      debugPrint('⚠️ Response is a List, attempting to extract first Map element');
      if (responseData.first is Map<String, dynamic>) {
        debugPrint('✅ First element is a Map, using it');
        return responseData.first as Map<String, dynamic>;
      } else {
        debugPrint('❌ First element is not a Map, wrapping List in data field');
        return {'success': true, 'data': responseData};
      }
    } else if (responseData is String) {
      debugPrint('⚠️ Response is a String, wrapping in message field');
      return {'success': true, 'message': responseData};
    } else {
      debugPrint('❌ Unknown response type, creating error response');
      return {
        'success': false,
        'error': 'Invalid response type: ${responseData.runtimeType}',
        'raw_response': responseData.toString()
      };
    }
  }

  // Sighting endpoints
  Future<api.CreateSightingResponse> submitSighting(api.SightingSubmission submission) async {
    try {
      final response = await ApiClient.dio.post(
        '/beep',
        data: submission.toJson(),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return api.CreateSightingResponse(
            success: data['success'],
            message: data['message'] ?? 'Sighting created successfully',
            timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
            data: data['data'] ?? {},
          );
        } else {
          throw ApiClientException(
            data['message'] ?? 'API request failed',
            statusCode: response.statusCode,
            details: data,
          );
        }
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Simplified sighting list for now - returning raw JSON
  Future<Map<String, dynamic>> listSightings({
    int limit = 20,
    int offset = 0,
    String? category,
    String? status,
    String? minAlertLevel,
    bool verifiedOnly = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'verified_only': verifiedOnly,
      };

      if (category != null) {
        queryParams['category'] = category.toLowerCase();
      }
      if (status != null) {
        queryParams['status'] = status.toLowerCase();
      }
      if (minAlertLevel != null) {
        queryParams['min_alert_level'] = minAlertLevel.toLowerCase();
      }

      final response = await ApiClient.dio.get(
        '/beep',
        queryParameters: queryParams,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Media upload endpoints
  Future<api.PresignedUploadResponse> getPresignedUpload(api.PresignedUploadRequest request) async {
    try {
      final response = await ApiClient.dio.post(
        '/media/presign',
        data: request.toJson(),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return api.PresignedUploadResponse(
            success: data['success'],
            message: data['message'] ?? 'Upload URL created successfully',
            timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
            data: api.PresignedUploadData.fromJson(data['data'] as Map<String, dynamic>),
          );
        } else {
          throw ApiClientException(
            data['message'] ?? 'Failed to create upload URL',
            statusCode: response.statusCode,
            details: data,
          );
        }
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<api.MediaUploadCompleteResponse> completeMediaUpload(api.MediaUploadCompleteRequest request) async {
    try {
      final response = await ApiClient.dio.post(
        '/media/complete',
        data: request.toJson(),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return api.MediaUploadCompleteResponse(
            success: data['success'],
            message: data['message'] ?? 'Upload completed successfully',
            timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
            data: api.MediaFile.fromJson(data['data'] as Map<String, dynamic>),
          );
        } else {
          throw ApiClientException(
            data['message'] ?? 'Failed to complete upload',
            statusCode: response.statusCode,
            details: data,
          );
        }
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Simplified bulk upload - returning raw JSON for now
  Future<Map<String, dynamic>> getBulkPresignedUploads(
    List<Map<String, dynamic>> requests, {
    String? sightingId,
  }) async {
    try {
      final bulkRequest = {
        'files': requests,
        if (sightingId != null) 'sighting_id': sightingId,
      };

      final response = await ApiClient.dio.post(
        '/media/bulk-presign',
        data: bulkRequest,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  // Plane matching endpoint - simplified for now
  Future<Map<String, dynamic>> checkPlaneMatch({
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required double azimuthDeg,
    required double pitchDeg,
    double? rollDeg,
    double? hfovDeg,
    double? accuracy,
    double? altitude,
    String? photoPath,
    String? description,
  }) async {
    try {
      final request = {
        'sensor_data': {
          'utc': timestamp.toIso8601String(),
          'latitude': latitude,
          'longitude': longitude,
          'azimuth_deg': azimuthDeg,
          'pitch_deg': pitchDeg,
          if (rollDeg != null) 'roll_deg': rollDeg,
          if (hfovDeg != null) 'hfov_deg': hfovDeg,
          if (accuracy != null) 'accuracy': accuracy,
          if (altitude != null) 'altitude': altitude,
        },
        if (photoPath != null) 'photo_path': photoPath,
        if (description != null) 'description': description,
      };

      final response = await ApiClient.dio.post(
        '/plane-match',
        data: request,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Alerts endpoints
  Future<Map<String, dynamic>> listAlerts({
    int limit = 20,
    int offset = 0,
    String? category,
    String? minAlertLevel,
    double? maxDistanceKm,
    double? latitude,
    double? longitude,
    int? recentHours,
    bool verifiedOnly = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'verified_only': verifiedOnly,
      };

      if (category != null) {
        queryParams['category'] = category.toLowerCase();
      }
      if (minAlertLevel != null) {
        queryParams['min_alert_level'] = minAlertLevel.toLowerCase();
      }
      if (maxDistanceKm != null && latitude != null && longitude != null) {
        queryParams['max_distance_km'] = maxDistanceKm;
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
      }
      if (recentHours != null) {
        queryParams['recent_hours'] = recentHours;
      }

      final response = await ApiClient.dio.get(
        '/beep',
        queryParameters: queryParams,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAlertDetails(String alertId) async {
    try {
      final response = await ApiClient.dio.get('/beep/$alertId');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getNearbyAlerts({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    int limit = 50,
    int? recentHours,
    String? minAlertLevel,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'radius_km': radiusKm,
        'limit': limit,
      };

      if (recentHours != null) {
        queryParams['recent_hours'] = recentHours;
      }
      if (minAlertLevel != null) {
        queryParams['min_alert_level'] = minAlertLevel.toLowerCase();
      }

      final response = await ApiClient.dio.get(
        '/beep/nearby',
        queryParameters: queryParams,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> triggerAlertProcessing() async {
    try {
      final response = await ApiClient.dio.post('/beep/trigger');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAlertsStats() async {
    try {
      final response = await ApiClient.dio.get('/beep/stats');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Witness aggregation endpoints for Task 7
  Future<Map<String, dynamic>> getWitnessAggregation(String alertId) async {
    try {
      final response = await ApiClient.dio.get('/beep/$alertId/aggregation');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAlertWitnesses(String alertId) async {
    try {
      final response = await ApiClient.dio.get('/beep/$alertId/witnesses');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> escalateAlert(String alertId) async {
    try {
      final response = await ApiClient.dio.post('/beep/$alertId/escalate');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Photo metadata submission for astronomical/aircraft identification
  Future<bool> submitPhotoMetadata(String sightingId, Map<String, dynamic> metadata) async {
    try {
      debugPrint('Submitting comprehensive photo metadata for sighting $sightingId');
      
      final response = await ApiClient.dio.post(
        '/photo-metadata/$sightingId',
        data: metadata,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        debugPrint('Photo metadata submitted successfully');
        return true;
      } else {
        debugPrint('Failed to submit photo metadata: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Error submitting photo metadata: ${_handleError(e)}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error submitting photo metadata: $e');
      return false;
    }
  }

  // Witness confirmation endpoints - Phase 1 "I SEE IT TOO" feature
  Future<Map<String, dynamic>> confirmWitness({
    required String sightingId,
    required String deviceId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? bearingDeg,
    String? description,
    bool stillVisible = true,
    String? devicePlatform,
    String? appVersion,
  }) async {
    try {
      final request = {
        'device_id': deviceId,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          if (accuracy != null) 'accuracy': accuracy,
          if (altitude != null) 'altitude': altitude,
        },
        if (bearingDeg != null) 'bearing_deg': bearingDeg,
        if (description != null && description.isNotEmpty) 'description': description,
        'still_visible': stillVisible,
        if (devicePlatform != null) 'device_platform': devicePlatform,
        if (appVersion != null) 'app_version': appVersion,
      };

      final response = await ApiClient.dio.post(
        '/beep/$sightingId/witnesses',
        data: request,
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getWitnessStatus({
    required String sightingId,
    required String deviceId,
  }) async {
    try {
      final response = await ApiClient.dio.get('/beep/$sightingId/witnesses/$deviceId');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Anonymous beep endpoints for Phase 0/1 - Quick alerts
  Future<Map<String, dynamic>> sendAnonymousBeep(Map<String, dynamic> alertData) async {
    try {
      final response = await ApiClient.dio.post('/beep', data: alertData);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await ApiClient.dio.get('/ping');
      return response.statusCode == 200 && response.data['message'] == 'pong';
    } catch (e) {
      return false;
    }
  }

  // Helper methods for data conversion
  api.SightingCategory _mapCategoryToApi(api.SightingCategory category) {
    return category; // Direct mapping since they're the same enum
  }

  api.SensorDataApi? _mapSensorDataToApi(SensorData? sensorData) {
    if (sensorData == null) {
      return null;
    }
    
    return api.SensorDataApi(
      timestamp: sensorData.utc,
      location: api.GeoCoordinates(
        latitude: sensorData.latitude,
        longitude: sensorData.longitude,
        altitude: sensorData.altitude,
        accuracy: sensorData.accuracy,
      ),
      azimuthDeg: sensorData.azimuthDeg,
      pitchDeg: sensorData.pitchDeg,
      rollDeg: sensorData.rollDeg,
      hfovDeg: sensorData.hfovDeg,
      vfovDeg: null, // Not available in current SensorData model
      deviceId: null, // Not available in current SensorData model
      appVersion: null, // Not available in current SensorData model
    );
  }

  // Configuration
  void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = '$newBaseUrl';
  }

  void setTimeout(Duration timeout) {
    dio.options.connectTimeout = timeout;
    dio.options.receiveTimeout = timeout;
  }

  // DEPRECATED: Legacy JWT-based magic link authentication
  // This method is kept for backward compatibility but should not be used
  @Deprecated('Use exchangeMagicCode instead')
  Future<Map<String, dynamic>> exchangeMagicToken(String token) async {
    // For backward compatibility, try to use token as code
    debugPrint('[ApiClient] WARNING: exchangeMagicToken is deprecated, redirecting to exchangeMagicCode');
    return exchangeMagicCode(token);
  }

  /// NEW: Exchange authorization code for tokens (authorization code flow)
  Future<Map<String, dynamic>> exchangeMagicCode(String code) async {
    final startTime = DateTime.now();
    final reqId = "api-${startTime.millisecondsSinceEpoch}";
    
    try {
      debugPrint('[API][$reqId] ==================== MAGIC CODE EXCHANGE START ====================');
      debugPrint('[API][$reqId] Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('[API][$reqId] Code length: ${code.length}');
      debugPrint('[API][$reqId] Code preview: ${code.length > 8 ? '${code.substring(0, 8)}...' : code}');
      debugPrint('[API][$reqId] Base URL: ${dio.options.baseUrl}');
      
      // Get device info for the request
      String deviceId = 'unknown';
      try {
        const storage = FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
        );
        final storedDeviceId = await storage.read(key: 'device_id');
        if (storedDeviceId != null) {
          deviceId = storedDeviceId;
        }
        debugPrint('[API][$reqId] Device ID: $deviceId');
      } catch (e) {
        debugPrint('[API][$reqId] ❌ Could not get device ID: $e');
      }
      
      // Prepare request body (use only 'code' as per backend API spec)
      final requestBody = {
        'code': code,
        'device_id': deviceId,
        'platform': Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown'),
        'app_version': '1.0.0', // TODO: Get from package info
      };
      
      debugPrint('[API][$reqId] Request body prepared: ${requestBody.keys}');
      debugPrint('[API][$reqId] Calling POST /auth/magic/exchange');
      debugPrint('[API][$reqId] Timeout settings - send: 8s, receive: 8s');
      
      final requestStartTime = DateTime.now();
      final response = await ApiClient.dio.post(
        '/auth/magic/exchange',
        data: requestBody,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-Request-ID': reqId,
          },
          validateStatus: (status) => status != null && status < 500,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      
      final requestEndTime = DateTime.now();
      final requestDuration = requestEndTime.difference(requestStartTime).inMilliseconds;
      debugPrint('[API][$reqId] ==================== HTTP REQUEST COMPLETED ====================');
      
      debugPrint('[API][$reqId] Request duration: ${requestDuration}ms');
      debugPrint('[API][$reqId] Response status: ${response.statusCode}');
      debugPrint('[API][$reqId] Response data type: ${response.data.runtimeType}');
      debugPrint('[API][$reqId] Raw response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        debugPrint('[API][$reqId] ==================== SUCCESS RESPONSE ANALYSIS ====================');
        debugPrint('[API][$reqId] ✅ HTTP 200 received, parsing response data');
        debugPrint('[API][$reqId] Response keys: ${responseData.keys.toList()}');
        debugPrint('[API][$reqId] Success field: ${responseData['success']}');
        
        // Check for required fields (backend now returns standardized format)
        // Expected: { success, access, refresh, expires_in, user: {id, email, username, ...} }
        final hasAccess = responseData.containsKey('access') || responseData.containsKey('access_token');
        final hasRefresh = responseData.containsKey('refresh') || responseData.containsKey('refresh_token');
        final hasUser = responseData.containsKey('user');
        debugPrint('[API][$reqId] Required fields check: access=$hasAccess, refresh=$hasRefresh, user=$hasUser');
        
        if (responseData['access'] != null) {
          final accessToken = responseData['access'] as String;
          debugPrint('[API][$reqId] Access token length: ${accessToken.length}');
          debugPrint('[API][$reqId] Access token preview: ${accessToken.length > 20 ? '${accessToken.substring(0, 20)}...' : accessToken}');
        }
        
        if (responseData['refresh'] != null) {
          final refreshToken = responseData['refresh'] as String;
          debugPrint('[API][$reqId] Refresh token length: ${refreshToken.length}');
        }
        
        if (responseData['user'] != null) {
          final userData = responseData['user'] as Map<String, dynamic>;
          debugPrint('[API][$reqId] User data keys: ${userData.keys.toList()}');
          debugPrint('[API][$reqId] User data: $userData');
        }
        
        debugPrint('[API][$reqId] ✅ Response validation passed, returning data');
        debugPrint('[API][$reqId] ==================== MAGIC CODE EXCHANGE SUCCESS ====================');
        return responseData;
      } else {
        debugPrint('[API][$reqId] ==================== ERROR RESPONSE ANALYSIS ====================');
        final errorMsg = response.data is Map 
          ? (response.data as Map)['detail'] ?? 'Code exchange failed'
          : 'Code exchange failed';
        debugPrint('[API][$reqId] ❌ HTTP ${response.statusCode}: $errorMsg');
        debugPrint('[API][$reqId] ❌ Full response data: ${response.data}');
        debugPrint('[API][$reqId] ❌ Response type: ${response.data.runtimeType}');
        debugPrint('[API][$reqId] ==================== MAGIC CODE EXCHANGE ERROR ====================');
        throw ApiClientException(
          'Backend code exchange failed: $errorMsg',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final errorTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('[API][$reqId] ==================== DIO EXCEPTION ANALYSIS ====================');
      debugPrint('[API][$reqId] ❌ DioException after ${errorTime}ms');
      debugPrint('[API][$reqId] ❌ Exception type: ${e.type}');
      debugPrint('[API][$reqId] ❌ Exception message: ${e.message}');
      debugPrint('[API][$reqId] ❌ Request options: ${e.requestOptions.uri}');
      debugPrint('[API][$reqId] ❌ Request method: ${e.requestOptions.method}');
      debugPrint('[API][$reqId] ❌ Request headers: ${e.requestOptions.headers}');
      debugPrint('[API][$reqId] ❌ Request data: ${e.requestOptions.data}');
      
      if (e.response != null) {
        debugPrint('[API][$reqId] ❌ Response status: ${e.response?.statusCode}');
        debugPrint('[API][$reqId] ❌ Response headers: ${e.response?.headers}');
        debugPrint('[API][$reqId] ❌ Response data: ${e.response?.data}');
        debugPrint('[API][$reqId] ❌ Response type: ${e.response?.data.runtimeType}');
      } else {
        debugPrint('[API][$reqId] ❌ No response object - connection failed');
      }
      
      debugPrint('[API][$reqId] ❌ Stack trace: ${e.stackTrace}');
      
      String errorMessage;
      if (e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Request timed out after 5 seconds';
        debugPrint('[API][$reqId] ❌ SEND TIMEOUT detected');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Response timed out after 5 seconds';
        debugPrint('[API][$reqId] ❌ RECEIVE TIMEOUT detected');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out';
        debugPrint('[API][$reqId] ❌ CONNECTION TIMEOUT detected');
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error: ${e.message}';
        debugPrint('[API][$reqId] ❌ CONNECTION ERROR detected');
      } else if (e.response?.statusCode == 410) {
        final errorData = e.response?.data;
        errorMessage = errorData is Map 
          ? (errorData['detail'] ?? 'Invalid, expired, or already used code') 
          : 'Invalid, expired, or already used code';
        debugPrint('[API][$reqId] ❌ HTTP 410 - Code invalid/expired/used');
      } else {
        errorMessage = 'Network error during code exchange: ${e.message}';
        debugPrint('[API][$reqId] ❌ Generic network error');
      }
      
      debugPrint('[API][$reqId] ==================== THROWING API CLIENT EXCEPTION ====================');
      throw ApiClientException(errorMessage, statusCode: e.response?.statusCode);
      
    } catch (e, stackTrace) {
      final errorTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('[API][$reqId] ==================== UNEXPECTED EXCEPTION ====================');
      debugPrint('[API][$reqId] ❌ Unexpected error after ${errorTime}ms: $e');
      debugPrint('[API][$reqId] ❌ Error type: ${e.runtimeType}');
      debugPrint('[API][$reqId] ❌ Stack trace: $stackTrace');
      debugPrint('[API][$reqId] ==================== THROWING UNEXPECTED ERROR ====================');
      throw ApiClientException('Unexpected error: $e', statusCode: null);
    }
  }

  // Generic HTTP methods for admin functionality
  Future<Map<String, dynamic>> getJson(String endpoint) async {
    try {
      final response = await ApiClient.dio.get(endpoint);
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiClientException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> get(String endpoint) async {
    try {
      return await ApiClient.dio.get(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cleanup
  void dispose() {
    // Note: Don't close static dio as it's shared
    _instance = null;
  }
}

// Extension for easier access
extension ApiClientExtension on ApiClient {
  /// Upload a complete sighting with media files
  Future<String> submitSightingWithMedia({
    required String title,
    required String description,
    required api.SightingCategory category,
    SensorData? sensorData,
    required List<File> mediaFiles,
    int? durationSeconds,
    int witnessCount = 1,
    List<String> tags = const [],
    bool isPublic = true,
    Function(double)? onProgress,
  }) async {
    try {
      // Step 1: Create sighting first to get sighting ID
      if (onProgress != null) onProgress(0.1);
      // Prepare sighting data without media initially
      final sightingData = {
        'title': title,
        'description': description,
        'category': category.toString().split('.').last,
        'witness_count': witnessCount,
        'is_public': isPublic,
        'tags': tags,
      };
      
      // Add sensor data if available (flattened format for enrichment)
      if (sensorData != null) {
        sightingData['sensor_data'] = {
          'timestamp': sensorData.utc.toIso8601String(),
          'latitude': sensorData.latitude,
          'longitude': sensorData.longitude,
          'accuracy': sensorData.accuracy,
          'altitude': sensorData.altitude,
          'azimuth_deg': sensorData.azimuthDeg,
          'pitch_deg': sensorData.pitchDeg,
          'roll_deg': sensorData.rollDeg,
          'hfov_deg': sensorData.hfovDeg,
        };
      }
      
      debugPrint('Creating sighting first to get ID...');
      final sightingResponse = await ApiClient.dio.post('/beep', data: sightingData);
      
      // Extract sighting ID from response
      String sightingId;
      if (sightingResponse.data is Map<String, dynamic>) {
        final data = sightingResponse.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          sightingId = data['data']['sighting_id'] as String;
          debugPrint('Sighting created with ID: $sightingId');
        } else {
          throw Exception('Failed to create sighting: ${data['message']}');
        }
      } else {
        throw Exception('Invalid sighting creation response format');
      }
      
      // Step 2: Upload media files using the sighting ID
      List<String> mediaFileNames = [];
      if (mediaFiles.isNotEmpty) {
        debugPrint('Uploading ${mediaFiles.length} media files for sighting $sightingId...');
        if (onProgress != null) onProgress(0.3);
        
        for (int i = 0; i < mediaFiles.length; i++) {
          final file = mediaFiles[i];
          debugPrint('Uploading file ${i + 1}/${mediaFiles.length}: ${file.path}');
          
          // Upload file using sighting ID
          final fileName = await uploadMediaFileForSighting(sightingId, file);
          mediaFileNames.add(fileName);
          
          // Update progress
          if (onProgress != null) {
            onProgress(0.3 + (0.5 * (i + 1) / mediaFiles.length));
          }
        }
        
        debugPrint('All media files uploaded successfully');
        
        // Step 3: Update sighting with media file names
        if (onProgress != null) onProgress(0.9);
        await updateSightingMedia(sightingId, mediaFileNames);
        
        // Step 4: Submit comprehensive photo metadata for astronomical identification
        // TODO: Pass metadata from photo capture through submission flow
      }
      
      if (onProgress != null) onProgress(1.0);
      return sightingId;
      
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      debugPrint('Sighting submission error: $e');
      rethrow;
    }
  }

  /// Safely extracts filename from file path, handling content URIs and edge cases
  String _safeExtractFilename(String filePath) {
    try {
      final pathParts = filePath.split('/');
      final fileName = pathParts.isNotEmpty ? pathParts.last : 'unknown_file';
      if (fileName.isEmpty || fileName == '/') {
        return 'media_file_${DateTime.now().millisecondsSinceEpoch}';
      }
      return fileName;
    } catch (e) {
      debugPrint('Error extracting filename from $filePath: $e');
      return 'media_file_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Safely extracts file extension from file path, handling content URIs and edge cases
  String _safeExtractExtension(String filePath) {
    try {
      final pathParts = filePath.split('.');
      final extension = pathParts.isNotEmpty ? pathParts.last.toLowerCase() : '';
      if (extension.isEmpty) {
        return ''; // Let calling code handle empty extension
      }
      return extension;
    } catch (e) {
      debugPrint('Error extracting extension from $filePath: $e');
      return '';
    }
  }

  String _getContentTypeFromFile(File file) {
    final extension = _safeExtractExtension(file.path);
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      default:
        return 'application/octet-stream';
    }
  }

  api.MediaType _getMediaTypeFromFile(File file) {
    final extension = _safeExtractExtension(file.path);
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return api.MediaType.photo;
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return api.MediaType.video;
    } else if (['mp3', 'wav', 'aac', 'ogg'].contains(extension)) {
      return api.MediaType.audio;
    }
    return api.MediaType.photo; // Default fallback
  }

  Future<String> uploadMediaFile(String sightingId, File file) async {
    try {
      debugPrint('Uploading media file using presigned upload: ${file.path}');
      
      // Step 1: Get presigned upload URL
      final presignResponse = await createPresignedUpload(file);
      final uploadId = presignResponse['upload_id'] as String;
      final uploadUrl = presignResponse['upload_url'] as String;
      final fields = presignResponse['fields'] as Map<String, dynamic>;
      
      debugPrint('Got presigned upload URL: $uploadUrl');
      
      // Step 2: Upload file directly to S3/MinIO
      final success = await uploadFileToStorage(uploadUrl, fields, file);
      
      if (!success) {
        throw Exception('Failed to upload file to storage');
      }
      
      debugPrint('File uploaded to storage successfully');
      
      // Step 3: File is already saved, return the API URL
      final fileName = _safeExtractFilename(file.path);
      final mediaUrl = '${AppEnvironment.apiBaseUrl}/media/default/${fileName}';
      
      debugPrint('Media upload completed successfully with URL: $mediaUrl');
      return mediaUrl;
      
    } catch (e) {
      debugPrint('Error uploading media file: $e');
      rethrow;
    }
  }

  // New sighting-based media upload method
  Future<String> uploadMediaFileForSighting(String sightingId, File file) async {
    try {
      debugPrint('Uploading media file for sighting: $sightingId');
      
      // Step 1: Get presigned upload URL with sighting ID
      final presignResponse = await createPresignedUploadForSighting(sightingId, file);
      debugPrint('Presign response: $presignResponse');
      
      final uploadId = presignResponse['upload_id'] as String;
      final uploadUrl = presignResponse['upload_url'] as String;
      final fields = presignResponse['fields'] as Map<String, dynamic>;
      
      debugPrint('Got presigned upload URL: $uploadUrl');
      
      // Step 2: Upload file directly to S3/MinIO
      final success = await uploadFileToStorage(uploadUrl, fields, file);
      
      if (!success) {
        throw Exception('Failed to upload file to storage');
      }
      
      debugPrint('File uploaded to storage successfully');
      
      // Step 3: Complete the upload to create database record
      debugPrint('Completing media upload...');
      await completeMediaUploadForSighting(uploadId, file);
      
      final fileName = _safeExtractFilename(file.path);
      debugPrint('Media upload completed successfully with filename: $fileName');
      return fileName;
      
    } catch (e) {
      debugPrint('Error uploading media file: $e');
      rethrow;
    }
  }

  Future<void> updateSightingMedia(String sightingId, List<String> fileNames) async {
    try {
      debugPrint('Updating sighting $sightingId with media files: $fileNames');
      
      final response = await ApiClient.dio.patch('/beep/$sightingId/media', data: {
        'media_files': fileNames,
      });
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        debugPrint('Sighting media updated successfully');
      } else {
        throw Exception('Failed to update sighting media: ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('Error updating sighting media: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPresignedUploadForSighting(String sightingId, File file) async {
    try {
      final fileName = _safeExtractFilename(file.path);
      final contentType = _getContentTypeFromFile(file);
      final fileSize = await file.length();
      
      final requestData = {
        'filename': fileName,
        'content_type': contentType,
        'size_bytes': fileSize,
        'sighting_id': sightingId, // NEW: Include sighting ID
      };
      
      debugPrint('Creating presigned upload for sighting $sightingId: $fileName ($fileSize bytes)');
      
      final response = await ApiClient.dio.post('/media/presign', data: requestData);
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create presigned upload: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> completeMediaUploadForSighting(String uploadId, File file) async {
    try {
      final fileName = _safeExtractFilename(file.path);
      
      debugPrint('Completing upload for: $uploadId');
      
      final response = await ApiClient.dio.post('/media/complete', data: {
        'upload_id': uploadId,
        'media_type': _getMediaTypeFromFile(file).toString().split('.').last,
      });
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        // Return just the filename, not a full URL
        return fileName;
      } else {
        throw Exception('Failed to complete upload: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadMediaToSighting(String sightingId, File file) async {
    try {
      debugPrint('=== MEDIA UPLOAD DEBUG START ===');
      debugPrint('Sighting ID: $sightingId');
      debugPrint('File path: ${file.path}');
      debugPrint('File exists: ${await file.exists()}');
      
      if (!await file.exists()) {
        debugPrint('ERROR: File does not exist at path: ${file.path}');
        throw Exception('Media file not found at path: ${file.path}');
      }
      
      final fileSize = await file.length();
      debugPrint('File size: $fileSize bytes');
      
      if (fileSize == 0) {
        debugPrint('ERROR: File is empty');
        throw Exception('Media file is empty');
      }
      
      final formData = FormData();
      
      // Add the file to the 'files' field (FastAPI expects List[UploadFile])
      debugPrint('Creating multipart file...');
      final filename = _safeExtractFilename(file.path);
      
      // Add 5-second timeout for file reading to prevent infinite hang
      final multipartFile = await MultipartFile.fromFile(file.path, filename: filename)
          .timeout(const Duration(seconds: 5), onTimeout: () {
            throw TimeoutException('File reading timeout after 5 seconds', const Duration(seconds: 5));
          });
      
      formData.files.add(MapEntry('files', multipartFile));
      
      // Add form fields
      formData.fields.add(const MapEntry('source', 'mobile_app'));
      debugPrint('Form data created successfully');
      
      final uploadUrl = '/beep/$sightingId/media';
      debugPrint('Upload URL: $uploadUrl');
      debugPrint('Making POST request...');

      final response = await ApiClient.dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        debugPrint('=== MEDIA UPLOAD SUCCESS ===');
        return _safeResponseToMap(response.data, context: 'Media upload response');
      } else {
        debugPrint('ERROR: Upload failed with status ${response.statusCode}');
        throw Exception('Failed to upload media: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('=== MEDIA UPLOAD DIO ERROR ===');
      debugPrint('Error type: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('=== MEDIA UPLOAD GENERAL ERROR ===');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> triggerAlertsForSighting(String sightingId, double latitude, double longitude) async {
    try {
      debugPrint('=== TRIGGER ALERTS DEBUG START ===');
      final deviceId = await beepService.getOrCreateDeviceId();
      debugPrint('Got device ID for alerts: $deviceId');
      
      final response = await ApiClient.dio.post(
        '/beep/send/$sightingId',
        data: {
          'device_id': deviceId,
          'location': {
            'latitude': latitude,
            'longitude': longitude,
          }
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      debugPrint('Alert trigger response status: ${response.statusCode}');
      debugPrint('Alert trigger response data: ${response.data}');
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        debugPrint('=== TRIGGER ALERTS SUCCESS ===');
        return _safeResponseToMap(response.data, context: 'Trigger alerts response');
      } else {
        throw Exception('Failed to trigger alerts: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('=== TRIGGER ALERTS DIO ERROR ===');
      debugPrint('DioException: $e');
      throw _handleError(e);
    } catch (e) {
      debugPrint('=== TRIGGER ALERTS GENERAL ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Media upload endpoints
  Future<Map<String, dynamic>> createPresignedUpload(File file) async {
    try {
      final fileName = _safeExtractFilename(file.path);
      final contentType = _getContentTypeFromFile(file);
      final fileSize = await file.length();
      
      final requestData = {
        'filename': fileName,
        'content_type': contentType,
        'size_bytes': fileSize,
        // Optional: Add checksum if needed
        // 'checksum': await _calculateFileChecksum(file),
      };
      
      debugPrint('Creating presigned upload for: $fileName ($fileSize bytes)');
      
      final response = await ApiClient.dio.post('/media/presign', data: requestData);
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('upload_id') && data.containsKey('upload_url')) {
          return data;
        }
      }
      
      throw ApiClientException(
        response.data is Map<String, dynamic> 
            ? (response.data as Map<String, dynamic>)['message'] ?? 'Failed to create upload URL'
            : 'Failed to create upload URL',
      );
      
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      rethrow;
    }
  }

  Future<String> completeMediaUpload(String uploadId, File file) async {
    try {
      final contentType = _getContentTypeFromFile(file);
      final mediaType = contentType.startsWith('image/') ? 'photo' : 
                       contentType.startsWith('video/') ? 'video' : 'photo';
      
      final requestData = {
        'upload_id': uploadId,
        'media_type': mediaType,
        'metadata': {
          'original_path': file.path,
          'upload_timestamp': DateTime.now().toIso8601String(),
        },
      };
      
      debugPrint('Completing upload for: $uploadId');
      
      final response = await ApiClient.dio.post('/media/complete', data: requestData);
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['url'] == null) {
          throw ApiClientException('Invalid completion response - no URL returned');
        }
        final mediaUrl = data['url'] as String;
        debugPrint('Upload completed with URL: $mediaUrl');
        return mediaUrl;
      }
      
      throw ApiClientException(
        response.data is Map<String, dynamic> 
            ? (response.data as Map<String, dynamic>)['message'] ?? 'Failed to complete upload'
            : 'Failed to complete upload',
      );
      
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      rethrow;
    }
  }

  // Simplified bulk upload - returning raw JSON for now
  Future<Map<String, dynamic>> createBulkPresignedUploads(List<File> files, String? sightingId) async {
    try {
      final fileRequests = <Map<String, dynamic>>[];
      
      for (final file in files) {
        final fileName = _safeExtractFilename(file.path);
        final contentType = _getContentTypeFromFile(file);
        final fileSize = await file.length();
        
        fileRequests.add({
          'filename': fileName,
          'content_type': contentType,
          'size_bytes': fileSize,
        });
      }
      
      final requestData = {
        'files': fileRequests,
        if (sightingId != null) 'sighting_id': sightingId,
      };
      
      debugPrint('Creating bulk presigned uploads for ${files.length} files');
      
      final response = await ApiClient.dio.post('/media/bulk-presign', data: requestData);
      
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      
      throw ApiClientException('Invalid bulk upload response');
      
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      rethrow;
    }
  }

  // File upload to S3/MinIO
  Future<bool> uploadFileToStorage(
    String uploadUrl,
    Map<String, dynamic> fields,
    File file,
  ) async {
    try {
      debugPrint('Uploading file to storage: $uploadUrl');
      
      // Create form data with all required fields
      final formData = FormData();
      
      // Add all the presigned form fields first
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
      
      // Add the file last (S3 requirement)
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          file.path,
          filename: (() {
            // Safely extract filename from file path
            try {
              final pathParts = file.path.split('/');
              final fileName = pathParts.isNotEmpty ? pathParts.last : 'unknown_file';
              return (fileName.isEmpty || fileName == '/') 
                ? 'media_file_${DateTime.now().millisecondsSinceEpoch}' 
                : fileName;
            } catch (e) {
              debugPrint('Error extracting filename from ${file.path}: $e');
              return 'media_file_${DateTime.now().millisecondsSinceEpoch}';
            }
          })(),
        ),
      ));
      
      final uploadResponse = await ApiClient.dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          // Don't follow redirects for S3 uploads
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      
      debugPrint('Storage upload response status: ${uploadResponse.statusCode}');
      
      // S3 returns 204 on successful upload
      return uploadResponse.statusCode == 204 || uploadResponse.statusCode == 200;
      
    } catch (e) {
      if (e is DioException) {
        debugPrint('File upload failed: ${e.message}');
        debugPrint('Response: ${e.response?.data}');
      }
      return false;
    }
  }
}