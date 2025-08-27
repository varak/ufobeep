import 'package:flutter/material.dart';

/// Authentication states for the app
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Interface for providing authentication state
abstract class AuthStateProvider {
  AuthStatus get status;
}

/// Authentication gate that routes based ONLY on auth state
/// NO anonymous/guest user creation - clean separation of concerns
/// Based on ChatGPT's architecture recommendations
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