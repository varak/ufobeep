import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

enum AlertLevel {
  normal,      // Single witness, standard beep
  urgent,      // 3+ witnesses, urgent warble
  emergency,   // 10+ witnesses, emergency siren
  critical     // 50+ witnesses, air raid level
}

class AlertSoundService {
  static const String _quietHoursEnabledKey = 'quiet_hours_enabled';
  static const String _quietHoursStartKey = 'quiet_hours_start';
  static const String _quietHoursEndKey = 'quiet_hours_end';
  static const String _volumeKey = 'alert_volume';
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  static final AlertSoundService _instance = AlertSoundService._internal();
  factory AlertSoundService() => _instance;
  AlertSoundService._internal();

  Future<void> initialize() async {
    // Initialize local notifications for custom sounds
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
    
    // Create notification channels for different alert levels
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    // Create vibration patterns
    final normalVibration = Int64List.fromList([0, 500]);
    final urgentVibration = Int64List.fromList([0, 300, 200, 300, 200, 300]);
    final emergencyVibration = Int64List.fromList([0, 1000, 500, 1000, 500, 1000]);
    final criticalVibration = Int64List.fromList([0, 2000, 1000, 2000, 1000, 2000]);

    final normalChannel = AndroidNotificationChannel(
      'ufobeep_normal',
      'Normal Alerts',
      description: 'Standard UFO sighting notifications',
      importance: Importance.high,
      enableVibration: true,
      vibrationPattern: normalVibration,
    );

    final urgentChannel = AndroidNotificationChannel(
      'ufobeep_urgent',
      'Urgent Alerts',
      description: 'Multiple witness UFO sightings',
      importance: Importance.max,
      enableVibration: true,
      vibrationPattern: urgentVibration,
      enableLights: true,
      ledColor: const Color(0xFFFF0000),
    );

    final emergencyChannel = AndroidNotificationChannel(
      'ufobeep_emergency',
      'Emergency Alerts',
      description: 'Mass UFO sightings - LOOK NOW!',
      importance: Importance.max,
      enableVibration: true,
      vibrationPattern: emergencyVibration,
      enableLights: true,
      ledColor: const Color(0xFFFF0000),
    );

    final criticalChannel = AndroidNotificationChannel(
      'ufobeep_critical',
      'Critical Alerts',
      description: 'Regional UFO event - EVERYONE LOOK!',
      importance: Importance.max,
      enableVibration: true,
      vibrationPattern: criticalVibration,
      enableLights: true,
      ledColor: const Color(0xFFFF0000),
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(normalChannel);
      await androidPlugin.createNotificationChannel(urgentChannel);
      await androidPlugin.createNotificationChannel(emergencyChannel);
      await androidPlugin.createNotificationChannel(criticalChannel);
    }
  }

  Future<void> playAlertSound(AlertLevel level, {int witnessCount = 1}) async {
    // Check quiet hours (but override for emergency/critical)
    if (level == AlertLevel.normal || level == AlertLevel.urgent) {
      final inQuietHours = await _isInQuietHours();
      if (inQuietHours) {
        print('In quiet hours, using vibration only');
        await _vibrateOnly(level);
        return;
      }
    }

    // Get user volume preference (default to max for accessibility)
    final prefs = await SharedPreferences.getInstance();
    final volume = prefs.getDouble(_volumeKey) ?? 1.0;
    
    // Set to maximum volume for better accessibility
    await _audioPlayer.setVolume(1.0);
    
    // Play appropriate sound based on level
    String soundFile;
    List<int> vibrationPattern;
    
    switch (level) {
      case AlertLevel.normal:
        soundFile = 'sounds/normal_beep.mp3';
        vibrationPattern = [0, 500];
        break;
      case AlertLevel.urgent:
        soundFile = 'sounds/urgent_warble.mp3';
        vibrationPattern = [0, 300, 200, 300, 200, 300];
        break;
      case AlertLevel.emergency:
        soundFile = 'sounds/emergency_siren.mp3';
        vibrationPattern = [0, 1000, 500, 1000, 500, 1000];
        break;
      case AlertLevel.critical:
        soundFile = 'sounds/critical_alarm.mp3';
        vibrationPattern = [0, 2000, 1000, 2000, 1000, 2000];
        break;
    }

    // Play sound
    try {
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      print('Error playing alert sound: $e');
      // Fallback to system sound
      await _playSystemSound(level);
    }

    // Vibrate
    if (await Vibration.hasVibrator() ?? false) {
      if (level == AlertLevel.critical) {
        // Continuous vibration for critical alerts
        Vibration.vibrate(duration: 5000);
      } else {
        Vibration.vibrate(pattern: vibrationPattern);
      }
    }
  }

