import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/environment.dart';
import 'config/locale_config.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/user_preferences_provider.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await AppEnvironment.initialize();
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Log configuration in debug mode
  AppEnvironment.logConfig();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const UFOBeepApp(),
    ),
  );
}

class UFOBeepApp extends ConsumerWidget {
  const UFOBeepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
