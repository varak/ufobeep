import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/alerts_provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/video_player_widget.dart';
import '../../services/permission_service.dart';
import '../../services/api_client.dart';
import '../../services/anonymous_beep_service.dart';
import '../../services/sound_service.dart';
import '../../utils/alert_title_utils.dart';

class AlertDetailScreen extends ConsumerStatefulWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  bool _isConfirming = false;
  bool? _hasConfirmed;
  int _witnessCount = 0;
  
  /// Detect media type from URL if API type is missing or incorrect
  String _detectMediaTypeFromUrl(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.mp4') || lowerUrl.contains('.mov') || lowerUrl.contains('.avi')) {
      return 'video';
    }
    return 'image';
  }
  

  @override
  void initState() {
    super.initState();
    // Skip witness status check for now - it's causing hangs
    // _checkWitnessStatus();
  }

  Future<void> _checkWitnessStatus() async {
    try {
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      final status = await ApiClient.instance.getWitnessStatus(
        sightingId: widget.alertId,
        deviceId: deviceId,
      );
      
      if (mounted) {
        setState(() {
          _hasConfirmed = status['has_confirmed'] ?? false;
          _witnessCount = status['witness_count'] ?? 0;
        });
      }
    } catch (e) {
      // Silently fail - will show confirmation button by default
      print('Failed to check witness status: $e');
    }
  }

  Future<void> _confirmWitness() async {
    if (_isConfirming || _hasConfirmed == true) return;

    setState(() {
      _isConfirming = true;
    });

    try {
      // Check location permission
      if (!permissionService.locationGranted) {
        await permissionService.refreshPermissions();
        if (!permissionService.locationGranted) {
          _showPermissionDialog();
          return;
        }
      }

      // Get current location
      final position = await permissionService.getCurrentLocation();
      if (position == null) {
        _showLocationError();
        return;
      }

      // Play confirmation sound
      await SoundService.I.play(AlertSound.tap, haptic: true);

      // Get device ID
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();

      // Confirm witness
      final result = await ApiClient.instance.confirmWitness(
        sightingId: widget.alertId,
        deviceId: deviceId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        stillVisible: true,
      );

      if (mounted) {
        setState(() {
          _hasConfirmed = true;
          _witnessCount = result['data']['witness_count'] ?? _witnessCount + 1;
        });

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Witness confirmation recorded! ($_witnessCount total witnesses)'),
            backgroundColor: AppColors.semanticSuccess,
            duration: const Duration(seconds: 2),
          ),
        );

        // Play success sound
        await SoundService.I.play(AlertSound.tap);

        // If escalation was triggered, play appropriate sound
        if (result['data']['escalation_triggered'] == true) {
          final witnessCount = result['data']['witness_count'] ?? 0;
          if (witnessCount >= 10) {
            await SoundService.I.play(AlertSound.emergency, haptic: true);
          } else if (witnessCount >= 3) {
            await SoundService.I.play(AlertSound.urgent);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm witness: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Required'),
        content: const Text('UFOBeep needs your location to confirm you as a witness. Please grant location permission in Settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              permissionService.openPermissionSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to get your location. Please ensure GPS is enabled.'),
        backgroundColor: AppColors.semanticWarning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alertAsync = ref.watch(alertByIdProvider(widget.alertId));
    final appState = ref.watch(appStateProvider);
    final alertsAsync = ref.watch(alertsListProvider);

    return alertAsync.when(
      data: (alert) {
        if (alert == null) {
          // Simple 1-second delay before showing "not found" message
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

        return Scaffold(
          appBar: AppBar(
            title: Text(AlertTitleUtils.getContextualTitleFromAlert(alert)),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  context.go('/alert/${widget.alertId}/chat');
                },
              ),
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
                // Media section
                _buildMediaSection(alert),
                const SizedBox(height: 24),


                // Verification status only (remove redundant category)
                if (alert.isVerified)
                  Row(
                    children: [
                      Chip(
                        label: const Text('VERIFIED'),
                        backgroundColor: AppColors.brandPrimary.withOpacity(0.2),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Title - show date/time instead of repetitive "UFO Sighting"
                Text(
                  _formatDateTime(alert.createdAt),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),

                // Description - show actual description or contextual placeholder
                if (alert.description != null && alert.description!.isNotEmpty)
                  Text(
                    alert.description!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Text(
                    'Visual sighting captured with UFOBeep',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 24),


                const SizedBox(height: 24),

                // Location & Time Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.access_time,
                          label: 'Time',
                          value: _formatDateTime(alert.createdAt),
                        ),
                        if (alert.locationName != null)
                          _DetailRow(
                            icon: Icons.location_on,
                            label: 'Location',
                            value: alert.locationName!,
                          ),
                        if (alert.distance != null)
                          _DetailRow(
                            icon: Icons.straighten,
                            label: 'Distance',
                            value: '${alert.distance!.toStringAsFixed(1)} km',
                          ),
                        _DetailRow(
                          icon: Icons.place,
                          label: 'Coordinates',
                          value: '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mini compass section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Direction',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildMiniCompass(alert),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Enrichment Data Section (if available)
                if (alert.enrichment != null && alert.enrichment!.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Environmental Analysis',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          if (alert.enrichment!['weather'] != null) ...[
                            // Basic weather condition
                            _DetailRow(
                              icon: Icons.wb_sunny,
                              label: 'Weather',
                              value: '${alert.enrichment!['weather']['condition']} - ${alert.enrichment!['weather']['description']}',
                            ),
                            
                            // Temperature information
                            _DetailRow(
                              icon: Icons.thermostat,
                              label: 'Temperature',
                              value: '${alert.enrichment!['weather']['temperature']}°C (feels like ${alert.enrichment!['weather']['feels_like']}°C)',
                            ),
                            if (alert.enrichment!['weather']['dew_point'] != null)
                              _DetailRow(
                                icon: Icons.water_drop,
                                label: 'Dew Point',
                                value: '${alert.enrichment!['weather']['dew_point']}°C',
                              ),
                            
                            // Atmospheric conditions
                            _DetailRow(
                              icon: Icons.visibility,
                              label: 'Visibility',
                              value: '${alert.enrichment!['weather']['visibility']} km',
                            ),
                            _DetailRow(
                              icon: Icons.water,
                              label: 'Humidity',
                              value: '${alert.enrichment!['weather']['humidity']}%',
                            ),
                            _DetailRow(
                              icon: Icons.speed,
                              label: 'Pressure',
                              value: '${alert.enrichment!['weather']['pressure']} hPa',
                            ),
                            if (alert.enrichment!['weather']['cloud_coverage'] != null)
                              _DetailRow(
                                icon: Icons.cloud,
                                label: 'Cloud Cover',
                                value: '${alert.enrichment!['weather']['cloud_coverage']}%',
                              ),
                            if (alert.enrichment!['weather']['uv_index'] != null && alert.enrichment!['weather']['uv_index'] > 0)
                              _DetailRow(
                                icon: Icons.wb_sunny_outlined,
                                label: 'UV Index',
                                value: '${alert.enrichment!['weather']['uv_index']}',
                              ),
                            
                            // Wind information
                            if (alert.enrichment!['weather']['wind_speed'] != null && alert.enrichment!['weather']['wind_speed'] > 0) ...[
                              _DetailRow(
                                icon: Icons.air,
                                label: 'Wind',
                                value: '${(alert.enrichment!['weather']['wind_speed'] * 3.6).toStringAsFixed(1)} km/h ${_getWindDirection(alert.enrichment!['weather']['wind_direction'])}',
                              ),
                              if (alert.enrichment!['weather']['wind_gust'] != null && alert.enrichment!['weather']['wind_gust'] > 0)
                                _DetailRow(
                                  icon: Icons.tornado,
                                  label: 'Wind Gusts',
                                  value: '${(alert.enrichment!['weather']['wind_gust'] * 3.6).toStringAsFixed(1)} km/h',
                                ),
                            ],
                            
                            // Sun times (if available)
                            if (alert.enrichment!['weather']['sunrise'] != null && alert.enrichment!['weather']['sunset'] != null) ...[
                              _DetailRow(
                                icon: Icons.wb_twilight,
                                label: 'Sunrise',
                                value: _formatTimestamp(alert.enrichment!['weather']['sunrise']),
                              ),
                              _DetailRow(
                                icon: Icons.nights_stay,
                                label: 'Sunset',
                                value: _formatTimestamp(alert.enrichment!['weather']['sunset']),
                              ),
                            ],
                          ],
                          if (alert.enrichment!['plane_match'] != null) ...[
                            _DetailRow(
                              icon: Icons.flight,
                              label: 'Plane Analysis',
                              value: alert.enrichment!['plane_match']['is_plane'] == false 
                                  ? 'No aircraft detected (${(alert.enrichment!['plane_match']['confidence'] * 100).toStringAsFixed(0)}% confidence)'
                                  : 'Aircraft possible',
                            ),
                          ],
                          if (alert.enrichment!['celestial'] != null) ...[
                            _DetailRow(
                              icon: Icons.nightlight,
                              label: 'Moon Phase',
                              value: alert.enrichment!['celestial']['moon_phase_name'] ?? 'Unknown',
                            ),
                            if (alert.enrichment!['celestial']['visible_planets'] != null &&
                                (alert.enrichment!['celestial']['visible_planets'] as List).isNotEmpty)
                              _DetailRow(
                                icon: Icons.star,
                                label: 'Visible Planets',
                                value: (alert.enrichment!['celestial']['visible_planets'] as List).join(', '),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Photo Analysis Section (if available)
                if (alert.photoAnalysis != null && alert.photoAnalysis!.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photo Analysis',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          ...alert.photoAnalysis!.map((analysis) => _buildPhotoAnalysisItem(analysis)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Witness Confirmation - moved to bottom for prominence
                _buildWitnessConfirmationButton(alert),
                const SizedBox(height: 24),
                
                // Action Buttons
                Column(
                  children: [
                    // Chat button (full width)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.go('/alert/${widget.alertId}/chat');
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Join Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Add Photos button (full width)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddPhotosDialog(context, widget.alertId),
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Photos & Videos'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandPrimary,
                          side: const BorderSide(color: AppColors.brandPrimary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Report to MUFON button (full width)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showMufonReportDialog(context),
                        icon: const Icon(Icons.report_outlined),
                        label: const Text('Report to MUFON'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.textSecondary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildMediaSection(Alert alert) {
    if (alert.mediaFiles.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if no media
    }

    // Show first media file (image or video)
    final media = alert.mediaFiles.first;
    final apiType = media['type'] as String? ?? 'image';
    
    // Use web-optimized URL for better loading in detail view
    String mediaUrl = media['web_url'] as String? ?? media['url'] as String? ?? '';
    
    // For videos, use original URL as we may not have web-optimized video yet
    if (apiType == 'video') {
      mediaUrl = media['url'] as String? ?? '';
    }
    
    // Use API type if available and not 'image', otherwise detect from URL
    final mediaType = (apiType != 'image') ? apiType : _detectMediaTypeFromUrl(mediaUrl);
    
    if (mediaUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: AppColors.textTertiary),
              SizedBox(height: 8),
              Text('Media file unavailable', style: TextStyle(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => mediaType == 'video' ? null : _showFullscreenImage(context, media['url'] as String? ?? mediaUrl),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxHeight: 300,
              minHeight: 200,
            ),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: mediaType == 'video' 
                  ? VideoPlayerWidget(videoUrl: mediaUrl)
                  : Image.network(
                      mediaUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
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
                              Icon(Icons.error, size: 48, color: AppColors.semanticError),
                              SizedBox(height: 8),
                              Text('Failed to load image', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          ),
        ),
        if (alert.mediaFiles.length > 1) ...[
          const SizedBox(height: 8),
          Text(
            '+${alert.mediaFiles.length - 1} more media file${alert.mediaFiles.length > 2 ? 's' : ''}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }


  Widget _buildPhotoAnalysisItem(Map<String, dynamic> analysis) {
    final String status = analysis['analysis_status'] ?? 'pending';
    final String? classification = analysis['classification'];
    final String? matchedObject = analysis['matched_object'];
    final double? confidence = analysis['confidence']?.toDouble();
    final String filename = analysis['filename'] ?? 'Unknown file';
    final int? processingTime = analysis['processing_duration_ms'];
    
    // Status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'completed':
        statusColor = AppColors.brandPrimary;
        statusIcon = Icons.check_circle;
        statusText = 'Star/Planet Detection Complete';
        break;
      case 'pending':
        statusColor = AppColors.semanticWarning;
        statusIcon = Icons.pending;
        statusText = 'Star/Planet Detection Pending...';
        break;
      case 'failed':
        statusColor = AppColors.semanticError;
        statusIcon = Icons.error;
        statusText = 'Star/Planet Detection Failed';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.help;
        statusText = 'Unknown Status';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Icon(Icons.photo, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Photo Analysis',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (status == 'completed' && classification != null) ...[
            const SizedBox(height: 12),
            // Analysis results
            Row(
              children: [
                // Classification icon
                Icon(
                  classification == 'planet' ? Icons.brightness_2 :
                  classification == 'satellite' ? Icons.satellite_alt :
                  Icons.help_outline,
                  color: classification == 'planet' ? AppColors.brandPrimary :
                         classification == 'satellite' ? Colors.cyan :
                         AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (matchedObject != null) ...[
                        Text(
                          matchedObject,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${classification![0].toUpperCase()}${classification.substring(1)} detected',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ] else ...[
                        Text(
                          classification == 'inconclusive' ? 'No celestial objects detected' : 
                          classification == 'unknown' ? 'Analysis inconclusive' :
                          'Unidentified ${classification}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (confidence != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Confidence: ',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${(confidence * 100).toInt()}%',
                              style: TextStyle(
                                color: confidence > 0.8 ? AppColors.brandPrimary :
                                       confidence > 0.5 ? AppColors.semanticWarning :
                                       AppColors.semanticError,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
          
          if (status == 'failed') ...[
            const SizedBox(height: 8),
            Text(
              analysis['analysis_error'] ?? 'Analysis failed for unknown reason',
              style: const TextStyle(
                color: AppColors.semanticError,
                fontSize: 12,
              ),
            ),
          ],
          
          if (processingTime != null && status == 'completed') ...[
            const SizedBox(height: 8),
            Text(
              'Analysis completed in ${(processingTime / 1000).toStringAsFixed(1)}s',
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String _getWindDirection(dynamic windDirection) {
    if (windDirection == null) return '';
    
    final degrees = windDirection is num ? windDirection.toDouble() : double.tryParse(windDirection.toString()) ?? 0.0;
    
    if (degrees >= 348.75 || degrees < 11.25) return 'N';
    if (degrees >= 11.25 && degrees < 33.75) return 'NNE';
    if (degrees >= 33.75 && degrees < 56.25) return 'NE';
    if (degrees >= 56.25 && degrees < 78.75) return 'ENE';
    if (degrees >= 78.75 && degrees < 101.25) return 'E';
    if (degrees >= 101.25 && degrees < 123.75) return 'ESE';
    if (degrees >= 123.75 && degrees < 146.25) return 'SE';
    if (degrees >= 146.25 && degrees < 168.75) return 'SSE';
    if (degrees >= 168.75 && degrees < 191.25) return 'S';
    if (degrees >= 191.25 && degrees < 213.75) return 'SSW';
    if (degrees >= 213.75 && degrees < 236.25) return 'SW';
    if (degrees >= 236.25 && degrees < 258.75) return 'WSW';
    if (degrees >= 258.75 && degrees < 281.25) return 'W';
    if (degrees >= 281.25 && degrees < 303.75) return 'WNW';
    if (degrees >= 303.75 && degrees < 326.25) return 'NW';
    if (degrees >= 326.25 && degrees < 348.75) return 'NNW';
    
    return '';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      DateTime dateTime;
      
      if (timestamp is int) {
        // Unix timestamp
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      } else if (timestamp is String) {
        // ISO string
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'N/A';
      }
      
      // Format as time only (HH:MM)
      final hours = dateTime.hour.toString().padLeft(2, '0');
      final minutes = dateTime.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    } catch (e) {
      return 'N/A';
    }
  }

  void _showAddPhotosDialog(BuildContext context, String alertId) {
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
                      // Navigate to beep screen with context to attach to this alert
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
                      // Navigate to beep screen with gallery picker and context
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

  void _showMufonReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: Row(
            children: [
              const Icon(Icons.report_outlined, color: AppColors.brandPrimary),
              const SizedBox(width: 8),
              const Text('Report to MUFON'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
                if (await canLaunchUrl(mufonUrl)) {
                  await launchUrl(mufonUrl, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open MUFON website'),
                      backgroundColor: AppColors.semanticError,
                    ),
                  );
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

  void _showFullscreenImage(BuildContext context, String imageUrl) {
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

  Widget _buildWitnessConfirmationButton(Alert alert) {
    final witnessCount = _witnessCount > 0 ? _witnessCount : alert.witnessCount;
    
    if (_hasConfirmed == true) {
      // Already confirmed - show status
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.semanticSuccess.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.semanticSuccess.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              size: 24,
              color: AppColors.semanticSuccess,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ You confirmed this sighting',
                    style: TextStyle(
                      color: AppColors.semanticSuccess,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$witnessCount total witnesses',
                    style: const TextStyle(
                      color: AppColors.semanticSuccess,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show confirmation button
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isConfirming ? null : _confirmWitness,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPrimary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isConfirming
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Confirming witness...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.visibility,
                      size: 20,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'I SEE IT TOO! ($witnessCount witnesses)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMiniCompass(Alert alert) {
    return FutureBuilder<Position?>(
      future: permissionService.getCurrentLocation(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Row(
            children: [
              const Icon(Icons.explore, color: AppColors.textTertiary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Getting your location...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          );
        }

        final userLocation = snapshot.data!;
        final bearing = _calculateBearing(
          userLocation.latitude,
          userLocation.longitude,
          alert.latitude,
          alert.longitude,
        );
        final distance = alert.distance ?? _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          alert.latitude,
          alert.longitude,
        );

        return Row(
          children: [
            // Mini compass indicator
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkBorder, width: 2),
                color: AppColors.darkBackground,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass face with N/S/E/W markers
                  CustomPaint(
                    size: const Size(60, 60),
                    painter: _CompassFacePainter(),
                  ),
                  // Direction arrow pointing to sighting
                  Transform.rotate(
                    angle: bearing * math.pi / 180,
                    child: const Icon(
                      Icons.navigation,
                      color: AppColors.brandPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Direction info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getCardinalDirection(bearing)} (${bearing.toStringAsFixed(0)}°)',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${distance.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Navigate button
            OutlinedButton.icon(
              onPressed: () {
                _navigateToSighting(alert, bearing, distance);
              },
              icon: const Icon(Icons.explore, size: 16),
              label: const Text('Orient'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandPrimary,
                side: const BorderSide(color: AppColors.brandPrimary),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * math.pi / 180;
    final lat1Rad = lat1 * math.pi / 180;
    final lat2Rad = lat2 * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) - 
              math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
              math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  String _getCardinalDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
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
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.textTertiary;

    // Draw compass face circle
    canvas.drawCircle(center, radius, paint);

    // Draw cardinal direction markers
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // North
    textPainter.text = const TextSpan(
      text: 'N',
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - radius + 2));

    // South
    textPainter.text = const TextSpan(
      text: 'S',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w400,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy + radius - textPainter.height - 2));

    // East
    textPainter.text = const TextSpan(
      text: 'E',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w400,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx + radius - textPainter.width - 2, center.dy - textPainter.height / 2));

    // West
    textPainter.text = const TextSpan(
      text: 'W',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w400,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - radius + 2, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}