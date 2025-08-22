/// User Service - MP13-1
/// Handles user registration, username generation, and user management for UFOBeep
/// Replaces device ID system with human-readable usernames like 'cosmic.whisper.7823'

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/anonymous_beep_service.dart';

// User registration models
class UsernameGenerationResponse {
  final String username;
  final List<String> alternatives;

  UsernameGenerationResponse({
    required this.username,
    required this.alternatives,
  });

  factory UsernameGenerationResponse.fromJson(Map<String, dynamic> json) {
    return UsernameGenerationResponse(
      username: json['username'] ?? '',
      alternatives: List<String>.from(json['alternatives'] ?? []),
    );
  }
}

class UserRegistrationResponse {
  final String userId;
  final String username;
  final String deviceId;
  final bool isNewUser;
  final String message;

  UserRegistrationResponse({
    required this.userId,
    required this.username,
    required this.deviceId,
    required this.isNewUser,
    required this.message,
  });

  factory UserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return UserRegistrationResponse(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      deviceId: json['device_id'] ?? '',
      isNewUser: json['is_new_user'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class UserProfile {
  final String userId;
  final String username;
  final String? email;
  final String? displayName;
  final double alertRangeKm;
  final bool unitsMetric;
  final String preferredLanguage;
  final bool isVerified;
  final DateTime createdAt;
  final Map<String, dynamic> stats;

  UserProfile({
    required this.userId,
    required this.username,
    this.email,
    this.displayName,
    required this.alertRangeKm,
    required this.unitsMetric,
    required this.preferredLanguage,
    required this.isVerified,
    required this.createdAt,
    required this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      displayName: json['display_name'],
      alertRangeKm: (json['alert_range_km'] ?? 50.0).toDouble(),
      unitsMetric: json['units_metric'] ?? true,
      preferredLanguage: json['preferred_language'] ?? 'en',
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      stats: json['stats'] ?? {},
    );
  }
}

class UserService {
  static const String _apiBaseUrl = 'https://api.ufobeep.com';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _isRegisteredKey = 'is_registered';
  static const String _deviceIdKey = 'device_id';

  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._internal();
  UserService._internal();

  /// Generate new username options for user registration
  Future<UsernameGenerationResponse> generateUsername() async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/generate-username'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UsernameGenerationResponse.fromJson(data);
      } else {
        throw Exception('Failed to generate username: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Username generation error: $e');
    }
  }

  /// Register user with UFOBeep username system
  Future<UserRegistrationResponse> registerUser({
    String? customUsername,
    String? email,
    double alertRangeKm = 50.0,
    bool unitsMetric = true,
    String preferredLanguage = 'en',
  }) async {
    try {
      // Get device ID from existing anonymous service
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      
      final requestBody = {
        'device_id': deviceId,
        'platform': 'android', // TODO: Detect platform properly
        'alert_range_km': alertRangeKm,
        'units_metric': unitsMetric,
        'preferred_language': preferredLanguage,
      };

      if (customUsername != null && customUsername.isNotEmpty) {
        requestBody['username'] = customUsername;
      }

      if (email != null && email.isNotEmpty) {
        requestBody['email'] = email;
      }

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userResponse = UserRegistrationResponse.fromJson(data);
        
        // Store user info locally
        await _storeUserInfo(
          userId: userResponse.userId,
          username: userResponse.username,
          deviceId: userResponse.deviceId,
        );
        
        return userResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Get existing user by device ID (for returning users)
  Future<UserRegistrationResponse?> getUserByDeviceId() async {
    try {
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/users/by-device/$deviceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userResponse = UserRegistrationResponse.fromJson(data);
        
        // Update stored user info
        await _storeUserInfo(
          userId: userResponse.userId,
          username: userResponse.username,
          deviceId: userResponse.deviceId,
        );
        
        return userResponse;
      } else if (response.statusCode == 404) {
        // User not found, needs registration
        return null;
      } else {
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting user by device ID: $e');
      return null;
    }
  }

  /// Get user profile by username
  Future<UserProfile?> getUserProfile(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/users/profile/$username'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Validate username availability and format
  Future<Map<String, dynamic>> validateUsername(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/validate-username'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Validation failed: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'valid': false,
        'available': false,
        'error': 'Validation error: $e',
      };
    }
  }

  /// Initialize user system - check if user is registered or needs registration
  Future<bool> initializeUser() async {
    try {
      // Check if user is already registered locally
      final prefs = await SharedPreferences.getInstance();
      final isRegistered = prefs.getBool(_isRegisteredKey) ?? false;
      
      if (isRegistered) {
        final storedUsername = prefs.getString(_usernameKey);
        final storedUserId = prefs.getString(_userIdKey);
        
        if (storedUsername != null && storedUserId != null) {
          print('User already registered: $storedUsername');
          return true;
        }
      }
      
      // Try to get user from server by device ID
      final existingUser = await getUserByDeviceId();
      if (existingUser != null) {
        print('Found existing user: ${existingUser.username}');
        return true;
      }
      
      print('User needs registration');
      return false;
      
    } catch (e) {
      print('Error initializing user: $e');
      return false;
    }
  }

  /// Get current user info from local storage
  Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'username': prefs.getString(_usernameKey),
      'deviceId': prefs.getString(_deviceIdKey),
    };
  }

  /// Store user info locally
  Future<void> _storeUserInfo({
    required String userId,
    required String username,
    required String deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_deviceIdKey, deviceId);
    await prefs.setBool(_isRegisteredKey, true);
    
    print('Stored user info: $username ($userId)');
  }

  /// Clear user data (for logout/reset)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_deviceIdKey);
    await prefs.setBool(_isRegisteredKey, false);
  }

  /// Check if user is registered
  Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isRegisteredKey) ?? false;
  }

  /// Get current username (for UI display)
  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Get current user ID (for API calls)
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Update anonymous_beep_service to use username system
  /// This replaces device ID lookups with user ID lookups
  Future<String> getOrCreateUserId() async {
    // Try to get existing user ID
    final userId = await getCurrentUserId();
    if (userId != null) {
      return userId;
    }

    // If no user ID, check if user exists on server
    final existingUser = await getUserByDeviceId();
    if (existingUser != null) {
      return existingUser.userId;
    }

    // If no existing user, initiate registration flow
    throw Exception('User not registered - please complete registration');
  }
}

/// Global instance for easy access
final userService = UserService.instance;