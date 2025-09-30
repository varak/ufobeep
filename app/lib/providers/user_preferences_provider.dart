import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_preferences.dart';
import '../config/environment.dart';
import '../config/locale_config.dart';
import '../services/api_client.dart';
import '../services/beep_service.dart';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// User preferences notifier
class UserPreferencesNotifier extends StateNotifier<UserPreferences?> {
  UserPreferencesNotifier(this._prefs) : super(null) {
    _loadPreferences();
  }

  final SharedPreferences _prefs;
  static const String _prefsKey = 'user_preferences';

  Future<void> _loadPreferences() async {
    try {
      // Always detect device language for app store compliance
      final deviceLang = ui.PlatformDispatcher.instance.locale.languageCode;
      final deviceLanguageSupported = LocaleConfig.supportedLocales
          .any((l) => l.languageCode == deviceLang);

      final prefsJson = _prefs.getString(_prefsKey);
      if (prefsJson != null) {
        final prefsMap = jsonDecode(prefsJson) as Map<String, dynamic>;
        final savedPrefs = UserPreferences.fromJson(prefsMap);

        // Only auto-update to device language if user hasn't explicitly chosen a different language
        // Check if saved language was explicitly set vs auto-detected on first run
        final isAutoDetectedLanguage = savedPrefs.language == AppEnvironment.defaultLocale;
        final shouldUseDeviceLanguage = deviceLanguageSupported &&
                                       savedPrefs.language != deviceLang &&
                                       isAutoDetectedLanguage; // Only override if using default, not explicit choice

        state = shouldUseDeviceLanguage
            ? savedPrefs.copyWith(language: deviceLang)
            : savedPrefs;

        // Update stored preferences if we changed to device language
        if (shouldUseDeviceLanguage) {
          try {
            final jsonStr = jsonEncode(state!.toJson());
            await _prefs.setString(_prefsKey, jsonStr);
          } catch (_) {}
        }
      } else {
        // First run: detect device locale and use it if supported
        final initial = UserPreferences(
          language: deviceLanguageSupported ? deviceLang : AppEnvironment.defaultLocale,
          alertRangeKm: 100.0,
        );
        state = initial;
        // Persist immediately so subsequent launches keep the choice
        try {
          final jsonStr = jsonEncode(initial.toJson());
          await _prefs.setString(_prefsKey, jsonStr);
        } catch (_) {}
      }
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        debugPrint('Error loading user preferences: $e');
      }
      // Fallback to default preferences
      state = UserPreferences(
        language: AppEnvironment.defaultLocale,
        alertRangeKm: 100.0,
      );
    }
  }

  Future<bool> updatePreferences(UserPreferences preferences) async {
    try {
      final updatedPrefs = preferences.copyWith(lastUpdated: DateTime.now());
      final prefsJson = jsonEncode(updatedPrefs.toJson());
      await _prefs.setString(_prefsKey, prefsJson);
      state = updatedPrefs;

      // Sync critical preferences (DND/snooze/language) to backend
      try {
        await _syncToBackend(updatedPrefs);
        debugPrint('✅ Preferences synced to backend successfully');
      } catch (syncError) {
        debugPrint('⚠️ WARNING: Preferences saved locally but backend sync failed: $syncError');
        debugPrint('⚠️ Push notifications may use old language/DND settings until sync succeeds');
        // Continue - local preferences still work
      }

      return true;
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        debugPrint('Error saving user preferences: $e');
      }
      return false;
    }
  }

  /// Sync critical user preferences (DND, snooze_until) to backend
  Future<void> _syncToBackend(UserPreferences prefs) async {
    try {
      debugPrint('🔄 Starting DND sync to backend...');
      
      final beepService = BeepService();
      final deviceId = await beepService.getOrCreateDeviceId();
      
      debugPrint('📱 Device ID for sync: $deviceId');
      
      // Prepare API request with preferences
      final Map<String, dynamic> updateData = {
        'snooze_until': prefs.dndUntil?.toUtc().toIso8601String(), // null to disable DND
        'preferences': {
          // Sync Flutter format DND/quiet hours to backend
          'quietHoursEnabled': prefs.quietHoursEnabled,
          'quietHoursStart': prefs.quietHoursStart,
          'quietHoursEnd': prefs.quietHoursEnd,
          'allowEmergencyOverride': prefs.allowEmergencyOverride,
          'dndUntil': prefs.dndUntil?.toUtc().toIso8601String(),
          // Include other user preferences
          'alertRangeKm': prefs.alertRangeKm,
          'language': prefs.language,
          'units': prefs.units,
        }
      };
      
      debugPrint('📡 Sending PUT /devices/$deviceId with data: $updateData');
      
      // Send to backend device update API
      final response = await ApiClient.dio.put('/devices/$deviceId', data: updateData);
      
      debugPrint('✅ DND sync successful: ${response.statusCode} ${response.data}');
    } catch (e) {
      debugPrint('❌ Failed to sync DND to backend: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      // Don't throw - local preferences should still work
    }
  }

  Future<bool> updateDisplayName(String displayName) async {
    if (state != null) {
      return updatePreferences(state!.copyWith(displayName: displayName));
    }
    return false;
  }

  Future<bool> updateEmail(String email) async {
    if (state != null) {
      return updatePreferences(state!.copyWith(email: email));
    }
    return false;
  }

  Future<bool> updateLanguage(String language) async {
    if (state != null) {
      return updatePreferences(state!.copyWith(language: language));
    }
    return false;
  }

  // Immediate, non-blocking language update to avoid UI hangs during locale switch
  bool setLanguageImmediate(String language) {
    try {
      final current = state ?? UserPreferences(
        language: AppEnvironment.defaultLocale,
        alertRangeKm: 100.0,
      );
      final updated = current.copyWith(language: language, lastUpdated: DateTime.now());
      state = updated; // Optimistic local state update
      // Persist asynchronously (best-effort)
      final prefsJson = jsonEncode(updated.toJson());
      _prefs.setString(_prefsKey, prefsJson);
      return true;
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        debugPrint('Error in setLanguageImmediate: $e');
      }
      return false;
    }
  }

  Future<bool> updateAlertRange(double rangeKm) async {
    if (state != null) {
      return updatePreferences(state!.copyWith(alertRangeKm: rangeKm));
    }
    return false;
  }

  Future<bool> updateUnits(String units) async {
    if (state != null) {
      return updatePreferences(state!.copyWith(units: units));
    }
    return false;
  }

  Future<bool> updateLocationPrivacy(LocationPrivacy privacy) async {
    if (state != null) {
      return updatePreferences(state!.copyWith(locationPrivacy: privacy));
    }
    return false;
  }


  Future<bool> toggleArCompass() async {
    if (state != null) {
      return updatePreferences(state!.copyWith(
        enableArCompass: !state!.enableArCompass,
      ));
    }
    return false;
  }

  Future<bool> togglePilotMode() async {
    if (state != null) {
      return updatePreferences(state!.copyWith(
        enablePilotMode: !state!.enablePilotMode,
      ));
    }
    return false;
  }

  Future<bool> updateAlertCategories(List<String> categories) async {
    if (state != null) {
      return updatePreferences(state!.copyWith(alertCategories: categories));
    }
    return false;
  }

  Future<bool> clearPreferences() async {
    try {
      await _prefs.remove(_prefsKey);
      state = null;
      return true;
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        debugPrint('Error clearing user preferences: $e');
      }
      return false;
    }
  }
}

