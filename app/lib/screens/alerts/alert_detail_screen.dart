import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../../providers/alerts_provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/alert_title_utils.dart';
import '../../widgets/alert_sections/alert_hero_section.dart';
import '../../widgets/alert_sections/alert_details_section.dart';
import '../../widgets/alert_sections/alert_direction_section.dart';
import '../../widgets/alert_sections/alert_actions_section.dart';
import '../../widgets/enrichment/enrichment_section.dart';
import '../../services/anonymous_beep_service.dart';
import '../../services/user_service.dart';
import '../../services/api_client.dart';

class AlertDetailScreen extends ConsumerStatefulWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  String? _currentUserDeviceId;
  bool _isWitnessConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Get current user's ID (username-based system MP13-1)
    try {
      // Try to get user ID first, fallback to device ID for transition period
      String? userId;
      try {
        userId = await userService.getCurrentUserId();
        print('DEBUG: Loaded user ID: "$userId"');
      } catch (e) {
        // Fallback to device ID for users not yet migrated to username system
        final deviceId = await anonymousBeepService.getOrCreateDeviceId();
        print('DEBUG: Fallback to device ID: "$deviceId"');
        userId = deviceId;
      }
      
      if (mounted && userId != null) {
        setState(() {
          _currentUserDeviceId = userId; // Using same variable name during transition
        });
        print('DEBUG: Set _currentUserDeviceId to: "$_currentUserDeviceId"');
        
        // Check if this user is a confirmed witness
        await _checkWitnessStatus(userId);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _checkWitnessStatus(String deviceId) async {
    try {
      final result = await ApiClient.instance.getWitnessStatus(
        sightingId: widget.alertId,
        deviceId: deviceId,
      );
      
      if (mounted) {
        setState(() {
          _isWitnessConfirmed = result['data']?['has_confirmed'] ?? false;
        });
      }
    } catch (e) {
      print('Error checking witness status: $e');
      // Assume not confirmed if error
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertAsync = ref.watch(alertByIdProvider(widget.alertId));
    final appState = ref.watch(appStateProvider);
    final alertsAsync = ref.watch(alertsListProvider);

    return alertAsync.when(
      data: (alert) {
        if (alert == null) {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Alert')),
                  body: const Center(
                    child: CircularProgressIndicator(color: AppColors.brandPrimary),
                  ),
                );
              }
              return Scaffold(
                appBar: AppBar(title: const Text('Alert')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Alert not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(alertByIdProvider(widget.alertId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        print('DEBUG: Building alert detail for alert.reporterId: "${alert.reporterId}"');
        print('DEBUG: Current _currentUserDeviceId: "$_currentUserDeviceId"');
        
        return Scaffold(
          appBar: AppBar(
            title: Text(AlertTitleUtils.getContextualTitleFromAlert(alert)),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Share alert
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero section with media
                AlertHeroSection(
                  alert: alert,
                  onMediaTap: () => _showFullscreenImage(alert),
                ),
                const SizedBox(height: 24),
                
                // Alert details
                AlertDetailsSection(alert: alert),
                const SizedBox(height: 24),
                
                // Direction and compass
                AlertDirectionSection(
                  alert: alert,
                  onNavigate: (bearing, distance) => _navigateToSighting(alert, bearing, distance),
                  onShowMap: (userLocation, alert) => _showMapView(userLocation, alert),
                ),
                const SizedBox(height: 24),

                // Environmental context (if available)
                if (alert.enrichment != null && alert.enrichment!.isNotEmpty) ...[
                  EnrichmentSection(
                    enrichmentData: alert.enrichment,
                    alertCreatorDeviceId: alert.reporterId,
                    currentUserDeviceId: _currentUserDeviceId,
                    isWitnessConfirmed: _isWitnessConfirmed,
                  ),
                  const SizedBox(height: 24),
                ],

                // Photo analysis (if available) 
                if (alert.photoAnalysis != null && alert.photoAnalysis!.isNotEmpty) ...[
                  _buildPhotoAnalysisSection(alert),
                  const SizedBox(height: 24),
                ],

                // Action buttons (including witness confirmation)
                AlertActionsSection(
                  alert: alert,
                  currentUserDeviceId: _currentUserDeviceId,
                  onAddPhotos: () => _showAddPhotosDialog(widget.alertId),
                  onReportToMufon: () => _showMufonReportDialog(),
                  onWitnessConfirmed: (witnessCount) {
                    // Refresh witness status after confirmation
                    if (_currentUserDeviceId != null) {
                      _checkWitnessStatus(_currentUserDeviceId!);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Alert')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Alert')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.semanticError,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load alert',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(alertByIdProvider(widget.alertId)),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullscreenImage(Alert alert) {
    if (alert.mediaFiles.isEmpty) return;
    
    final media = alert.mediaFiles.first;
    final imageUrl = media['url'] as String? ?? '';
    
    if (imageUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.brandPrimary),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: AppColors.semanticError),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSighting(Alert alert, double bearing, double distance) {
    final targetName = AlertTitleUtils.getShortTitleFromAlert(alert);
    final compassParams = {
      'targetLat': alert.latitude.toString(),
      'targetLon': alert.longitude.toString(),
      'targetName': Uri.encodeComponent(targetName),
      'targetBearing': bearing.toStringAsFixed(1),
      'distance': distance.toStringAsFixed(1),
      'alertId': alert.id,
    };
    
    final uri = Uri(path: '/compass', queryParameters: compassParams);
    context.go(uri.toString());
  }

  void _showMapView(Position userLocation, Alert alert) {
    final targetName = AlertTitleUtils.getShortTitleFromAlert(alert);
    final mapParams = {
      'userLat': userLocation.latitude.toString(),
      'userLon': userLocation.longitude.toString(),
      'alertLat': alert.latitude.toString(),
      'alertLon': alert.longitude.toString(),
      'alertId': alert.id,
      'alertName': Uri.encodeComponent(targetName),
    };
    
    final uri = Uri(path: '/map', queryParameters: mapParams);
    context.go(uri.toString());
  }

  void _showAddPhotosDialog(String alertId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Photos & Videos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Additional photos will be attached to this sighting',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/beep?attachTo=$alertId');
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/beep?attachTo=$alertId&source=gallery');
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('From Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandPrimary,
                      side: const BorderSide(color: AppColors.brandPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMufonReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Row(
            children: [
              Icon(Icons.report_outlined, color: AppColors.brandPrimary),
              SizedBox(width: 8),
              Text('Report to MUFON'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About UFOBeep & MUFON',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'UFOBeep is designed for quick, real-time alerts to help witnesses connect and verify sightings instantly.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 12),
                Text(
                  'MUFON (Mutual UFO Network) is the world\'s oldest and largest UFO investigation organization. They collect detailed scientific reports and conduct thorough investigations.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16),
                Text(
                  'Why Report to MUFON?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Permanent scientific record\n'
                  '• Professional investigation\n'
                  '• Detailed witness testimony\n'
                  '• Contributing to UFO research\n'
                  '• Access to MUFON\'s global database',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16),
                Text(
                  'The MUFON report form will ask for detailed information about your sighting including time, duration, weather conditions, and a full description.',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                final Uri mufonUrl = Uri.parse('https://mufon.com/cms-ifo-info/');
                try {
                  await launchUrl(
                    mufonUrl, 
                    mode: LaunchMode.externalApplication,
                    webViewConfiguration: const WebViewConfiguration(
                      enableJavaScript: true,
                      enableDomStorage: true,
                    ),
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open MUFON website: $e'),
                        backgroundColor: AppColors.semanticError,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open MUFON Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  // Keep only essential legacy sections for environmental and photo analysis
  // These will be modularized later if needed

  Widget _buildPhotoAnalysisSection(Alert alert) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.photo, color: AppColors.brandPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                'Photo Analysis',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Analysis: ${alert.photoAnalysis!.length} photo${alert.photoAnalysis!.length == 1 ? '' : 's'} processed',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}