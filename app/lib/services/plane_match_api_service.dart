import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/environment.dart';
import '../models/sensor_data.dart';

class PlaneMatchApiService {
  late final Dio _dio;
  
  PlaneMatchApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppEnvironment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logging interceptor in debug mode
    if (AppEnvironment.debugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    // Add error handling interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('PlaneMatchApiService Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  Future<PlaneMatchResponse> matchPlane(SensorData sensorData) async {
    try {
      debugPrint('PlaneMatchApiService: Sending sensor data for plane matching');
      
      final request = PlaneMatchRequest(
        sensorData: sensorData,
        photoPath: null, // Not sending photo path for now
        description: 'Sky object capture',
      );

      final response = await _dio.post(
        '/v1/plane-match',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        debugPrint('PlaneMatchApiService: Received plane match response');
        return PlaneMatchResponse.fromJson(response.data);
      } else {
        throw PlaneMatchException(
          'Server returned status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

    } on DioException catch (e) {
      debugPrint('PlaneMatchApiService: Dio error - ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw PlaneMatchException('Connection timeout - please check your internet connection');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw PlaneMatchException('Server response timeout - plane matching service may be overloaded');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final message = _extractErrorMessage(e.response?.data) ?? 'Server error';
        
        if (statusCode == 400) {
          throw PlaneMatchException('Invalid sensor data: $message', statusCode: statusCode);
        } else if (statusCode == 429) {
          throw PlaneMatchException('Rate limit exceeded - please try again later', statusCode: statusCode);
        } else if (statusCode == 503) {
          throw PlaneMatchException('Plane matching service temporarily unavailable', statusCode: statusCode);
        } else {
          throw PlaneMatchException('Server error: $message', statusCode: statusCode);
        }
      } else {
        throw PlaneMatchException('Network error - please check your connection');
      }
    } catch (e) {
      debugPrint('PlaneMatchApiService: Unexpected error - $e');
      
      if (e is PlaneMatchException) {
        rethrow;
      } else {
        throw PlaneMatchException('Unexpected error during plane matching: $e');
      }
    }
  }

  Future<Map<String, dynamic>> getServiceHealth() async {
    try {
      final response = await _dio.get('/v1/plane-match/health');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw PlaneMatchException(
          'Health check failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

    } on DioException catch (e) {
      debugPrint('PlaneMatchApiService: Health check failed - ${e.message}');
      throw PlaneMatchException('Service health check failed');
    }
  }

  String? _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        return responseData['detail'] as String? ?? 
               responseData['message'] as String? ??
               responseData['error'] as String?;
      } else if (responseData is String) {
        // Try to parse as JSON
        final decoded = json.decode(responseData);
        if (decoded is Map<String, dynamic>) {
          return decoded['detail'] as String? ?? 
                 decoded['message'] as String? ??
                 decoded['error'] as String?;
        }
        return responseData;
      }
    } catch (e) {
      debugPrint('PlaneMatchApiService: Could not extract error message: $e');
    }
    return null;
  }
}

class PlaneMatchException implements Exception {
  final String message;
  final int? statusCode;

  const PlaneMatchException(this.message, {this.statusCode});

  @override
  String toString() => message;

  bool get isNetworkError => statusCode == null;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isRateLimited => statusCode == 429;
  bool get isServiceUnavailable => statusCode == 503;
}

// Mock service for testing/development
class MockPlaneMatchApiService extends PlaneMatchApiService {
  static final List<PlaneMatchResponse> _mockResponses = [
    // Mock plane match
    PlaneMatchResponse(
      isPlane: true,
      matchedFlight: PlaneMatchInfo(
        callsign: 'UAL123',
        icao24: 'a1b2c3',
        aircraftType: 'Boeing 737',
        origin: 'SFO',
        destination: 'LAX',
        altitude: 10500,
        velocity: 250,
        angularError: 1.2,
      ),
      confidence: 0.85,
      reason: 'Matched aircraft UAL123 with 1.2° error',
      timestamp: DateTime.now().toUtc(),
    ),
    
    // Mock no plane found
    PlaneMatchResponse(
      isPlane: false,
      confidence: 0.0,
      reason: 'No aircraft found within 50km radius',
      timestamp: DateTime.now().toUtc(),
    ),
    
    // Mock low confidence match
    PlaneMatchResponse(
      isPlane: true,
      matchedFlight: PlaneMatchInfo(
        callsign: null,
        icao24: 'xyz789',
        aircraftType: null,
        angularError: 3.8,
      ),
      confidence: 0.35,
      reason: 'Possible aircraft match with 3.8° error',
      timestamp: DateTime.now().toUtc(),
    ),
  ];
  
  static int _responseIndex = 0;

  @override
  Future<PlaneMatchResponse> matchPlane(SensorData sensorData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Return cycling mock responses
    final response = _mockResponses[_responseIndex % _mockResponses.length];
    _responseIndex++;
    
    debugPrint('MockPlaneMatchApiService: Returning mock response - isPlane: ${response.isPlane}');
    
    return response.copyWith(timestamp: DateTime.now().toUtc());
  }

  @override
  Future<Map<String, dynamic>> getServiceHealth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'status': 'healthy',
      'plane_match_enabled': true,
      'radius_km': 50.0,
      'tolerance_deg': 2.5,
      'cache_ttl': 10,
      'time_quantization': 5,
      'opensky_configured': true,
      'mock': true,
    };
  }
}

extension PlaneMatchResponseExtensions on PlaneMatchResponse {
  PlaneMatchResponse copyWith({
    bool? isPlane,
    PlaneMatchInfo? matchedFlight,
    double? confidence,
    String? reason,
    DateTime? timestamp,
  }) {
    return PlaneMatchResponse(
      isPlane: isPlane ?? this.isPlane,
      matchedFlight: matchedFlight ?? this.matchedFlight,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}