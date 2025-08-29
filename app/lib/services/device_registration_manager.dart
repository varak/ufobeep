import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'device_service.dart';
import 'auth_repository.dart';
import '../models/api_models.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Coordinates device registration after BOTH auth and FCM tokens are available
/// Prevents the timing issue where device registration fails due to missing JWT
class DeviceRegistrationManager {
  static final DeviceRegistrationManager _instance = DeviceRegistrationManager._internal();
  factory DeviceRegistrationManager() => _instance;
  DeviceRegistrationManager._internal();

  String? _jwt;
  String? _fcmToken;
  bool _pushEnabled = false;
  bool _inFlight = false;
  bool _registered = false;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  
  final DeviceService _deviceService = DeviceService();

  /// Called when auth token becomes available
  void onAuthTokenAvailable(String jwt) {
    debugPrint('🔐 DeviceRegistration: Auth token available (${jwt.length} chars)');
    _jwt = jwt;
    _retryCount = 0; // Reset retry count on new auth token
    debugPrint('🔐 DeviceRegistration: Prerequisites check - JWT: ✓, FCM: ${_fcmToken != null ? "✓" : "✗"}, Push: ${_pushEnabled ? "✓" : "✗"}');
    _attemptRegister();
  }

  /// Called when auth is cleared (logout)
  void onAuthCleared() {
    debugPrint('🔐 DeviceRegistration: Auth cleared');
    _jwt = null;
    _registered = false;
    _retryTimer?.cancel();
  }

  /// Called when FCM token becomes available
  void onFcmTokenAvailable(String token) {
    final isRefresh = _fcmToken != null && _fcmToken != token;
    debugPrint('🔔 DeviceRegistration: FCM token ${isRefresh ? "refreshed" : "available"} (${token.length} chars, ends: ...${token.substring(token.length - 6)})');
    _fcmToken = token;
    debugPrint('🔔 DeviceRegistration: Prerequisites check - JWT: ${_jwt != null ? "✓" : "✗"}, FCM: ✓, Push: ${_pushEnabled ? "✓" : "✗"}');
    _attemptRegister();
  }

  /// Called when push permission changes
  void onPushPermissionChanged(bool enabled) {
    debugPrint('🔔 DeviceRegistration: Push permission = $enabled');
    _pushEnabled = enabled;
    _attemptRegister();
  }

  /// Attempt device registration if all prerequisites are met
  Future<void> _attemptRegister() async {
    if (_inFlight) {
      debugPrint('📱 DeviceRegistration: Already in flight, skipping');
      return;
    }
    
    if (_jwt == null) {
      debugPrint('📱 DeviceRegistration: Missing JWT token - waiting for authentication');
      return;
    }
    
    if (_fcmToken == null) {
      debugPrint('📱 DeviceRegistration: Missing FCM token - waiting for push service initialization');
      return;
    }
    
    if (!_pushEnabled) {
      debugPrint('📱 DeviceRegistration: Push notifications disabled - skipping registration');
      return;
    }

    _inFlight = true;
    debugPrint('📱 DeviceRegistration: 🚀 Starting registration attempt');
    debugPrint('📱 DeviceRegistration: ├── JWT: ${_jwt!.substring(0, 20)}...');
    debugPrint('📱 DeviceRegistration: ├── FCM: ...${_fcmToken!.substring(_fcmToken!.length - 10)}');
    debugPrint('📱 DeviceRegistration: └── Push enabled: $_pushEnabled');
    
    try {
      final deviceResponse = await _deviceService.registerDevice(
        pushToken: _fcmToken!,
        alertNotifications: true,
        chatNotifications: true,
        systemNotifications: true,
        includeLocation: true,
      );
      
      if (deviceResponse != null) {
        _registered = true;
        _retryCount = 0; // Reset retry count on success
        debugPrint('✅ DeviceRegistration: SUCCESS - Device registered');
        debugPrint('📱 DeviceRegistration: ├── Device ID: ${deviceResponse.deviceId}');
        debugPrint('📱 DeviceRegistration: ├── Platform: ${deviceResponse.platform.value}');
        debugPrint('📱 DeviceRegistration: └── Push enabled: ${deviceResponse.pushEnabled}');
      } else {
        debugPrint('❌ DeviceRegistration: FAILED - API returned null response');
        debugPrint('📱 DeviceRegistration: This usually indicates a server error or invalid request');
        _scheduleRetry();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ DeviceRegistration: EXCEPTION - Registration failed');
      debugPrint('📱 DeviceRegistration: ├── Error: ${e.toString()}');
      debugPrint('📱 DeviceRegistration: ├── Type: ${e.runtimeType}');
      
      // Parse HTTP error details if available
      if (e.toString().contains('XMLHttpRequest error') || e.toString().contains('HttpException')) {
        debugPrint('📱 DeviceRegistration: ├── Likely HTTP error - check network/auth');
      }
      
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        debugPrint('📱 DeviceRegistration: ├── 401 UNAUTHORIZED - JWT token may be invalid/expired');
      } else if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        debugPrint('📱 DeviceRegistration: ├── 403 FORBIDDEN - insufficient permissions');
      } else if (e.toString().contains('422')) {
        debugPrint('📱 DeviceRegistration: ├── 422 VALIDATION ERROR - invalid request data');
      }
      
      debugPrint('📱 DeviceRegistration: └── Will retry in 10 seconds...');
      _scheduleRetry();
    } finally {
      _inFlight = false;
    }
  }

  /// Schedule a retry with exponential backoff
  void _scheduleRetry() {
    if (_retryCount >= _maxRetries) {
      debugPrint('🚫 DeviceRegistration: Max retries ($_maxRetries) exceeded - giving up');
      debugPrint('📱 DeviceRegistration: Device will NOT receive push notifications');
      debugPrint('📱 DeviceRegistration: Try logging out/in or restarting app to retry');
      return;
    }
    
    _retryTimer?.cancel();
    _retryCount++;
    
    // Exponential backoff: 2^attempt * 5 seconds (5s, 10s, 20s, 40s, 80s)
    final delaySeconds = (1 << (_retryCount - 1)) * 5;
    
    debugPrint('🔄 DeviceRegistration: Scheduling retry #$_retryCount in ${delaySeconds}s');
    
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      debugPrint('🔄 DeviceRegistration: Executing retry #$_retryCount');
      _attemptRegister();
    });
  }

  /// Public method to nudge registration attempt
  Future<void> ensureRegisteredSoon() async {
    debugPrint('📱 DeviceRegistration: Manual registration check requested');
    await _attemptRegister();
  }

  /// Check if device is currently registered
  bool get isRegistered => _registered;
  
  /// Dispose resources
  void dispose() {
    _retryTimer?.cancel();
  }
}