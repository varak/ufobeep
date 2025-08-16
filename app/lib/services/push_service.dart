import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../services/permission_service.dart';
import '../services/anonymous_beep_service.dart';

class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  static PushService get instance => _instance;

  bool _initialized = false;
  String? _currentToken;

  /// Initialize Firebase and register device for push notifications
  static Future<void> initAndRegister() async {
    try {
      print('Initializing Firebase and FCM...');
      
      // Initialize Firebase
      await Firebase.initializeApp();
      print('Firebase initialized successfully');

      final fcm = FirebaseMessaging.instance;

      // Configure foreground notification presentation options
      await fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      final token = await fcm.getToken();
      if (token == null) {
        print('Failed to get FCM token');
        return;
      }

      print('FCM token obtained: ${token.substring(0, 20)}...');
      PushService.instance._currentToken = token;

      // Get device ID from anonymous beep service
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      
      // Get current location if available
      final permissionService = PermissionService();
      double? lat, lon;
      
      if (permissionService.locationGranted) {
        try {
          final position = await permissionService.getCurrentLocation();
          if (position != null) {
            lat = position.latitude;
            lon = position.longitude;
            print('Location for registration: $lat, $lon');
          }
        } catch (e) {
          print('Failed to get location for registration: $e');
        }
      }

      // Register device with API
      await ApiClient.post('/api/register/device', {
        'device_id': deviceId,
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'lat': lat,
        'lon': lon,
      });

      print('Device registered successfully with FCM');

      // Handle token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print('FCM token refreshed');
        PushService.instance._currentToken = newToken;
        
        try {
          await ApiClient.post('/api/register/device', {
            'device_id': deviceId,
            'fcm_token': newToken,
            'platform': Platform.isIOS ? 'ios' : 'android',
            'lat': lat,
            'lon': lon,
          });
          print('Device re-registered with new FCM token');
        } catch (e) {
          print('Failed to re-register device with new token: $e');
        }
      });

      // Set up message handlers
      _setupMessageHandlers();

      PushService.instance._initialized = true;
      print('Push service initialization complete');

    } catch (e) {
      print('Error initializing push service: $e');
    }
  }

  /// Set up message handlers for foreground and background notifications
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.data}');
      
      // Handle different message types
      final messageType = message.data['type'];
      switch (messageType) {
        case 'test':
          print('Received test push notification');
          break;
        case 'alert':
          print('Received UFO alert notification');
          // TODO: Show local notification and navigate to alert
          break;
        case 'witness':
          print('Received witness notification');
          break;
        default:
          print('Unknown message type: $messageType');
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.data}');
      
      // TODO: Navigate to appropriate screen based on message data
      final messageType = message.data['type'];
      switch (messageType) {
        case 'alert':
          // Navigate to alert detail screen
          final alertId = message.data['alert_id'];
          if (alertId != null) {
            // Navigate to /alert/$alertId
            print('Should navigate to alert: $alertId');
          }
          break;
        default:
          print('Unhandled notification tap for type: $messageType');
      }
    });
  }

  /// Get current FCM token
  String? get currentToken => _currentToken;

  /// Check if push service is initialized
  bool get isInitialized => _initialized;

  /// Update device location (call when location changes)
  static Future<void> updateLocation(double lat, double lon) async {
    try {
      if (!PushService.instance._initialized) {
        print('Push service not initialized, skipping location update');
        return;
      }

      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      final token = PushService.instance._currentToken;
      
      if (token == null) {
        print('No FCM token available for location update');
        return;
      }

      await ApiClient.post('/api/register/device', {
        'device_id': deviceId,
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'lat': lat,
        'lon': lon,
      });

      print('Device location updated: $lat, $lon');
    } catch (e) {
      print('Failed to update device location: $e');
    }
  }

  /// Test push notification
  static Future<bool> testPush() async {
    try {
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      
      final response = await ApiClient.post('/api/push/test', {
        'device_id': deviceId,
      });

      print('Test push response: $response');
      return response['ok'] == true;
    } catch (e) {
      print('Failed to send test push: $e');
      return false;
    }
  }
}

// Global function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');
  print('Background message data: ${message.data}');
}