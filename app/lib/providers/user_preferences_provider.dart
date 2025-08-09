import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_preferences.dart';
import '../config/environment.dart';

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
      final prefsJson = _prefs.getString(_prefsKey);
      if (prefsJson != null) {
        final prefsMap = jsonDecode(prefsJson) as Map<String, dynamic>;
        state = UserPreferences.fromJson(prefsMap);
      } else {
        // Set default preferences
        state = UserPreferences(
          language: AppEnvironment.defaultLocale,
          alertRangeKm: 10.0,
        );
      }
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        print('Error loading user preferences: $e');
      }
      // Fallback to default preferences
      state = UserPreferences(
        language: AppEnvironment.defaultLocale,
        alertRangeKm: 10.0,
      );
    }
  }

  Future<bool> updatePreferences(UserPreferences preferences) async {
    try {
      final updatedPrefs = preferences.copyWith(lastUpdated: DateTime.now());
      final prefsJson = jsonEncode(updatedPrefs.toJson());
      await _prefs.setString(_prefsKey, prefsJson);
      state = updatedPrefs;
      return true;
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        print('Error saving user preferences: $e');
      }
      return false;
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

  Future<bool> updateAlertRange(double rangeKm) async {
    if (state != null) {
      return updatePreferences(state!.copyWith(alertRangeKm: rangeKm));
    }
    return false;
  }

  Future<bool> togglePushNotifications() async {
    if (state != null) {
      return updatePreferences(state!.copyWith(
        enablePushNotifications: !state!.enablePushNotifications,
      ));
    }
    return false;
  }

  Future<bool> toggleLocationAlerts() async {
    if (state != null) {
      return updatePreferences(state!.copyWith(
        enableLocationAlerts: !state!.enableLocationAlerts,
      ));
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

  Future<bool> updateUnits(String units) async {
    if (state != null) {
      return updatePreferences(state!.copyWith(units: units));
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
        print('Error clearing user preferences: $e');
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
  return prefs?.alertRangeKm ?? 10.0;
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