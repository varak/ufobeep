import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'device_service.dart';
import 'sound_service.dart';
import 'anonymous_beep_service.dart';
import 'permission_service.dart';
import 'api_client.dart';
import '../routing/app_router.dart';

class PushNotificationService {
  static const String _permissionKey = 'push_permission_granted';
  static const String _tokenKey = 'fcm_token';
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DeviceService _deviceService = deviceService;
  late final Dio _dio;

  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.ufobeep.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  Future<void> initialize() async {
    // Request permission for push notifications
    final permission = await requestPermission();
    
    if (permission) {
      // Get FCM token
      final token = await getToken();
      if (token != null) {
        // Register device with token
        await _deviceService.registerDevice(pushToken: token);
        
        // Also register with FCM device API for Phase 0
        await _registerWithFCMAPI(token);
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) async {
          print('FCM token refreshed: $newToken');
          await _deviceService.updatePushToken(newToken);
          await _cacheToken(newToken);
        });
      }
      
      // Set up message handlers
      _setupMessageHandlers();
    }
  }

  Future<bool> requestPermission() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Always check actual system permission status, don't rely only on cache
    try {
      final currentSettings = await _messaging.getNotificationSettings();
      final hasSystemPermission = currentSettings.authorizationStatus == AuthorizationStatus.authorized ||
                                 currentSettings.authorizationStatus == AuthorizationStatus.provisional;
      
      // If system says we don't have permission, clear cache and re-request
      if (!hasSystemPermission) {
        await prefs.remove(_permissionKey);
        print('System permission denied, cleared cache and will re-request');
      } else {
        // Update cache to match system state
        await prefs.setBool(_permissionKey, true);
        print('System permission confirmed, updated cache');
        return true;
      }
    } catch (e) {
      print('Error checking system permission status: $e');
      // Fall back to re-requesting if we can't check
      await prefs.remove(_permissionKey);
    }

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                     settings.authorizationStatus == AuthorizationStatus.provisional;

      // Cache the permission result
      await prefs.setBool(_permissionKey, granted);
      
      if (granted) {
        print('Push notification permission granted');
      } else {
        print('Push notification permission denied: ${settings.authorizationStatus}');
      }

      return granted;
    } catch (e) {
      print('Error requesting push notification permission: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _cacheToken(token);
        print('FCM Token obtained: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<String?> getCachedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _cacheToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.messageId}');
      _handleMessage(message, isBackground: false);
    });

    // Handle messages when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background message: ${message.messageId}');
      _handleMessage(message, isBackground: true);
    });

    // Handle messages when app is terminated (handled in main.dart background handler)
  }

  void _handleMessage(RemoteMessage message, {required bool isBackground}) {
    print('Push notification received:');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Handle different notification types
    final notificationType = message.data['type'] ?? 'general';
    
    switch (notificationType) {
      case 'sighting_alert':
        _handleSightingAlert(message);
        break;
      case 'chat_message':
        _handleChatMessage(message);
        break;
      case 'system_notification':
        _handleSystemNotification(message);
        break;
      default:
        _handleGeneralNotification(message);
    }

    // Update notification statistics
    _updateNotificationStats(opened: isBackground);
  }

  void _handleSightingAlert(RemoteMessage message) async {
    print('Handling sighting alert notification');
    final sightingId = message.data['sighting_id'];
    final witnessCountStr = message.data['witness_count'] ?? '1';
    final witnessCount = int.tryParse(witnessCountStr) ?? 1;
    
    // Play appropriate escalated alert sound based on witness count
    if (witnessCount >= 10) {
      await SoundService.I.play(AlertSound.emergency, haptic: true);
    } else if (witnessCount >= 3) {
      await SoundService.I.play(AlertSound.urgent);
    } else {
      await SoundService.I.play(AlertSound.normal);
    }
    
    // Also play push notification sound
    await SoundService.I.play(AlertSound.pushPing);
    
    if (sightingId != null) {
      print('Sighting ID: $sightingId, Witnesses: $witnessCount');
      navigateToAlert(sightingId);
    }
  }

  void _handleChatMessage(RemoteMessage message) {
    print('Handling chat message notification');
    final chatId = message.data['chat_id'];
    if (chatId != null) {
      print('Chat ID: $chatId');
      navigateToChat(chatId);
    }
  }

  void _handleSystemNotification(RemoteMessage message) {
    print('Handling system notification');
    // TODO: Show in-app notification or navigate to settings
  }

  void _handleGeneralNotification(RemoteMessage message) {
    print('Handling general notification');
    // TODO: Show generic notification handler
  }

  Future<void> _updateNotificationStats({required bool opened}) async {
    try {
      // This could be expanded to track notification statistics
      // For now, just log the interaction
      if (opened) {
        print('Notification was opened by user');
      } else {
        print('Notification was received in foreground');
      }
    } catch (e) {
      print('Error updating notification stats: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  Future<void> subscribeToLocationAlerts(double latitude, double longitude, double radiusKm) async {
    // Subscribe to location-based alerts
    // This could be implemented with geofencing topics or handled server-side
    final topic = 'alerts_${latitude.toStringAsFixed(1)}_${longitude.toStringAsFixed(1)}';
    await subscribeToTopic(topic);
  }

  Future<bool> isPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionKey) ?? false;
  }

  Future<void> refreshTokenAndRegister() async {
    try {
      await _messaging.deleteToken();
      final newToken = await getToken();
      if (newToken != null) {
        await _deviceService.updatePushToken(newToken);
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
  }

  void navigateToAlert(String alertId) {
    try {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.go('/alert/$alertId');
        print('Navigated to alert detail: $alertId');
      } else {
        print('Cannot navigate: no valid context available');
        // Store for later navigation when app becomes active
        _pendingNavigation = '/alert/$alertId';
      }
    } catch (e) {
      print('Error navigating to alert $alertId: $e');
    }
  }

  String? _pendingNavigation;

  void navigateToChat(String chatId) {
    try {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.go('/alert/$chatId/chat');
        print('Navigated to chat: $chatId');
      } else {
        print('Cannot navigate: no valid context available');
        _pendingNavigation = '/alert/$chatId/chat';
      }
    } catch (e) {
      print('Error navigating to chat $chatId: $e');
    }
  }

  void processPendingNavigation() {
    if (_pendingNavigation != null) {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.go(_pendingNavigation!);
        print('Processed pending navigation: $_pendingNavigation');
        _pendingNavigation = null;
      }
    }
  }

  /// Register device with FCM API for Phase 0 proximity alerts
  Future<void> _registerWithFCMAPI(String fcmToken) async {
    try {
      // Get device ID from anonymous beep service
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      
      // Get current location if available
      double? lat, lon;
      if (permissionService.locationGranted) {
        try {
          final position = await permissionService.getCurrentLocation();
          if (position != null) {
            lat = position.latitude;
            lon = position.longitude;
          }
        } catch (e) {
          print('Failed to get location for FCM registration: $e');
        }
      }

      // Register with existing devices API (cleaner)
      final response = await _dio.post('/devices/register', data: {
        'device_id': deviceId,
        'push_token': fcmToken,
        'push_provider': 'fcm',
        'platform': Platform.isIOS ? 'ios' : 'android',
        'alert_notifications': true,
        'chat_notifications': true,
        'system_notifications': true,
      });

      print('FCM device registration successful: ${response.data['success']}');
    } catch (e) {
      print('Failed to register with FCM API: $e');
    }
  }

  /// Test push notification via FCM API
  Future<bool> testPushNotification() async {
    try {
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      
      final response = await _dio.post('/api/push/test', data: {
        'device_id': deviceId,
      });

      print('Test push response: ${response.data}');
      return response.data['ok'] == true;
    } catch (e) {
      print('Failed to send test push: $e');
      return false;
    }
  }

  void dispose() {
    // Clean up resources if needed
  }
}

// Global instance
final pushNotificationService = PushNotificationService();