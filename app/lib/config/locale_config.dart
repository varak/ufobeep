import 'dart:ui';
import 'package:flutter/material.dart';
import 'environment.dart';
import '../l10n/generated/app_localizations.dart';

class LocaleConfig {
  // Reflect supported locales from generated localizations
  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
  
  static const Map<String, String> localeNames = {
    'en': 'English',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
    'pt': 'Português',
    'ru': 'Русский',
    'ja': '日本語',
    'zh': '中文',
    'it': 'Italiano',
    'tr': 'Türkçe',
    'ar': 'العربية',
    'pl': 'Polski',
    'cs': 'Čeština',
    'ko': '한국어',
    'hi': 'हिन्दी',
    'sv': 'Svenska',
    'da': 'Dansk',
    'no': 'Norsk',
    'fi': 'Suomi',
    'el': 'Ελληνικά',
    'nl': 'Nederlands',
    'he': 'עברית',
  };
  
  static const Map<String, String> localeFlags = {
    'en': '🇺🇸',
    'es': '🇪🇸',
    'de': '🇩🇪',
    'fr': '🇫🇷',
    'pt': '🇵🇹',
    'ru': '🇷🇺',
    'ja': '🇯🇵',
    'zh': '🇨🇳',
    'it': '🇮🇹',
    'tr': '🇹🇷',
    'ar': '🇸🇦',
    'pl': '🇵🇱',
    'cs': '🇨🇿',
    'ko': '🇰🇷',
    'hi': '🇮🇳',
    'sv': '🇸🇪',
    'da': '🇩🇰',
    'no': '🇳🇴',
    'fi': '🇫🇮',
    'el': '🇬🇷',
    'nl': '🇳🇱',
    'he': '🇮🇱',
  };
  
  static Locale get defaultLocale {
    final defaultCode = AppEnvironment.defaultLocale;
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == defaultCode,
      orElse: () => const Locale('en', 'US'),
    );
  }
  
  static bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
  
  static Locale? localeResolutionCallback(
    List<Locale>? locales,
    Iterable<Locale> supportedLocales,
  ) {
    // If no device locales are provided, use default
    if (locales == null || locales.isEmpty) {
      return defaultLocale;
    }
    
    // Try to find exact match (language + country)
    for (final locale in locales) {
      for (final supportedLocale in supportedLocales) {
        if (locale.languageCode == supportedLocale.languageCode &&
            locale.countryCode == supportedLocale.countryCode) {
          return supportedLocale;
        }
      }
    }
    
    // Try to find language match only
    for (final locale in locales) {
      for (final supportedLocale in supportedLocales) {
        if (locale.languageCode == supportedLocale.languageCode) {
          return supportedLocale;
        }
      }
    }
    
    // Fallback to default
    return defaultLocale;
  }
  
  static String getLocaleName(String languageCode) {
    return localeNames[languageCode] ?? languageCode.toUpperCase();
  }
  
  static String getLocaleFlag(String languageCode) {
    return localeFlags[languageCode] ?? '🌐';
  }
  
  static String getLocaleDisplayName(Locale locale) {
    final name = getLocaleName(locale.languageCode);
    final flag = getLocaleFlag(locale.languageCode);
    return '$flag $name';
  }
}
