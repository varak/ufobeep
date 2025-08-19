import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'dart:convert';

import 'config/environment.dart';
import 'config/locale_config.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/user_preferences.dart';
import 'providers/user_preferences_provider.dart';
import 'routing/app_router.dart';
import 'services/push_notification_service.dart';
import 'services/sound_service.dart';
import 'services/permission_service.dart';
import 'services/share_intent_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Critical startup operations in parallel
  final stopwatch = Stopwatch()..start();
  print('🚀 UFOBeep starting...');
  
  // Run critical initialization in parallel
  final results = await Future.wait([
    Firebase.initializeApp(),
    AppEnvironment.initialize(),
    SharedPreferences.getInstance(),
  ]);
  
  final sharedPreferences = results[2] as SharedPreferences;
  print('✅ Core initialization: ${stopwatch.elapsedMilliseconds}ms');
  
  // Set up Firebase messaging background handler early
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Get initial message quickly
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  
  // Log configuration
  AppEnvironment.logConfig();
  
  print('✅ App ready: ${stopwatch.elapsedMilliseconds}ms');
  
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
  print('🔧 Initializing background services...');
  final stopwatch = Stopwatch()..start();
  
  // Initialize services that don't block app startup  
  // (permissions moved to splash screen initialization)
  await Future.wait([
    SoundService.I.init(),
    pushNotificationService.initialize(),
  ]);
  
  // Initialize share intent service
  await ShareIntentService().initialize();
  
  print('✅ Background services ready: ${stopwatch.elapsedMilliseconds}ms');
}

class UFOBeepApp extends ConsumerStatefulWidget {
  const UFOBeepApp({super.key, this.initialMessage});
  
  final RemoteMessage? initialMessage;

  @override
  ConsumerState<UFOBeepApp> createState() => _UFOBeepAppState();
}

class _UFOBeepAppState extends ConsumerState<UFOBeepApp> {
  @override
  void initState() {
    super.initState();
    
    // Handle initial message after the widget tree is built
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInitialMessage(widget.initialMessage!);
      });
    }
    
    // Set up share intent callback once in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupShareIntentCallback();
    });
  }
  
  void _setupShareIntentCallback() {
    final router = ref.read(appRouterProvider);
    
    ShareIntentService.setOnSharedMediaCallback((sharedMedia) async {
      print('Main: Share intent callback triggered with ${sharedMedia.mediaType}: ${sharedMedia.filePath}');
      
      // Create properly named file with correct extension
      final originalFile = sharedMedia.file;
      final bytes = await originalFile.readAsBytes();
      final extension = _detectFileExtension(bytes, sharedMedia.isVideo);
      final properFileName = 'shared_media_${DateTime.now().millisecondsSinceEpoch}$extension';
      final tempDir = originalFile.parent;
      final properFile = File('${tempDir.path}/$properFileName');
      await originalFile.copy(properFile.path);
      
      print('Main: Created proper ${sharedMedia.isVideo ? 'video' : 'image'} file: ${properFile.path}');
      
      // Navigate directly to beep composition screen with shared media
      router.go('/beep/compose', extra: {
        'mediaFile': properFile,
        'isVideo': sharedMedia.isVideo,
        'sensorData': null,
        'photoMetadata': <String, dynamic>{},
        'description': '', // Empty description so placeholder shows
      });
      print('Main: Navigated to composition screen with shared ${sharedMedia.mediaType}');
    });
    
    // Check for shared files now that callback is set
    ShareIntentService.checkForSharedFiles();
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
    print('Processing initial message: ${message.messageId}');
    
    final notificationType = message.data['type'] ?? 'general';
    
    switch (notificationType) {
      case 'sighting_alert':
        final sightingId = message.data['sighting_id'];
        if (sightingId != null) {
          print('Navigating to sighting alert: $sightingId');
          pushNotificationService.navigateToAlert(sightingId);
        }
        break;
      case 'chat_message':
        final chatId = message.data['chat_id'];
        if (chatId != null) {
          print('Navigating to chat: $chatId');
          pushNotificationService.navigateToChat(chatId);
        }
        break;
    }
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
      supportedLocales: LocaleConfig.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locales, supportedLocales) =>
          LocaleConfig.localeResolutionCallback(locales != null ? [locales] : null, supportedLocales),
    );
  }
}

// Removed - now handled by PermissionService

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
  
  // Process the notification type and play appropriate sounds
  final notificationType = message.data['type'] ?? 'general';
  final witnessCountStr = message.data['witness_count'] ?? '1';
  final witnessCount = int.tryParse(witnessCountStr) ?? 1;
  
  print('Background notification type: $notificationType, witnesses: $witnessCount');
  
  // Initialize sound service for background processing
  try {
    await SoundService.I.init();
    
    // Load user preferences for DND/quiet hours checking
    dynamic userPrefs;
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      if (prefsJson != null) {
        final prefsMap = jsonDecode(prefsJson) as Map<String, dynamic>;
        userPrefs = UserPreferences.fromJson(prefsMap);
        print('🔇 Background: Loaded user preferences for DND checking');
      }
    } catch (e) {
      print('⚠️ Background: Could not load user preferences: $e');
    }
    
    // Handle sighting alerts with escalated sounds
    if (notificationType == 'sighting_alert') {
      // Play appropriate escalated alert sound based on witness count
      if (witnessCount >= 10) {
        await SoundService.I.play(AlertSound.emergency, haptic: true, witnessCount: witnessCount, userPrefs: userPrefs);
        print('🚨 BACKGROUND: Playing EMERGENCY alert (${witnessCount} witnesses)');
      } else if (witnessCount >= 3) {
        await SoundService.I.play(AlertSound.urgent, witnessCount: witnessCount, userPrefs: userPrefs);
        print('⚠️ BACKGROUND: Playing URGENT alert (${witnessCount} witnesses)');
      } else {
        await SoundService.I.play(AlertSound.normal, witnessCount: witnessCount, userPrefs: userPrefs);
        print('📢 BACKGROUND: Playing NORMAL alert (${witnessCount} witnesses)');
      }
      
      // Also play push notification sound
      await SoundService.I.play(AlertSound.pushPing, userPrefs: userPrefs);
    } else {
      // For other notification types, play a simple ping
      await SoundService.I.play(AlertSound.pushPing, userPrefs: userPrefs);
    }
  } catch (e) {
    print('Error playing background notification sound: $e');
  }
}
