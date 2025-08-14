import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_widget.dart';

class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertAsync = ref.watch(alertByIdProvider(alertId));

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

                // Category & Verification
                Row(
                  children: [
                    Chip(
                      label: Text(alert.category.replaceAll('_', ' ').toUpperCase()),
                    ),
                    const SizedBox(width: 8),
                    if (alert.isVerified)
                      Chip(
                        label: const Text('VERIFIED'),
                        backgroundColor: AppColors.brandPrimary.withOpacity(0.2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  alert.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Map Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        MapWidget(
                          alerts: [alert],
                          height: 200,
                          center: LatLng(alert.latitude, alert.longitude),
                          zoom: 13.0,
                          showControls: true,
                        ),
                      ],
                    ),
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
                              // TODO: Navigate to alert location
                            },
                            icon: const Icon(Icons.directions),
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
                        label: const Text('Add More Photos'),
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
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
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
              'Add More Photos',
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