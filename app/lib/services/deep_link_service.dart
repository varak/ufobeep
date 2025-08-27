import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deep link service for handling push notification and URL-based navigation
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  GoRouter? _router;

  /// Initialize deep link handling
  Future<void> initialize(GoRouter router) async {
    _router = router;
    _appLinks = AppLinks();

    // Handle app links (URL schemes)
    await _initializeAppLinks();

    // Handle push notification deep links
    await _initializePushNotificationLinks();
  }

  /// Initialize app link handling (ufobeep:// scheme)
  Future<void> _initializeAppLinks() async {
    try {
      // Handle app launch from link
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        print('App launched from link: $initialUri');
        await _handleDeepLink(initialUri);
      }

      // Handle links while app is running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) async {
          print('Received app link: $uri');
          await _handleDeepLink(uri);
        },
        onError: (err) {
          print('Deep link error: $err');
        },
      );
    } catch (e) {
      print('Failed to initialize app links: $e');
    }
  }

  /// Initialize push notification deep link handling
  Future<void> _initializePushNotificationLinks() async {
    try {
      // Handle notification tap when app is terminated
      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        print('App launched from notification: ${initialMessage.data}');
        await _handlePushNotificationData(initialMessage.data);
      }

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        print('Notification opened app: ${message.data}');
        await _handlePushNotificationData(message.data);
      });

      // Handle notification when app is in foreground (optional)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('Foreground notification: ${message.data}');
        // Optionally show in-app notification or handle immediately
      });
    } catch (e) {
      print('Failed to initialize push notification links: $e');
    }
  }

  /// Handle deep link URI
  Future<void> _handleDeepLink(Uri uri) async {
    if (_router == null) {
      print('❌ Router not initialized');
      return;
    }

    try {
      final String scheme = uri.scheme;
      final String host = uri.host;
      final List<String> pathSegments = uri.pathSegments;
      final Map<String, String> queryParams = uri.queryParameters;

      print('🔗 DEEP LINK HANDLER DEBUG:');
      print('   📍 Full URI: $uri');
      print('   📱 Scheme: $scheme');
      print('   🌐 Host: $host');
      print('   📂 Path segments: $pathSegments');
      print('   ⚙️  Query params: $queryParams');
      
      // Special logging for auth completion
      if (host == 'auth' && pathSegments.isNotEmpty && pathSegments[0] == 'complete') {
        print('🔐 MAGIC LINK DEEP LINK DETECTED:');
        print('   🎫 Token: ${queryParams['token']?.substring(0, 20)}...');
        print('   👤 User ID: ${queryParams['user_id']}');
        print('   📝 Username: ${queryParams['username']}');
        print('   📧 Email: ${queryParams['email']}');
      }

      // Handle ufobeep:// scheme
      if (scheme == 'ufobeep') {
        await _handleUFOBeepScheme(host, pathSegments, queryParams);
      } 
      // Handle https:// scheme (web app links)
      else if (scheme == 'https' && (host == 'ufobeep.com' || host == 'www.ufobeep.com')) {
        await _handleWebAppLink(pathSegments, queryParams);
      }
      // Handle Firebase dynamic link format (com.ufobeep:/__/auth/...)
      else if (scheme.startsWith('com.ufobeep')) {
        print('🔥 Firebase format detected, converting to standard auth flow...');
        await _handleFirebaseDynamicLink(uri);
      } else {
        print('⚠️ Unsupported deep link scheme: $scheme');
        print('   Falling back to alerts screen...');
        _router!.go('/alerts');
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
      print('   Stack trace: ${StackTrace.current}');
      // Fallback to alerts screen with better error handling
      try {
        _router!.go('/alerts');
      } catch (routerError) {
        print('❌ Even fallback navigation failed: $routerError');
      }
    }
  }

  /// Handle ufobeep:// scheme deep links
  Future<void> _handleUFOBeepScheme(
    String host,
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    switch (host) {
      case 'sighting':
        await _handleSightingLink(pathSegments, queryParams);
        break;
      case 'alerts':
        await _handleAlertsLink(pathSegments, queryParams);
        break;
      case 'chat':
        await _handleChatLink(pathSegments, queryParams);
        break;
      case 'auth':
        await _handleAuthLink(pathSegments, queryParams);
        break;
      case 'compass':
        await _handleCompassLink(pathSegments, queryParams);
        break;
      case 'profile':
        await _handleProfileLink(pathSegments, queryParams);
        break;
      default:
        print('Unknown UFOBeep host: $host');
        _router!.go('/');
    }
  }

  /// Handle web app links (https://ufobeep.com/...)
  Future<void> _handleWebAppLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    if (pathSegments.isEmpty) {
      _router!.go('/');
      return;
    }

    switch (pathSegments[0]) {
      case 'alerts':
        if (pathSegments.length > 1) {
          final sightingId = pathSegments[1];
          _router!.go('/alerts/$sightingId');
        } else {
          _router!.go('/');
        }
        break;
      case 'app':
        _router!.go('/');
        break;
      case 'auth':
        // Handle web auth links (e.g., https://ufobeep.com/auth/magic?token=...)
        if (pathSegments.length > 1 && pathSegments[1] == 'magic') {
          print('Web magic link detected, checking authentication state...');
          await _handleMagicLinkCompletion(queryParams);
        } else {
          _router!.go('/sign-in');
        }
        break;
      default:
        _router!.go('/');
    }
  }

  /// Handle sighting-related deep links
  Future<void> _handleSightingLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    if (pathSegments.isEmpty) {
      _router!.go('/');
      return;
    }

    final sightingId = pathSegments[0];

    if (pathSegments.length > 1) {
      switch (pathSegments[1]) {
        case 'chat':
          // Navigate to sighting detail with chat tab
          _router!.go('/alerts/$sightingId?tab=chat');
          break;
        case 'compass':
          // Navigate to compass pointing to sighting
          _router!.go('/compass?target_sighting=$sightingId');
          break;
        default:
          _router!.go('/alerts/$sightingId');
      }
    } else {
      // Navigate to sighting detail
      _router!.go('/alerts/$sightingId');
    }
  }

  /// Handle alerts list deep links
  Future<void> _handleAlertsLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    // Navigate to alerts/home with optional filters
    String route = '/';
    
    if (queryParams.isNotEmpty) {
      final params = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      route += '?$params';
    }
    
    _router!.go(route);
  }

  /// Handle chat deep links
  Future<void> _handleChatLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    if (pathSegments.isEmpty) {
      _router!.go('/');
      return;
    }

    final roomId = pathSegments[0];
    final sightingId = queryParams['sighting_id'];

    if (sightingId != null) {
      _router!.go('/alerts/$sightingId?tab=chat');
    } else {
      // Generic chat room (if supported)
      _router!.go('/chat?room_id=$roomId');
    }
  }

  /// Handle compass deep links
  Future<void> _handleCompassLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    String route = '/compass';
    
    if (queryParams.isNotEmpty) {
      final params = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      route += '?$params';
    }
    
    _router!.go(route);
  }

  /// Handle auth deep links (redirect to proper GoRouter route)
  Future<void> _handleAuthLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    print('🔐 AUTH LINK HANDLER DEBUG:');
    print('   📂 Path segments: $pathSegments');
    print('   ⚙️  Query params: $queryParams');
    
    if (pathSegments.isEmpty) {
      print('⚠️  No path segments, redirecting to /sign-in');
      _router!.go('/sign-in');
      return;
    }

    final action = pathSegments[0];
    print('🎬 Action: $action');
    
    if (action == 'complete') {
      // Redirect to proper GoRouter route instead of handling auth here
      // This ensures consistent auth flow through the app's routing system
      print('🔄 DEEP LINK REDIRECT: Deep link redirecting to GoRouter /auth/complete route');
      
      // Build the route with query parameters
      final uri = Uri(
        path: '/auth/complete',
        queryParameters: queryParams,
      );
      
      final routeString = uri.toString();
      print('🎯 Final route: $routeString');
      
      _router!.go(routeString);
      print('✅ Redirect completed');
    } else {
      print('⚠️  Unknown action: $action, redirecting to /sign-in');
      _router!.go('/sign-in');
    }
  }

  /// Handle profile deep links
  Future<void> _handleProfileLink(
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    _router!.go('/profile');
  }


  /// Handle Firebase dynamic link format (com.ufobeep:/__/auth/action?oobCode=...)
  Future<void> _handleFirebaseDynamicLink(Uri uri) async {
    print('🔥 FIREBASE DYNAMIC LINK DEBUG:');
    print('   Full URI: $uri');
    
    try {
      // Extract relevant parameters from Firebase format
      final queryParams = uri.queryParameters;
      
      // Check for oobCode (out of band code) or other Firebase auth params
      if (queryParams.containsKey('oobCode') || queryParams.containsKey('mode')) {
        print('   Firebase auth action detected');
        print('   Mode: ${queryParams['mode']}');
        print('   OOB Code: ${queryParams['oobCode']}');
        
        // Convert to our standard auth success flow
        _router!.go('/alerts');
        return;
      }
      
      // Check if it contains our custom token parameter
      if (queryParams.containsKey('token')) {
        print('   Custom token found: ${queryParams['token']}');
        _router!.go('/alerts');
        return;
      }
      
      // Fallback for unrecognized Firebase links
      print('   Unrecognized Firebase link format, navigating to alerts');
      _router!.go('/alerts');
      
    } catch (e) {
      print('❌ Error processing Firebase dynamic link: $e');
      _router!.go('/alerts');
    }
  }

  /// Handle push notification data
  Future<void> _handlePushNotificationData(Map<String, dynamic> data) async {
    try {
      final String? type = data['type'];
      final String? deepLink = data['deep_link'];

      print('Handling push notification type: $type');

      // Use deep link if available
      if (deepLink != null && deepLink.isNotEmpty) {
        final uri = Uri.parse(deepLink);
        await _handleDeepLink(uri);
        return;
      }

      // Fallback to type-based navigation
      switch (type) {
        case 'sighting_alert':
          final String? sightingId = data['sighting_id'];
          if (sightingId != null) {
            _router!.go('/alerts/$sightingId');
          } else {
            _router!.go('/');
          }
          break;

        case 'chat_message':
          final String? sightingId = data['sighting_id'];
          if (sightingId != null) {
            _router!.go('/alerts/$sightingId?tab=chat');
          } else {
            _router!.go('/');
          }
          break;

        case 'system':
          // Navigate to appropriate system page
          _router!.go('/profile');
          break;

        default:
          print('Unknown notification type: $type');
          _router!.go('/');
      }
    } catch (e) {
      print('Error handling push notification data: $e');
      _router!.go('/');
    }
  }

  /// Parse deep link from string
  Uri? parseDeepLink(String link) {
    try {
      return Uri.parse(link);
    } catch (e) {
      print('Failed to parse deep link: $link, error: $e');
      return null;
    }
  }

  /// Create deep link for sighting
  String createSightingLink(String sightingId, {String? action}) {
    if (action != null) {
      return 'ufobeep://sighting/$sightingId/$action';
    }
    return 'ufobeep://sighting/$sightingId';
  }

  /// Create deep link for chat
  String createChatLink(String sightingId) {
    return 'ufobeep://sighting/$sightingId/chat';
  }

  /// Create deep link for compass
  String createCompassLink({String? targetSighting, double? latitude, double? longitude}) {
    String link = 'ufobeep://compass';
    List<String> params = [];
    
    if (targetSighting != null) {
      params.add('target_sighting=${Uri.encodeComponent(targetSighting)}');
    }
    if (latitude != null) {
      params.add('lat=${latitude.toString()}');
    }
    if (longitude != null) {
      params.add('lon=${longitude.toString()}');
    }
    
    if (params.isNotEmpty) {
      link += '?${params.join('&')}';
    }
    
    return link;
  }

  /// Test deep link navigation
  Future<void> testNavigation(String deepLink) async {
    if (!kDebugMode) return;
    
    print('🧪 Testing deep link: $deepLink');
    final uri = parseDeepLink(deepLink);
    if (uri != null) {
      await _handleDeepLink(uri);
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}

/// Global deep link service instance
final deepLinkService = DeepLinkService();