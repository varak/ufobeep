import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/environment.dart';
import 'config/locale_config.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await AppEnvironment.initialize();
  
  // Log configuration in debug mode
  AppEnvironment.logConfig();
  
  runApp(
    const ProviderScope(
      child: UFOBeepApp(),
    ),
  );
}

class UFOBeepApp extends ConsumerWidget {
  const UFOBeepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppEnvironment.appName,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      
      // Internationalization
      supportedLocales: LocaleConfig.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: LocaleConfig.localeResolutionCallback,
    );
  }
}
