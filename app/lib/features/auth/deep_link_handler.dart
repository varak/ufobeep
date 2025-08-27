import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';

typedef MagicTokenHandler = Future<void> Function(Map<String, String> tokenData);

/// Centralized deep link handler that processes magic links BEFORE UI renders
/// Based on ChatGPT's architecture recommendations for clean separation of concerns
class DeepLinkHandler {
  final MagicTokenHandler onMagicToken;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _processedInitial = false;

  DeepLinkHandler({required this.onMagicToken});

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
    _linkSubscription = _appLinks.linkStream.listen(
      (uri) async {
        debugPrint('🔗 DeepLinkHandler: Processing stream link: $uri');
        await _handleUri(uri);
      },
      onError: (e) {
        debugPrint('❌ DeepLinkHandler: Stream error: $e');
      },
    );
  }

  /// Process deep link URI - focus only on magic link auth
  Future<void> _handleUri(Uri uri) async {
    try {
      debugPrint('🔍 DeepLinkHandler: Analyzing URI:');
      debugPrint('   Scheme: ${uri.scheme}');
      debugPrint('   Host: ${uri.host}');
      debugPrint('   Path: ${uri.path}');
      debugPrint('   Query: ${uri.queryParameters}');
      
      // Expected: ufobeep://auth/complete?token=...&user_id=...&username=...
      if (uri.scheme == 'ufobeep' && 
          uri.host == 'auth' && 
          uri.path == '/complete') {
        
        final queryParams = uri.queryParameters;
        final token = queryParams['token'];
        final userId = queryParams['user_id'];  
        final username = queryParams['username'];
        
        if (token != null && token.isNotEmpty && 
            userId != null && userId.isNotEmpty &&
            username != null && username.isNotEmpty) {
          
          debugPrint('✅ DeepLinkHandler: Valid magic link detected');
          debugPrint('   Token: ${token.substring(0, 20)}...');
          debugPrint('   User ID: $userId');
          debugPrint('   Username: $username');
          
          // Pass all auth data to handler
          await onMagicToken(queryParams);
        } else {
          debugPrint('❌ DeepLinkHandler: Magic link missing required parameters');
          debugPrint('   Token: ${token != null ? "present" : "missing"}');
          debugPrint('   User ID: ${userId != null ? "present" : "missing"}');  
          debugPrint('   Username: ${username != null ? "present" : "missing"}');
        }
      } else {
        // Ignore non-magic links
        debugPrint('ℹ️ DeepLinkHandler: Non-magic link ignored: ${uri.scheme}://${uri.host}${uri.path}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ DeepLinkHandler: Failed to parse deep link: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}