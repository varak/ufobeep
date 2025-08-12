import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/alert_enrichment.dart';
import '../../widgets/enrichment/enrichment_section.dart';

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
                        if (alert.distance != null)
                          _DetailRow(
                            icon: Icons.location_on,
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

                // Enrichment Section
                EnrichmentSection(
                  enrichment: _getMockEnrichment(alert.id),
                ),
                const SizedBox(height: 24),

                // Action Buttons
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

  AlertEnrichment? _getMockEnrichment(String alertId) {
    // Mock enrichment data to demonstrate different states
    // In production, this would come from the API
    final mockIndex = alertId.hashCode % 4;
    
    switch (mockIndex) {
      case 0:
        // Pending state
        return AlertEnrichment(
          alertId: alertId,
          status: EnrichmentStatus.pending,
        );
      
      case 1:
        // Processing state
        return AlertEnrichment(
          alertId: alertId,
          status: EnrichmentStatus.processing,
        );
      
      case 2:
        // Error state
        return AlertEnrichment(
          alertId: alertId,
          status: EnrichmentStatus.failed,
          errorMessage: 'Unable to fetch environmental data. Please try again later.',
        );
      
      case 3:
      default:
        // Complete state with rich data
        return AlertEnrichment(
          alertId: alertId,
          status: EnrichmentStatus.completed,
          processedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          weather: const WeatherData(
            condition: 'Clear',
            description: 'Clear sky with excellent visibility',
            temperature: 22.5,
            humidity: 65,
            windSpeed: 12.3,
            windDirection: 270,
            visibility: 10.0,
            cloudCoverage: 15,
            iconCode: '01n',
          ),
          celestial: CelestialData(
            sun: const SunData(
              altitude: -15.2,
              azimuth: 285.7,
              isVisible: false,
            ),
            moon: const MoonData(
              altitude: 45.3,
              azimuth: 120.5,
              phase: 0.65,
              phaseName: 'Waxing Gibbous',
              isVisible: true,
            ),
            visiblePlanets: const [
              PlanetData(
                name: 'Venus',
                altitude: 25.4,
                azimuth: 245.2,
                magnitude: -4.1,
                isVisible: true,
              ),
              PlanetData(
                name: 'Jupiter',
                altitude: 60.2,
                azimuth: 180.5,
                magnitude: -2.5,
                isVisible: true,
              ),
              PlanetData(
                name: 'Mars',
                altitude: 35.7,
                azimuth: 155.3,
                magnitude: 0.5,
                isVisible: true,
              ),
            ],
            brightStars: const [],
          ),
          satellites: const [
            SatelliteData(
              name: 'STARLINK-1234',
              noradId: '45678',
              altitude: 42.5,
              azimuth: 135.2,
              elevation: 42.5,
              range: 550,
              isVisible: true,
              category: 'starlink',
            ),
            SatelliteData(
              name: 'ISS',
              noradId: '25544',
              altitude: -10.2,
              azimuth: 290.5,
              elevation: -10.2,
              range: 420,
              isVisible: false,
              category: 'iss',
            ),
            SatelliteData(
              name: 'COSMOS 2251 DEB',
              noradId: '34422',
              altitude: 15.3,
              azimuth: 75.8,
              elevation: 15.3,
              range: 780,
              isVisible: true,
              category: 'other',
            ),
          ],
          contentAnalysis: const ContentAnalysis(
            isNsfw: false,
            nsfwConfidence: 0.02,
            detectedObjects: ['light', 'sky', 'cloud', 'unknown object'],
            suggestedTags: ['night-sky', 'unidentified', 'bright-light', 'moving-object'],
            qualityScore: 0.85,
            isPotentiallyMisleading: false,
            classificationNote: 'High-quality capture with clear object visibility. No known aircraft patterns detected.',
          ),
        );
    }
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