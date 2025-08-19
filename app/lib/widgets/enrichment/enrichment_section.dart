import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/alert_enrichment.dart';

class EnrichmentSection extends StatelessWidget {
  const EnrichmentSection({
    super.key,
    required this.enrichmentData,
  });

  final Map<String, dynamic>? enrichmentData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.science,
              color: AppColors.brandPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Environmental Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (enrichmentData != null)
              _buildStatusChip(EnrichmentStatus.completed),
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
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.schedule,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'Analysis Pending',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Environmental data will be available once processing begins.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.brandPrimary),
            const SizedBox(height: 16),
            Text(
              'Analyzing Environment...',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Checking weather, celestial objects, and satellite data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Card(
      color: AppColors.semanticError.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.semanticError,
            ),
            const SizedBox(height: 12),
            Text(
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
              style: TextStyle(
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
    final hasWeatherData = enrichmentData['weather'] != null;
    final hasSatelliteData = enrichmentData['satellites'] != null;
    final hasContentData = enrichmentData['content_filter'] != null;
    final hasData = hasWeatherData || hasSatelliteData || hasContentData;

    if (!hasData) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (hasWeatherData) ...[
          WeatherCardFromJson(weatherData: enrichmentData['weather']),
          const SizedBox(height: 16),
        ],
        if (hasSatelliteData) ...[
          SatelliteCardFromJson(satelliteData: enrichmentData['satellites']),
          const SizedBox(height: 16),
        ],
        if (hasContentData) ...[
          ContentAnalysisCardFromJson(contentData: enrichmentData['content_filter']),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class WeatherCardFromJson extends StatelessWidget {
  const WeatherCardFromJson({super.key, required this.weatherData});

  final Map<String, dynamic> weatherData;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Weather Conditions',
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
                  _formatTemperature(weatherData['temperature_c']),
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
                  label: 'Wind',
                  value: _formatWindSpeed(weatherData['wind_speed_ms']),
                ),
                _WeatherDetail(
                  icon: Icons.visibility,
                  label: 'Visibility',
                  value: _formatVisibility(weatherData['visibility_km']),
                ),
                _WeatherDetail(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: _formatHumidity(weatherData['humidity_percent']),
                ),
                _WeatherDetail(
                  icon: Icons.cloud,
                  label: 'Clouds',
                  value: _formatCloudCover(weatherData['cloud_cover_percent']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTemperature(dynamic temp) {
    if (temp == null) return '--°C';
    return '${temp.toStringAsFixed(1)}°C';
  }

  String _formatWindSpeed(dynamic speed) {
    if (speed == null) return '--';
    return '${speed.toStringAsFixed(1)} m/s';
  }

  String _formatVisibility(dynamic visibility) {
    if (visibility == null) return '--';
    return '${visibility.toStringAsFixed(1)} km';
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
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nights_stay, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Celestial Objects',
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
                'Visible Planets',
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
    
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        'Satellite Passes (${allPasses.length})',
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
              Text(
                'No visible satellite passes found',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
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
    
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Content Analysis',
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
                  isSafe ? 'Content is safe' : 'Content flagged for review',
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
                  'Confidence: ',
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
                'Method: ${contentData['analysis_method']}',
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