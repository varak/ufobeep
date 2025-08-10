import 'dart:math' as math;
import '../models/user_preferences.dart';
import '../models/alert_enrichment.dart';

/// Service for calculating effective visibility range and filtering alerts
/// Implements the formula: min(profile_range, 2×weather_visibility) with 30km fallback
class VisibilityService {
  static final VisibilityService _instance = VisibilityService._internal();
  factory VisibilityService() => _instance;
  VisibilityService._internal();

  /// Default fallback visibility when weather data is unavailable
  static const double fallbackVisibilityKm = 30.0;
  
  /// Maximum reasonable visibility for calculation
  static const double maxVisibilityKm = 100.0;
  
  /// Minimum visibility threshold
  static const double minVisibilityKm = 0.5;

  /// Calculate effective visibility range based on profile settings and weather
  double calculateEffectiveRange({
    required UserPreferences preferences,
    WeatherData? weather,
  }) {
    final profileRangeKm = preferences.alertRangeKm;
    
    // Get weather-based visibility
    final weatherVisibilityKm = weather?.visibility ?? fallbackVisibilityKm;
    
    // Apply the formula: min(profile, 2×visibility)
    final weatherEffectiveRange = weatherVisibilityKm * 2.0;
    final effectiveRange = math.min(profileRangeKm, weatherEffectiveRange);
    
    // Ensure reasonable bounds
    return effectiveRange.clamp(minVisibilityKm, maxVisibilityKm);
  }

  /// Get visibility category based on weather conditions
  VisibilityCategory getVisibilityCategory(double visibilityKm) {
    if (visibilityKm >= 10.0) {
      return VisibilityCategory.excellent;
    } else if (visibilityKm >= 5.0) {
      return VisibilityCategory.good;
    } else if (visibilityKm >= 2.0) {
      return VisibilityCategory.fair;
    } else if (visibilityKm >= 1.0) {
      return VisibilityCategory.poor;
    } else {
      return VisibilityCategory.veryPoor;
    }
  }

  // NOTE: Alert filtering methods removed to avoid import issues
  // These would be implemented when the Alert model is properly available

  /// Get visibility advice based on current conditions
  String getVisibilityAdvice({
    required UserPreferences preferences,
    WeatherData? weather,
  }) {
    final effectiveRange = calculateEffectiveRange(
      preferences: preferences,
      weather: weather,
    );
    
    final profileRange = preferences.alertRangeKm;
    final weatherVisibility = weather?.visibility ?? fallbackVisibilityKm;
    final category = getVisibilityCategory(weatherVisibility);
    
    if (effectiveRange < profileRange) {
      return 'Visibility reduced to ${effectiveRange.toStringAsFixed(1)} km due to ${category.description} conditions';
    } else if (weather == null) {
      return 'Using standard visibility range of ${effectiveRange.toStringAsFixed(1)} km';
    } else {
      return 'Good visibility - full ${effectiveRange.toStringAsFixed(1)} km range available';
    }
  }

  /// Calculate visibility impact on alert range
  VisibilityImpact calculateVisibilityImpact({
    required UserPreferences preferences,
    WeatherData? weather,
  }) {
    final profileRange = preferences.alertRangeKm;
    final effectiveRange = calculateEffectiveRange(
      preferences: preferences,
      weather: weather,
    );
    
    final reductionPercent = ((profileRange - effectiveRange) / profileRange * 100);
    final weatherVisibility = weather?.visibility ?? fallbackVisibilityKm;
    
    return VisibilityImpact(
      profileRangeKm: profileRange,
      effectiveRangeKm: effectiveRange,
      weatherVisibilityKm: weatherVisibility,
      reductionPercent: reductionPercent.clamp(0.0, 100.0),
      category: getVisibilityCategory(weatherVisibility),
      isReduced: effectiveRange < profileRange,
      advice: getVisibilityAdvice(preferences: preferences, weather: weather),
    );
  }

  /// Get visibility status for UI display
  VisibilityStatus getVisibilityStatus({
    required UserPreferences preferences,
    WeatherData? weather,
  }) {
    final impact = calculateVisibilityImpact(
      preferences: preferences,
      weather: weather,
    );
    
    if (impact.category == VisibilityCategory.veryPoor) {
      return VisibilityStatus.critical;
    } else if (impact.category == VisibilityCategory.poor) {
      return VisibilityStatus.warning;
    } else if (impact.isReduced) {
      return VisibilityStatus.reduced;
    } else {
      return VisibilityStatus.good;
    }
  }

