import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'config/environment.dart';
import 'config/locale_config.dart';
import 'l10n/app_localizations.dart';
import 'models/user_preferences.dart';
import 'models/sensor_data.dart';
import 'providers/user_preferences_provider.dart';
import 'routing/app_router.dart';
import 'services/push_notification_service.dart';
import 'services/sound_service.dart';
import 'services/share_intent_service.dart';
import 'services/pending_share_queue.dart';
import 'services/notifications.dart';
import 'services/ui_feedback.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';
import 'services/auth_repository.dart';
import 'services/device_registration_manager.dart';
import 'services/location_update_manager.dart';
import 'services/location_tracking_service.dart';
import 'services/sensor_service.dart';
import 'services/deep_link_service.dart';
import 'features/auth/deep_link_handler.dart';

import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add error handling so crashes show instead of white screen
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('🚨 FlutterError: ${details.exceptionAsString()}\n${details.stack}');
  };
  ErrorWidget.builder = (details) => Material(
    color: Colors.red.shade50,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          'Error: ${details.exceptionAsString()}', 
          style: const TextStyle(color: Colors.red, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
  
  final stopwatch = Stopwatch()..start();
  
  // Get and display build info
  final packageInfo = await PackageInfo.fromPlatform();
  final buildNumber = packageInfo.buildNumber;
  final version = packageInfo.version;
  debugPrint('🚀 UFOBeep starting... v$version build #$buildNumber');
  
  // Initialize environment first (needed by other services)
  await AppEnvironment.initialize(packageInfo: packageInfo);
  
  // ChatGPT: Initialize ApiClient with interceptor
  ApiClient.init();
  
  // Ensure notification permissions are requested early
  await Notifications.ensureNotificationPermission();
  
  // Initialize notification channels
  await Notifications.initializeChannels();

  // Run critical initialization in parallel (Firebase MUST be first)
  final results = await Future.wait([
    Firebase.initializeApp(),
    SharedPreferences.getInstance(),
  ]);
  
  // ChatGPT: perform silent refresh before runApp for fast/clean routing
  final auth = AuthRepository();
  await auth.loadSessionOnStartup();

  // Initialize AuthService to restore authentication state
  await AuthService().initialize();
  debugPrint('✅ AuthService initialized - authentication state restored');

  // Initialize DeviceRegistrationManager asynchronously to prevent blocking startup
  Future.delayed(Duration.zero, () {
    DeviceRegistrationManager().start();
    debugPrint('✅ DeviceRegistrationManager started asynchronously');
  });
  
  // LocationUpdateManager disabled - replaced with efficient geofence-based LocationTrackingService
  // Battery-draining continuous GPS monitoring replaced with smart geofencing
  // Future.delayed(Duration.zero, () async {
  //   final locationManager = LocationUpdateManager(
  //     auth: auth,
  //     baseUrl: AppEnvironment.apiBaseUrl,
  //   );
  //   await locationManager.start();
  //   debugPrint('✅ LocationUpdateManager started in background');
  // });

  // Initialize efficient geofence-based LocationTrackingService (replaces LocationUpdateManager)
  Future.delayed(Duration.zero, () async {
    await locationTrackingService.initialize();
    debugPrint('✅ LocationTrackingService initialized for background movement detection');
  });
  
  final sharedPreferences = results[1] as SharedPreferences;
  debugPrint('✅ Core initialization: ${stopwatch.elapsedMilliseconds}ms');
  
  // Set up Firebase messaging background handler early
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Get initial message quickly
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  
  // Log configuration
  AppEnvironment.logConfig();
  
  debugPrint('✅ App ready: ${stopwatch.elapsedMilliseconds}ms');
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: UFOBeepApp(initialMessage: initialMessage),
    ),
  );
  
  // Defer non-critical initialization to after app starts
  _initializeNonCriticalServices();
}

