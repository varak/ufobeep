import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/alerts_provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_widget.dart';
import '../../services/permission_service.dart';

class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertAsync = ref.watch(alertByIdProvider(alertId));
    final appState = ref.watch(appStateProvider);
    final alertsAsync = ref.watch(alertsListProvider);

    return alertAsync.when(
      data: (alert) {
        if (alert == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alert')),
            body: const Center(
              child: Text('Alert not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(alert.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  context.go('/alert/$alertId/chat');
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

                // Live Sightings Map section
                _buildLiveSightingsMap(alert, alertsAsync),
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

                // Description - only show if it's not the default message
                if (alert.description != 'UFO sighting captured with UFOBeep app' && 
                    alert.description.isNotEmpty)
                  Text(
                    alert.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (alert.description == 'UFO sighting captured with UFOBeep app' || 
                    alert.description.isEmpty)
                  Text(
                    'Visual sighting captured with UFOBeep',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
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
                        if (alert.bearing != null)
                          _DetailRow(
                            icon: Icons.explore,
                            label: 'Direction',
                            value: '${alert.bearing!.toStringAsFixed(0)}°',
                          ),
                        _DetailRow(
                          icon: Icons.place,
                          label: 'Coordinates',
                          value: '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
                        ),
                        const SizedBox(height: 16),
                        // Navigation button (only show if user is not the reporter)
                        // Debug: Current user: ${appState.currentUserId}, Reporter: ${alert.reporterId}
                        if (appState.currentUserId != alert.reporterId && appState.currentUserId != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to compass with target location
                                final targetName = alert.title;
                                final bearing = alert.bearing?.toString() ?? '';
                                final distance = alert.distance?.toString() ?? '';
                                context.go('/compass?targetLat=${alert.latitude}&targetLon=${alert.longitude}&targetName=${Uri.encodeComponent(targetName)}&bearing=$bearing&distance=$distance&alertId=${alert.id}');
                              },
                              icon: const Icon(Icons.navigation, size: 18),
                              label: const Text('Navigate to Sighting'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandPrimary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
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

                // Action Buttons
                Column(
                  children: [
                    // First row: Chat and Navigate
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.go('/alert/$alertId/chat');
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Join Chat'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Navigate to compass with target location
                              final targetName = alert.title;
                              final bearing = alert.bearing?.toString() ?? '';
                              final distance = alert.distance?.toString() ?? '';
                              context.go('/compass?targetLat=${alert.latitude}&targetLon=${alert.longitude}&targetName=${Uri.encodeComponent(targetName)}&bearing=$bearing&distance=$distance&alertId=${alert.id}');
                            },
                            icon: const Icon(Icons.navigation),
                            label: const Text('Navigate'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Second row: Add Photos button (full width)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddPhotosDialog(context, alertId),
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Photos & Videos'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandPrimary,
                          side: const BorderSide(color: AppColors.brandPrimary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                onPressed: () => ref.invalidate(alertByIdProvider(alertId)),
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
              Icon(Icons.image_not_supported, size: 48, color: AppColors.textTertiary),
              SizedBox(height: 8),
              Text('No media available', style: TextStyle(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }

    // Show first media file (image)
    final media = alert.mediaFiles.first;
    final imageUrl = media['url'] as String? ?? '';
    
    if (imageUrl.isEmpty) {
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
            onTap: () => _showFullscreenImage(context, imageUrl),
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
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain, // Changed from cover to contain to prevent distortion
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

  Widget _buildLiveSightingsMap(Alert alert, AsyncValue<List<Alert>> alertsAsync) {
    return alertsAsync.when(
      data: (allAlerts) {
        // Get current user location to center the map
        return FutureBuilder<LatLng?>(
          future: _getUserLocation(),
          builder: (context, locationSnapshot) {
            // Use user's current location as center, fallback to alert location
            final center = locationSnapshot.data ?? LatLng(alert.latitude, alert.longitude);
            
            // Filter alerts to show nearby ones (within ~10km radius for better map context)
            final nearbyAlerts = _getNearbyAlerts(allAlerts, alert, 10.0);
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.map, color: AppColors.brandPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Live Sightings Map',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${nearbyAlerts.length} nearby',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MapWidget(
                          alerts: nearbyAlerts,
                          center: center, // Center on user's location
                          zoom: 12.0, // Closer zoom for detail view
                          height: 250,
                          showControls: true,
                          onAlertTap: (tappedAlert) {
                            if (tappedAlert.id != alert.id) {
                              // Navigate to tapped alert if it's different
                              context.go('/alert/${tappedAlert.id}');
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      locationSnapshot.hasData 
                          ? 'Map centered on your current location'
                          : 'Map centered on sighting location',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Loading live sightings map...'),
              const SizedBox(height: 12),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.brandPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Failed to load sightings map'),
              const SizedBox(height: 12),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 48, color: AppColors.textTertiary),
                      SizedBox(height: 8),
                      Text('Map unavailable', style: TextStyle(color: AppColors.textTertiary)),
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

  Future<LatLng?> _getUserLocation() async {
    try {
      final permissionService = PermissionService();
      if (permissionService.locationGranted) {
        final position = await permissionService.getCurrentLocation();
        if (position != null) {
          return LatLng(position.latitude, position.longitude);
        }
      }
      return null;
    } catch (e) {
      print('Failed to get user location for map: $e');
      return null;
    }
  }

  List<Alert> _getNearbyAlerts(List<Alert> allAlerts, Alert currentAlert, double radiusKm) {
    // Always include the current alert
    final nearbyAlerts = <Alert>[currentAlert];
    
    // Add other alerts within the radius
    for (final alert in allAlerts) {
      if (alert.id == currentAlert.id) continue; // Skip current alert
      
      final distance = _calculateDistance(
        currentAlert.latitude, 
        currentAlert.longitude,
        alert.latitude, 
        alert.longitude,
      );
      
      if (distance <= radiusKm) {
        nearbyAlerts.add(alert);
      }
    }
    
    return nearbyAlerts;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
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