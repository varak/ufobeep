import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'sound_service.dart';

class Notifications {
  static const String channelId = 'ufobeep_beeps';
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> ensureNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  static Future<void> initializeChannels() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notifications.initialize(initializationSettings);
    
    // Create high-priority beep notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      'UFO Beep Alerts',
      description: 'High priority notifications for nearby UFO sightings',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    
    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> handleForegroundBeep() async {
    try {
      // Haptic feedback for immediate physical alert
      HapticFeedback.mediumImpact();
      
      // Play alert sound using our sound service (includes warm-up)
      await SoundService.I.play(AlertSound.normal, haptic: true);
    } catch (e) {
      print('Error handling foreground beep: $e');
    }
  }
}