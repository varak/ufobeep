import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../config/environment.dart';
import '../../providers/app_state.dart';
import '../../providers/initialization_provider.dart';
import '../../services/auth_service.dart';
import '../../services/auth_repository.dart';
import '../../widgets/splash/loading_animation.dart';
import '../../l10n/app_localizations.dart';
import '../onboarding/onboarding_screen.dart';

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

    debugPrint('SPLASH DEBUG: Starting navigation flow');

    // Check if onboarding is needed first
    final onboardingCompleted = await OnboardingService.isOnboardingCompleted();
    if (!onboardingCompleted) {
      debugPrint('SPLASH DEBUG: Onboarding needed, navigating to onboarding');
      context.go('/onboarding');
      return;
    }

    debugPrint('SPLASH DEBUG: Onboarding complete, checking auth state');
    final authRepo = AuthRepository();
    
    // Wait for AuthRepository to be ready with timeout protection
    int waitAttempts = 0;
    const maxWaitAttempts = 30; // 3 seconds max wait (reduced to prevent hanging)
    const waitInterval = Duration(milliseconds: 100);

    while (!authRepo.isReady && waitAttempts < maxWaitAttempts) {
      if (authRepo.isHydrating) {
        debugPrint('SPLASH DEBUG: AuthRepository is hydrating, waiting... (${waitAttempts + 1}/$maxWaitAttempts)');
      } else if (!authRepo.isReady) {
        debugPrint('SPLASH DEBUG: AuthRepository not ready, waiting... (${waitAttempts + 1}/$maxWaitAttempts)');
      }

      await Future.delayed(waitInterval);
      waitAttempts++;

      if (!mounted) return;
    }
    
    if (!authRepo.isReady) {
      debugPrint('SPLASH DEBUG: AuthRepository failed to become ready after ${maxWaitAttempts * 100}ms, proceeding anyway');
    } else {
      debugPrint('SPLASH DEBUG: AuthRepository is ready after ${waitAttempts * 100}ms');
    }
    
    // Check authentication state from AuthRepository (single source of truth)
    final currentUser = authRepo.currentUser;
    
    if (currentUser != null && currentUser.username != null) {
      // User is fully authenticated with complete profile
      debugPrint('SPLASH DEBUG: Authenticated user found: ${currentUser.username}');
      debugPrint('SPLASH DEBUG: Navigating to /alerts');
      context.go('/alerts');
    } else if (currentUser != null && currentUser.username == null) {
      // User exists but needs username - send to registration
      debugPrint('SPLASH DEBUG: User exists but no username, going to registration');
      context.go('/register');
    } else {
      // User is not authenticated or auth state is invalid
      debugPrint('SPLASH DEBUG: No authenticated user found, going to sign-in');
      debugPrint('SPLASH DEBUG: AuthRepository isHydrating: ${authRepo.isHydrating}');
      
      // Only clear session if not currently hydrating (to avoid race condition with magic link auth)
      if (!authRepo.isHydrating) {
        try {
          await authRepo.clearSession();
          debugPrint('SPLASH DEBUG: Cleared stale session');
        } catch (e) {
          debugPrint('SPLASH DEBUG: Error clearing session: $e');
        }
      } else {
        debugPrint('SPLASH DEBUG: Skipping session clear - AuthRepository is hydrating');
      }
      
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
        title: Text(
          AppLocalizations.of(context)!.splashInitializationFailedTitle,
          style: TextStyle(color: AppColors.semanticError),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.splashInitializationError,
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
            child: Text(AppLocalizations.of(context)!.splashRetry),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/sign-in');
            },
            child: Text(AppLocalizations.of(context)!.splashContinue),
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
            child: Text(AppLocalizations.of(context)!.ok, style: const TextStyle(color: AppColors.brandPrimary)),
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
          AppLocalizations.of(context)!.splashTagline,
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
            loading: () => AppLocalizations.of(context)!.splashStartingUp,
            error: (_, __) => AppLocalizations.of(context)!.splashInitializationFailed,
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
        Text(
          AppLocalizations.of(context)!.splashInitializing,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}