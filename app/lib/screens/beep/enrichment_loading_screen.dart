import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../services/sound_service.dart';
import '../../services/api_client.dart';
import '../../widgets/glass_card.dart';

class EnrichmentLoadingScreen extends ConsumerStatefulWidget {
  final String beepId;
  final VoidCallback onComplete;

  const EnrichmentLoadingScreen({
    Key? key,
    required this.beepId,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<EnrichmentLoadingScreen> createState() => _EnrichmentLoadingScreenState();
}

class _EnrichmentLoadingScreenState extends ConsumerState<EnrichmentLoadingScreen>
    with TickerProviderStateMixin {

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Map<String, bool> _processorStatus = {
    'weather': false,
    'geocoding': false,
    'aircraft_tracking': false,
    'satellites': false,
    'celestial': false,
  };

  double _overallProgress = 0.0;
  String _currentProcessor = 'weather';
  bool _showContinueButton = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Show continue button after 2 seconds (escape hatch if it hangs)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showContinueButton = true);
    });

    // Start checking enrichment status
    _checkEnrichmentProgress();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkEnrichmentProgress() async {
    // Poll the actual beep API to check real enrichment completion
    int attempts = 0;
    const maxAttempts = 30; // 15 seconds max wait (500ms per attempt)

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;

      try {
        // Fetch actual beep data from API
        final beepData = await ApiClient.instance.getAlertDetails(widget.beepId);
        final enrichment = beepData['enrichment_data'] as Map<String, dynamic>? ?? {};

        // Check which processors have completed by looking at actual data
        final hasWeather = enrichment['weather'] != null;
        final hasGeocoding = enrichment['geocoding'] != null;
        final hasAircraft = enrichment['aircraft_tracking'] != null;
        final hasSatellites = enrichment['satellites'] != null;
        final hasCelestial = enrichment['celestial'] != null &&
                            enrichment['celestial']['processing'] != true;

        // Update status for completed processors
        if (hasWeather && !_processorStatus['weather']!) {
          _markProcessorComplete('weather');
        }
        if (hasGeocoding && !_processorStatus['geocoding']!) {
          _markProcessorComplete('geocoding');
        }
        if (hasAircraft && !_processorStatus['aircraft_tracking']!) {
          _markProcessorComplete('aircraft_tracking');
        }
        if (hasSatellites && !_processorStatus['satellites']!) {
          _markProcessorComplete('satellites');
        }
        if (hasCelestial && !_processorStatus['celestial']!) {
          _markProcessorComplete('celestial');
        }

        // Check if all critical processors completed (weather + geocoding minimum)
        final criticalComplete = hasWeather && hasGeocoding;
        final allComplete = _processorStatus.values.every((status) => status);

        if (allComplete || (criticalComplete && attempts >= 20)) {
          // All done or critical data ready and waited long enough
          widget.onComplete();
          return;
        }
      } catch (e) {
        debugPrint('Error checking enrichment progress: $e');
        // Continue polling even if request fails
      }
    }

    // Timeout after 15 seconds - show beep anyway
    if (mounted) {
      debugPrint('Enrichment polling timeout - showing beep with partial data');
      widget.onComplete();
    }
  }

  void _markProcessorComplete(String processorName) {
    setState(() {
      _processorStatus[processorName] = true;
      _overallProgress = _processorStatus.values.where((status) => status).length / _processorStatus.length;
      _currentProcessor = _getNextProcessor();
    });

    // SoundService.I.play(AlertSound.tap);
  }

  String _getNextProcessor() {
    for (var entry in _processorStatus.entries) {
      if (!entry.value) return entry.key;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing UFO icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: const Icon(
                      Icons.blur_circular,
                      size: 80,
                      color: AppColors.brandPrimary,
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                l10n.processingAlert,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                l10n.analyzingEnvironment,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Progress bar
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _overallProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Processor status list
              Column(
                children: [
                  _buildProcessorItem('weather', '🌤️ ${l10n.weatherAnalysis}', _processorStatus['weather']!),
                  _buildProcessorItem('geocoding', '📍 ${l10n.locationAnalysis}', _processorStatus['geocoding']!),
                  _buildProcessorItem('aircraft_tracking', '✈️ ${l10n.aircraftTracking}', _processorStatus['aircraft_tracking']!),
                  _buildProcessorItem('satellites', '🛰️ ${l10n.satelliteAnalysis}', _processorStatus['satellites']!),
                  _buildProcessorItem('celestial', '🌙 ${l10n.celestialAnalysis}', _processorStatus['celestial']!),
                ],
              ),

              const SizedBox(height: 24),

              // Current processor indicator
              if (_currentProcessor.isNotEmpty && !_showContinueButton)
                Text(
                  l10n.analyzing(_getProcessorDisplayName(_currentProcessor)),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.brandPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),

              const SizedBox(height: 48),

              // Continue button after timeout (appears below all processors)
              if (_showContinueButton)
                TextButton(
                  onPressed: () => widget.onComplete(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    l10n.splashContinue,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.brandPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildProcessorItem(String processorName, String displayName, bool isComplete) {
    final isActive = _currentProcessor == processorName && !isComplete;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isComplete
                ? const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                    key: ValueKey('complete'),
                  )
                : isActive
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                        ),
                        key: ValueKey('loading'),
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        color: AppColors.textTertiary,
                        size: 20,
                        key: ValueKey('waiting'),
                      ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 16,
                color: isComplete
                    ? AppColors.success
                    : isActive
                        ? AppColors.brandPrimary
                        : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getProcessorDisplayName(String processorName) {
    final l10n = AppLocalizations.of(context)!;
    switch (processorName) {
      case 'weather': return l10n.processorWeather;
      case 'geocoding': return l10n.processorLocation;
      case 'aircraft_tracking': return l10n.processorAircraft;
      case 'satellites': return l10n.processorSatellites;
      case 'celestial': return l10n.processorCelestial;
      default: return processorName;
    }
  }
}