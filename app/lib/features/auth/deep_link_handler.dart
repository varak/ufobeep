import 'dart:async';
import 'package:flutter/foundation.dart';
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

  /// Process deep link URI - ChatGPT's comprehensive logging approach
  Future<void> _handleUri(Uri uri) async {
    debugPrint('[DeepLink] 🔗 DEEP_LINK_DEBUG: Received URI: $uri');
    debugPrint('[DeepLink] 🔗 DEEP_LINK_DEBUG: Scheme: ${uri.scheme}');
    debugPrint('[DeepLink] 🔗 DEEP_LINK_DEBUG: Host: ${uri.host}');
    debugPrint('[DeepLink] 🔗 DEEP_LINK_DEBUG: Path: ${uri.path}');
    debugPrint('[DeepLink] 🔗 DEEP_LINK_DEBUG: Query Parameters: ${uri.queryParameters}');
    
    // Get current route context for debugging
    try {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        debugPrint('[DeepLink] 🔗 DEEP_LINK_DEBUG: Navigation context available');
      }
    } catch (e) {
      debugPrint('[DeepLink] 🔗 DEEP_LINK_DEBUG: Could not get current route: $e');
    }
    
    try {
      // Robust HTTPS + custom scheme parsing with explicit logging
      // Accept either:
      // 1) https://api.ufobeep.com/auth/magic/complete/new?code=...   (HTTPS App Link; code-only)
      // 2) ufobeep://auth/complete?token=...&user_id=...&username=... (custom scheme; full data)
      
      final isHttps = uri.scheme == 'https' && uri.host == 'api.ufobeep.com';
      // Some backends append trailing segments or slash; accept prefix
      final isHttpsMagic = isHttps && uri.path.startsWith('/auth/magic');
      final isCustom = uri.scheme == 'ufobeep' && uri.host == 'auth' && uri.path == '/complete';

      debugPrint('[DeepLink] Analysis: isHttps=$isHttps, isHttpsMagic=$isHttpsMagic, isCustom=$isCustom');

      if (isCustom) {
        final qp = uri.queryParameters;
        final token = qp['token'];
        final userId = qp['user_id'];
        final username = qp['username'];
        final email = qp['email'];
        
        debugPrint('[DeepLink] Custom scheme detected');
        debugPrint('[DeepLink] token=${token != null ? "${token.substring(0, 20)}..." : "null"}');
        debugPrint('[DeepLink] user_id=$userId');
        debugPrint('[DeepLink] username=$username');
        debugPrint('[DeepLink] email=$email');
        
        if (token == null || userId == null || username == null) {
          debugPrint('[DeepLink][WARN] Missing params in custom scheme link.');
          return;
        }
        
        debugPrint('[DeepLink] Calling loginWithMagicToken with full data');
        await authService.beginProcessingLink();
        final success = await authService.loginWithMagicToken(
          token: token,
          userId: userId,
          username: username,
        );
        debugPrint('[DeepLink] Custom scheme login result: $success');
        
        // ChatGPT's navigation approach: navigate after successful auth
        if (success) {
          _navigateToMainApp();
        }
        return;
      }

      if (isHttpsMagic) {
        // Enhanced dual-mode HTTPS handling (ChatGPT's Phase 2 solution)
        final code = uri.queryParameters['code'];
        final token = uri.queryParameters['token']; // Legacy fallback
        
        debugPrint('[DeepLink] HTTPS App Link detected');
        debugPrint('[DeepLink] code present? ${code != null}');
        debugPrint('[DeepLink] token present? ${token != null} (legacy)');
        
        if (code != null && code.isNotEmpty) {
          // Phase 2: Let GoRouter handle HTTPS links via redirect function
          debugPrint('[DeepLink] 🔗 PHASE_2_DEBUG: HTTPS magic link with code detected');
          debugPrint('[DeepLink] 🔗 PHASE_2_DEBUG: Letting GoRouter normalize via redirect function');
          debugPrint('[DeepLink] 🔗 PHASE_2_DEBUG: GoRouter will convert to /auth/magic?code=$code');
          
          // Navigate to the HTTPS URL - GoRouter redirect will normalize it
          final context = rootNavigatorKey.currentContext;
          if (context != null && context.mounted) {
            // Use the original HTTPS URL - GoRouter will redirect to internal route
            context.go(uri.toString());
            debugPrint('[DeepLink] 🔗 PHASE_2_DEBUG: Navigated to HTTPS URL for GoRouter processing');
          } else {
            debugPrint('[DeepLink][WARN] No context for GoRouter navigation');
          }
          return;
        } else if (token != null && token.isNotEmpty) {
          // LEGACY: Direct JWT token flow (bypass GoRouter for legacy support)
          debugPrint('[DeepLink] Using legacy JWT token flow (direct processing)');
          debugPrint('[DeepLink] token length: ${token.length}');
          
          await authService.beginProcessingLink();
          final success = await authService.loginWithMagicToken(token: token);
          debugPrint('[DeepLink] Legacy token login result: $success');
          
          if (success) {
            _navigateToMainApp();
          }
          return;
        } else {
          debugPrint('[DeepLink][ERROR] No code or token in HTTPS magic link.');
          return;
        }
      }

      debugPrint('[DeepLink] Ignored URI (not magic auth): $uri');
    } catch (e, st) {
      debugPrint('[DeepLink][ERROR] Exception handling URI: $e');
      debugPrint('[DeepLink][ERROR] Stack trace: $st');
    }
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