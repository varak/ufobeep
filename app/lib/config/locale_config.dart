import 'dart:ui';
import 'package:flutter/material.dart';
import 'environment.dart';

class LocaleConfig {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English (US)
    Locale('es', 'ES'), // Spanish (Spain)
    Locale('de', 'DE'), // German (Germany)
  ];
  
  static const Map<String, String> localeNames = {
    'en': 'English',
    'es': 'Español',
    'de': 'Deutsch',
  };
  
  static const Map<String, String> localeFlags = {
    'en': '🇺🇸',
    'es': '🇪🇸', 
    'de': '🇩🇪',
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