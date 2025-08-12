import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/app_theme.dart';

import '../screens/home/home_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/alerts/alert_detail_screen.dart';
import '../screens/beep/beep_screen.dart';
import '../screens/beep/beep_composition_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/compass/compass_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/registration_screen.dart';
import '../screens/profile/language_settings_screen.dart';
import '../screens/splash/splash_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Global access to router for navigation from services
GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home/Alerts Feed
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              // Alert Detail
              GoRoute(
                path: 'alert/:id',
                name: 'alert-detail',
                builder: (context, state) {
                  final alertId = state.pathParameters['id']!;
                  return AlertDetailScreen(alertId: alertId);
                },
                routes: [
                  // Chat for specific alert
                  GoRoute(
                    path: 'chat',
                    name: 'alert-chat',
                    builder: (context, state) {
                      final alertId = state.pathParameters['id']!;
                      return ChatScreen(alertId: alertId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Beep (Capture/Upload)
          GoRoute(
            path: '/beep',
            name: 'beep',
            builder: (context, state) => const BeepScreen(),
            routes: [
              // Beep Composition
              GoRoute(
                path: 'compose',
                name: 'beep-compose',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final imageFile = extra?['imageFile'];
                  
                  // If no image file provided, redirect back to beep screen
                  if (imageFile == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.go('/beep');
                    });
                    return const Scaffold(
                      backgroundColor: AppColors.darkBackground,
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  return BeepCompositionScreen(
                    imageFile: imageFile,
                    sensorData: extra?['sensorData'],
                    planeMatch: extra?['planeMatch'],
                  );
                },
              ),
            ],
          ),

          // Compass
          GoRoute(
            path: '/compass',
            name: 'compass',
            builder: (context, state) => const CompassScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // Language Settings
              GoRoute(
                path: 'language',
                name: 'language-settings',
                builder: (context, state) => const LanguageSettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Registration Screen
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegistrationScreen(),
      ),

      // Standalone Alerts List (if needed)
      GoRoute(
        path: '/alerts',
        name: 'alerts',
        builder: (context, state) => const AlertsScreen(),
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MainBottomNavBar(),
    );
  }
}

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    int currentIndex = 0;
    if (currentLocation.startsWith('/beep')) {
      currentIndex = 1;
    } else if (currentLocation.startsWith('/compass')) {
      currentIndex = 2;
    } else if (currentLocation.startsWith('/profile')) {
      currentIndex = 3;
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/beep');
            break;
          case 2:
            context.go('/compass');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_a_photo),
          label: 'Beep',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Compass',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}