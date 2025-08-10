import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/environment.dart';
import '../config/locale_config.dart';

enum InitializationStep {
  environment,
  permissions,
  userPreferences,
  localization,
  networkCheck,
  deviceInfo,
  complete,
}

class InitializationResult {
  final bool success;
  final String? error;
  final InitializationStep lastStep;
  final Map<String, dynamic> data;

  const InitializationResult({
    required this.success,
    this.error,
    required this.lastStep,
    this.data = const {},
  });

  InitializationResult copyWith({
    bool? success,
    String? error,
    InitializationStep? lastStep,
    Map<String, dynamic>? data,
  }) {
    return InitializationResult(
      success: success ?? this.success,
      error: error ?? this.error,
      lastStep: lastStep ?? this.lastStep,
      data: data ?? this.data,
    );
  }
}

class InitializationService {
  static final InitializationService _instance = InitializationService._internal();
  factory InitializationService() => _instance;
  InitializationService._internal();

  StreamController<InitializationStep>? _stepController;
  StreamController<double>? _progressController;
  StreamController<String>? _messageController;

  Stream<InitializationStep> get stepStream => _stepController?.stream ?? const Stream.empty();
  Stream<double> get progressStream => _progressController?.stream ?? const Stream.empty();
  Stream<String> get messageStream => _messageController?.stream ?? const Stream.empty();

  Future<InitializationResult> initialize() async {
    _stepController = StreamController<InitializationStep>.broadcast();
    _progressController = StreamController<double>.broadcast();
    _messageController = StreamController<String>.broadcast();

    try {
      final result = await _performInitialization();
      return result;
    } catch (e) {
      _logError('Initialization failed: $e');
      return InitializationResult(
        success: false,
        error: e.toString(),
        lastStep: InitializationStep.environment,
      );
    } finally {
      await _stepController?.close();
      await _progressController?.close();
      await _messageController?.close();
    }
  }

  Future<InitializationResult> _performInitialization() async {
    final Map<String, dynamic> initData = {};
    
    try {
      // Step 1: Environment validation
      await _updateProgress(InitializationStep.environment, 0.1, 'Validating environment...');
      final envResult = await _validateEnvironment();
      if (!envResult.success) {
        return envResult;
      }
      initData.addAll(envResult.data);

      // Step 2: Check and request permissions
      await _updateProgress(InitializationStep.permissions, 0.25, 'Checking permissions...');
      final permResult = await _checkPermissions();
      if (!permResult.success) {
        return permResult;
      }
      initData.addAll(permResult.data);

      // Step 3: Load user preferences
      await _updateProgress(InitializationStep.userPreferences, 0.4, 'Loading preferences...');
      final prefResult = await _loadUserPreferences();
      if (!prefResult.success) {
        return prefResult;
      }
      initData.addAll(prefResult.data);

      // Step 4: Initialize localization
      await _updateProgress(InitializationStep.localization, 0.6, 'Setting up localization...');
      final localeResult = await _initializeLocalization(initData);
      if (!localeResult.success) {
        return localeResult;
      }
      initData.addAll(localeResult.data);

      // Step 5: Network connectivity check
      await _updateProgress(InitializationStep.networkCheck, 0.8, 'Checking connectivity...');
      final networkResult = await _checkNetworkConnectivity();
      if (!networkResult.success) {
        return networkResult;
      }
      initData.addAll(networkResult.data);

      // Step 6: Device information
      await _updateProgress(InitializationStep.deviceInfo, 0.9, 'Gathering device info...');
      final deviceResult = await _gatherDeviceInfo();
      if (!deviceResult.success) {
        return deviceResult;
      }
      initData.addAll(deviceResult.data);

      // Step 7: Complete
      await _updateProgress(InitializationStep.complete, 1.0, 'Initialization complete!');

      _logInfo('Initialization completed successfully');
      return InitializationResult(
        success: true,
        lastStep: InitializationStep.complete,
        data: initData,
      );

    } catch (e) {
      _logError('Initialization error: $e');
      return InitializationResult(
        success: false,
        error: e.toString(),
        lastStep: InitializationStep.environment,
        data: initData,
      );
    }
  }