  Future<void> _playSystemSound(AlertLevel level) async {
    // Use local notifications to play system sounds
    final String channelId = _getChannelId(level);
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'UFO Alert!',
      _getAlertMessage(level),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(level),
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: _getIosSound(level),
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: level == AlertLevel.critical 
              ? InterruptionLevel.critical 
              : InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  String _getChannelId(AlertLevel level) {
    switch (level) {
      case AlertLevel.normal:
        return 'ufobeep_normal';
      case AlertLevel.urgent:
        return 'ufobeep_urgent';
      case AlertLevel.emergency:
        return 'ufobeep_emergency';
      case AlertLevel.critical:
        return 'ufobeep_critical';
    }
  }

  String _getChannelName(AlertLevel level) {
    switch (level) {
      case AlertLevel.normal:
        return 'Normal Alerts';
      case AlertLevel.urgent:
        return 'Urgent Alerts';
      case AlertLevel.emergency:
        return 'Emergency Alerts';
      case AlertLevel.critical:
        return 'Critical Alerts';
    }
  }

  String _getAlertMessage(AlertLevel level) {
    switch (level) {
      case AlertLevel.normal:
        return 'UFO sighting nearby - tap to look!';
      case AlertLevel.urgent:
        return 'Multiple witnesses! UFO confirmed nearby!';
      case AlertLevel.emergency:
        return 'MASS SIGHTING! Everyone look NOW!';
      case AlertLevel.critical:
        return 'REGIONAL EVENT! Sky phenomenon in progress!';
    }
  }

  String _getIosSound(AlertLevel level) {
    switch (level) {
      case AlertLevel.normal:
        return 'normal_beep.caf';
      case AlertLevel.urgent:
        return 'urgent_warble.caf';
      case AlertLevel.emergency:
        return 'emergency_siren.caf';
      case AlertLevel.critical:
        return 'critical_alarm.caf';
    }
  }

  Future<void> _vibrateOnly(AlertLevel level) async {
    if (await Vibration.hasVibrator() ?? false) {
      switch (level) {
        case AlertLevel.normal:
          Vibration.vibrate(pattern: [0, 200]);
          break;
        case AlertLevel.urgent:
          Vibration.vibrate(pattern: [0, 200, 100, 200]);
          break;
        case AlertLevel.emergency:
          Vibration.vibrate(pattern: [0, 500, 200, 500]);
          break;
        case AlertLevel.critical:
          Vibration.vibrate(duration: 2000);
          break;
      }
    }
  }

  Future<bool> _isInQuietHours() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_quietHoursEnabledKey) ?? false;
    
    if (!enabled) return false;
    
    final startHour = prefs.getInt(_quietHoursStartKey) ?? 22;
    final endHour = prefs.getInt(_quietHoursEndKey) ?? 7;
    
    final now = DateTime.now();
    final currentHour = now.hour;
    
    if (startHour <= endHour) {
      return currentHour >= startHour && currentHour < endHour;
    } else {
      return currentHour >= startHour || currentHour < endHour;
    }
  }

  AlertLevel determineAlertLevel(int witnessCount) {
    if (witnessCount >= 50) return AlertLevel.critical;
    if (witnessCount >= 10) return AlertLevel.emergency;
    if (witnessCount >= 3) return AlertLevel.urgent;
    return AlertLevel.normal;
  }

  Future<void> testAlert(AlertLevel level) async {
    print('Testing alert level: $level');
    await playAlertSound(level);
  }

  Future<void> stopAllSounds() async {
    await _audioPlayer.stop();
    await Vibration.cancel();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

// Global instance
final alertSoundService = AlertSoundService();