// User preferences provider
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserPreferencesNotifier(prefs);
});

// Convenience providers
final userLanguageProvider = Provider<String>((ref) {
  final prefs = ref.watch(userPreferencesProvider);
  return prefs?.language ?? AppEnvironment.defaultLocale;
});

final alertRangeProvider = Provider<double>((ref) {
  final prefs = ref.watch(userPreferencesProvider);
  return prefs?.alertRangeKm ?? 100.0;
});

final unitsProvider = Provider<String>((ref) {
  final prefs = ref.watch(userPreferencesProvider);
  return prefs?.units ?? 'metric';
});

final isRegisteredProvider = Provider<bool>((ref) {
  final prefs = ref.watch(userPreferencesProvider);
  return prefs?.isComplete == true;
});

// Registration state
class RegistrationNotifier extends StateNotifier<RegistrationData> {
  RegistrationNotifier() : super(const RegistrationData(displayName: ''));

  void updateDisplayName(String displayName) {
    state = RegistrationData(
      displayName: displayName,
      email: state.email,
      language: state.language,
      alertRangeKm: state.alertRangeKm,
      agreeToTerms: state.agreeToTerms,
      agreeToPrivacyPolicy: state.agreeToPrivacyPolicy,
      enableNotifications: state.enableNotifications,
      deviceToken: state.deviceToken,
    );
  }

