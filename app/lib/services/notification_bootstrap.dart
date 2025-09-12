import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class NotificationBootstrap {
  static const String _channelId = 'ufobeep_alerts';

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> initialize({BuildContext? context}) async {
    if (_isInitialized) return;

    try {
      print('🔔 BOOTSTRAP: Initializing notification system...');

      // Initialize local notifications plugin
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(initSettings);
      print('🔔 BOOTSTRAP: Local notifications plugin initialized');

      // Create unified notification channel with localized strings
      await _createNotificationChannel(context);
      print('🔔 BOOTSTRAP: Notification channel created');

      // Request notification permission on Android 13+
      await _requestNotificationPermission();
      print('🔔 BOOTSTRAP: Permission check completed');

      _isInitialized = true;
      print('🔔 BOOTSTRAP: Notification system initialization complete');
    } catch (e) {
      print('🔔 BOOTSTRAP ERROR: Failed to initialize notifications: $e');
      rethrow;
    }
  }

  static Future<void> _createNotificationChannel(BuildContext? context) async {
    // Get localized strings, fallback to English if context unavailable
    String channelName = 'UFOBeep Alerts';
    String channelDescription = 'Notifications for UFO beeps and proximity alerts';
    
    if (context != null) {
      try {
        final l10n = AppLocalizations.of(context)!;
        channelName = l10n?.notificationChannelAlerts ?? channelName;
        channelDescription = l10n?.notificationChannelAlertsDesc ?? channelDescription;
        print('🔔 BOOTSTRAP: Using localized channel strings');
      } catch (e) {
        print('🔔 BOOTSTRAP: Could not load localized strings, using fallback: $e');
      }
    }

    final androidChannel = AndroidNotificationChannel(
      _channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
      playSound: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    print('🔔 BOOTSTRAP: Created notification channel "$_channelId" with Importance.max');
  }

  static Future<bool> _requestNotificationPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    // Check current permission status
    final status = await Permission.notification.status;
    print('🔔 BOOTSTRAP: Current notification permission status: $status');

    if (status.isGranted) {
      print('🔔 BOOTSTRAP: Notification permission already granted');
      return true;
    }

    if (status.isDenied) {
      print('🔔 BOOTSTRAP: Requesting notification permission...');
      final result = await Permission.notification.request();
      print('🔔 BOOTSTRAP: Permission request result: $result');
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      print('🔔 BOOTSTRAP: Notification permission permanently denied');
      return false;
    }

    return false;
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    BuildContext? context,
  }) async {
    if (!_isInitialized) {
      print('🔔 BOOTSTRAP WARNING: Notification system not initialized, initializing now...');
      await initialize(context: context);
    }

    try {
      // Get localized channel strings, fallback to English
      String channelName = 'UFOBeep Alerts';
      String channelDescription = 'Notifications for UFO beeps and proximity alerts';
      
      if (context != null) {
        try {
          final l10n = AppLocalizations.of(context)!;
          channelName = l10n?.notificationChannelAlerts ?? channelName;
          channelDescription = l10n?.notificationChannelAlertsDesc ?? channelDescription;
        } catch (e) {
          print('🔔 BOOTSTRAP: Could not load localized strings for notification: $e');
        }
      }

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        autoCancel: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: data?.toString(),
      );

      print('🔔 BOOTSTRAP: Local notification shown - Title: "$title", Body: "$body"');
    } catch (e) {
      print('🔔 BOOTSTRAP ERROR: Failed to show local notification: $e');
      rethrow;
    }
  }

  static String get channelId => _channelId;
  static bool get isInitialized => _isInitialized;
}