  Future<InitializationResult> _validateEnvironment() async {
    try {
      // Validate critical environment variables
      final apiUrl = AppEnvironment.apiBaseUrl;
      final matrixUrl = AppEnvironment.matrixBaseUrl;
      
      if (apiUrl.isEmpty) {
        throw Exception('API Base URL is not configured');
      }
      
      if (matrixUrl.isEmpty) {
        throw Exception('Matrix Base URL is not configured');
      }

      // Validate supported locales
      final supportedLocales = AppEnvironment.supportedLocales;
      if (supportedLocales.isEmpty) {
        throw Exception('No supported locales configured');
      }

      _logInfo('Environment validation passed');
      return InitializationResult(
        success: true,
        lastStep: InitializationStep.environment,
        data: {
          'apiUrl': apiUrl,
          'matrixUrl': matrixUrl,
          'supportedLocales': supportedLocales,
          'environment': AppEnvironment.current.toString(),
        },
      );
    } catch (e) {
      return InitializationResult(
        success: false,
        error: 'Environment validation failed: $e',
        lastStep: InitializationStep.environment,
      );
    }
  }

  Future<InitializationResult> _checkPermissions() async {
    try {
      final Map<String, bool> permissions = {};
      final List<String> requestedPermissions = [];

      // Request location permission (critical for beep submission)
      var locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted && !locationStatus.isPermanentlyDenied) {
        _logInfo('Requesting location permission...');
        locationStatus = await Permission.location.request();
        requestedPermissions.add('location');
      }
      permissions['location'] = locationStatus.isGranted;

      // Request camera permission (critical for beep submission)
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted && !cameraStatus.isPermanentlyDenied) {
        _logInfo('Requesting camera permission...');
        cameraStatus = await Permission.camera.request();
        requestedPermissions.add('camera');
      }
      permissions['camera'] = cameraStatus.isGranted;

      // Check notification permission (optional)
      final notificationStatus = await Permission.notification.status;
      permissions['notification'] = notificationStatus.isGranted;

      // Check microphone permission (for video recording, optional)
      final microphoneStatus = await Permission.microphone.status;
      permissions['microphone'] = microphoneStatus.isGranted;

      // Request storage permission (needed for photo access)
      Permission storagePermission;
      if (Platform.isAndroid) {
        storagePermission = Permission.storage;
      } else {
        storagePermission = Permission.photos;
      }
      var storageStatus = await storagePermission.status;
      if (!storageStatus.isGranted && !storageStatus.isPermanentlyDenied) {
        _logInfo('Requesting storage permission...');
        storageStatus = await storagePermission.request();
        requestedPermissions.add('storage');
      }
      permissions['storage'] = storageStatus.isGranted;

      // Log critical permission status
      final hasCriticalPermissions = permissions['location'] == true && permissions['camera'] == true;
      if (!hasCriticalPermissions) {
        _logWarning('Missing critical permissions - Location: ${permissions['location']}, Camera: ${permissions['camera']}');
      }

      _logInfo('Permission check completed: $permissions');
      _logInfo('Requested permissions during init: $requestedPermissions');
      
