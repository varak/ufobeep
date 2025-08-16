import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config/environment.dart';
import 'config/locale_config.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/user_preferences_provider.dart';
import 'routing/app_router.dart';
import 'services/push_notification_service.dart';
import 'services/sound_service.dart';
import 'services/permission_service.dart';
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
  await Future.wait([
    SoundService.I.init(),
    permissionService.initializePermissions(),
    pushNotificationService.initialize(),
  ]);
  
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
}
