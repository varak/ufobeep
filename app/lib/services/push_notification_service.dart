import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_service.dart';
import 'device_registration_manager.dart';
import '../providers/alerts_provider.dart';
import 'sound_service.dart';
import 'beep_service.dart';
import 'permission_service.dart';
import 'api_client.dart';
import '../models/user_preferences.dart';
import '../providers/user_preferences_provider.dart';
import '../routing/app_router.dart';

class PushNotificationService {
  static const String _permissionKey = 'push_permission_granted';
  static const String _tokenKey = 'fcm_token';

  // Helper function to safely convert dynamic values to Map for bracket access
  Map<String, dynamic> _asJsonMap(dynamic v) {
    if (v == null) return {};
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    if (v is List) {
      // Turn list into a map with numeric keys, so any ['x'] access will visibly fail early.
      return {
        "_type": "List",
        "length": v.length,
        "0": v.isNotEmpty ? v[0] : null,
      };
    }
    if (v is String && v.trim().startsWith('{')) {
      try { 
        return Map<String, dynamic>.from(jsonDecode(v)); 
      } catch (_) {}
    }
    return {"_type": v.runtimeType.toString(), "value": v.toString()};
  }
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DeviceService _deviceService = deviceService;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
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
    // Initialize local notifications for rich notifications
    await _initializeLocalNotifications();
    
    // Request permission for push notifications
    final permission = await requestPermission();
    
