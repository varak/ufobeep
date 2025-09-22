import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../glass_card.dart';
import '../../models/alert_enrichment.dart';
import '../../utils/unit_conversion.dart';
import '../../providers/user_preferences_provider.dart';
import 'premium_satellite_card.dart';

class EnrichmentSection extends ConsumerWidget {
  const EnrichmentSection({
    super.key,
    required this.enrichmentData,
    this.alertCreatorDeviceId,
    this.currentUserDeviceId,
    this.isWitnessConfirmed = false,
    this.alertSource,
    this.reporterUsername,
  });

  final Map<String, dynamic>? enrichmentData;
  final String? alertCreatorDeviceId;
  final String? currentUserDeviceId;
  final bool isWitnessConfirmed;
  final String? alertSource;
  final String? reporterUsername;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final units = userPrefs?.units ?? 'metric';
    // Skip enrichment data display for MUFON cases
    final isMufonCase = alertSource == 'mufon' || reporterUsername == 'MUFON_Database';
    if (isMufonCase) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.envAnalysisTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (enrichmentData != null) ...[
              const SizedBox(height: 8),
              _buildStatusChip(EnrichmentStatus.completed),
            ],
          ],
        ),
        const SizedBox(height: 16),

        if (enrichmentData == null || enrichmentData!.isEmpty)
          _buildPendingState()
        else
          _buildEnrichmentData(enrichmentData!),
      ],
    );
  }

  Widget _buildStatusChip(EnrichmentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingState() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Icon(
              Icons.schedule,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) => Text(
                AppLocalizations.of(context)!.envAnalysisPending,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) => Text(
                AppLocalizations.of(context)!.envAnalysisPendingDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.brandPrimary),
            const SizedBox(height: 16),
            // Reuse pending title for loading to keep copy simple/consistent
            Builder(
              builder: (context) => Text(
                AppLocalizations.of(context)!.envAnalysisPending,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.semanticError,
            ),
            const SizedBox(height: 12),
            const Text(
              'Analysis Failed',
              style: TextStyle(
                color: AppColors.semanticError,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrichmentData(Map<String, dynamic> enrichmentData) {
    // Debug logging
    debugPrint('DEBUG: Enrichment keys: ${enrichmentData.keys.toList()}');
    debugPrint('DEBUG: BlackSky data: ${enrichmentData['blacksky']}');
    debugPrint('DEBUG: SkyFi data: ${enrichmentData['skyfi']}');

    final hasAircraftData = enrichmentData['aircraft_tracking'] != null;
    final hasWeatherData = enrichmentData['weather'] != null;
    final hasSatelliteData = enrichmentData['satellites'] != null;
    final hasContentData = enrichmentData['content_filter'] != null;
    final hasBlackSkyData = enrichmentData['blacksky'] != null;
    final hasSkyFiData = enrichmentData['skyfi'] != null;
    final hasCelestialData = enrichmentData['celestial'] != null;
    final hasLocationData = enrichmentData['location'] != null;
    final hasProcessingSummaryData = enrichmentData['processing_summary'] != null;
    final hasData = hasAircraftData || hasWeatherData || hasSatelliteData || hasContentData || hasBlackSkyData || hasSkyFiData || hasCelestialData || hasLocationData || hasProcessingSummaryData;
    
    debugPrint('DEBUG: hasBlackSkyData = $hasBlackSkyData');
    debugPrint('DEBUG: hasSkyFiData = $hasSkyFiData');

    if (!hasData) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (hasWeatherData) ...[
          WeatherCardFromJson(weatherData: enrichmentData['weather']),
          const SizedBox(height: 16),
        ],
        if (hasCelestialData) ...[
          CelestialCardFromJson(celestialData: enrichmentData['celestial']),
          const SizedBox(height: 16),
        ],
        if (hasLocationData) ...[
          LocationCardFromJson(locationData: enrichmentData['location']),
          const SizedBox(height: 16),
        ],
        if (hasSatelliteData) ...[
          SatelliteCardFromJson(satelliteData: enrichmentData['satellites']),
          const SizedBox(height: 16),
        ],
        if (hasAircraftData) ...[
          _buildAircraftTrackingCard(enrichmentData['aircraft_tracking']),
          const SizedBox(height: 16),
        ],
        if (hasProcessingSummaryData) ...[
          ProcessingSummaryCardFromJson(summaryData: enrichmentData['processing_summary']),
          const SizedBox(height: 16),
        ],
        if (hasBlackSkyData || hasSkyFiData) ...[
          _canViewPremiumSatelliteImagery()
            ? PremiumSatelliteCard(
                blackskyData: enrichmentData['blacksky'],
                skyfiData: enrichmentData['skyfi'],
              )
            : _buildPremiumUpgradePrompt(),
          const SizedBox(height: 16),
        ],
        if (hasContentData) ...[
          ContentAnalysisCardFromJson(contentData: enrichmentData['content_filter']),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildAircraftTrackingCard(Map<String, dynamic> data) {
    final aircraft = data['aircraft'] as List? ?? [];
    final total = data['total'] as int? ?? 0;
    final summary = data['summary'] as String? ?? 'No aircraft detected';

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✈️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) => Text(
                    AppLocalizations.of(context)!.aircraftTrackingTitle,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brandPrimary),
                  ),
                  child: Text('$total', style: TextStyle(color: AppColors.brandPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(summary, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            if (aircraft.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...aircraft.take(3).map((a) {
                final callsign = a['callsign'] ?? '';
                final distance = a['distance_km']?.toDouble() ?? 0.0;
                final altitude = a['altitude_ft'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) => Text(
                          callsign.isEmpty ? AppLocalizations.of(context)!.unknownAircraft : callsign,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final userPrefs = ref.watch(userPreferencesProvider);
                          final units = userPrefs?.units ?? 'metric';
                          return Text(
                            '${UnitConversion.formatDistance(distance * 1000, units)} away${altitude != null ? ' • ${altitude}ft' : ''}',
                            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
              if (total > 3)
                Builder(
                  builder: (context) => Text(
                    '+${total - 3} ${AppLocalizations.of(context)!.moreAircraft}',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Check if current user can view premium satellite imagery
  /// Only beep creator and confirmed witnesses can see BlackSky/SkyFi data (MP13-4)
  bool _canViewPremiumSatelliteImagery() {
    debugPrint('DEBUG: _canViewPremiumSatelliteImagery check');
    debugPrint('DEBUG: currentUserDeviceId: "$currentUserDeviceId"');
    debugPrint('DEBUG: alertCreatorDeviceId: "$alertCreatorDeviceId"');
    debugPrint('DEBUG: isWitnessConfirmed: $isWitnessConfirmed');
    
    // Deny access if no current user ID (guest users)
    if (currentUserDeviceId == null) {
      debugPrint('DEBUG: No current user ID - guest access denied');
      return false;
    }
    
    // Deny access if no alert creator ID (can't determine creator)
    if (alertCreatorDeviceId == null || alertCreatorDeviceId!.isEmpty) {
      debugPrint('DEBUG: No alert creator ID - access denied');
      return false;
    }
    
    // Allow if user is the alert creator
    if (currentUserDeviceId == alertCreatorDeviceId) {
      debugPrint('DEBUG: User is alert creator, allowing access');
      return true;
    }
    
    // Allow if user is a confirmed witness (already validated within 2x visibility distance)
    if (isWitnessConfirmed) {
      debugPrint('DEBUG: User is confirmed witness, allowing access');
      return true;
    }
    
    // Otherwise, deny access (guest users)
    debugPrint('DEBUG: Access denied - not creator or confirmed witness');
    return false;
  }

  /// Build upgrade prompt for users who can't access premium satellite imagery
  Widget _buildPremiumUpgradePrompt() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.satellite_alt, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context)!.premiumImageryTitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context)!.premiumImagerySubtitle,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.lock, color: AppColors.textSecondary, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            
            // Access requirements
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) => Text(
                      AppLocalizations.of(context)!.premiumImageryAccessOnly,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors.brandPrimary, size: 16),
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context)!.premiumAccessCreators,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.visibility, color: AppColors.brandPrimary, size: 16),
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context)!.premiumAccessWitnesses,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Platform info (Coming Soon)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'BlackSky',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) => Text(
                            AppLocalizations.of(context)!.comingSoon,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'SkyFi',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) => Text(
                            AppLocalizations.of(context)!.comingSoon,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherCardFromJson extends ConsumerWidget {
  const WeatherCardFromJson({super.key, required this.weatherData});

  final Map<String, dynamic> weatherData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final units = userPrefs?.units ?? 'metric';
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.weatherConditionsTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherData['weather_main']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        weatherData['weather_description']?.toString() ?? 'No description',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  UnitConversion.formatTemperature(weatherData['temperature_c'], units),
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _WeatherDetail(
                  icon: Icons.air,
                  label: AppLocalizations.of(context)!.windLabel,
                  value: UnitConversion.formatWindSpeed(weatherData['wind_speed_ms'], units),
                ),
                _WeatherDetail(
                  icon: Icons.visibility,
                  label: AppLocalizations.of(context)!.visibility,
                  value: UnitConversion.formatVisibility(weatherData['visibility_km'], units),
                ),
                _WeatherDetail(
                  icon: Icons.water_drop,
                  label: AppLocalizations.of(context)!.humidity,
                  value: _formatHumidity(weatherData['humidity_percent']),
                ),
                _WeatherDetail(
                  icon: Icons.cloud,
                  label: AppLocalizations.of(context)!.clouds,
                  value: _formatCloudCover(weatherData['cloud_cover_percent']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  String _formatHumidity(dynamic humidity) {
    if (humidity == null) return '--%';
    return '${humidity}%';
  }

  String _formatCloudCover(dynamic clouds) {
    if (clouds == null) return '--%';
    return '${clouds}%';
  }
}

class _WeatherDetail extends StatelessWidget {
  const _WeatherDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class CelestialCard extends StatelessWidget {
  const CelestialCard({super.key, required this.celestial});

  final CelestialData celestial;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nights_stay, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.celestialDataTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sun and Moon
            Row(
              children: [
                Expanded(
                  child: _CelestialObject(
                    icon: Icons.wb_sunny,
                    name: 'Sun',
                    altitude: celestial.sun.altitudeFormatted,
                    azimuth: celestial.sun.azimuthFormatted,
                    isVisible: celestial.sun.isVisible,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _CelestialObject(
                    icon: Icons.nights_stay,
                    name: 'Moon (${celestial.moon.phaseName})',
                    altitude: celestial.moon.altitudeFormatted,
                    azimuth: celestial.moon.azimuthFormatted,
                    isVisible: celestial.moon.isVisible,
                  ),
                ),
              ],
            ),

            if (celestial.visiblePlanets.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.visiblePlanets,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...celestial.visiblePlanets.map((planet) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.brandPrimary),
                      const SizedBox(width: 8),
                      Text(
                        '${planet.name}: ${planet.altitudeFormatted} alt, ${planet.azimuthFormatted} az',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CelestialObject extends StatelessWidget {
  const _CelestialObject({
    required this.icon,
    required this.name,
    required this.altitude,
    required this.azimuth,
    required this.isVisible,
  });

  final IconData icon;
  final String name;
  final String altitude;
  final String azimuth;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isVisible ? AppColors.brandPrimary : AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isVisible ? AppColors.brandPrimary : AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alt: $altitude',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                'Az: $azimuth',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SatelliteCardFromJson extends StatelessWidget {
  const SatelliteCardFromJson({super.key, required this.satelliteData});

  final Map<String, dynamic> satelliteData;

  @override
  Widget build(BuildContext context) {
    final issPasses = satelliteData['iss_passes'] as List<dynamic>? ?? [];
    final starlinkPasses = satelliteData['starlink_passes'] as List<dynamic>? ?? [];
    final allPasses = [...issPasses, ...starlinkPasses];
    
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.satellite, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.satellitePassesTitle} (${allPasses.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Satellites visible overhead at sighting time & location',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...issPasses.map((pass) => _buildSatellitePass(pass)),
            ...starlinkPasses.map((pass) => _buildSatellitePass(pass)),
            
            if (allPasses.isEmpty)
              Builder(
                builder: (context) => Text(
                  AppLocalizations.of(context)!.noSatellitePasses,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildSatellitePass(Map<String, dynamic> pass) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: pass['is_visible_pass'] == true ? AppColors.brandPrimary : AppColors.darkBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Satellite name and direction
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: pass['is_visible_pass'] == true ? AppColors.brandPrimary : AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${pass['satellite_name']?.toString() ?? 'Unknown'} - ${pass['direction'] ?? 'unknown direction'}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (pass['is_visible_pass'] == true)
                  Icon(
                    Icons.visibility,
                    size: 12,
                    color: AppColors.brandPrimary,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Details line with all available data
            Text(
              _formatSatelliteDetails(pass),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatSatelliteDetails(Map<String, dynamic> pass) {
    final List<String> details = [];
    
    // Max elevation
    if (pass['max_elevation_deg'] != null) {
      details.add('Max elevation: ${pass['max_elevation_deg']}°');
    }
    
    // Brightness magnitude
    if (pass['brightness_magnitude'] != null) {
      details.add('Magnitude: ${pass['brightness_magnitude']}');
    }
    
    // Max elevation time
    if (pass['max_elevation_time_utc'] != null) {
      try {
        final timeUtc = DateTime.parse(pass['max_elevation_time_utc']);
        final timeLocal = timeUtc.toLocal();
        details.add('${timeLocal.hour.toString().padLeft(2, '0')}:${timeLocal.minute.toString().padLeft(2, '0')}:${timeLocal.second.toString().padLeft(2, '0')}');
      } catch (e) {
        // If time parsing fails, just show the raw string
        details.add(pass['max_elevation_time_utc'].toString());
      }
    }
    
    return details.join(' | ');
  }
}

class ContentAnalysisCardFromJson extends StatelessWidget {
  const ContentAnalysisCardFromJson({super.key, required this.contentData});

  final Map<String, dynamic> contentData;

  @override
  Widget build(BuildContext context) {
    final isSafe = contentData['is_safe'] ?? true;
    final confidence = contentData['confidence'] ?? 0.0;
    
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.contentAnalysisTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Safety Status
            Row(
              children: [
                Icon(
                  isSafe ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: isSafe ? AppColors.semanticSuccess : AppColors.semanticWarning,
                ),
                const SizedBox(width: 8),
                Text(
                  isSafe ? AppLocalizations.of(context)!.contentSafe : AppLocalizations.of(context)!.contentFlagged,
                  style: TextStyle(
                    color: isSafe ? AppColors.semanticSuccess : AppColors.semanticWarning,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Confidence Score
            Row(
              children: [
                Text(
                  '${AppLocalizations.of(context)!.confidenceLabel}: ',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${(confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            if (contentData['analysis_method'] != null) ...[
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.methodLabel}: ${contentData['analysis_method']}',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CelestialCardFromJson extends StatelessWidget {
  const CelestialCardFromJson({super.key, required this.celestialData});

  final Map<String, dynamic> celestialData;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.nights_stay, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.celestialDataTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sun data
            if (celestialData['sun'] != null) ...
              _buildCelestialObject(
                context,
                'Sun',
                Icons.wb_sunny,
                celestialData['sun'],
              ),

            // Moon data
            if (celestialData['moon'] != null) ...
              _buildCelestialObject(
                context,
                'Moon',
                Icons.nights_stay,
                celestialData['moon'],
              ),

            // Visible planets
            if (celestialData['visible_planets'] != null &&
                (celestialData['visible_planets'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.visiblePlanets,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ...(celestialData['visible_planets'] as List).take(3).map((planet) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppColors.brandPrimary),
                      const SizedBox(width: 8),
                      Text(
                        '${planet['name'] ?? 'Unknown'}: ${planet['altitude']?.toStringAsFixed(1) ?? '0'}° alt',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCelestialObject(
    BuildContext context,
    String name,
    IconData icon,
    Map<String, dynamic> objectData,
  ) {
    final isVisible = objectData['is_visible'] ?? false;
    final altitude = objectData['altitude']?.toDouble() ?? 0.0;
    final azimuth = objectData['azimuth']?.toDouble() ?? 0.0;

    return [
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isVisible ? AppColors.brandPrimary : AppColors.darkBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isVisible ? AppColors.brandPrimary : AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (name == 'Moon' && objectData['phase_name'] != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${objectData['phase_name']})',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${altitude.toStringAsFixed(1)}° alt • ${azimuth.toStringAsFixed(1)}° az',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isVisible)
              const Icon(
                Icons.visibility,
                size: 12,
                color: AppColors.brandPrimary,
              ),
          ],
        ),
      ),
    ];
  }
}

class LocationCardFromJson extends StatelessWidget {
  const LocationCardFromJson({super.key, required this.locationData});

  final Map<String, dynamic> locationData;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.locationDataTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // City, State, Country
            if (locationData['city'] != null || locationData['state'] != null || locationData['country'] != null)
              Row(
                children: [
                  const Icon(Icons.place, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [locationData['city'], locationData['state'], locationData['country']]
                        .where((e) => e != null && e.toString().isNotEmpty)
                        .join(', '),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

            if (locationData['timezone'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Text(
                    '${AppLocalizations.of(context)!.timezone}: ${locationData['timezone']}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],

            if (locationData['coordinates'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Text(
                    '${AppLocalizations.of(context)!.coordinates}: ${locationData['coordinates']}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProcessingSummaryCardFromJson extends StatelessWidget {
  const ProcessingSummaryCardFromJson({super.key, required this.summaryData});

  final Map<String, dynamic> summaryData;

  @override
  Widget build(BuildContext context) {
    final successfulProcessors = summaryData['successful_processors'] as List<dynamic>? ?? [];
    final failedProcessors = summaryData['failed_processors'] as List<dynamic>? ?? [];
    final processingTimeMs = summaryData['processing_time_ms']?.toDouble() ?? 0.0;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.processingSummaryTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Processing time
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Text(
                  '${AppLocalizations.of(context)!.processingTime}: ${(processingTimeMs / 1000).toStringAsFixed(1)}s',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Successful processors
            if (successfulProcessors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.semanticSuccess),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.successful} (${successfulProcessors.length})',
                          style: const TextStyle(
                            color: AppColors.semanticSuccess,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          successfulProcessors.join(', '),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Failed processors
            if (failedProcessors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error, size: 16, color: AppColors.semanticError),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.failed} (${failedProcessors.length})',
                          style: const TextStyle(
                            color: AppColors.semanticError,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          failedProcessors.join(', '),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