  void updateEmail(String email) {
    state = RegistrationData(
      displayName: state.displayName,
      email: email.isEmpty ? null : email,
      language: state.language,
      alertRangeKm: state.alertRangeKm,
      agreeToTerms: state.agreeToTerms,
      agreeToPrivacyPolicy: state.agreeToPrivacyPolicy,
      enableNotifications: state.enableNotifications,
      deviceToken: state.deviceToken,
    );
  }

  void updateLanguage(String language) {
    state = RegistrationData(
      displayName: state.displayName,
      email: state.email,
      language: language,
      alertRangeKm: state.alertRangeKm,
      agreeToTerms: state.agreeToTerms,
      agreeToPrivacyPolicy: state.agreeToPrivacyPolicy,
      enableNotifications: state.enableNotifications,
      deviceToken: state.deviceToken,
    );
  }

  void updateAlertRange(double rangeKm) {
    state = RegistrationData(
      displayName: state.displayName,
      email: state.email,
      language: state.language,
      alertRangeKm: rangeKm,
      agreeToTerms: state.agreeToTerms,
      agreeToPrivacyPolicy: state.agreeToPrivacyPolicy,
      enableNotifications: state.enableNotifications,
      deviceToken: state.deviceToken,
    );
  }

  void toggleTermsAgreement() {
    state = RegistrationData(
      displayName: state.displayName,
      email: state.email,
      language: state.language,
      alertRangeKm: state.alertRangeKm,
      agreeToTerms: !state.agreeToTerms,
      agreeToPrivacyPolicy: state.agreeToPrivacyPolicy,
      enableNotifications: state.enableNotifications,
      deviceToken: state.deviceToken,
    );
  }

  void togglePrivacyAgreement() {
    state = RegistrationData(
      displayName: state.displayName,
      email: state.email,
      language: state.language,
      alertRangeKm: state.alertRangeKm,
      agreeToTerms: state.agreeToTerms,
      agreeToPrivacyPolicy: !state.agreeToPrivacyPolicy,
      enableNotifications: state.enableNotifications,
      deviceToken: state.deviceToken,
    );
  }

  void toggleNotifications() {
    state = RegistrationData(
      displayName: state.displayName,
      email: state.email,
      language: state.language,
      alertRangeKm: state.alertRangeKm,
      agreeToTerms: state.agreeToTerms,
      agreeToPrivacyPolicy: state.agreeToPrivacyPolicy,
      enableNotifications: !state.enableNotifications,
      deviceToken: state.deviceToken,
    );
  }

  void reset() {
    state = const RegistrationData(displayName: '');
  }
}

final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationData>((ref) {
  return RegistrationNotifier();
});

// Current locale provider
final currentLocaleProvider = Provider<Locale>((ref) {
  final language = ref.watch(userLanguageProvider);
  return LocaleConfig.supportedLocales.firstWhere(
    (locale) => locale.languageCode == language,
    orElse: () => LocaleConfig.defaultLocale,
  );
});