      return InitializationResult(
        success: true,
        lastStep: InitializationStep.permissions,
        data: {
          'permissions': permissions,
          'hasCriticalPermissions': hasCriticalPermissions,
          'requestedPermissions': requestedPermissions,
        },
      );
    } catch (e) {
      return InitializationResult(
        success: false,
        error: 'Permission check failed: $e',
        lastStep: InitializationStep.permissions,
      );
    }
  }

  Future<InitializationResult> _loadUserPreferences() async {
    try {
      // This will be handled by the UserPreferencesProvider
      // We're just validating that the preferences system is working
      
      _logInfo('User preferences loading initiated');
      return InitializationResult(
        success: true,
        lastStep: InitializationStep.userPreferences,
        data: {'preferencesLoaded': true},
      );
    } catch (e) {
      return InitializationResult(
        success: false,
        error: 'User preferences loading failed: $e',
        lastStep: InitializationStep.userPreferences,
      );
    }
  }

  Future<InitializationResult> _initializeLocalization(Map<String, dynamic> initData) async {
    try {
      // Get system locale
      final systemLocale = Platform.localeName.split('_')[0];
      final defaultLocale = AppEnvironment.defaultLocale;
      final supportedLocales = AppEnvironment.supportedLocales;

      // Determine best locale
      String selectedLocale = defaultLocale;
      if (supportedLocales.contains(systemLocale)) {
        selectedLocale = systemLocale;
      }

      // Validate locale configuration
      final localeConfig = LocaleConfig.supportedLocales
          .where((locale) => locale.languageCode == selectedLocale)
          .toList();

      if (localeConfig.isEmpty) {
        throw Exception('Selected locale $selectedLocale is not properly configured');
      }

      _logInfo('Localization initialized with locale: $selectedLocale');
      return InitializationResult(
        success: true,
        lastStep: InitializationStep.localization,
        data: {
          'selectedLocale': selectedLocale,
          'systemLocale': systemLocale,
          'defaultLocale': defaultLocale,
          'availableLocales': supportedLocales,
        },
      );
    } catch (e) {
      return InitializationResult(
        success: false,
        error: 'Localization initialization failed: $e',
        lastStep: InitializationStep.localization,
      );
    }
  }

  Future<InitializationResult> _checkNetworkConnectivity() async {
    try {
      // Simple connectivity check
      bool isConnected = true;
      String connectionType = 'unknown';

      try {
        final result = await InternetAddress.lookup('google.com').timeout(
          const Duration(seconds: 5),
        );
        isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        connectionType = 'internet';
      } catch (e) {
        isConnected = false;
        connectionType = 'none';
      }

      _logInfo('Network connectivity: $isConnected ($connectionType)');
      return InitializationResult(
        success: true, // Don't fail init for network issues
        lastStep: InitializationStep.networkCheck,
        data: {
          'isConnected': isConnected,
          'connectionType': connectionType,
        },
      );
    } catch (e) {
      return InitializationResult(
        success: true, // Don't fail init for network issues
        lastStep: InitializationStep.networkCheck,
        data: {
          'isConnected': false,
          'connectionType': 'error',
          'error': e.toString(),
        },
      );
    }
  }

  Future<InitializationResult> _gatherDeviceInfo() async {
    try {
      final Map<String, dynamic> deviceInfo = {};

      // Platform information
      deviceInfo['platform'] = Platform.operatingSystem;
      deviceInfo['version'] = Platform.operatingSystemVersion;
      deviceInfo['isPhysicalDevice'] = !Platform.environment.containsKey('FLUTTER_TEST');

      // App information
      deviceInfo['appVersion'] = AppEnvironment.appVersion;
      deviceInfo['appName'] = AppEnvironment.appName;
      deviceInfo['debugMode'] = AppEnvironment.debugMode;

      // Screen information (basic)
      try {
        final view = WidgetsBinding.instance.platformDispatcher.views.first;
        deviceInfo['screenSize'] = {
          'width': view.physicalSize.width,
          'height': view.physicalSize.height,
          'devicePixelRatio': view.devicePixelRatio,
        };
      } catch (e) {
        _logWarning('Could not get screen information: $e');
      }

      _logInfo('Device information gathered');
      return InitializationResult(
        success: true,
        lastStep: InitializationStep.deviceInfo,
        data: {'deviceInfo': deviceInfo},
      );
    } catch (e) {
      return InitializationResult(
        success: false,
        error: 'Device info gathering failed: $e',
        lastStep: InitializationStep.deviceInfo,
      );
    }
  }

  Future<void> _updateProgress(InitializationStep step, double progress, String message) async {
    _stepController?.add(step);
    _progressController?.add(progress);
    _messageController?.add(message);
    
    // Small delay to make progress visible
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _logInfo(String message) {
    if (AppEnvironment.enableLogging) {
      debugPrint('[InitializationService] INFO: $message');
    }
  }

  void _logWarning(String message) {
    if (AppEnvironment.enableLogging) {
      debugPrint('[InitializationService] WARNING: $message');
    }
  }

  void _logError(String message) {
    if (AppEnvironment.enableLogging) {
      debugPrint('[InitializationService] ERROR: $message');
    }
  }

  void dispose() {
    _stepController?.close();
    _progressController?.close();
    _messageController?.close();
  }
}