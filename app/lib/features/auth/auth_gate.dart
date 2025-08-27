import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Authentication states for the app (legacy compatibility)
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Interface for providing authentication state (legacy compatibility)
abstract class AuthStateProvider {
  AuthStatus get status;
}

/// Streaming Authentication Gate that prevents race conditions
/// Shows loading state while processing magic links
/// Based on ChatGPT's architecture recommendations
class StreamingAuthGate extends StatefulWidget {
  final AuthService authService;

  const StreamingAuthGate({
    super.key,
    required this.authService,
  });

  @override
  State<StreamingAuthGate> createState() => _StreamingAuthGateState();
}

class _StreamingAuthGateState extends State<StreamingAuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: widget.authService.authStream,
      initialData: widget.authService.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? AuthState.unknown();
        
        switch (state.phase) {
          case AuthPhase.processingLink:
          case AuthPhase.unknown:
            return _buildLoadingScreen(
              state.phase == AuthPhase.processingLink 
                ? 'Processing magic link...' 
                : 'Loading...'
            );
            
          case AuthPhase.authenticated:
            // Navigate to main app
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.go('/alerts');
            });
            return _buildLoadingScreen('Redirecting...');
            
          case AuthPhase.unauthenticated:
            // Navigate to sign-in
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.go('/sign-in');
            });
            return _buildLoadingScreen('Redirecting to sign-in...');
        }
      },
    );
  }
  
  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.brandPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Legacy Authentication gate (for backward compatibility)
class AuthGate extends StatelessWidget {
  final AuthStateProvider auth;
  final Widget authenticated;
  final Widget unauthenticated;
  final Widget? loading;

  const AuthGate({
    super.key,
    required this.auth,
    required this.authenticated,
    required this.unauthenticated,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    switch (auth.status) {
      case AuthStatus.authenticated:
        return authenticated;
      case AuthStatus.unauthenticated:
        return unauthenticated;
      case AuthStatus.unknown:
      default:
        return loading ?? const Scaffold(
          backgroundColor: Color(0xFF1A1A1A), // Dark background to match app
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF00D4AA), // Brand color
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}