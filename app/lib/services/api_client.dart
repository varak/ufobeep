import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../config/environment.dart';
import '../models/api_models.dart' as api;
import '../models/sensor_data.dart';
import '../models/sighting_submission.dart' as local;

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
  late final Dio _dio;
  String? _authToken;

  // Singleton pattern
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    final baseOptions = BaseOptions(
      baseUrl: '${AppEnvironment.apiBaseUrl}',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'UFOBeep/1.0.0 (Flutter)',
      },
    );

    _dio = Dio(baseOptions);

    // Add request interceptor for auth
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log successful responses in debug mode
          if (AppEnvironment.isDebug) {
            print('API Response: ${response.requestOptions.method} ${response.requestOptions.path} -> ${response.statusCode}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          // Log errors
          print('API Error: ${error.requestOptions.method} ${error.requestOptions.path} -> ${error.response?.statusCode}: ${error.message}');
          handler.next(error);
        },
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == null && error.type == DioExceptionType.connectionTimeout) {
            // Retry on connection timeout
            try {
              final retryResponse = await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              handler.resolve(retryResponse);
              return;
            } catch (retryError) {
              // If retry also fails, continue with original error
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  // Authentication
  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  bool get isAuthenticated => _authToken != null;

  // Helper method to handle API responses
  T _handleResponse<T>(Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['success'] == true) {
          return fromJson(data);
        } else {
          throw ApiClientException(
            data['message'] ?? 'API request failed',
            statusCode: response.statusCode,
            details: data,
          );
        }
      }
      throw ApiClientException('Invalid response format', statusCode: response.statusCode);
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

  // Sighting endpoints
  Future<api.CreateSightingResponse> submitSighting(api.SightingSubmission submission) async {
    try {
      final response = await _dio.post(
        '/sightings',
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

      final response = await _dio.get(
        '/sightings',
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
      final response = await _dio.post(
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
      final response = await _dio.post(
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

      final response = await _dio.post(
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

      final response = await _dio.post(
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

      final response = await _dio.get(
        '/alerts',
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
      final response = await _dio.get('/alerts/$alertId');

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

      final response = await _dio.get(
        '/alerts/nearby',
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
      final response = await _dio.post('/alerts/trigger');

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
      final response = await _dio.get('/alerts/stats');

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
      final response = await _dio.get('/ping');
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
    _dio.options.baseUrl = '$newBaseUrl';
  }

  void setTimeout(Duration timeout) {
    _dio.options.connectTimeout = timeout;
    _dio.options.receiveTimeout = timeout;
  }

  // Cleanup
  void dispose() {
    _dio.close();
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
      // Simplified sighting data - no media upload for now
      final sightingData = {
        'title': title,
        'description': description,
        'category': category.toString().split('.').last,
        'witness_count': witnessCount,
        'is_public': isPublic,
        'tags': tags,
      };
      
      // Add sensor data if available
      if (sensorData != null) {
        sightingData['sensor_data'] = {
          'utc': sensorData.utc.toIso8601String(),
          'latitude': sensorData.latitude,
          'longitude': sensorData.longitude,
          'azimuth_deg': sensorData.azimuthDeg,
          'pitch_deg': sensorData.pitchDeg,
          'roll_deg': sensorData.rollDeg,
          'hfov_deg': sensorData.hfovDeg,
          'accuracy': sensorData.accuracy,
          'altitude': sensorData.altitude,
        };
      }
      
      // Add media info (file count only to avoid blocking file I/O)
      if (mediaFiles.isNotEmpty) {
        sightingData['media_info'] = {
          'file_count': mediaFiles.length,
          'note': 'Media files captured but not uploaded yet',
        };
      }
      
      if (onProgress != null) onProgress(0.5);
      
      debugPrint('Submitting sighting data: ${sightingData.toString()}');
      
      final response = await _dio.post('/sightings', data: sightingData);
      
      debugPrint('Sighting response: ${response.data}');
      
      // Parse response
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final sightingData = data['data'] as Map<String, dynamic>;
          final sightingId = sightingData['sighting_id'] ?? 'unknown_id';
          
          // Upload media files if any
          if (mediaFiles.isNotEmpty) {
            debugPrint('Uploading ${mediaFiles.length} media files for sighting $sightingId');
            if (onProgress != null) onProgress(0.7);
            
            for (int i = 0; i < mediaFiles.length; i++) {
              final file = mediaFiles[i];
              try {
                await uploadMediaFile(sightingId, file);
                debugPrint('Uploaded media file ${i + 1}/${mediaFiles.length}');
                if (onProgress != null) {
                  final progress = 0.7 + (0.3 * (i + 1) / mediaFiles.length);
                  onProgress(progress);
                }
              } catch (e) {
                debugPrint('Failed to upload media file ${i + 1}: $e');
                // Continue with other files even if one fails
              }
            }
          }
          
          if (onProgress != null) onProgress(1.0);
          return sightingId;
        }
      }
      
      throw ApiClientException('Invalid sighting response format');
      
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      debugPrint('Sighting submission error: $e');
      rethrow;
    }
  }

  String _getContentTypeFromFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
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
    final extension = file.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return api.MediaType.photo;
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return api.MediaType.video;
    } else if (['mp3', 'wav', 'aac', 'ogg'].contains(extension)) {
      return api.MediaType.audio;
    }
    return api.MediaType.photo; // Default fallback
  }

  Future<void> uploadMediaFile(String sightingId, File file) async {
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
      
      // Step 3: Mark upload as complete
      await completeMediaUpload(uploadId, file);
      
      debugPrint('Media upload completed successfully');
      
    } catch (e) {
      debugPrint('Error uploading media file: $e');
      rethrow;
    }
  }

  // Media upload endpoints
  Future<Map<String, dynamic>> createPresignedUpload(File file) async {
    try {
      final fileName = file.path.split('/').last;
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
      
      final response = await _dio.post('/media/presign', data: requestData);
      
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

  Future<void> completeMediaUpload(String uploadId, File file) async {
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
      
      final response = await _dio.post('/media/complete', data: requestData);
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['id'] == null) {
          throw ApiClientException('Invalid completion response');
        }
        debugPrint('Upload completed: ${data['id']}');
        return;
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
        final fileName = file.path.split('/').last;
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
      
      final response = await _dio.post('/media/bulk-presign', data: requestData);
      
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
          filename: file.path.split('/').last,
        ),
      ));
      
      final uploadResponse = await _dio.post(
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