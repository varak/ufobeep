import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../config/environment.dart';
import '../../providers/app_state.dart';
import '../../providers/initialization_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/splash/loading_animation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Start the initialization process
      final initNotifier = ref.read(initializationProvider.notifier);
      await initNotifier.initialize();
      
      // Check if initialization was successful
      final initResult = ref.read(initializationProvider);
      if (initResult?.success == true) {
        // Mark app as initialized in global state
        ref.read(appStateProvider.notifier).setInitialized(true);
        
        // Small delay to show completion
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Navigate based on Firebase auth state only
        await _navigateBasedOnAuthState();
      } else {
        // Handle initialization failure
        _showInitializationError(initResult?.error ?? 'Unknown initialization error');
      }
    } catch (e) {
      _showInitializationError(e.toString());
    }
  }

  Future<void> _navigateBasedOnAuthState() async {
    if (!mounted) return;
    
    final currentUser = authService.currentUser;
    
    if (currentUser != null) {
      // User has Firebase auth - check if they have complete backend profile
      print('SPLASH DEBUG: Firebase user exists: ${currentUser.uid}');
      
      try {
        // Check if user has stored username (indicates complete profile)
        final prefs = await SharedPreferences.getInstance();
        final storedUsername = prefs.getString('username');
        final userPreferences = prefs.getString('user_preferences');
        
        print('SPLASH DEBUG: Stored username: $storedUsername');
        print('SPLASH DEBUG: User preferences exist: ${userPreferences != null}');
        
        if (storedUsername != null && storedUsername.isNotEmpty && userPreferences != null) {
          // User has complete profile, go to main app
          print('SPLASH DEBUG: Complete profile found, going to alerts');
          context.go('/alerts');
        } else {
          // Firebase user exists but no local profile - sign out and start fresh
          print('SPLASH DEBUG: Firebase user with no profile, clearing auth and going to sign-in');
          await authService.signOut();
          context.go('/sign-in');
        }
      } catch (e) {
        print('SPLASH DEBUG: Error checking profile: $e, clearing auth and going to sign-in');
        await authService.signOut();
        context.go('/sign-in');
      }
    } else {
      // User is unauthenticated, go to sign-in screen
      print('SPLASH DEBUG: No Firebase user, going to sign-in');
      context.go('/sign-in');
    }
  }

  void _showInitializationError(String error) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Initialization Failed',
          style: TextStyle(color: AppColors.semanticError),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The app failed to initialize properly:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.semanticError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.semanticError.withOpacity(0.3),
                ),
              ),
              child: Text(
                error,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryInitialization();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/sign-in');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    ref.read(initializationProvider.notifier).reset();
    _initializeApp();
  }


  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.brandPrimary),
            const SizedBox(width: 16),
            Text(
              message,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message, {VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.semanticError),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('OK', style: TextStyle(color: AppColors.brandPrimary)),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHeader(context),
                _buildLoadingSection(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          AppEnvironment.appName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.brandPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'v${AppEnvironment.appVersion}',
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Real-time sighting alerts',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    final initProgress = ref.watch(initializationProgressProvider);
    final initMessage = ref.watch(initializationMessageProvider);
    final hasError = ref.watch(hasInitializationErrorProvider);

    return Column(
      children: [
        LoadingAnimation(
          progress: initProgress.when(
            data: (progress) => progress,
            loading: () => 0.0,
            error: (_, __) => 0.0,
          ),
          message: initMessage.when(
            data: (message) => message,
            loading: () => 'Starting up...',
            error: (_, __) => 'Initialization failed',
          ),
          isError: hasError,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (AppEnvironment.debugMode) ...[
          Text(
            'Environment: ${AppEnvironment.current.name}',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
        ],
        const Text(
          'Initializing...',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}