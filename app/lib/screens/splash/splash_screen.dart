import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../config/environment.dart';
import '../../providers/app_state.dart';
import '../../providers/initialization_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../services/initialization_service.dart';
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
        
        // Navigate based on user registration status
        await _navigateToNextScreen();
      } else {
        // Handle initialization failure
        _showInitializationError(initResult?.error ?? 'Unknown initialization error');
      }
    } catch (e) {
      _showInitializationError(e.toString());
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;
    
    // Check if user is registered
    final isRegistered = ref.read(isRegisteredProvider);
    
    if (isRegistered) {
      // Navigate to main app
      context.go('/');
    } else {
      // Navigate to registration/onboarding
      context.go('/register');
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
              context.go('/');
            },
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    ref.read(initializationProvider.notifier).reset();
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    final initStep = ref.watch(initializationStepProvider);
    final initProgress = ref.watch(initializationProgressProvider);
    final initMessage = ref.watch(initializationMessageProvider);
    final hasError = ref.watch(hasInitializationErrorProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Header with app branding
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Name
                      Text(
                        AppEnvironment.appName,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Version
                      Text(
                        'v${AppEnvironment.appVersion}',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Tagline
                      Text(
                        'Real-time sighting alerts',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Loading animation and progress
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      
                      // Step indicator (only in debug mode)
                      if (AppEnvironment.debugMode)
                        InitializationStepIndicator(
                          currentStep: initStep.when(
                            data: (step) => step,
                            loading: () => InitializationStep.environment,
                            error: (_, __) => InitializationStep.environment,
                          ),
                          hasError: hasError,
                        ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              Expanded(
                flex: 1,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (AppEnvironment.debugMode) ...[
                        Text(
                          'Environment: ${AppEnvironment.current.name}',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const Text(
                        'Initializing...',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}