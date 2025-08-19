import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the analytics service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;

  AnalyticsService() {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }

  FirebaseAnalyticsObserver get observer => _observer;

  // User events
  Future<void> logSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method ?? 'email');
  }

  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method ?? 'anonymous');
  }

  // Alert/Sighting events
  Future<void> logSightingReported({
    required String alertId,
    String? category,
    bool? hasMedia,
    String? location,
  }) async {
    await _analytics.logEvent(
      name: 'sighting_reported',
      parameters: {
        'alert_id': alertId,
        'category': category ?? 'unknown',
        'has_media': hasMedia ?? false,
        'location': location ?? 'unknown',
      },
    );
  }

  Future<void> logSightingViewed({
    required String alertId,
    String? source, // 'notification', 'list', 'map', etc.
  }) async {
    await _analytics.logEvent(
      name: 'sighting_viewed',
      parameters: {
        'alert_id': alertId,
        'source': source ?? 'unknown',
      },
    );
  }

  Future<void> logWitnessConfirmation({
    required String alertId,
    required double distance,
  }) async {
    await _analytics.logEvent(
      name: 'witness_confirmation',
      parameters: {
        'alert_id': alertId,
        'distance_km': distance,
      },
    );
  }

  // Navigation events
  Future<void> logCompassUsed({
    required String alertId,
    required double bearing,
    required double distance,
  }) async {
    await _analytics.logEvent(
      name: 'compass_navigation',
      parameters: {
        'alert_id': alertId,
        'bearing': bearing,
        'distance_km': distance,
      },
    );
  }

  Future<void> logMapViewed({
    required String alertId,
    String? mapType, // 'detail', 'overview'
  }) async {
    await _analytics.logEvent(
      name: 'map_viewed',
      parameters: {
        'alert_id': alertId,
        'map_type': mapType ?? 'unknown',
      },
    );
  }

  // Media events
  Future<void> logPhotoTaken({
    required String alertId,
    String? source, // 'camera', 'gallery'
  }) async {
    await _analytics.logEvent(
      name: 'photo_taken',
      parameters: {
        'alert_id': alertId,
        'source': source ?? 'camera',
      },
    );
  }

  Future<void> logVideoRecorded({
    required String alertId,
    required int durationSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'video_recorded',
      parameters: {
        'alert_id': alertId,
        'duration_seconds': durationSeconds,
      },
    );
  }

  // Notification events
  Future<void> logNotificationReceived({
    required String alertId,
    required double distance,
  }) async {
    await _analytics.logEvent(
      name: 'notification_received',
      parameters: {
        'alert_id': alertId,
        'distance_km': distance,
      },
    );
  }

  Future<void> logNotificationTapped({
    required String alertId,
  }) async {
    await _analytics.logEvent(
      name: 'notification_tapped',
      parameters: {
        'alert_id': alertId,
      },
    );
  }

  // Settings events
  Future<void> logSettingsChanged({
    required String setting,
    required String value,
  }) async {
    await _analytics.logEvent(
      name: 'settings_changed',
      parameters: {
        'setting': setting,
        'value': value,
      },
    );
  }

  Future<void> logRangeChanged({
    required double oldRange,
    required double newRange,
  }) async {
    await _analytics.logEvent(
      name: 'alert_range_changed',
      parameters: {
        'old_range_km': oldRange,
        'new_range_km': newRange,
      },
    );
  }

  // Chat events
  Future<void> logChatJoined({
    required String alertId,
  }) async {
    await _analytics.logEvent(
      name: 'chat_joined',
      parameters: {
        'alert_id': alertId,
      },
    );
  }

  Future<void> logMessageSent({
    required String alertId,
    String? messageType, // 'text', 'media'
  }) async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {
        'alert_id': alertId,
        'message_type': messageType ?? 'text',
      },
    );
  }

  // Error events
  Future<void> logError({
    required String error,
    String? context,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error': error,
        'context': context ?? 'unknown',
      },
    );
  }

  // Performance events
  Future<void> logPerformance({
    required String action,
    required int durationMs,
  }) async {
    await _analytics.logEvent(
      name: 'performance_metric',
      parameters: {
        'action': action,
        'duration_ms': durationMs,
      },
    );
  }

  // User properties
  Future<void> setUserProperties({
    String? deviceType,
    String? appVersion,
    bool? notificationsEnabled,
    double? alertRange,
  }) async {
    if (deviceType != null) {
      await _analytics.setUserProperty(name: 'device_type', value: deviceType);
    }
    if (appVersion != null) {
      await _analytics.setUserProperty(name: 'app_version', value: appVersion);
    }
    if (notificationsEnabled != null) {
      await _analytics.setUserProperty(
        name: 'notifications_enabled', 
        value: notificationsEnabled.toString(),
      );
    }
    if (alertRange != null) {
      await _analytics.setUserProperty(
        name: 'alert_range_km', 
        value: alertRange.toString(),
      );
    }
  }

  // Set user ID (anonymous or authenticated)
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Enable/disable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }
}