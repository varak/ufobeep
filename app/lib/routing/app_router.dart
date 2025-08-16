import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/app_theme.dart';

import '../screens/home/home_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/alerts/alert_detail_screen.dart';
import '../screens/beep/beep_screen.dart';
import '../screens/beep/quick_beep_screen.dart';
import '../screens/beep/beep_composition_screen.dart';
import '../screens/beep/camera_capture_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/compass/compass_screen.dart';
import '../screens/map/map_screen.dart';
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
      // Splash Screen (redirects to beep screen)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
        redirect: (context, state) => '/beep',
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
              // Custom Camera (no approval modal)
              GoRoute(
                path: 'camera',
                name: 'beep-camera',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final description = extra?['description'] as String?;
                  return CameraCaptureScreen(description: description);
                },
              ),
              // Beep Composition
              GoRoute(
                path: 'compose',
                name: 'beep-compose',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  
                  debugPrint('Router: Extra data keys: ${extra?.keys}');
                  
                  final imageFile = extra?['imageFile'];
                  
                  // If no image file provided, redirect back to beep screen
                  if (imageFile == null) {
                    debugPrint('ERROR: No image file in extra data, redirecting to /beep');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.go('/beep');
                    });
                    return Scaffold(
                      backgroundColor: AppColors.darkBackground,
                      appBar: AppBar(
                        title: const Text('Loading...'),
                        backgroundColor: AppColors.darkSurface,
                      ),
                      body: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Redirecting back to beep screen...',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  debugPrint('Found image file: $imageFile');
                  
                  try {
                    return BeepCompositionScreen(
                      imageFile: imageFile,
                      sensorData: extra?['sensorData'],
                      photoMetadata: extra?['photoMetadata'],
                      description: extra?['description'],
                    );
                  } catch (e, stackTrace) {
                    debugPrint('ERROR creating BeepCompositionScreen: $e');
                    debugPrint('Stack trace: $stackTrace');
                    
                    // Return error screen instead of crashing
                    return Scaffold(
                      backgroundColor: AppColors.darkBackground,
                      appBar: AppBar(
                        title: const Text('Error'),
                        backgroundColor: AppColors.darkSurface,
                      ),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error,
                              color: AppColors.semanticError,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load compose screen',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              e.toString(),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => context.go('/beep'),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          // Map (main tab)
          GoRoute(
            path: '/map',
            name: 'map',
            builder: (context, state) => const MapScreen(),
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

      // Compass (accessible from alert details, not in bottom nav)
      GoRoute(
        path: '/compass',
        name: 'compass',
        builder: (context, state) {
          // Extract target coordinates from query parameters
          final targetLat = state.uri.queryParameters['targetLat'];
          final targetLon = state.uri.queryParameters['targetLon'];
          final targetName = state.uri.queryParameters['targetName'];
          final bearing = state.uri.queryParameters['bearing'];
          final distance = state.uri.queryParameters['distance'];
          final alertId = state.uri.queryParameters['alertId'];
          
          return CompassScreen(
            targetLat: targetLat != null ? double.tryParse(targetLat) : null,
            targetLon: targetLon != null ? double.tryParse(targetLon) : null,
            targetName: targetName,
            targetBearing: bearing != null ? double.tryParse(bearing) : null,
            targetDistance: distance != null ? double.tryParse(distance) : null,
            alertId: alertId,
          );
        },
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
    } else if (currentLocation.startsWith('/map')) {
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
            context.go('/map');
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
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}