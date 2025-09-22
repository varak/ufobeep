import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user_preferences.g.dart';

const Object _undefinedValue = Object();

enum LocationPrivacy {
  exact,     // Use exact coordinates
  jittered,  // Apply 100-300m jitter (default)
  approximate, // Round to ~1km precision
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
    }
  }
}

@JsonSerializable()
class UserPreferences {
  final String? displayName;
  final String? email;
  final String language;
  final double alertRangeKm;
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
  final bool use24HourTime; // Use 24-hour time format (true) or 12-hour with AM/PM (false)
  final DateTime? lastUpdated;

  const UserPreferences({
    this.displayName,
    this.email,
    this.language = 'en',
    this.alertRangeKm = 10.0,
    this.enableArCompass = true,
    this.enablePilotMode = false,
    this.alertCategories = const ['ufo', 'anomaly', 'aircraft'],
    this.units = 'metric',
    this.darkMode = true,
    this.useWeatherVisibility = true,
    this.enableVisibilityFilters = false,
    this.locationPrivacy = LocationPrivacy.jittered,
    this.mediaOnlyAlerts,
    this.ignoreAnonymousBeeps,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22, // Will be overridden by language-aware defaults
    this.quietHoursEnd = 7,    // Will be overridden by language-aware defaults
    this.allowEmergencyOverride = true,
    this.dndUntil,
    this.use24HourTime = true,
    this.lastUpdated,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  /// Create UserPreferences with language-aware defaults
  factory UserPreferences.withLanguageDefaults({
    String? displayName,
    String? email,
    String language = 'en',
    double alertRangeKm = 10.0,
    bool enableArCompass = true,
    bool enablePilotMode = false,
    List<String> alertCategories = const ['ufo', 'anomaly', 'aircraft'],
    String? units,
    bool darkMode = true,
    bool useWeatherVisibility = true,
    bool enableVisibilityFilters = false,
    LocationPrivacy locationPrivacy = LocationPrivacy.jittered,
    bool? mediaOnlyAlerts,
    bool? ignoreAnonymousBeeps,
    bool quietHoursEnabled = false,
    int quietHoursStart = 22,
    int quietHoursEnd = 7,
    bool allowEmergencyOverride = true,
    DateTime? dndUntil,
    bool? use24HourTime,
    DateTime? lastUpdated,
  }) {
    final (defaultQuietStart, defaultQuietEnd) = _getDefaultQuietHoursForLanguage(language);

    return UserPreferences(
      displayName: displayName,
      email: email,
      language: language,
      alertRangeKm: alertRangeKm,
      enableArCompass: enableArCompass,
      enablePilotMode: enablePilotMode,
      alertCategories: alertCategories,
      units: units ?? _getDefaultUnitsForLanguage(language),
      darkMode: darkMode,
      useWeatherVisibility: useWeatherVisibility,
      enableVisibilityFilters: enableVisibilityFilters,
      locationPrivacy: locationPrivacy,
      mediaOnlyAlerts: mediaOnlyAlerts,
      ignoreAnonymousBeeps: ignoreAnonymousBeeps,
      quietHoursEnabled: quietHoursEnabled, // Don't override existing user preferences
      quietHoursStart: quietHoursStart ?? defaultQuietStart,
      quietHoursEnd: quietHoursEnd ?? defaultQuietEnd,
      allowEmergencyOverride: allowEmergencyOverride,
      dndUntil: dndUntil,
      use24HourTime: use24HourTime ?? getDefault24HourForLanguage(language),
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    String? displayName,
    String? email,
    String? language,
    double? alertRangeKm,
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
    Object? dndUntil = _undefinedValue,
    bool? use24HourTime,
    Object? lastUpdated = _undefinedValue,
  }) {
    return UserPreferences(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      language: language ?? this.language,
      alertRangeKm: alertRangeKm ?? this.alertRangeKm,
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
      dndUntil: dndUntil == _undefinedValue ? this.dndUntil : dndUntil as DateTime?,
      use24HourTime: use24HourTime ?? this.use24HourTime,
      lastUpdated: lastUpdated == _undefinedValue ? this.lastUpdated : lastUpdated as DateTime?,
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

  /// Get effective unit system - uses user preference or auto-detects from language
  String get effectiveUnits {
    // If user has explicitly set units, use that
    if (units != 'metric') return units;

    // Otherwise, auto-detect from language
    // Import is at top of file
    return _getDefaultUnitsForLanguage(language);
  }

  /// Get effective time format - uses language-aware default
  bool get effectiveUse24HourTime {
    return use24HourTime;
  }

  /// Internal method to get default units for language (matches UnitConversion logic)
  static String _getDefaultUnitsForLanguage(String languageCode) {
    const Map<String, String> languageToUnits = {
      'en': 'imperial',  // English (primarily US/UK)
      'es': 'metric',    // Spanish
      'de': 'metric',    // German
      'fr': 'metric',    // French
      'it': 'metric',    // Italian
      'pt': 'metric',    // Portuguese
      'ru': 'metric',    // Russian
      'zh': 'metric',    // Chinese
      'ja': 'metric',    // Japanese
      'ko': 'metric',    // Korean
      'ar': 'metric',    // Arabic
      'hi': 'metric',    // Hindi
      'tr': 'metric',    // Turkish
      'nl': 'metric',    // Dutch
      'sv': 'metric',    // Swedish
      'da': 'metric',    // Danish
      'no': 'metric',    // Norwegian
      'fi': 'metric',    // Finnish
      'pl': 'metric',    // Polish
      'cs': 'metric',    // Czech
      'el': 'metric',    // Greek
      'he': 'metric',    // Hebrew
    };
    return languageToUnits[languageCode.toLowerCase()] ?? 'metric';
  }

  /// Internal method to get default quiet hours for language/culture
  static (int, int) _getDefaultQuietHoursForLanguage(String languageCode) {
    // Returns (start_hour, end_hour) based on cultural sleep patterns
    const Map<String, (int, int)> languageToQuietHours = {
      'en': (22, 7),   // English - 10 PM to 7 AM (North American pattern)
      'es': (23, 8),   // Spanish - 11 PM to 8 AM (European/Latin pattern)
      'fr': (23, 8),   // French - 11 PM to 8 AM (European pattern)
      'de': (22, 7),   // German - 10 PM to 7 AM (Central European pattern)
      'it': (23, 8),   // Italian - 11 PM to 8 AM (Mediterranean pattern)
      'ru': (23, 8),   // Russian - 11 PM to 8 AM (Eastern European pattern)
      'zh': (22, 7),   // Chinese - 10 PM to 7 AM (East Asian pattern)
      'ja': (23, 7),   // Japanese - 11 PM to 7 AM (Japanese pattern)
      'ko': (23, 7),   // Korean - 11 PM to 7 AM (Korean pattern)
      'ar': (24, 8),   // Arabic - 12 AM to 8 AM (Middle Eastern pattern)
      'pt': (23, 8),   // Portuguese - 11 PM to 8 AM (Brazilian/Portuguese pattern)
    };

    return languageToQuietHours[languageCode] ?? (22, 7); // Default to 10 PM - 7 AM
  }

  /// Get default 24-hour time format for language
  static bool getDefault24HourForLanguage(String languageCode) {
    const Map<String, bool> languageTo24Hour = {
      'en': false,  // English - 12-hour with AM/PM (US style)
      'es': true,   // Spanish - 24-hour
      'de': true,   // German - 24-hour
      'fr': true,   // French - 24-hour
      'it': true,   // Italian - 24-hour
      'pt': true,   // Portuguese - 24-hour
      'ru': true,   // Russian - 24-hour
      'zh': true,   // Chinese - 24-hour
      'ja': true,   // Japanese - 24-hour
      'ko': true,   // Korean - 24-hour
      'ar': true,   // Arabic - 24-hour
      'hi': true,   // Hindi - 24-hour
      'tr': true,   // Turkish - 24-hour
      'nl': true,   // Dutch - 24-hour
      'sv': true,   // Swedish - 24-hour
      'da': true,   // Danish - 24-hour
      'no': true,   // Norwegian - 24-hour
      'fi': true,   // Finnish - 24-hour
      'pl': true,   // Polish - 24-hour
      'cs': true,   // Czech - 24-hour
      'el': true,   // Greek - 24-hour
      'he': true,   // Hebrew - 24-hour
    };
    return languageTo24Hour[languageCode.toLowerCase()] ?? true; // Default to 24-hour
  }

  static const List<String> availableLanguages = [
    'en', 'es', 'de', 'fr', 'it', 'pt', 'ru', 'zh', 'ja', 'ko',
    'ar', 'hi', 'tr', 'nl', 'sv', 'da', 'no', 'fi', 'pl', 'cs', 'el', 'he'
  ];
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
    return UserPreferences.withLanguageDefaults(
      displayName: displayName,
      email: email,
      language: language,
      alertRangeKm: alertRangeKm,
      lastUpdated: DateTime.now(),
    );
  }
}