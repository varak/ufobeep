import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';

import '../../providers/alerts_provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/alert_title_utils.dart';
import '../../widgets/alert_sections/alert_hero_section.dart';
import '../../widgets/alert_sections/alert_details_section.dart';
import '../../widgets/alert_sections/alert_direction_section.dart';
import '../../widgets/alert_sections/alert_actions_section.dart';
import '../../widgets/video_player_widget.dart';
import '../../widgets/enrichment/enrichment_section.dart';
import '../../services/beep_service.dart';
import '../../services/user_service.dart';
import '../../services/api_client.dart';
import '../../services/ui_feedback.dart';
import '../../widgets/glass_card.dart';

class AlertDetailScreen extends ConsumerStatefulWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  String? _currentUserDeviceId;
  bool _isWitnessConfirmed = false;
  bool _isFollowing = false;
  bool _followingLoading = false;

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
        final deviceId = await beepService.getOrCreateDeviceId();
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
        
        // Check follow status for comments
        await _checkFollowStatus();
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
  
  Future<void> _checkFollowStatus() async {
    try {
      final response = await ApiClient.dio.get('/alerts/${widget.alertId}/follow');
      if (mounted) {
        setState(() {
          _isFollowing = response.data['following'] ?? false;
        });
      }
    } catch (e) {
      print('Error checking follow status: $e');
      // Assume not following if error
    }
  }
  
  Future<void> _toggleFollow() async {
    if (_followingLoading) return;
    
    setState(() {
      _followingLoading = true;
    });
    
    try {
      if (_isFollowing) {
        await ApiClient.dio.delete('/alerts/${widget.alertId}/follow');
        setState(() {
          _isFollowing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unfollowed alert - no more comment notifications'),
              backgroundColor: AppColors.textSecondary,
            ),
          );
        }
      } else {
        await ApiClient.dio.post('/alerts/${widget.alertId}/follow');
        setState(() {
          _isFollowing = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Following alert - you\'ll get comment notifications'),
              backgroundColor: AppColors.brandPrimary,
            ),
          );
        }
      }
    } catch (e) {
      print('Error toggling follow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _followingLoading = false;
        });
      }
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
        
        return NightSkyBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(AlertTitleUtils.getContextualTitleFromAlert(alert)),
              backgroundColor: Colors.transparent,
              elevation: 0,
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
                  onMediaTap: (index) => _showFullscreenImage(alert, index),
                ),
                const SizedBox(height: 24),
                
                // Alert details
                AlertDetailsSection(alert: alert),
                const SizedBox(height: 24),
                
                // Direction and compass - hidden for MUFON alerts
                if (alert.source != 'mufon') ...[
                  AlertDirectionSection(
                    alert: alert,
                    onNavigate: (bearing, distance) => _navigateToSighting(alert, bearing, distance),
                    onShowMap: (userLocation, alert) => _showMapView(userLocation, alert),
                  ),
                  const SizedBox(height: 24),
                ],

                // Environmental context (if available) - hidden for MUFON alerts
                if (alert.enrichment != null && alert.enrichment!.isNotEmpty && alert.source != 'mufon') ...[
                  EnrichmentSection(
                    enrichmentData: alert.enrichment,
                    alertCreatorDeviceId: alert.reporterId,
                    currentUserDeviceId: _currentUserDeviceId,
                    isWitnessConfirmed: _isWitnessConfirmed,
                    alertSource: alert.source,
                    reporterUsername: alert.username,
                  ),
                  const SizedBox(height: 24),
                ],

                // Photo analysis (if available) 
                if (alert.photoAnalysis != null && alert.photoAnalysis!.isNotEmpty) ...[
                  _buildPhotoAnalysisSection(alert),
                  const SizedBox(height: 24),
                ],

                // Action buttons (including witness confirmation) - hidden for MUFON alerts
                if (alert.source != 'mufon') ...[
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
                      // Also refresh the alert data to update witness count display
                    ref.invalidate(alertByIdProvider(widget.alertId));
                  },
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Follow toggle for comment notifications
                _buildFollowSection(),
                const SizedBox(height: 16),
                
                // Comments section
                _buildCommentsSection(alert),
              ],
            ),
          ),
        ), // Scaffold
        ); // NightSkyBackground
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

  void _showFullscreenImage(Alert alert, [int startIndex = 0]) {
    if (alert.mediaFiles.isEmpty) return;
    
    final media = alert.mediaFiles[startIndex];
    final mediaUrl = media['url'] as String? ?? '';
    final mediaType = media['type'] as String? ?? 'image';
    
    if (mediaUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: _buildFullscreenMediaContent(mediaUrl, mediaType),
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

  Widget _buildFullscreenMediaContent(String mediaUrl, String mediaType) {
    if (mediaType == 'video') {
      // For videos, use VideoPlayerWidget in fullscreen
      return VideoPlayerWidget(
        videoUrl: mediaUrl,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      // For images, use InteractiveViewer for zoom functionality
      return InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          mediaUrl,
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
      );
    }
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

  Future<void> _pickFromGalleryForAlert(String alertId) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true, // Enable multiple file selection
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      // Close the modal
      Navigator.of(context).pop();

      // Navigate to multi-file upload screen
      context.push('/beep/multi-upload', extra: {
        'files': result.files,
        'alertId': alertId,
      });

    } catch (e) {
      debugPrint('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick files: $e')),
      );
    }
  }

  void _refreshAlert() {
    // Refresh the alert data after media upload
    ref.refresh(alertByIdProvider(widget.alertId));
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
              AppLocalizations.of(context).edit,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).beepExplain,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    onTap: () async {
                      await UiFeedback.click();
                      Navigator.pop(context);
                      context.push('/beep/camera', extra: {
                        'attachToSightingId': alertId,
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).capturePhoto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassCard(
                    onTap: () async {
                      await UiFeedback.click();
                      Navigator.pop(context);
                      await _pickFromGalleryForAlert(alertId);
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).pickFromGallery,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context).cancel,
                style: const TextStyle(color: AppColors.textSecondary),
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
  
  Widget _buildFollowSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _isFollowing ? Icons.notifications : Icons.notifications_outlined,
            color: _isFollowing ? AppColors.brandPrimary : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isFollowing ? 'Following this alert' : 'Follow for notifications',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isFollowing 
                    ? 'You\'ll get notified of new comments'
                    : 'Get notified when someone comments',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_followingLoading) 
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandPrimary,
              ),
            )
          else
            Switch(
              value: _isFollowing,
              onChanged: (_) => _toggleFollow(),
              activeColor: AppColors.brandPrimary,
            ),
        ],
      ),
    );
  }
  
  Widget _buildCommentsSection(Alert alert) {
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
              Icon(Icons.chat_bubble_outline, color: AppColors.brandPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                'Discussion',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Join the conversation about this sighting',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _navigateToComments(alert),
              icon: const Icon(Icons.comment, size: 18),
              label: Text(
                alert.commentCount > 0 
                  ? 'View Comments (${alert.commentCount})'
                  : 'Add Comment'
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandPrimary,
                side: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToComments(Alert alert) async {
    await UiFeedback.click();
    
    final alertTitle = AlertTitleUtils.getContextualTitleFromAlert(alert);
    final uri = Uri(path: '/alert/${alert.id}/comments', queryParameters: {
      'title': alertTitle,
    });
    
    if (mounted) {
      context.go(uri.toString());
    }
  }
}