Future<void> _initializeNonCriticalServices() async {
  debugPrint('🔧 Initializing background services...');
  final stopwatch = Stopwatch()..start();
  
  // Initialize services that don't block app startup  
  // (permissions moved to splash screen initialization)
  await Future.wait([
    SoundService.I.init(),
    UiFeedback.init(), // Initialize native UI feedback service for Moto fix
    pushNotificationService.initialize(),
  ]);
  
  // Initialize share intent service - placeholder, actual init will be done in the app widget
  // ShareIntentService init will be called later with proper callback
  
  debugPrint('✅ Background services ready: ${stopwatch.elapsedMilliseconds}ms');
}

class UFOBeepApp extends ConsumerStatefulWidget {
  const UFOBeepApp({super.key, this.initialMessage});
  
  final RemoteMessage? initialMessage;

  @override
  ConsumerState<UFOBeepApp> createState() => _UFOBeepAppState();
}

class _UFOBeepAppState extends ConsumerState<UFOBeepApp> {
  late final AuthService _auth;
  late final DeepLinkHandler _deepLinkHandler;
  late final AuthRepository _authRepo;
  VoidCallback? _authListener;
  
  // Queue for share intent data when user is not authenticated
  Map<String, dynamic>? _queuedShareData;
  
  @override
  void initState() {
    super.initState();
    
    _auth = AuthService(); // Use existing singleton
    
    // ChatGPT's pattern: Initialize DeepLinkHandler BEFORE UI renders
    _deepLinkHandler = DeepLinkHandler();
    
    // Start deep link listening immediately
    _deepLinkHandler.init();
    
    // Listen for authentication state changes to process queued share data
    _authRepo = AuthRepository();
    _authListener = () {
      if (_authRepo.isReady && _authRepo.currentUser != null && _queuedShareData != null) {
        debugPrint('Main: Authentication detected, processing queued share data');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _processQueuedShareData();
        });
      }
    };
    _authRepo.addListener(_authListener!);
    
    // Handle initial Firebase message after the widget tree is built
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInitialMessage(widget.initialMessage!);
      });
    }

    // Check for pending notification payloads from background handler
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingNotificationPayload();
    });
    
    // Set up share intent callback once in initState  
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupShareIntentCallback();
    });
  }
  
  @override
  void dispose() {
    _deepLinkHandler.dispose();
    if (_authListener != null) {
      _authRepo.removeListener(_authListener!);
    }
    super.dispose();
  }
  
  void _setupShareIntentCallback() {
    final router = ref.read(appRouterProvider);
    
    // Initialize ShareIntentService with callback
    ShareIntentService().init(onQueued: () async {
      debugPrint('Main: Share intent detected, processing queue...');
      await _processShareQueue(router);
    });
  }
  
  Future<void> _processShareQueue(router) async {
    if (!PendingShareQueue().hasItems) return;
    
    try {
      final items = PendingShareQueue().items;
      debugPrint('Main: Processing ${items.length} shared items');
      
      // Convert SharedMediaItems to Files
      final files = <File>[];
      for (final item in items) {
        final file = File(item.uri.path);
        if (await file.exists()) {
          files.add(file);
        } else {
          debugPrint('Main: Shared file does not exist: ${item.uri.path}');
        }
      }
      
      if (files.isEmpty) {
        debugPrint('Main: No valid shared files found');
        PendingShareQueue().clear();
        return;
      }
        
      // Collect location data for beep composition
      debugPrint('Main: Collecting location data for shared media...');
      SensorData? sensorData;
      try {
        final sensorService = SensorService();
        sensorData = await sensorService.captureSensorData();
        debugPrint('Main: Location data collected successfully');
      } catch (e) {
        debugPrint('Main: Failed to collect sensor data: $e');
        // Continue without sensor data
      }
        
      // Check if user is authenticated
      if (_authRepo.isReady && _authRepo.currentUser != null) {
        debugPrint('Main: User authenticated, navigating to beep composition');
        
        // Navigate to beep composition screen with the first shared file
        final firstFile = files.first;
        final isVideo = firstFile.path.toLowerCase().endsWith('.mp4') || 
                       firstFile.path.toLowerCase().endsWith('.mov') || 
                       firstFile.path.toLowerCase().endsWith('.avi');
        
        final shareData = {
          'mediaFiles': files.map((file) => {
            'mediaFile': file,
            'isVideo': file.path.toLowerCase().endsWith('.mp4') || 
                      file.path.toLowerCase().endsWith('.mov') || 
                      file.path.toLowerCase().endsWith('.avi'),
            'photoMetadata': <String, dynamic>{},
            'platformFile': null,
          }).toList(),
          'sensorData': sensorData,
          'description': '',
        };
        
        debugPrint('🎯 MAIN: Share intent (authenticated) - navigating with data: $shareData');
        router.go('/beepscreen', extra: shareData);
        
        PendingShareQueue().clear();
      } else {
        debugPrint('Main: User not authenticated, queueing share data');
        
        // Queue the share data for after authentication  
        final firstFile = files.first;
        final isVideo = firstFile.path.toLowerCase().endsWith('.mp4') || 
                       firstFile.path.toLowerCase().endsWith('.mov') || 
                       firstFile.path.toLowerCase().endsWith('.avi');
        
        _queuedShareData = {
          'mediaFiles': files.map((file) => {
            'mediaFile': file,
            'isVideo': file.path.toLowerCase().endsWith('.mp4') || 
                      file.path.toLowerCase().endsWith('.mov') || 
                      file.path.toLowerCase().endsWith('.avi'),
            'photoMetadata': <String, dynamic>{},
            'platformFile': null,
          }).toList(),
          'sensorData': sensorData,
          'description': '',
        };
        // Don't clear the queue yet - will clear when processed
      }
        
    } catch (e, stackTrace) {
      debugPrint('ERROR: Failed to process shared media: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Fallback: navigate to regular beep screen if share intent fails
      router.go('/beep');
      debugPrint('Main: Fell back to regular beep screen due to error');
      PendingShareQueue().clear();
    }
  }
  
  /// Detects file extension from file content using magic bytes
  String _detectFileExtension(List<int> bytes, bool isVideo) {
    if (isVideo) {
      // Enhanced video detection with more formats
      if (bytes.length >= 12) {
        // MP4: ftyp header variants
        if (bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70) {
          return '.mp4';
        }
        // MOV: QuickTime signature (moov)
        if (bytes[4] == 0x6D && bytes[5] == 0x6F && bytes[6] == 0x6F && bytes[7] == 0x76) {
          return '.mov';
        }
        // 3GP: 3gp file type
        if (bytes[4] == 0x33 && bytes[5] == 0x67 && bytes[6] == 0x70) {
          return '.3gp';
        }
      }
      
      // AVI: RIFF header with AVI signature
      if (bytes.length >= 12 && 
          bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
          bytes[8] == 0x41 && bytes[9] == 0x56 && bytes[10] == 0x49 && bytes[11] == 0x20) {
        return '.avi';
      }
      
      // WebM: EBML header
      if (bytes.length >= 4 && 
          bytes[0] == 0x1A && bytes[1] == 0x45 && bytes[2] == 0xDF && bytes[3] == 0xA3) {
        return '.webm';
      }
      
      return '.mp4'; // Default for video
    } else {
      // Image detection using magic bytes
      if (bytes.length >= 4) {
        // JPEG: FF D8 FF
        if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
          return '.jpg';
        }
        // PNG: 89 50 4E 47
        if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
          return '.png';
        }
        // GIF: 47 49 46 38
        if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) {
          return '.gif';
        }
        // WebP: RIFF...WEBP
        if (bytes.length >= 12 && 
            bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
            bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
          return '.webp';
        }
        // BMP: 42 4D
        if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
          return '.bmp';
        }
      }
      return '.jpg'; // Default for images
    }
  }
  
  void _handleInitialMessage(RemoteMessage message) {
    debugPrint('Processing initial message: ${message.messageId}');
    
    final notificationType = message.data['type'] ?? 'general';
    
    switch (notificationType) {
      case 'sighting_alert':
        final sightingId = message.data['sighting_id'];
        if (sightingId != null) {
          debugPrint('Navigating to sighting alert: $sightingId');
          pushNotificationService.navigateToAlert(sightingId);
        }
        break;
      case 'chat_message':
        final chatId = message.data['chat_id'];
        if (chatId != null) {
          debugPrint('Navigating to chat: $chatId');
          pushNotificationService.navigateToChat(chatId);
        }
        break;
    }
  }

  Future<void> _checkPendingNotificationPayload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = prefs.getString('pending_notification_payload');

      if (payload != null && payload.isNotEmpty) {
        debugPrint('🔔 Found pending notification payload: $payload');

        // Clear the stored payload
        await prefs.remove('pending_notification_payload');

        // Handle the deep link
        final uri = Uri.parse(payload);
        if (uri.scheme == 'ufobeep') {
          debugPrint('🔔 Processing notification deep link: $payload');
          await deepLinkService.testNavigation(payload);
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking pending notification payload: $e');
    }
  }

  void _processQueuedShareData() {
    if (_queuedShareData == null) return;
    
    debugPrint('🎯 MAIN: Processing queued share data after authentication');
    final router = ref.read(appRouterProvider);
    final shareData = _queuedShareData!;
    _queuedShareData = null; // Clear the queue
    
    debugPrint('🎯 MAIN: Share intent (queued) - navigating with data: $shareData');
    // Navigate to beep composer with the queued share data
    router.go('/beep/compose', extra: shareData);
    debugPrint('🎯 MAIN: Navigated to beep composer with queued share data');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final currentLocale = ref.watch(currentLocaleProvider);

    return MaterialApp.router(
      title: AppEnvironment.appName,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      
      // Internationalization
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locales, supportedLocales) =>
          LocaleConfig.localeResolutionCallback(locales != null ? [locales] : null, supportedLocales),
    );
  }
}

