import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:file_picker/file_picker.dart';

import '../theme/app_theme.dart';
import '../services/ui_feedback.dart';

import '../screens/alerts/alerts_screen.dart';
import '../screens/alerts/alert_detail_screen.dart';
import '../screens/comments/comments_screen.dart';
import '../screens/beep/beep_screen.dart';
import '../screens/beep/beep_composition_screen.dart';
import '../screens/beep/camera_capture_screen.dart';
import '../screens/beep/multi_file_upload_screen.dart';
import '../screens/compass/compass_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/user_registration_screen.dart';
import '../screens/profile/language_settings_screen.dart';
import '../screens/profile/location_tracking_screen.dart';
import '../screens/profile/data_management_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/account_recovery_screen.dart';
import '../screens/auth/phone_setup_screen.dart';
import '../screens/auth/firebase_phone_auth_screen.dart';
import '../screens/auth/firebase_email_auth_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/notifications/notification_management_screen.dart';
import '../models/shared_media_data.dart';
import '../models/sensor_data.dart';
import '../l10n/app_localizations.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Global access to router for navigation from services
GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

// Route logger to track navigation events
class _RouteLogger extends NavigatorObserver {
  void _log(String s) => debugPrint('🧭 [NAV] $s');

  @override
  void didPush(Route route, Route? previousRoute) =>
      _log('push -> ${route.settings.name ?? route.settings.arguments ?? route}');
  @override
  void didPop(Route route, Route? previousRoute) =>
      _log('pop  <- ${route.settings.name ?? route.settings.arguments ?? route}');
  @override
  void didRemove(Route route, Route? previousRoute) =>
      _log('remove  ${route.settings.name ?? route}');
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) =>
      _log('replace ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
}

// No transition page to avoid platform view races
class _NoTransitionPage extends CustomTransitionPage<void> {
  _NoTransitionPage(Widget child)
      : super(
          child: child,
          transitionsBuilder: (c, a, s, child) => child, // no animation
        );
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    observers: [_RouteLogger()],
    // 🔭 Global redirect tracer with camera route bypass
    redirect: (context, state) {
      final location = state.uri.toString();
      debugPrint('🔄 [GLOBAL REDIRECT] ${state.matchedLocation}  uri=${state.uri}');
      
      // Hard bypass for camera routes to prevent redirect loops
      if (state.matchedLocation == '/beep/camera' || state.matchedLocation == '/diag/camera') {
        return null;
      }
      
      // Handle HTTPS magic links by converting to internal route
      if (location.startsWith('https://ufobeep.com/api/auth/magic/complete/new')) {
        final uri = Uri.parse(location);
        final code = uri.queryParameters['code'];
        
        if (code != null && code.isNotEmpty) {
          debugPrint('🔄 Redirecting HTTPS magic link to internal route with code: ${code.substring(0, 8)}...');
          return '/auth/magic?code=$code';
        }
      }
      
      return null; // No redirect needed
    },
    // Add error handling for unrecognized routes
    errorBuilder: (context, state) {
      debugPrint('🚫 GO ROUTER ERROR:');
      debugPrint('   Location: ${state.uri}');
      debugPrint('   Error: ${state.error}');
      
      // Return a fallback screen that navigates to alerts
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.semanticError,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Navigation Error',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Could not navigate to: ${state.uri}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // ChatGPT's fix: Navigate to sign-in instead of creating users
                  context.go('/sign-in');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                ),
                child: const Text('Back to Sign In', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    },
    routes: [
      // ✅ CAMERA ROUTES AT ROOT LEVEL (outside any ShellRoute to prevent redirect issues)
      // Debug-only diagnostic screen - TEMPORARILY DISABLED FOR DEBUGGING
      // if (!kReleaseMode)
      //   GoRoute(
      //     path: '/diag/camera',
      //     name: 'diag-camera',
      //     parentNavigatorKey: _rootNavigatorKey,
      //     pageBuilder: (context, state) {
      //     },
      //   ),
      // Production camera capture screen - KEEP AT ROOT FOREVER
      GoRoute(
        path: '/beep/camera',
        name: 'beep-camera',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          debugPrint('🚦 ROUTER: /beep/camera pageBuilder called - creating PRODUCTION CameraCaptureScreen');
          final extra = state.extra as Map<String, dynamic>?;
          return _NoTransitionPage(CameraCaptureScreen(
            description: extra?['description'],
            attachToSightingId: extra?['attachToSightingId'],
            returnToComposition: extra?['returnToComposition'] ?? false,
            preFetchedGPS: extra?['preFetchedGPS'],
          ));
        },
      ),
      
