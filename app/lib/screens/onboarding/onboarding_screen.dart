import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 4;

  // Solid blue theme colors (no opacity/blur)
  static const Color _backgroundColor = Color(0xFF0A0F2C); // Solid dark navy
  static const Color _titleColor = Color(0xFFFFFFFF); // Bright white
  static const Color _accentColor = Color(0xFF4CC9F0); // Neon blue
  static const Color _bodyTextColor = Color(0xFFB8BCC8); // Light gray

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);

    if (mounted) {
      context.go('/sign-in');
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Main content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildSlide1(),
                    _buildSlide2(),
                    _buildSlide3(),
                    _buildSlide4(),
                  ],
                ),
              ),

              // Bottom navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide1() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large UFO icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor.withOpacity(0.1),
              border: Border.all(color: _accentColor, width: 3),
            ),
            child: const Center(
              child: Text(
                '🛸',
                style: TextStyle(fontSize: 120),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            AppLocalizations.of(context)!.onboardingWelcomeTitle,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Body text
          Text(
            AppLocalizations.of(context)!.onboardingWelcomeBody,
            style: const TextStyle(
              color: _bodyTextColor,
              fontSize: 18,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera/reporting icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor.withOpacity(0.1),
              border: Border.all(color: _accentColor, width: 3),
            ),
            child: const Center(
              child: Icon(
                Icons.camera_alt,
                size: 100,
                color: _accentColor,
              ),
            ),
          ),

          const SizedBox(height: 40),

          Text(
            AppLocalizations.of(context)!.onboardingReportTitle,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.of(context)!.onboardingReportBody,
            style: const TextStyle(
              color: _bodyTextColor,
              fontSize: 18,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSlide3() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Compass/navigation icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor.withOpacity(0.1),
              border: Border.all(color: _accentColor, width: 3),
            ),
            child: const Center(
              child: Icon(
                Icons.explore,
                size: 100,
                color: _accentColor,
              ),
            ),
          ),

          const SizedBox(height: 40),

          Text(
            AppLocalizations.of(context)!.onboardingCompassTitle,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.of(context)!.onboardingCompassBody,
            style: const TextStyle(
              color: _bodyTextColor,
              fontSize: 18,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSlide4() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Community/globe icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor.withOpacity(0.1),
              border: Border.all(color: _accentColor, width: 3),
            ),
            child: const Center(
              child: Icon(
                Icons.public,
                size: 100,
                color: _accentColor,
              ),
            ),
          ),

          const SizedBox(height: 40),

          Text(
            AppLocalizations.of(context)!.onboardingCommunityTitle,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.of(context)!.onboardingCommunityBody,
            style: const TextStyle(
              color: _bodyTextColor,
              fontSize: 18,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (_currentPage > 0)
            OutlinedButton.icon(
              onPressed: _previousPage,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(AppLocalizations.of(context)!.back),
              style: OutlinedButton.styleFrom(
                foregroundColor: _accentColor,
                side: BorderSide(color: _accentColor, width: 2),
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
          else
            const SizedBox(width: 100),

          // Page indicators
          Row(
            children: List.generate(_totalPages, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? _accentColor : _accentColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          // Next/Skip/Get Started button
          if (_currentPage < _totalPages - 1)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Skip button
                TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    AppLocalizations.of(context)!.skip,
                    style: TextStyle(
                      color: _bodyTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Next button
                ElevatedButton.icon(
                  onPressed: _nextPage,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(AppLocalizations.of(context)!.next),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: _backgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            )
          else
            // Get Started button (final slide)
            ElevatedButton.icon(
              onPressed: _completeOnboarding,
              icon: const Icon(Icons.check, size: 18),
              label: Text(AppLocalizations.of(context)!.getStarted),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: _backgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }
}

// Static method to check if onboarding is needed
class OnboardingService {
  static const String _onboardingKey = 'onboardingDone';

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, false);
  }
}