    if (permission) {
      // Get FCM token
      final token = await getToken();
      if (token != null) {
        // Notify DeviceRegistrationManager that FCM token is available
        DeviceRegistrationManager().onFcmTokenAvailable(token);
        
        // Notify about push permission being granted
        DeviceRegistrationManager().onPushPermissionChanged(true);
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) async {
          print('FCM token refreshed: $newToken');
          await _cacheToken(newToken);
          // Notify DeviceRegistrationManager of the new token
          DeviceRegistrationManager().onFcmTokenAvailable(newToken);
        });
      }
      
      // Set up message handlers
      _setupMessageHandlers();
    } else {
      // Notify DeviceRegistrationManager that push permission was denied
      DeviceRegistrationManager().onPushPermissionChanged(false);
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
      case 'comment':
        _handleCommentNotification(message);
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
    final submitterDeviceId = message.data['submitter_device_id'];
    final distance = message.data['distance'];
    final locationName = message.data['location_name'] ?? 'Unknown Location';
    
    // Check if this device submitted the beep - if so, don't auto-navigate
    final currentDeviceId = await _deviceService.getDeviceId();
    final isOwnBeep = submitterDeviceId != null && submitterDeviceId == currentDeviceId;
    
    if (isOwnBeep) {
      print('🚫 SKIPPING OWN BEEP: device $currentDeviceId submitted sighting $sightingId');
      return; // Don't process self-notifications
    }
    
    print('📱 PROCESSING ALERT: sighting $sightingId from device $submitterDeviceId (current: $currentDeviceId)');
    
    
    // Load user preferences for DND/quiet hours checking
    dynamic userPrefs;
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      if (prefsJson != null) {
        final prefsMap = jsonDecode(prefsJson) as Map<String, dynamic>;
        userPrefs = UserPreferences.fromJson(prefsMap);
        print('🔇 Foreground: Loaded user preferences for DND checking');
      }
    } catch (e) {
      print('⚠️ Foreground: Could not load user preferences: $e');
    }
    
    // Show rich notification with action buttons
    await _showRichNotification(sightingId, witnessCount, distance, locationName);
    
    // Play appropriate escalated alert sound based on witness count
    if (witnessCount >= 10) {
      await SoundService.I.play(AlertSound.emergency, haptic: true, witnessCount: witnessCount, userPrefs: userPrefs);
    } else if (witnessCount >= 3) {
      await SoundService.I.play(AlertSound.urgent, witnessCount: witnessCount, userPrefs: userPrefs);
    } else {
      await SoundService.I.play(AlertSound.normal, witnessCount: witnessCount, userPrefs: userPrefs);
    }
    
    // Also play push notification sound
    await SoundService.I.play(AlertSound.pushPing, userPrefs: userPrefs);
    
    // Check if we should refresh alerts tab
    final shouldRefreshAlerts = message.data['refresh_alerts'] == 'true';
    if (shouldRefreshAlerts) {
      try {
        final container = ProviderScope.containerOf(rootNavigatorKey.currentContext!);
        container.refresh(alertsListProvider);
        
        // Force invalidate individual alert cache for the new sighting
        if (sightingId != null) {
          container.invalidate(alertByIdProvider(sightingId));
          print('🔄 Force invalidated individual alert cache for $sightingId');
          
          // Pre-fetch the fresh alert data to populate cache
          container.read(alertByIdProvider(sightingId));
          print('📥 Pre-fetched fresh alert data for $sightingId');
        }
        
        print('🔄 Refreshed alerts tab due to new proximity alert');
      } catch (e) {
        print('Could not refresh alerts tab: $e');
      }
    }
    
    if (sightingId != null) {
      print('Sighting ID: $sightingId, Witnesses: $witnessCount');
      
      // Extract sighting location data for compass navigation
      final sightingLat = message.data['latitude'];
      final sightingLon = message.data['longitude'];
      final sightingName = message.data['location_name'] ?? 'UFO Sighting';
      final bearing = message.data['bearing'];
      
      // Refresh alerts cache to ensure fresh data for notification clicks
      try {
        final container = ProviderScope.containerOf(rootNavigatorKey.currentContext!);
        container.refresh(alertsListProvider);
        
        // Force invalidate the specific alert's cache for immediate media display
        container.invalidate(alertByIdProvider(sightingId));
        
        // Pre-fetch fresh data to ensure media is loaded
        container.read(alertByIdProvider(sightingId));
        print('Force invalidated and pre-fetched alert $sightingId for fresh notification data with media');
      } catch (e) {
        print('Could not refresh alerts cache: $e');
      }
      
      // Navigate to alert details instead of compass
      // The alert detail screen will have a "Navigate to Sighting" button with compass
      navigateToAlert(sightingId);
    }
  }

  void _handleCommentNotification(RemoteMessage message) async {
    print('🔔 Handling comment notification');
    print('🔔 Full message data: ${message.data}');
    
    // Handle various possible field names for sighting ID
    final sightingId = message.data['sighting_id'] ?? 
                       message.data['sightingId'] ?? 
                       message.data['alert_id'] ?? 
                       message.data['alertId'];
    final commentId = message.data['comment_id'] ?? message.data['commentId'];
    
    if (sightingId != null) {
      print('🔔 Comment on sighting: $sightingId (comment ID: $commentId)');
      
      // Show visual notification
      await _showCommentNotification(message);
      
      // Play notification sound for comment
      await SoundService.I.play(AlertSound.pushPing);
      
      // Always trigger comments refresh for any listening screens
      // This is safe because only screens with registered listeners will refresh
      print('🔔 Calling CommentsRefreshNotifier.notifyRefresh($sightingId)');
      CommentsRefreshNotifier.instance.notifyRefresh(sightingId);
      
      // Refresh alerts to show new comment count
      try {
        final container = ProviderScope.containerOf(rootNavigatorKey.currentContext!);
        container.invalidate(alertByIdProvider(sightingId));
        print('🔄 Refreshed alert provider for $sightingId');
      } catch (e) {
        print('❌ Could not refresh alert cache: $e');
      }
      
      // Navigate to comments (this will be ignored if user is already there)
      navigateToComments(sightingId);
    } else {
      print('⚠️ Comment notification missing sighting_id in data: ${message.data}');
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

  void navigateToComments(String alertId) {
    try {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        // Check if we're already on the comments screen
        try {
          final currentLocation = GoRouter.of(context).routeInformationProvider.value.uri.toString();
          final targetRoute = '/alert/$alertId/comments';
          
          if (currentLocation.contains(targetRoute)) {
            print('🔄 Already on comments screen for $alertId - skipping navigation');
            return;
          }
          
          print('🔄 Navigating to comments: $targetRoute');
          context.go(targetRoute);
          print('✅ Navigation completed for: $alertId');
        } catch (routeError) {
          // Fallback: attempt navigation anyway
          print('⚠️ Could not check current route, navigating anyway: $routeError');
          final route = '/alert/$alertId/comments';
          context.go(route);
        }
      } else {
        print('❌ Cannot navigate: no valid context available');
        _pendingNavigation = '/alert/$alertId/comments';
        print('📝 Set pending navigation: $_pendingNavigation');
      }
    } catch (e) {
      print('❌ Error navigating to comments $alertId: $e');
    }
  }

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

  void navigateToCompass({
    required String sightingId,
    required double? targetLat,
    required double? targetLon,
    String? targetName,
    double? distance,
    double? bearing,
  }) {
    try {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted && targetLat != null && targetLon != null) {
        // Build compass URL with parameters
        final params = <String, String>{
          'alertId': sightingId,
          'targetLat': targetLat.toString(),
          'targetLon': targetLon.toString(),
        };
        
        if (targetName != null) params['targetName'] = targetName;
        if (distance != null) params['distance'] = distance.toString();
        if (bearing != null) params['bearing'] = bearing.toString();
        
        final uri = Uri(path: '/compass', queryParameters: params);
        context.go(uri.toString());
        print('Navigated to compass for sighting: $sightingId at ($targetLat, $targetLon)');
      } else {
        print('Cannot navigate to compass: no valid context or coordinates');
        // Fallback to alert detail
        navigateToAlert(sightingId);
      }
    } catch (e) {
      print('Error navigating to compass for sighting $sightingId: $e');
      // Fallback to alert detail
      navigateToAlert(sightingId);
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
      final deviceId = await beepService.getOrCreateDeviceId();
      
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
      final deviceId = await beepService.getOrCreateDeviceId();
      
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

  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    // Combined initialization settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    // Initialize the plugin with a callback for when notification is tapped
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    print('✅ Local notifications initialized for rich notification support');
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.actionId} for payload: ${response.payload}');
    
    final payload = response.payload;
    if (payload == null) return;
    
    // Parse the payload to get sighting ID
    final parts = payload.split('|');
    if (parts.isEmpty) return;
    
    final sightingId = parts[0];
    final action = response.actionId;
    
    print('Processing notification action: $action for sighting: $sightingId');
    
    // Handle different action buttons
    switch (action) {
      case 'see_it_too':
        _handleSeeItTooAction(sightingId);
        break;
      case 'dismiss_snooze':
        _handleDismissAndSnoozeAction(sightingId);
        break;
      case 'dismiss':
        _handleDismissAction(sightingId);
        break;
      default:
        // Default tap action - navigate to alert
        navigateToAlert(sightingId);
        break;
    }
  }
  
  Future<void> _showCommentNotification(RemoteMessage message) async {
    final sightingId = message.data['sighting_id'];
    final title = message.notification?.title ?? '💬 New Comment';
    final body = message.notification?.body ?? 'Someone commented on an alert';
    
    final androidDetails = AndroidNotificationDetails(
      'ufobeep_comments',
      'Comment Notifications',
      channelDescription: 'Notifications when someone comments on alerts you follow',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: false, // We handle sounds separately
      enableVibration: true,
    );
    
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false, // We handle sounds separately
      interruptionLevel: InterruptionLevel.active,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      sightingId.hashCode + 1000, // Different ID from alert notifications
      title,
      body,
      notificationDetails,
      payload: sightingId,
    );
    
    print('📱 Comment notification shown for sighting $sightingId');
  }

  Future<void> _showRichNotification(String sightingId, int witnessCount, String? distance, String locationName) async {
    // Format distance for display
    String distanceText = '';
    if (distance != null) {
      final distanceNum = double.tryParse(distance);
      if (distanceNum != null) {
        if (distanceNum < 1.0) {
          distanceText = ' • ${(distanceNum * 1000).round()}m away';
        } else {
          distanceText = ' • ${distanceNum.toStringAsFixed(1)}km away';
        }
      }
    }
    
    // Create witness count text with escalation indicators
    String witnessText = '';
    String urgencyIndicator = '';
    if (witnessCount >= 10) {
      witnessText = '$witnessCount witnesses';
      urgencyIndicator = '🚨 EMERGENCY';
    } else if (witnessCount >= 3) {
      witnessText = '$witnessCount witnesses';
      urgencyIndicator = '⚠️ URGENT';
    } else if (witnessCount > 1) {
      witnessText = '$witnessCount witnesses';
      urgencyIndicator = '📢';
    } else {
      witnessText = 'New sighting';
      urgencyIndicator = '📢';
    }
    
    // Create the notification
    final androidDetails = AndroidNotificationDetails(
      'ufobeep_rich_alerts',
      'UFO Alert Actions',
      channelDescription: 'Rich UFO sighting notifications with quick actions',
      importance: witnessCount >= 10 ? Importance.max : Importance.high,
      priority: witnessCount >= 10 ? Priority.max : Priority.high,
      showWhen: true,
      category: AndroidNotificationCategory.recommendation,
      enableVibration: true,
      playSound: false, // We handle sounds separately
      actions: [
        const AndroidNotificationAction(
          'see_it_too',
          'I see it too',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'dismiss_snooze',
          'Snooze',
          showsUserInterface: false,
        ),
      ],
    );
    
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false, // We handle sounds separately
      interruptionLevel: witnessCount >= 10 
          ? InterruptionLevel.critical 
          : InterruptionLevel.timeSensitive,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Show the rich notification
    await _localNotifications.show(
      sightingId.hashCode, // Use sighting ID hash as notification ID
      '$urgencyIndicator UFO Sighting',
      '$witnessText near $locationName$distanceText',
      notificationDetails,
      payload: '$sightingId|$witnessCount|$distance|$locationName',
    );
    
    print('📱 Rich notification shown for sighting $sightingId with ${witnessCount} witnesses');
  }
  
  void _handleSeeItTooAction(String sightingIdRaw) async {
    print('📱 User confirmed sighting: $sightingIdRaw');
    
    // Validate and sanitize sighting ID outside try block for scope access
    final sightingId = sightingIdRaw.trim();
    if (sightingId.isEmpty) {
      print('❌ Invalid sighting ID for witness confirmation');
      return;
    }
    
    try {
      // Build witness payload safely
      final deviceId = await _deviceService.getDeviceId();
      final loc = await permissionService.getCurrentLocation(); // existing
      
      // IMPORTANT: build location as a Map explicitly (no Position objects)
      final Map<String, dynamic>? locationMap = loc == null ? null : {
        "latitude": loc.latitude,
        "longitude": loc.longitude,
        "altitude": loc.altitude,
        "accuracy": loc.accuracy,
      };
      
      // Build flat witness data (no nested objects, just flat fields as before)
      final Map<String, dynamic> witnessData = {
        "device_id": deviceId,
        "witness_type": "visual",
        "confirmed": true,
        "quick_action": true,
        "still_visible": true,
        // Use flat location fields as per API expectation
        "latitude": locationMap?["latitude"],
        "longitude": locationMap?["longitude"], 
        "altitude": locationMap?["altitude"],
        "accuracy": locationMap?["accuracy"],
      };

      // Sanity: ensure it's a Map (not List) *before* send
      assert(witnessData is Map<String, dynamic>);
      print('[SEEIT] Sending payload: ${jsonEncode(witnessData)}');

      final resp = await ApiClient.dio.post(
        '/alerts/$sightingId/witnesses',
        data: witnessData,
        options: Options(responseType: ResponseType.json),
      );

      // Normalize response using defensive helper
      final raw = resp.data;
      final data = _asJsonMap(raw);

      // TEMP LOGS (keep until bug is fixed)
      debugPrint('[SEEIT] resp.type=${raw.runtimeType} keys=${data.keys}');
      debugPrint('[SEEIT] resp.json=${jsonEncode(data)}');

      // If backend returns a List in any path, fail fast with a clear message.
      if (data["_type"] == "List") {
        throw StateError("Witness API returned a List; Dart expects a JSON object. Normalize backend or branch here.");
      }

      // SAFE ACCESS: never do data['x']['y'] without guarding
      final success = data["success"] ?? data["ok"] ?? false;
      if (success is bool && success) {
        print('✅ Witness confirmation successful');
        
        // Safe access to nested response data
        final witnessCount = data["witness_count"] ?? data["data"]?["witness_count"] ?? 0;
        if (witnessCount > 0) {
          print('[SEEIT] New witness count: $witnessCount');
        }
      } else {
        // handle error object safely  
        final err = _asJsonMap(data["error"]);
        debugPrint('[SEEIT] error=$err');
        print('⚠️ Unexpected response format or error: ${data["message"] ?? "Unknown error"}');
      }

      // Check for existing comments AFTER confirmation to get the updated state
      bool commentsExisted = false;
      try {
        final commentsResp = await ApiClient.dio.get('/alerts/$sightingId/comments?limit=5');
        final commentsData = commentsResp.data;
        if (commentsData is Map && commentsData['items'] is List) {
          final comments = commentsData['items'] as List;
          // Check if there are comments OTHER than just the auto-generated "I saw it too"
          final nonAutoComments = comments.where((comment) => 
            comment is Map && 
            comment['body'] != null && 
            !comment['body'].toString().contains('I saw it too!')
          ).toList();
          commentsExisted = nonAutoComments.isNotEmpty;
          print('🔍 Comments existed (excluding auto-comment): $commentsExisted (${comments.length} total, ${nonAutoComments.length} non-auto)');
        }
      } catch (e) {
        print('⚠️ Could not check comments after confirmation: $e');
        // Default to staying on alert page on error
        commentsExisted = false;
      }

      // Smart navigation: only go to comments if there's already a conversation
      if (commentsExisted) {
        print('🔄 Comments existed - navigating to join conversation for sighting: $sightingId');
        navigateToComments(sightingId);
      } else {
        print('🏠 No existing conversation - staying on alert screen to show confirmation for sighting: $sightingId');
        // Stay on current screen (alert detail) to show witness confirmation
        // User is auto-followed via backend and will get future comment notifications
      }
      
      print('✅ Witness confirmation sent for sighting $sightingId');
    } catch (e, st) {
      // Emit extremely specific diagnostics to find the exact offender
      debugPrint('[SEEIT][EXC] $e');
      debugPrint('[SEEIT][STACK] $st');
      
      // Extract clear error message from DioException
      String errorMessage = 'Failed to send witness confirmation';
      if (e is DioException && e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map) {
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } else if (errorData is String) {
            errorMessage = errorData;
          }
        } catch (parseError) {
          print('Could not parse error response: $parseError');
        }
      }
      
      print('❌ $errorMessage: $e');
      // On error, don't navigate anywhere - stay on current screen to show error
      // (Smart navigation doesn't apply when confirmation failed)
    }
  }
  
  
  void _handleDismissAndSnoozeAction(String sightingId) async {
    print('📱 User dismissed and snoozed alerts for 1 hour: $sightingId');
    
    try {
      // Get the sighting details for API recording
      final deviceId = await _deviceService.getDeviceId();
      
      // Get location for dismissal record (less critical, use fallback)
      final position = await permissionService.getCurrentLocation();
      final latitude = position?.latitude?.toDouble() ?? 0.0;
      final longitude = position?.longitude?.toDouble() ?? 0.0;
      
      // Call API to record the dismissal with flat data
      await ApiClient.dio.post('/alerts/$sightingId/witnesses', data: {
        'device_id': deviceId,
        'witness_type': 'dismissed',
        'confirmed': false,
        'quick_action': true,
        'still_visible': false,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': position?.altitude?.toDouble(),
        'accuracy': position?.accuracy?.toDouble(),
      });
      
      // Enable 1-hour DND using same pattern as profile screen
      await _enableDndFor1Hour();
      
      print('✅ Dismissed and enabled DND for 1 hour');
    } catch (e) {
      print('❌ Failed to dismiss and snooze: $e');
    }
  }
  
  void _handleDismissAction(String sightingId) {
    print('📱 User dismissed notification for sighting: $sightingId');
    // Just dismiss - no API call needed
  }

  /// Enable DND for 1 hour using same pattern as profile screen
  Future<void> _enableDndFor1Hour() async {
    try {
      // Get user preferences from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      
      if (prefsJson != null) {
        final prefsMap = jsonDecode(prefsJson) as Map<String, dynamic>;
        final currentPrefs = UserPreferences.fromJson(prefsMap);
        
        // Set DND until 1 hour from now (exact same pattern as profile screen)
        final dndUntil = DateTime.now().add(Duration(hours: 1));
        final updatedPrefs = currentPrefs.copyWith(dndUntil: dndUntil);
        
        // Save updated preferences
        final updatedPrefsJson = jsonEncode(updatedPrefs.toJson());
        await prefs.setString('user_preferences', updatedPrefsJson);
        
        print('📱 DND enabled until ${dndUntil.toString().substring(11, 16)}');
      } else {
        print('⚠️ No user preferences found, creating default with DND');
        
        // Create default preferences with DND enabled
        final dndUntil = DateTime.now().add(Duration(hours: 1));
        final defaultPrefs = UserPreferences(dndUntil: dndUntil);
        
        final prefsJson = jsonEncode(defaultPrefs.toJson());
        await prefs.setString('user_preferences', prefsJson);
        
        print('📱 Created default preferences with DND enabled until ${dndUntil.toString().substring(11, 16)}');
      }
    } catch (e) {
      print('❌ Failed to enable DND: $e');
    }
  }


  void dispose() {
    // Clean up resources if needed
  }
}

