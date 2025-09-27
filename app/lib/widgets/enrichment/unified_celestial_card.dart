import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../services/astronomical_translation_service.dart';
import '../glass_card.dart';

/// Unified celestial display - replaces all 7 scattered celestial implementations
/// One clean component for sun, moon, planets, and stars
class UnifiedCelestialCard extends StatelessWidget {
  final Map<String, dynamic> celestialData;

  const UnifiedCelestialCard({
    Key? key,
    required this.celestialData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('UNIFIED CELESTIAL DEBUG: Full input data keys: ${celestialData.keys.toList()}');
    debugPrint('UNIFIED CELESTIAL DEBUG: Celestial sub-data: ${celestialData['celestial']}');

    // Single source of truth - use celestial data directly
    final celestial = celestialData['celestial'] as Map<String, dynamic>? ?? {};
    debugPrint('UNIFIED CELESTIAL DEBUG: Celestial data empty: ${celestial.isEmpty}');

    if (celestial.isEmpty) {
      debugPrint('UNIFIED CELESTIAL DEBUG: Returning empty - no data');
      return const SizedBox.shrink();
    }

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header with emoji icon
          Row(
            children: [
              Text('🌙', style: TextStyle(fontSize: 20)),
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
          const SizedBox(height: 12),

          // Sun data
          if (_hasSunData()) _buildSunSection(context),

          // Moon data
          if (_hasMoonData()) _buildMoonSection(context),

          // Planets
          if (_hasPlanetData()) _buildPlanetsSection(context),

          // Stars
          if (_hasStarData()) _buildStarsSection(context),
        ],
        ),
      ),
    );
  }

  bool _hasSunData() {
    final celestial = celestialData['celestial'] as Map<String, dynamic>? ?? {};
    return celestial['sun'] != null;
  }

  bool _hasMoonData() {
    final celestial = celestialData['celestial'] as Map<String, dynamic>? ?? {};
    return celestial['moon'] != null;
  }

  bool _hasPlanetData() {
    final celestial = celestialData['celestial'] as Map<String, dynamic>? ?? {};
    final planets = celestial['visible_planets'] ?? [];
    return planets is List && planets.isNotEmpty;
  }

  bool _hasStarData() {
    final celestial = celestialData['celestial'] as Map<String, dynamic>? ?? {};
    final stars = celestial['bright_stars_visible'] ?? [];
    return stars is List && stars.isNotEmpty;
  }

  Widget _buildSunSection(BuildContext context) {
    final celestial = celestialData['celestial'] as Map<String, dynamic>;
    final sunData = celestial['sun'] as Map<String, dynamic>;
    final description = _getSunDescription(sunData, context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('☀️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sun: $description',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoonSection(BuildContext context) {
    final celestial = celestialData['celestial'] as Map<String, dynamic>;
    final moonData = celestial['moon'] as Map<String, dynamic>;
    final description = _getMoonDescription(moonData, context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('🌙', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Moon: $description',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsSection(BuildContext context) {
    final celestial = celestialData['celestial'] as Map<String, dynamic>;
    final planets = celestial['visible_planets'] as List;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🪐', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Planets: ${planets.length} visible',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...planets.map((planet) => _buildPlanetItem(planet, context)),
        ],
      ),
    );
  }

  Widget _buildStarsSection(BuildContext context) {
    final celestial = celestialData['celestial'] as Map<String, dynamic>;
    final stars = celestial['bright_stars_visible'] as List;
    final starNames = stars.map((s) => s['name']).join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('⭐', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Stars: $starNames',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetItem(Map<String, dynamic> planet, BuildContext context) {
    final name = planet['name'] ?? 'Unknown';
    final altitude = planet['altitude']?.toStringAsFixed(0) ?? '0';

    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 2),
      child: Text(
        '$name at ${altitude}°',
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getSunDescription(Map<String, dynamic> sunData, BuildContext context) {
    final category = sunData['visibility_category'] ?? 'dark';
    switch (category) {
      case 'daylight':
        return AppLocalizations.of(context)!.celestialSunDaylight;
      case 'twilight':
        return AppLocalizations.of(context)!.celestialSunTwilight;
      default:
        return AppLocalizations.of(context)!.celestialSunDark;
    }
  }

  String _getMoonDescription(Map<String, dynamic> moonData, BuildContext context) {
    final phaseName = moonData['phase_name'] ?? 'New Moon';
    final illumination = moonData['illumination'] ?? 0.0;
    final translatedPhase = AstronomicalTranslationService.translateMoonPhase(
      phaseName,
      AppLocalizations.of(context)!
    );

    return '$translatedPhase ${illumination.toStringAsFixed(0)}% illuminated';
  }

  /// Consolidate all possible celestial data formats into one standard structure
  Map<String, dynamic> _consolidateCelestialData() {
    debugPrint('UNIFIED CELESTIAL DEBUG: Input keys: ${celestialData.keys.toList()}');

    // Try different data sources in order of preference

    // 1. Try new structured format (celestial_v2)
    if (celestialData['celestial_v2'] != null) {
      debugPrint('UNIFIED CELESTIAL DEBUG: Using celestial_v2 data');
      return celestialData['celestial_v2'] as Map<String, dynamic>;
    }

    // 2. Try raw celestial data
    if (celestialData['celestial_raw'] != null) {
      debugPrint('UNIFIED CELESTIAL DEBUG: Using celestial_raw data');
      return celestialData['celestial_raw'] as Map<String, dynamic>;
    }

    // 3. Try standard celestial data
    if (celestialData['celestial'] != null) {
      debugPrint('UNIFIED CELESTIAL DEBUG: Using standard celestial data');
      return celestialData['celestial'] as Map<String, dynamic>;
    }

    // 4. Try direct celestial data (if passed directly)
    if (celestialData['sun'] != null || celestialData['moon'] != null ||
        celestialData['visible_planets'] != null || celestialData['bright_stars_visible'] != null) {
      debugPrint('UNIFIED CELESTIAL DEBUG: Using direct celestial data');
      return celestialData;
    }

    debugPrint('UNIFIED CELESTIAL DEBUG: No usable celestial data found');
    return {};
  }
}