  /// Get recommended actions based on visibility
  List<String> getVisibilityRecommendations({
    required UserPreferences preferences,
    WeatherData? weather,
  }) {
    final category = getVisibilityCategory(
      weather?.visibility ?? fallbackVisibilityKm,
    );
    
    switch (category) {
      case VisibilityCategory.veryPoor:
        return [
          'Visibility extremely limited - alerts only within 500m',
          'Consider waiting for better conditions',
          'Use caution if investigating sightings',
        ];
      case VisibilityCategory.poor:
        return [
          'Poor visibility conditions - reduced alert range',
          'Objects may be harder to identify',
          'Take extra care if investigating',
        ];
      case VisibilityCategory.fair:
        return [
          'Fair visibility - some distant alerts filtered',
          'Good conditions for nearby sightings',
        ];
      case VisibilityCategory.good:
        return [
          'Good visibility for most sighting investigations',
          'Clear conditions within normal range',
        ];
      case VisibilityCategory.excellent:
        return [
          'Excellent visibility - ideal for sighting investigations',
          'Full alert range available',
        ];
    }
  }
}

/// Visibility categories based on meteorological standards
enum VisibilityCategory {
  veryPoor,
  poor, 
  fair,
  good,
  excellent,
}

extension VisibilityCategoryExtension on VisibilityCategory {
  String get displayName {
    switch (this) {
      case VisibilityCategory.veryPoor:
        return 'Very Poor';
      case VisibilityCategory.poor:
        return 'Poor';
      case VisibilityCategory.fair:
        return 'Fair';
      case VisibilityCategory.good:
        return 'Good';
      case VisibilityCategory.excellent:
        return 'Excellent';
    }
  }

  String get description {
    switch (this) {
      case VisibilityCategory.veryPoor:
        return 'fog, heavy rain/snow';
      case VisibilityCategory.poor:
        return 'mist, light rain';
      case VisibilityCategory.fair:
        return 'haze, light clouds';
      case VisibilityCategory.good:
        return 'clear with some clouds';
      case VisibilityCategory.excellent:
        return 'perfectly clear';
    }
  }

  String get emoji {
    switch (this) {
      case VisibilityCategory.veryPoor:
        return '🌫️';
      case VisibilityCategory.poor:
        return '🌦️';
      case VisibilityCategory.fair:
        return '⛅';
      case VisibilityCategory.good:
        return '🌤️';
      case VisibilityCategory.excellent:
        return '☀️';
    }
  }
}

/// Status indicators for UI
enum VisibilityStatus {
  critical,
  warning,
  reduced,
  good,
}

extension VisibilityStatusExtension on VisibilityStatus {
  String get displayName {
    switch (this) {
      case VisibilityStatus.critical:
        return 'Critical';
      case VisibilityStatus.warning:
        return 'Warning';
      case VisibilityStatus.reduced:
        return 'Reduced';
      case VisibilityStatus.good:
        return 'Good';
    }
  }
}

/// Detailed visibility impact analysis
class VisibilityImpact {
  final double profileRangeKm;
  final double effectiveRangeKm;
  final double weatherVisibilityKm;
  final double reductionPercent;
  final VisibilityCategory category;
  final bool isReduced;
  final String advice;

  const VisibilityImpact({
    required this.profileRangeKm,
    required this.effectiveRangeKm,
    required this.weatherVisibilityKm,
    required this.reductionPercent,
    required this.category,
    required this.isReduced,
    required this.advice,
  });

  String get formattedReduction {
    if (reductionPercent < 1) {
      return 'No reduction';
    }
    return '${reductionPercent.toStringAsFixed(0)}% reduction';
  }

  String get effectiveRangeFormatted => '${effectiveRangeKm.toStringAsFixed(1)} km';
  String get profileRangeFormatted => '${profileRangeKm.toStringAsFixed(1)} km';
  String get weatherVisibilityFormatted => '${weatherVisibilityKm.toStringAsFixed(1)} km';
}