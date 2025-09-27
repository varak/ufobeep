import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';

class CameraFeaturesOnboarding extends StatefulWidget {
  const CameraFeaturesOnboarding({super.key});

  @override
  State<CameraFeaturesOnboarding> createState() => _CameraFeaturesOnboardingState();
}

class _CameraFeaturesOnboardingState extends State<CameraFeaturesOnboarding> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final OnboardingPage _cameraPage = OnboardingPage(
    icon: '📸',
    title: 'Camera Features',
    description: 'Master UFOBeep\'s camera tools for better evidence capture',
    features: [
      CameraFeature(
        icon: '⚡',
        title: 'Long Press → Camera',
        subtitle: 'Quick access when you spot something',
      ),
      CameraFeature(
        icon: '🔄',
        title: 'Switch Camera Views',
        subtitle: 'Front camera for video testimonials',
      ),
      CameraFeature(
        icon: '📱',
        title: 'Share to UFOBeep',
        subtitle: 'Gallery photos → automatic beep creation',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Camera Features',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildCameraFeaturesPage(_cameraPage),
            ),

            // Done button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  'Got It!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraFeaturesPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            page.icon,
            style: const TextStyle(fontSize: 80),
          ),

          const SizedBox(height: 32),

          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            page.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Camera features list
          ...page.features.map((feature) => _buildFeatureItem(feature)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(CameraFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                feature.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String icon;
  final String title;
  final String description;
  final List<CameraFeature> features;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
  });
}

class CameraFeature {
  final String icon;
  final String title;
  final String subtitle;

  CameraFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class NightSkyBackground extends StatelessWidget {
  final Widget child;

  const NightSkyBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.nightSkyTop,
            AppColors.nightSkyMiddle,
            AppColors.nightSkyBottom,
          ],
        ),
      ),
      child: child,
    );
  }
}