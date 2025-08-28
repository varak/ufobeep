import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/app_theme.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';

import '../screens/alerts/alerts_screen.dart';
import '../screens/alerts/alert_detail_screen.dart';
import '../screens/beep/beep_screen.dart';
import '../screens/beep/beep_composition_screen.dart';
import '../screens/beep/camera_capture_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/compass/compass_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/user_registration_screen.dart';
import '../screens/profile/language_settings_screen.dart';
import '../screens/auth/account_recovery_screen.dart';
import '../screens/auth/phone_setup_screen.dart';
import '../screens/auth/firebase_phone_auth_screen.dart';
import '../screens/auth/firebase_email_auth_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../models/shared_media_data.dart';

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
    // Redirect function to normalize HTTPS magic links to internal routes (ChatGPT's Phase 2)
    redirect: (context, state) {
      final location = state.uri.toString();
      debugPrint('🔄 GoRouter redirect check: $location');
      
      // Handle HTTPS magic links by converting to internal route
      if (location.startsWith('https://api.ufobeep.com/auth/magic/complete/new')) {
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
      print('🚫 GO ROUTER ERROR:');
      print('   Location: ${state.uri}');
      print('   Error: ${state.error}');
      
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
      // Splash Screen (handles its own navigation after initialization)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
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
                  
                  final mediaFile = extra?['mediaFile'] ?? extra?['imageFile']; // Support both old and new parameter names
                  final isVideo = extra?['isVideo'] ?? false;
                  
                  // If no media file provided, show error and provide navigation options
                  if (mediaFile == null) {
                    debugPrint('ERROR: No media file in extra data for beep composition');
                    return Scaffold(
                      backgroundColor: AppColors.darkBackground,
                      appBar: AppBar(
                        title: const Text('Composition Error'),
                        backgroundColor: AppColors.darkSurface,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.go('/beep'),
                        ),
                      ),
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
                              'No media file provided',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The shared media could not be found or processed.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => context.go('/beep'),
                              child: const Text('Back to Beep'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  debugPrint('Found ${isVideo ? 'video' : 'image'} file: $mediaFile');
                  
                  try {
                    return BeepCompositionScreen(
                      mediaFile: mediaFile,
                      isVideo: isVideo,
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
            builder: (context, state) {
              // Extract query parameters for alert-specific map view
              final userLat = state.uri.queryParameters['userLat'];
              final userLon = state.uri.queryParameters['userLon'];
              final alertLat = state.uri.queryParameters['alertLat'];
              final alertLon = state.uri.queryParameters['alertLon'];
              final alertId = state.uri.queryParameters['alertId'];
              final alertName = state.uri.queryParameters['alertName'];
              final calledFromAlert = alertId != null && alertLat != null && alertLon != null;
              
              return MapScreen(
                userLat: userLat != null ? double.tryParse(userLat) : null,
                userLon: userLon != null ? double.tryParse(userLon) : null,
                alertLat: alertLat != null ? double.tryParse(alertLat) : null,
                alertLon: alertLon != null ? double.tryParse(alertLon) : null,
                alertId: alertId,
                alertName: alertName,
                calledFromAlert: calledFromAlert,
              );
            },
          ),

          // Alerts (clean list without map)
          GoRoute(
            path: '/alerts',
            name: 'alerts',
            builder: (context, state) => const AlertsScreen(),
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
          debugPrint('🔗 Internal magic route hit with code: ${code?.substring(0, 8)}...');
          
          return MagicLinkProcessingScreen(code: code);
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

/// Magic Link Processing Screen with Circuit Breaker Pattern
class MagicLinkProcessingScreen extends StatefulWidget {
  final String? code;
  
  const MagicLinkProcessingScreen({super.key, this.code});
  
  @override
  State<MagicLinkProcessingScreen> createState() => _MagicLinkProcessingScreenState();
}

class _MagicLinkProcessingScreenState extends State<MagicLinkProcessingScreen> {
  bool _isProcessing = true;
  String _statusMessage = 'Authenticating...';
  String _subMessage = 'Please wait while we verify your magic link';
  
  @override
  void initState() {
    super.initState();
    _processWithCircuitBreaker();
  }
  
  void _processWithCircuitBreaker() async {
    if (widget.code == null || widget.code!.isEmpty) {
      _handleError('Invalid magic link - missing code');
      return;
    }
    
    try {
      // Circuit breaker: 10 second total timeout
      await Future.any([
        _processMagicLink(),
        Future.delayed(const Duration(seconds: 10), () => throw TimeoutException('Circuit breaker timeout', const Duration(seconds: 10))),
      ]);
      
    } on TimeoutException {
      _handleError('Verification timed out. Please try the magic link again.');
    } catch (e) {
      _handleError('Verification failed: ${e.toString()}');
    }
  }
  
  Future<void> _processMagicLink() async {
    try {
      debugPrint('🔗 MagicLinkProcessingScreen: Starting auth process');
      await AuthService().beginProcessingLink();
      
      setState(() {
        _subMessage = 'Exchanging authorization code...';
      });
      
      final success = await AuthService().loginWithMagicCode(code: widget.code!);
      
      if (success && mounted) {
        debugPrint('🔗 MagicLinkProcessingScreen: Auth successful, waiting for navigation');
        setState(() {
          _statusMessage = 'Success!';
          _subMessage = 'Redirecting to your dashboard...';
        });
        
        // Wait a moment for AuthRepository to update, then check navigation
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/alerts');
        }
      } else {
        _handleError('Authentication failed');
      }
    } catch (e) {
      _handleError('Authentication error: ${e.toString()}');
    }
  }
  
  void _handleError(String message) {
    if (!mounted) return;
    
    setState(() {
      _isProcessing = false;
      _statusMessage = 'Authentication Failed';
      _subMessage = message;
    });
    
    // Auto-redirect to sign-in after showing error
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/sign-in');
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
              ),
              const SizedBox(height: 16),
            ] else ...[
              const Icon(
                Icons.error_outline,
                color: AppColors.semanticError,
                size: 64,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              _statusMessage,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _subMessage,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (!_isProcessing) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/sign-in'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                ),
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    int currentIndex = 0;
    if (currentLocation == '/' || currentLocation.startsWith('/alerts') || currentLocation.startsWith('/alert/')) {
      currentIndex = 0;
    } else if (currentLocation.startsWith('/beep')) {
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
            context.go('/alerts');
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