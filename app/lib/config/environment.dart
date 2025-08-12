import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, staging, production }

class AppEnvironment {
  static Environment _current = Environment.production;
  
  static Environment get current => _current;
  
  static Future<void> initialize({Environment? env}) async {
    _current = env ?? _getEnvironmentFromPlatform();
    
    // Load environment variables from .env file
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not load .env file: $e');
      }
    }
  }
  
  static Environment _getEnvironmentFromPlatform() {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'production');
    switch (environment.toLowerCase()) {
      case 'staging':
        return Environment.staging;
      case 'development':
        return Environment.development;
      default:
        return Environment.production;
    }
  }
  
  // API Configuration
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url != null) return url;
    
    switch (_current) {
      case Environment.development:
        return Platform.isAndroid 
            ? 'http://10.0.2.2:8000'  // Android emulator localhost
            : 'http://localhost:8000'; // iOS simulator/physical device
      case Environment.staging:
        return 'https://api-staging.ufobeep.com';
      case Environment.production:
        return 'https://api.ufobeep.com';
    }
  }
  
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  
  static String get apiFullUrl => '$apiBaseUrl/$apiVersion';
  
  // Matrix Configuration
  static String get matrixBaseUrl {
    final url = dotenv.env['MATRIX_BASE_URL'];
    if (url != null) return url;
    
    switch (_current) {
      case Environment.development:
        return Platform.isAndroid 
            ? 'http://10.0.2.2:8008'  // Android emulator localhost
            : 'http://localhost:8008'; // iOS simulator/physical device
      case Environment.staging:
        return 'https://matrix-staging.ufobeep.com';
      case Environment.production:
        return 'https://matrix.ufobeep.com';
    }
  }
  
  static String get matrixServerName {
    final serverName = dotenv.env['MATRIX_SERVER_NAME'];
    if (serverName != null) return serverName;
    
    switch (_current) {
      case Environment.development:
        return 'localhost';
      case Environment.staging:
        return 'staging.ufobeep.com';
      case Environment.production:
        return 'ufobeep.com';
    }
  }
  
  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'UFOBeep';
  
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '0.1.0';
  
  // Debug Settings
  static bool get isDebug => _current == Environment.development && kDebugMode;
  
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true' || isDebug;
  
  static bool get mockLocation => dotenv.env['MOCK_LOCATION']?.toLowerCase() == 'true';
  
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true' || isDebug;
  
  // Feature Flags
  static bool get enableArCompass => dotenv.env['ENABLE_AR_COMPASS']?.toLowerCase() != 'false';
  
  static bool get enablePilotMode => dotenv.env['ENABLE_PILOT_MODE']?.toLowerCase() != 'false';
  
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true' && !isDebug;
  
  // Locale Configuration
  static String get defaultLocale => dotenv.env['DEFAULT_LOCALE'] ?? 'en';
  
  static List<String> get supportedLocales => 
      dotenv.env['SUPPORTED_LOCALES']?.split(',') ?? ['en', 'es', 'de'];
  
  // Network Configuration
  static int get connectTimeoutMs => int.tryParse(dotenv.env['CONNECT_TIMEOUT_MS'] ?? '') ?? 30000;
  
  static int get receiveTimeoutMs => int.tryParse(dotenv.env['RECEIVE_TIMEOUT_MS'] ?? '') ?? 30000;
  
  static int get sendTimeoutMs => int.tryParse(dotenv.env['SEND_TIMEOUT_MS'] ?? '') ?? 30000;
  
  // Location Configuration
  static double get locationAccuracyThreshold => 
      double.tryParse(dotenv.env['LOCATION_ACCURACY_THRESHOLD'] ?? '') ?? 100.0;
  
  static int get locationTimeoutMs => 
      int.tryParse(dotenv.env['LOCATION_TIMEOUT_MS'] ?? '') ?? 15000;
  
  // Logging
  static void logConfig() {
    if (enableLogging) {
      print('=== UFOBeep Environment Configuration ===');
      print('Environment: $_current');
      print('API Base URL: $apiBaseUrl');
      print('Matrix Base URL: $matrixBaseUrl');
      print('App Version: $appVersion');
      print('Debug Mode: $debugMode');
      print('Supported Locales: ${supportedLocales.join(", ")}');
      print('Default Locale: $defaultLocale');
      print('AR Compass: $enableArCompass');
      print('Pilot Mode: $enablePilotMode');
      print('==========================================');
    }
  }
}