// Removed - now handled by PermissionService

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
  
  // Process the notification type and play appropriate sounds
  final notificationType = message.data['type'] ?? 'general';
  final witnessCountStr = message.data['witness_count'] ?? '1';
  final witnessCount = int.tryParse(witnessCountStr) ?? 1;
  
  debugPrint('Background notification type: $notificationType, witnesses: $witnessCount');
  
  // Check DND/Quiet Hours before doing any background sounds/handling
  bool muted = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString('user_preferences');
    if (prefsJson != null) {
      final map = jsonDecode(prefsJson) as Map<String, dynamic>;
      final user = UserPreferences.fromJson(map);
      final now = DateTime.now();
      if (user.dndUntil != null && user.dndUntil!.isAfter(now)) {
        muted = true;
      } else if (user.quietHoursEnabled) {
        final start = user.quietHoursStart;
        final end = user.quietHoursEnd;
        final hour = now.hour;
        final inWindow = start == end ? false : (start < end ? (hour >= start && hour < end) : (hour >= start || hour < end));
        if (inWindow && !user.allowEmergencyOverride) muted = true;
      }
    }
  } catch (_) {}
  if (muted && notificationType == 'sighting_alert') {
    debugPrint('🔕 Background: muted by DND/Quiet Hours');
    return;
  }

  // Initialize local notifications for background processing
  try {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('🔔 BACKGROUND: Notification tapped with payload: ${response.payload}');
        if (response.payload != null && response.payload!.isNotEmpty) {
          // Store the payload for when the app launches/resumes
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('pending_notification_payload', response.payload!);
          debugPrint('🔔 BACKGROUND: Stored payload for app launch: ${response.payload}');
        }
      },
    );

    // Create notification based on type
    if (notificationType == 'sighting_alert') {
      final sightingId = message.data['sighting_id'];
      final distance = message.data['distance'];
      final locationName = message.data['location_name'] ?? 'Unknown Location';

      // Format distance display
      final distanceText = distance != null ?
        (double.tryParse(distance)! < 1.0 ?
          ' • ${(double.tryParse(distance)! * 1000).toInt()}m away' :
          ' • ${double.tryParse(distance)!.toStringAsFixed(1)}km away') : '';

      // Create urgency indicators
      final urgencyIcon = witnessCount >= 10 ? '🚨' :
                         witnessCount >= 3 ? '⚠️' : '📢';
      final witnessText = witnessCount > 1 ? '$witnessCount witnesses' : 'New sighting';

      final title = '$urgencyIcon UFO Sighting';
      final body = '$witnessText near $locationName$distanceText';

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'ufobeep_alerts',
        'UFO Alerts',
        channelDescription: 'UFO sighting proximity alerts',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        visibility: NotificationVisibility.public,
        ticker: 'UFO Alert - New Sighting Nearby', // TODO: Use proper l10n after translation generation
        enableLights: true,
        ledOnMs: 1000,
        ledOffMs: 500,
        ledColor: Color.fromARGB(255, 255, 0, 0),
        showWhen: true,
        fullScreenIntent: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        sightingId.hashCode,
        title,
        body,
        notificationDetails,
        payload: 'ufobeep://beep/$sightingId', // Deep link payload for navigation
      );

      debugPrint('🔔 BACKGROUND: Showed sighting notification - $title: $body');

    } else if (notificationType == 'comment') {
      final title = message.notification?.title ?? '💬 New Comment';
      final body = message.notification?.body ?? 'Someone commented on an alert';
      final sightingId = message.data['sighting_id'];

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'ufobeep_comments',
        'Comment Notifications',
        channelDescription: 'Notifications when someone comments',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        ticker: 'New Comment on UFO Alert', // TODO: Use proper l10n after translation generation
        enableLights: true,
        showWhen: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        (sightingId?.hashCode ?? 0) + 1000, // Different ID from alert notifications
        title,
        body,
        notificationDetails,
        payload: sightingId != null ? 'ufobeep://beep/$sightingId?focusComment=true' : null, // Deep link to beep detail page with comment focus
      );

      debugPrint('🔔 BACKGROUND: Showed comment notification - $title: $body');
    }

    // Initialize sound service for background processing
    await SoundService.I.init();

    // Load user preferences for DND/quiet hours checking
    dynamic userPrefs;
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      if (prefsJson != null) {
        final prefsMap = jsonDecode(prefsJson) as Map<String, dynamic>;
        userPrefs = UserPreferences.fromJson(prefsMap);
        debugPrint('🔇 Background: Loaded user preferences for DND checking');
      }
    } catch (e) {
      debugPrint('⚠️ Background: Could not load user preferences: $e');
    }

    // Handle sighting alerts with escalated sounds
    if (notificationType == 'sighting_alert') {
      // Play appropriate escalated alert sound based on witness count
      if (witnessCount >= 10) {
        await SoundService.I.play(AlertSound.emergency, haptic: true, witnessCount: witnessCount, userPrefs: userPrefs);
        debugPrint('🚨 BACKGROUND: Playing EMERGENCY alert (${witnessCount} witnesses)');
      } else if (witnessCount >= 3) {
        await SoundService.I.play(AlertSound.urgent, witnessCount: witnessCount, userPrefs: userPrefs);
        debugPrint('⚠️ BACKGROUND: Playing URGENT alert (${witnessCount} witnesses)');
      } else {
        await SoundService.I.play(AlertSound.normal, witnessCount: witnessCount, userPrefs: userPrefs);
        debugPrint('📢 BACKGROUND: Playing NORMAL alert (${witnessCount} witnesses)');
      }

      // Also play push notification sound
      await SoundService.I.play(AlertSound.pushPing, userPrefs: userPrefs);
    } else {
      // For other notification types, play a simple ping
      await SoundService.I.play(AlertSound.pushPing, userPrefs: userPrefs);
    }
  } catch (e) {
    debugPrint('Error in background notification handling: $e');
  }
}
