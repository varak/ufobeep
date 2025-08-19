// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      language: json['language'] as String? ?? 'en',
      alertRangeKm: (json['alertRangeKm'] as num?)?.toDouble() ?? 10.0,
      enablePushNotifications: json['enablePushNotifications'] as bool? ?? true,
      enableLocationAlerts: json['enableLocationAlerts'] as bool? ?? true,
      enableArCompass: json['enableArCompass'] as bool? ?? true,
      enablePilotMode: json['enablePilotMode'] as bool? ?? false,
      alertCategories:
          (json['alertCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['ufo', 'anomaly', 'aircraft'],
      units: json['units'] as String? ?? 'metric',
      darkMode: json['darkMode'] as bool? ?? true,
      useWeatherVisibility: json['useWeatherVisibility'] as bool? ?? true,
      enableVisibilityFilters: json['enableVisibilityFilters'] as bool? ?? true,
      locationPrivacy:
          $enumDecodeNullable(
            _$LocationPrivacyEnumMap,
            json['locationPrivacy'],
          ) ??
          LocationPrivacy.jittered,
      mediaOnlyAlerts: json['mediaOnlyAlerts'] as bool?,
      ignoreAnonymousBeeps: json['ignoreAnonymousBeeps'] as bool?,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: (json['quietHoursStart'] as num?)?.toInt() ?? 22,
      quietHoursEnd: (json['quietHoursEnd'] as num?)?.toInt() ?? 7,
      allowEmergencyOverride: json['allowEmergencyOverride'] as bool? ?? true,
      dndUntil: json['dndUntil'] == null
          ? null
          : DateTime.parse(json['dndUntil'] as String),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'email': instance.email,
      'language': instance.language,
      'alertRangeKm': instance.alertRangeKm,
      'enablePushNotifications': instance.enablePushNotifications,
      'enableLocationAlerts': instance.enableLocationAlerts,
      'enableArCompass': instance.enableArCompass,
      'enablePilotMode': instance.enablePilotMode,
      'alertCategories': instance.alertCategories,
      'units': instance.units,
      'darkMode': instance.darkMode,
      'useWeatherVisibility': instance.useWeatherVisibility,
      'enableVisibilityFilters': instance.enableVisibilityFilters,
      'locationPrivacy': _$LocationPrivacyEnumMap[instance.locationPrivacy]!,
      'mediaOnlyAlerts': instance.mediaOnlyAlerts,
      'ignoreAnonymousBeeps': instance.ignoreAnonymousBeeps,
      'quietHoursEnabled': instance.quietHoursEnabled,
      'quietHoursStart': instance.quietHoursStart,
      'quietHoursEnd': instance.quietHoursEnd,
      'allowEmergencyOverride': instance.allowEmergencyOverride,
      'dndUntil': instance.dndUntil?.toIso8601String(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

const _$LocationPrivacyEnumMap = {
  LocationPrivacy.exact: 'exact',
  LocationPrivacy.jittered: 'jittered',
  LocationPrivacy.approximate: 'approximate',
  LocationPrivacy.hidden: 'hidden',
};

RegistrationData _$RegistrationDataFromJson(Map<String, dynamic> json) =>
    RegistrationData(
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      language: json['language'] as String? ?? 'en',
      alertRangeKm: (json['alertRangeKm'] as num?)?.toDouble() ?? 10.0,
      agreeToTerms: json['agreeToTerms'] as bool? ?? false,
      agreeToPrivacyPolicy: json['agreeToPrivacyPolicy'] as bool? ?? false,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      deviceToken: json['deviceToken'] as String?,
    );

Map<String, dynamic> _$RegistrationDataToJson(RegistrationData instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'email': instance.email,
      'language': instance.language,
      'alertRangeKm': instance.alertRangeKm,
      'agreeToTerms': instance.agreeToTerms,
      'agreeToPrivacyPolicy': instance.agreeToPrivacyPolicy,
      'enableNotifications': instance.enableNotifications,
      'deviceToken': instance.deviceToken,
    };