/// Global notifier to trigger comments screen refresh when needed
class CommentsRefreshNotifier {
  static final CommentsRefreshNotifier _instance = CommentsRefreshNotifier._internal();
  factory CommentsRefreshNotifier() => _instance;
  CommentsRefreshNotifier._internal();
  static CommentsRefreshNotifier get instance => _instance;
  
  final Map<String, Set<VoidCallback>> _listeners = {};
  
  void addListener(String sightingId, VoidCallback callback) {
    print('📝 CommentsRefreshNotifier: addListener for sighting $sightingId');
    (_listeners[sightingId] ??= <VoidCallback>{}).add(callback);
    print('📝 CommentsRefreshNotifier: now ${_listeners[sightingId]!.length} listeners for $sightingId');
  }
  
  void removeListener(String sightingId, VoidCallback callback) {
    print('📝 CommentsRefreshNotifier: removeListener for sighting $sightingId');
    _listeners[sightingId]?.remove(callback);
    if (_listeners[sightingId]?.isEmpty == true) {
      _listeners.remove(sightingId);
    }
  }
  
  void notifyRefresh(String sightingId) {
    print('🔄 CommentsRefreshNotifier: notifying refresh for sighting $sightingId');
    final callbacks = List<VoidCallback>.from(_listeners[sightingId] ?? const []);
    print('🔄 CommentsRefreshNotifier: found ${callbacks.length} listeners');
    
    if (callbacks.isEmpty) {
      print('⚠️ CommentsRefreshNotifier: no listeners registered for sighting $sightingId');
      print('⚠️ Current listener keys: ${_listeners.keys.toList()}');
      return;
    }
    
    // Ensure callbacks run on the UI frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 CommentsRefreshNotifier: executing ${callbacks.length} callbacks on UI frame');
      for (final callback in callbacks) {
        try {
          callback();
        } catch (e, st) {
          print('❌ CommentsRefreshNotifier callback error: $e\n$st');
        }
      }
    });
  }
}

// Global instance
final pushNotificationService = PushNotificationService();