      // Splash Screen (handles its own navigation after initialization)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding flow
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Sign In Screen (for unauthenticated users)
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
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
            builder: (context, state) => const AlertsScreen(),
            routes: [
              // Alert Detail
              GoRoute(
                path: 'alert/:id',
                name: 'alert-detail',
                builder: (context, state) {
                  final alertId = state.pathParameters['id']!;
                  final extra = state.extra as Map<String, dynamic>?;
                  final initialCommentId = extra?['initialCommentId'] as String?;
                  final shouldFocusComment = state.uri.queryParameters['focusComment'] == 'true';
                  return AlertDetailScreen(
                    alertId: alertId,
                    initialCommentId: initialCommentId,
                    shouldFocusComment: shouldFocusComment,
                  );
                },
                routes: [
                  // Comments for specific alert
                  GoRoute(
                    path: 'comments',
                    name: 'alert-comments',
                    builder: (context, state) {
                      final alertId = state.pathParameters['id']!;
                      final alertTitle = state.uri.queryParameters['title'] ?? AppLocalizations.of(context)?.alertDetailTitle ?? 'Alert Details';
                      return CommentsScreen(
                        sightingId: alertId,
                        alertTitle: alertTitle,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Beep (Capture/Upload) - WITH REDIRECT TRACING
          GoRoute(
            path: '/beepscreen',
            name: 'beep',
            redirect: (context, state) {
              debugPrint('🔄 [/beepscreen REDIRECT] ${state.matchedLocation} uri=${state.uri} '
                        'fullPath=${state.fullPath}');
              // If you previously returned the SAME location conditionally, that's a loop.
              return null; // No redirect needed
            },
            builder: (context, state) {
              final attachTo = state.uri.queryParameters['attachTo'];
              final autoGallery = state.uri.queryParameters['autoGallery'] == 'true';
              
              // Handle camera return data and share intent data
              final extra = state.extra as Map<String, dynamic>?;
              File? mediaFile;
              List<File>? sharedMediaFiles;
              SensorData? sensorData;
              Map<String, dynamic>? photoMetadata;
              
              if (extra != null) {
                debugPrint('📸 BEEP ROUTE: Received extra data - ${extra.keys}');
                
                // Camera return data (single file)
                if (extra.containsKey('mediaFile')) {
                  mediaFile = extra['mediaFile'] as File?;
                  sensorData = extra['sensorData'] as SensorData?;
                  photoMetadata = extra['photoMetadata'] as Map<String, dynamic>?;
                  debugPrint('📸 BEEP ROUTE: Camera return data - single file');
                }
                
                // Share intent data (multiple files) - extract ALL files, don't set single mediaFile
                else if (extra.containsKey('mediaFiles')) {
                  final mediaFiles = extra['mediaFiles'] as List?;
                  if (mediaFiles != null && mediaFiles.isNotEmpty) {
                    sharedMediaFiles = [];
                    for (final fileData in mediaFiles) {
                      final fileMap = fileData as Map<String, dynamic>?;
                      if (fileMap != null && fileMap.containsKey('mediaFile')) {
                        final file = fileMap['mediaFile'] as File?;
                        if (file != null) {
                          sharedMediaFiles.add(file);
                        }
                      }
                    }
                    sensorData = extra['sensorData'] as SensorData?;
                    debugPrint('📸 BEEP ROUTE: Extracted ${sharedMediaFiles.length} shared media files');
                  }
                }
              }
              
              return BeepScreen(
                attachToSightingId: attachTo,
                autoOpenGallery: autoGallery,
                initialMediaFile: mediaFile,
                initialMediaFiles: sharedMediaFiles,
                initialSensorData: sensorData,
                initialPhotoMetadata: photoMetadata,
              );
            },
            routes: [
              // ❌ CAMERA ROUTE REMOVED - NOW AT ROOT LEVEL
              // Beep Composition
              GoRoute(
                path: 'compose',
                name: 'beep-compose',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  
                  debugPrint('🎯 ROUTER: BeepCompose - Extra data keys: ${extra?.keys}');
                  debugPrint('🎯 ROUTER: BeepCompose - Extra data: $extra');
                  
                  // Support both single and multi-file formats
                  final mediaFile = extra?['mediaFile'] ?? extra?['imageFile']; // Legacy single file
                  final mediaFiles = extra?['mediaFiles'] as List<Map<String, dynamic>>?; // New multi-file format
                  final isVideo = extra?['isVideo'] ?? false;
                  
                  debugPrint('🎯 ROUTER: BeepCompose - MediaFile: $mediaFile');
                  debugPrint('🎯 ROUTER: BeepCompose - MediaFiles: ${mediaFiles?.length} files');
                  debugPrint('🎯 ROUTER: BeepCompose - IsVideo: $isVideo');
                  
                  // Allow BeepCompositionScreen to handle empty media files gracefully
                  
                  if (mediaFiles != null && mediaFiles.isNotEmpty) {
                    debugPrint('Found ${mediaFiles.length} media files');
                  } else {
                    debugPrint('Found ${isVideo ? 'video' : 'image'} file: $mediaFile');
                  }
                  
                  try {
                    return BeepCompositionScreen(
                      // Legacy single file support
                      mediaFile: mediaFile,
                      isVideo: isVideo,
                      photoMetadata: extra?['photoMetadata'],
                      // New multi-file support
                      mediaFiles: mediaFiles,
                      // Common parameters
                      sensorData: extra?['sensorData'],
                      description: extra?['description'],
                      attachToSightingId: extra?['attachToSightingId'],
                    );
                  } catch (e, stackTrace) {
                    debugPrint('❌ ERROR creating BeepCompositionScreen: $e');
                    debugPrint('❌ Stack trace: $stackTrace');
                    debugPrint('❌ Extra data: $extra');
                    
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
                              onPressed: () => context.go('/beepscreen'),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              // Multi-file Upload Screen for existing alerts
              GoRoute(
                path: 'multi-upload',
                name: 'multi-upload',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final files = extra?['files'] as List<PlatformFile>? ?? [];
                  final alertId = extra?['alertId'] as String? ?? '';
                  
                  if (files.isEmpty || alertId.isEmpty) {
                    return const Scaffold(
                      body: Center(
                        child: Text('Invalid upload parameters'),
                      ),
                    );
                  }
                  
                  return MultiFileUploadScreen(
                    files: files,
                    alertId: alertId,
                  );
                },
              ),
            ],
          ),

          // Beep Detail (for notifications) - MOVED after /beep to fix route matching
          GoRoute(
            path: '/beep/:id',
            name: 'beep-detail',
            builder: (context, state) {
              final beepId = state.pathParameters['id']!;
              final extra = state.extra as Map<String, dynamic>?;
              final initialCommentId = extra?['initialCommentId'] as String?;
              final shouldFocusComment = state.uri.queryParameters['focusComment'] == 'true';
              return AlertDetailScreen(
                alertId: beepId,
                initialCommentId: initialCommentId,
                shouldFocusComment: shouldFocusComment,
              );
            },
            routes: [
              // Comments for specific beep
              GoRoute(
                path: 'comments',
                name: 'beep-comments',
                builder: (context, state) {
                  final beepId = state.pathParameters['id']!;
                  final beepTitle = state.uri.queryParameters['title'] ?? AppLocalizations.of(context)?.alertDetailTitle ?? 'Alert Details';
                  return CommentsScreen(
                    sightingId: beepId,
                    alertTitle: beepTitle,
                  );
                },
              ),
            ],
          ),

          // Alerts (clean list without map)
          GoRoute(
            path: '/alerts',
            name: 'alerts',
            builder: (context, state) => const AlertsScreen(),
          ),

          // Map Screen
          GoRoute(
            path: '/mapscreen',
            name: 'mapscreen',
            builder: (context, state) {
              // Extract target alert ID from query parameters
              final targetAlertId = state.uri.queryParameters['targetAlert'];

              return MapScreen(
                targetAlertId: targetAlertId,
              );
            },
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
              // Notification Management
              GoRoute(
                path: 'notifications',
                name: 'notification-management',
                builder: (context, state) => const NotificationManagementScreen(),
              ),
              // Location Tracking Settings
              GoRoute(
                path: 'location-tracking',
                name: 'location-tracking',
                builder: (context, state) => const LocationTrackingScreen(),
              ),
              // Data Management
              GoRoute(
                path: 'data-management',
                name: 'data-management',
                builder: (context, state) => const DataManagementScreen(),
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
        builder: (context, state) => const UserRegistrationScreen(),
      ),

      // Account Recovery with Email/SMS options
      GoRoute(
        path: '/recover',
        name: 'recover',
        builder: (context, state) => const AccountRecoveryScreen(),
      ),
      
      // Firebase Email Authentication
      GoRoute(
        path: '/email-auth',
        name: 'email-auth', 
        builder: (context, state) => const FirebaseEmailAuthScreen(),
      ),
      
      // Phone Setup Screen
      GoRoute(
        path: '/phone-setup',
        name: 'phone-setup',
        builder: (context, state) => const PhoneSetupScreen(),
      ),

      // Auth Login Screen (for deep links)
      GoRoute(
        path: '/auth/login',
        name: 'auth-login',
        builder: (context, state) => const AccountRecoveryScreen(),
      ),

      // Internal Magic Link Handler with Circuit Breaker (ChatGPT's Phase 2 solution)  
      // Deterministic outcome: success → AuthRepository drives navigation; failure → back to sign-in
      GoRoute(
        path: '/auth/magic',
        name: 'auth-magic',
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          debugPrint('🔗 Magic link route - DeepLinkHandler will process code: ${code?.substring(0, 8)}...');
          
          // Just show a loading screen - DeepLinkHandler does the actual processing
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Processing magic link...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
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

// MagicLinkProcessingScreen removed - DeepLinkHandler now handles all magic link processing

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    int currentIndex = 0;
    if (currentLocation == '/' || currentLocation.startsWith('/alerts') || currentLocation.startsWith('/alert/')) {
      currentIndex = 0;
    } else if (currentLocation.startsWith('/beepscreen') || currentLocation.startsWith('/beep/')) {
      currentIndex = 1;
    } else if (currentLocation.startsWith('/profile')) {
      currentIndex = 2;
    }

    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) async {
        await UiFeedback.click();
        switch (index) {
          case 0:
            context.go('/alerts');
            break;
          case 1:
            context.go('/beepscreen');
            break;
          case 2:
            context.go('/profile');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: l10n?.tabAlerts ?? 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.add_a_photo),
          label: l10n?.tabBeep ?? 'Beep',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: l10n?.profile ?? 'Profile',
        ),
      ],
    );
  }
}
