import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'config/environment.dart';
import 'config/locale_config.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/user_preferences_provider.dart';
import 'routing/app_router.dart';
import 'services/push_notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize environment configuration
  await AppEnvironment.initialize();
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Set up Firebase messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize push notifications
  await pushNotificationService.initialize();
  
  // Check if app was opened from a terminated state by a notification
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  
  // Log configuration in debug mode
  AppEnvironment.logConfig();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: UFOBeepApp(initialMessage: initialMessage),
    ),
  );
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}
