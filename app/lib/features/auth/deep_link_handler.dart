import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../routing/app_router.dart';

/// Centralized deep link handler that processes magic links BEFORE UI renders
/// Based on ChatGPT's architecture recommendations for clean separation of concerns
class DeepLinkHandler {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _processedInitial = false;
  
  // Deduplication guards to prevent duplicate code processing
  final _inFlight = <String>{};
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);

  DeepLinkHandler();

  /// Initialize deep link handling - call this BEFORE app UI starts
  Future<void> init() async {
    _appLinks = AppLinks();
    
    // 1) Handle initial link (cold start from magic link)
    if (!_processedInitial) {
      _processedInitial = true;
      try {
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          debugPrint('🔗 DeepLinkHandler: Processing initial link: $initialUri');
          await _handleUri(initialUri);
        }
      } on PlatformException catch (e) {
        debugPrint('❌ DeepLinkHandler: Initial link error: $e');
      }
    }
    
    // 2) Handle subsequent links (warm/foreground)
    _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) async {
        debugPrint('🔗 DeepLinkHandler: Processing stream link: $uri');
        await _handleUri(uri);
      },
      onError: (e) {
        debugPrint('❌ DeepLinkHandler: Stream error: $e');
      },
    );
  }

  /// Process deep link URI with deduplication guard
  Future<void> _handleUri(Uri uri) async {
    debugPrint('[DL] Processing URI: $uri');
    
    // Extract code for deduplication check
    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      // Deduplication guard #1: Time-based debouncing (300ms)
      final now = DateTime.now();
      if (now.difference(_lastProcessed) < const Duration(milliseconds: 300)) {
        debugPrint('[DL] Debounced code=${code.length > 8 ? code.substring(0, 8) + '...' : code}');
        return;
      }
      _lastProcessed = now;
      
      // Deduplication guard #2: In-flight processing check
      if (_inFlight.contains(code)) {
        debugPrint('[DL] Already processing code=${code.length > 8 ? code.substring(0, 8) + '...' : code}');
        return;
      }
      
      debugPrint('[DL] Processing code=${code.length > 8 ? code.substring(0, 8) + '...' : code}');
      _inFlight.add(code);
    }
    
    // Get current route context for debugging
    try {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        debugPrint('[DL] Navigation context available');
      }
    } catch (e) {
      debugPrint('[DL] Could not get current route: $e');
    }
    
    try {
      // Process the magic link (will be wrapped in finally for cleanup)
      await _processAuthLink(uri);
    } catch (e, st) {
      debugPrint('[DL] Exception handling URI: $e');
      debugPrint('[DL] Stack trace: $st');
    } finally {
      // Always cleanup in-flight tracking
      if (code != null && code.isNotEmpty) {
        _inFlight.remove(code);
      }
    }
  }
  
  /// Actual magic link processing logic
  Future<void> _processAuthLink(Uri uri) async {
    // Robust HTTPS + custom scheme parsing with explicit logging
    // Accept either:
    // 1) https://ufobeep.com/api/auth/magic/complete/new?code=...   (HTTPS App Link; code-only)
    // 2) ufobeep://auth/complete?token=...&user_id=...&username=... (custom scheme; full data)
      
      final isHttps = uri.scheme == 'https' && uri.host == 'ufobeep.com';
      // Some backends append trailing segments or slash; accept prefix
      final isHttpsMagic = isHttps && uri.path.startsWith('/api/auth/magic');
      final isCustom = uri.scheme == 'ufobeep' && uri.host == 'auth' && uri.path == '/complete';

      debugPrint('[DeepLink] Analysis: isHttps=$isHttps, isHttpsMagic=$isHttpsMagic, isCustom=$isCustom');

      if (isCustom) {
        final qp = uri.queryParameters;
        final code = qp['code'];  // NEW: Look for authorization code first
        final token = qp['token']; // LEGACY: Still check for token
        final userId = qp['user_id'];
        final username = qp['username'];
        final email = qp['email'];
        
        debugPrint('[DeepLink] Custom scheme detected');
        debugPrint('[DeepLink] code=${code != null ? "${code.substring(0, code.length.clamp(0, 8))}..." : "null"}');
        debugPrint('[DeepLink] token=${token != null ? "${token.substring(0, token.length.clamp(0, 20))}..." : "null"} (legacy)');
        debugPrint('[DeepLink] user_id=$userId');
        debugPrint('[DeepLink] username=$username');
        debugPrint('[DeepLink] email=$email');
        
        // NEW: Handle authorization code flow (preferred)
        if (code != null && code.isNotEmpty) {
          debugPrint('[DeepLink] Using NEW authorization code flow');
          await authService.beginProcessingLink();
          final success = await authService.loginWithMagicCode(code: code);
          debugPrint('[DeepLink] Authorization code exchange result: $success');
          
          if (success) {
            _navigateToMainApp();
          }
          return;
        }
        
        // LEGACY: Handle old token flow (backward compatibility)
        if (token != null && userId != null && username != null) {
          debugPrint('[DeepLink] Using LEGACY token flow (deprecated)');
          await authService.beginProcessingLink();
          final success = await authService.loginWithMagicToken(
            token: token,
            userId: userId,
            username: username,
          );
          debugPrint('[DeepLink] Legacy token login result: $success');
          
          if (success) {
            _navigateToMainApp();
          }
          return;
        }
        
        debugPrint('[DeepLink][WARN] Missing required params in custom scheme link.');
        return;
      }

      if (isHttpsMagic) {
        // Enhanced code-based HTTPS handling
        final code = uri.queryParameters['code'];
        final token = uri.queryParameters['token']; // Legacy fallback
        
        debugPrint('[DeepLink] HTTPS App Link detected');
        debugPrint('[DeepLink] code present? ${code != null}');
        debugPrint('[DeepLink] token present? ${token != null} (legacy)');
        
        if (code != null && code.isNotEmpty) {
          // NEW: Direct code exchange without GoRouter complexity
          debugPrint('[DeepLink] 🔗 HTTPS magic link with authorization code detected');
          debugPrint('[DeepLink] 🔗 Processing code exchange directly');
          
          await authService.beginProcessingLink();
          final success = await authService.loginWithMagicCode(code: code);
          debugPrint('[DeepLink] 🔗 Authorization code exchange result: $success');
          
          if (success) {
            _navigateToMainApp();
          }
          return;
        } else if (token != null && token.isNotEmpty) {
          // LEGACY: Direct JWT token flow (deprecated)
          debugPrint('[DeepLink] Using legacy JWT token flow (deprecated)');
          debugPrint('[DeepLink] token length: ${token.length}');
          
          // Try using token as code (backward compatibility)
          await authService.beginProcessingLink();
          final success = await authService.loginWithMagicCode(code: token);
          debugPrint('[DeepLink] Legacy token->code exchange result: $success');
          
          if (success) {
            _navigateToMainApp();
          }
          return;
        } else {
          debugPrint('[DeepLink][ERROR] No code or token in HTTPS magic link.');
          return;
        }
      }

    debugPrint('[DL] Ignored URI (not magic auth): $uri');
  }

  /// Navigate to main app after successful authentication (ChatGPT's approach)
  void _navigateToMainApp() {
    debugPrint('[DeepLink] 🔗 NAV_DEBUG: Starting navigation to main app after successful authentication');
    
    // Use ChatGPT's recommended post-frame callback approach to avoid navigation timing issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        debugPrint('[DeepLink] 🔗 NAV_DEBUG: Post-frame callback executing');
        // Get the current context from the global navigator
        final context = rootNavigatorKey.currentContext;
        debugPrint('[DeepLink] 🔗 NAV_DEBUG: Context available: ${context != null}');
        debugPrint('[DeepLink] 🔗 NAV_DEBUG: Context mounted: ${context?.mounted}');
        
        if (context != null && context.mounted) {
          debugPrint('[DeepLink] 🔗 NAV_DEBUG: Using GoRouter to navigate to /alerts');
          context.go('/alerts');
          debugPrint('[DeepLink] 🔗 NAV_DEBUG: Navigation to /alerts completed successfully');
        } else {
          debugPrint('[DeepLink][WARN] 🔗 NAV_DEBUG: Navigation context not available or not mounted');
        }
      } catch (e, stackTrace) {
        debugPrint('[DeepLink][ERROR] 🔗 NAV_DEBUG: Navigation failed: $e');
        debugPrint('[DeepLink][ERROR] 🔗 NAV_DEBUG: Stack trace: $stackTrace');
      }
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}