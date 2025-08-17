import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user_preferences.g.dart';

enum LocationPrivacy {
  exact,     // Use exact coordinates
  jittered,  // Apply 100-300m jitter (default)
  approximate, // Round to ~1km precision
  hidden,    // Don't include location
}

extension LocationPrivacyExtension on LocationPrivacy {
  String get displayName {
    switch (this) {
      case LocationPrivacy.exact:
        return 'Exact Location';
      case LocationPrivacy.jittered:
        return 'Approximate (±200m)';
      case LocationPrivacy.approximate:
        return 'General Area (~1km)';
      case LocationPrivacy.hidden:
        return 'No Location';
    }
  }

  String get description {
    switch (this) {
      case LocationPrivacy.exact:
        return 'Share your exact GPS coordinates';
      case LocationPrivacy.jittered:
        return 'Add small random offset for privacy (recommended)';
      case LocationPrivacy.approximate:
        return 'Round location to nearest kilometer';
      case LocationPrivacy.hidden:
        return 'Don\'t share location information';
    }
  }

  IconData get icon {
    switch (this) {
      case LocationPrivacy.exact:
        return Icons.gps_fixed;
      case LocationPrivacy.jittered:
        return Icons.location_on;
      case LocationPrivacy.approximate:
        return Icons.location_city;
      case LocationPrivacy.hidden:
        return Icons.location_off;
    }
  }
}

@JsonSerializable()
class UserPreferences {
  final String? displayName;
  final String? email;
  final String language;
  final double alertRangeKm;
  final bool enablePushNotifications;
  final bool enableLocationAlerts;
  final bool enableArCompass;
  final bool enablePilotMode;
  final List<String> alertCategories;
  final String units; // 'metric' or 'imperial'
  final bool darkMode;
  final bool useWeatherVisibility; // Use weather data for visibility calculations
  final bool enableVisibilityFilters; // Filter alerts based on visibility
  final LocationPrivacy locationPrivacy; // Default location sharing privacy
  final bool? mediaOnlyAlerts; // Only receive alerts with photos/videos
  final bool? ignoreAnonymousBeeps; // Only receive alerts from registered users
  final bool quietHoursEnabled; // Enable quiet hours mode
  final int quietHoursStart; // Start hour (24-hour format)
  final int quietHoursEnd; // End hour (24-hour format)
  final bool allowEmergencyOverride; // Allow emergency alerts during quiet hours
  final DateTime? dndUntil; // Do Not Disturb until this time (null = DND off)
  final DateTime? lastUpdated;

  const UserPreferences({
    this.displayName,
    this.email,
    this.language = 'en',
    this.alertRangeKm = 10.0,
    this.enablePushNotifications = true,
    this.enableLocationAlerts = true,
    this.enableArCompass = true,
    this.enablePilotMode = false,
    this.alertCategories = const ['ufo', 'anomaly', 'aircraft'],
    this.units = 'metric',
    this.darkMode = true,
    this.useWeatherVisibility = true,
    this.enableVisibilityFilters = true,
    this.locationPrivacy = LocationPrivacy.jittered,
    this.mediaOnlyAlerts,
    this.ignoreAnonymousBeeps,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
    this.allowEmergencyOverride = true,
    this.dndUntil,
    this.lastUpdated,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    String? displayName,
    String? email,
    String? language,
    double? alertRangeKm,
    bool? enablePushNotifications,
    bool? enableLocationAlerts,
    bool? enableArCompass,
    bool? enablePilotMode,
    List<String>? alertCategories,
    String? units,
    bool? darkMode,
    bool? useWeatherVisibility,
    bool? enableVisibilityFilters,
    LocationPrivacy? locationPrivacy,
    bool? mediaOnlyAlerts,
    bool? ignoreAnonymousBeeps,
    bool? quietHoursEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
    bool? allowEmergencyOverride,
    DateTime? dndUntil,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      language: language ?? this.language,
      alertRangeKm: alertRangeKm ?? this.alertRangeKm,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableLocationAlerts: enableLocationAlerts ?? this.enableLocationAlerts,
      enableArCompass: enableArCompass ?? this.enableArCompass,
      enablePilotMode: enablePilotMode ?? this.enablePilotMode,
      alertCategories: alertCategories ?? this.alertCategories,
      units: units ?? this.units,
      darkMode: darkMode ?? this.darkMode,
      useWeatherVisibility: useWeatherVisibility ?? this.useWeatherVisibility,
      enableVisibilityFilters: enableVisibilityFilters ?? this.enableVisibilityFilters,
      locationPrivacy: locationPrivacy ?? this.locationPrivacy,
      mediaOnlyAlerts: mediaOnlyAlerts ?? this.mediaOnlyAlerts,
      ignoreAnonymousBeeps: ignoreAnonymousBeeps ?? this.ignoreAnonymousBeeps,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      allowEmergencyOverride: allowEmergencyOverride ?? this.allowEmergencyOverride,
      dndUntil: dndUntil ?? this.dndUntil,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Validation methods
  bool get isComplete => displayName?.isNotEmpty == true;
  
  bool get hasValidEmail => email?.contains('@') == true && email?.contains('.') == true;
  
  bool get isValidRange => alertRangeKm >= 1.0 && alertRangeKm <= 100.0;

  // Helper methods
  String get alertRangeDisplay {
    if (alertRangeKm >= 999999.0) {
      return 'Show all';
    }
    if (units == 'imperial') {
      final miles = alertRangeKm * 0.621371;
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      return '${alertRangeKm.toStringAsFixed(1)} km';
    }
  }

  static const List<String> availableLanguages = ['en', 'es', 'de'];
  static const List<String> availableCategories = [
    'ufo', 'anomaly', 'aircraft', 'missing_person', 'unclassified'
  ];
  static const List<double> commonRanges = [1.0, 2.5, 5.0, 10.0, 25.0, 50.0, 100.0];
}

@JsonSerializable()
class RegistrationData {
  final String displayName;
  final String? email;
  final String language;
  final double alertRangeKm;
  final bool agreeToTerms;
  final bool agreeToPrivacyPolicy;
  final bool enableNotifications;
  final String? deviceToken;

  const RegistrationData({
    required this.displayName,
    this.email,
    this.language = 'en',
    this.alertRangeKm = 10.0,
    this.agreeToTerms = false,
    this.agreeToPrivacyPolicy = false,
    this.enableNotifications = true,
    this.deviceToken,
  });

  factory RegistrationData.fromJson(Map<String, dynamic> json) =>
      _$RegistrationDataFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationDataToJson(this);

  bool get isValid =>
      displayName.trim().isNotEmpty &&
      agreeToTerms &&
      agreeToPrivacyPolicy &&
      alertRangeKm >= 1.0 &&
      alertRangeKm <= 100.0;

  UserPreferences toUserPreferences() {
    return UserPreferences(
      displayName: displayName,
      email: email,
      language: language,
      alertRangeKm: alertRangeKm,
      enablePushNotifications: enableNotifications,
      lastUpdated: DateTime.now(),
    );
  }
}