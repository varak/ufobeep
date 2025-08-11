import 'package:json_annotation/json_annotation.dart';

part 'user_preferences.g.dart';

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
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Validation methods
  bool get isComplete => displayName?.isNotEmpty == true;
  
  bool get hasValidEmail => email?.contains('@') == true && email?.contains('.') == true;
  
  bool get isValidRange => alertRangeKm >= 1.0 && alertRangeKm <= 100.0;

  // Helper methods
  String get alertRangeDisplay {
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