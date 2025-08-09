import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'alert_enrichment.g.dart';

@JsonSerializable()
class AlertEnrichment {
  final String? id;
  final String alertId;
  final WeatherData? weather;
  final CelestialData? celestial;
  final List<SatelliteData> satellites;
  final ContentAnalysis? contentAnalysis;
  final EnrichmentStatus status;
  final DateTime? processedAt;
  final String? errorMessage;

  const AlertEnrichment({
    this.id,
    required this.alertId,
    this.weather,
    this.celestial,
    this.satellites = const [],
    this.contentAnalysis,
    this.status = EnrichmentStatus.pending,
    this.processedAt,
    this.errorMessage,
  });

  factory AlertEnrichment.fromJson(Map<String, dynamic> json) =>
      _$AlertEnrichmentFromJson(json);

  Map<String, dynamic> toJson() => _$AlertEnrichmentToJson(this);

  AlertEnrichment copyWith({
    String? id,
    String? alertId,
    WeatherData? weather,
    CelestialData? celestial,
    List<SatelliteData>? satellites,
    ContentAnalysis? contentAnalysis,
    EnrichmentStatus? status,
    DateTime? processedAt,
    String? errorMessage,
  }) {
    return AlertEnrichment(
      id: id ?? this.id,
      alertId: alertId ?? this.alertId,
      weather: weather ?? this.weather,
      celestial: celestial ?? this.celestial,
      satellites: satellites ?? this.satellites,
      contentAnalysis: contentAnalysis ?? this.contentAnalysis,
      status: status ?? this.status,
      processedAt: processedAt ?? this.processedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isComplete => status == EnrichmentStatus.completed;
  bool get isLoading => status == EnrichmentStatus.processing;
  bool get hasError => status == EnrichmentStatus.failed;
}

enum EnrichmentStatus {
  pending,
  processing,
  completed,
  failed,
}

extension EnrichmentStatusExtension on EnrichmentStatus {
  String get displayName {
    switch (this) {
      case EnrichmentStatus.pending:
        return 'Pending Analysis';
      case EnrichmentStatus.processing:
        return 'Analyzing...';
      case EnrichmentStatus.completed:
        return 'Analysis Complete';
      case EnrichmentStatus.failed:
        return 'Analysis Failed';
    }
  }

  Color get color {
    switch (this) {
      case EnrichmentStatus.pending:
        return Colors.grey;
      case EnrichmentStatus.processing:
        return Colors.blue;
      case EnrichmentStatus.completed:
        return Colors.green;
      case EnrichmentStatus.failed:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case EnrichmentStatus.pending:
        return Icons.schedule;
      case EnrichmentStatus.processing:
        return Icons.analytics;
      case EnrichmentStatus.completed:
        return Icons.check_circle;
      case EnrichmentStatus.failed:
        return Icons.error;
    }
  }
}

@JsonSerializable()
class WeatherData {
  final String condition;
  final String description;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double windDirection;
  final double visibility;
  final double cloudCoverage;
  final String iconCode;

  const WeatherData({
    required this.condition,
    required this.description,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.cloudCoverage,
    required this.iconCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);

  String get temperatureFormatted => '${temperature.toStringAsFixed(1)}°C';
  String get windFormatted => '${windSpeed.toStringAsFixed(1)} km/h ${_windDirectionName}';
  String get visibilityFormatted => '${visibility.toStringAsFixed(1)} km';
  String get humidityFormatted => '${humidity.toStringAsFixed(0)}%';
  String get cloudCoverageFormatted => '${cloudCoverage.toStringAsFixed(0)}%';

  String get _windDirectionName {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((windDirection + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}

@JsonSerializable()
class CelestialData {
  final SunData sun;
  final MoonData moon;
  final List<PlanetData> visiblePlanets;
  final List<StarData> brightStars;

  const CelestialData({
    required this.sun,
    required this.moon,
    required this.visiblePlanets,
    required this.brightStars,
  });

  factory CelestialData.fromJson(Map<String, dynamic> json) =>
      _$CelestialDataFromJson(json);

  Map<String, dynamic> toJson() => _$CelestialDataToJson(this);
}

@JsonSerializable()
class SunData {
  final double altitude;
  final double azimuth;
  final DateTime? sunrise;
  final DateTime? sunset;
  final bool isVisible;

  const SunData({
    required this.altitude,
    required this.azimuth,
    this.sunrise,
    this.sunset,
    required this.isVisible,
  });

  factory SunData.fromJson(Map<String, dynamic> json) =>
      _$SunDataFromJson(json);

  Map<String, dynamic> toJson() => _$SunDataToJson(this);

  String get altitudeFormatted => '${altitude.toStringAsFixed(1)}°';
  String get azimuthFormatted => '${azimuth.toStringAsFixed(1)}°';
}

@JsonSerializable()
class MoonData {
  final double altitude;
  final double azimuth;
  final double phase;
  final String phaseName;
  final bool isVisible;

  const MoonData({
    required this.altitude,
    required this.azimuth,
    required this.phase,
    required this.phaseName,
    required this.isVisible,
  });

  factory MoonData.fromJson(Map<String, dynamic> json) =>
      _$MoonDataFromJson(json);

  Map<String, dynamic> toJson() => _$MoonDataToJson(this);

  String get altitudeFormatted => '${altitude.toStringAsFixed(1)}°';
  String get azimuthFormatted => '${azimuth.toStringAsFixed(1)}°';
  String get phaseFormatted => '${(phase * 100).toStringAsFixed(0)}%';
}

@JsonSerializable()
class PlanetData {
  final String name;
  final double altitude;
  final double azimuth;
  final double magnitude;
  final bool isVisible;

  const PlanetData({
    required this.name,
    required this.altitude,
    required this.azimuth,
    required this.magnitude,
    required this.isVisible,
  });

  factory PlanetData.fromJson(Map<String, dynamic> json) =>
      _$PlanetDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlanetDataToJson(this);

  String get altitudeFormatted => '${altitude.toStringAsFixed(1)}°';
  String get azimuthFormatted => '${azimuth.toStringAsFixed(1)}°';
  String get magnitudeFormatted => '${magnitude.toStringAsFixed(1)}';
}

@JsonSerializable()
class StarData {
  final String name;
  final double altitude;
  final double azimuth;
  final double magnitude;

  const StarData({
    required this.name,
    required this.altitude,
    required this.azimuth,
    required this.magnitude,
  });

  factory StarData.fromJson(Map<String, dynamic> json) =>
      _$StarDataFromJson(json);

  Map<String, dynamic> toJson() => _$StarDataToJson(this);

  String get altitudeFormatted => '${altitude.toStringAsFixed(1)}°';
  String get azimuthFormatted => '${azimuth.toStringAsFixed(1)}°';
  String get magnitudeFormatted => '${magnitude.toStringAsFixed(1)}';
}

@JsonSerializable()
class SatelliteData {
  final String name;
  final String noradId;
  final double altitude;
  final double azimuth;
  final double elevation;
  final double range;
  final bool isVisible;
  final String category; // 'starlink', 'iss', 'other'
  final DateTime? nextPass;

  const SatelliteData({
    required this.name,
    required this.noradId,
    required this.altitude,
    required this.azimuth,
    required this.elevation,
    required this.range,
    required this.isVisible,
    required this.category,
    this.nextPass,
  });

  factory SatelliteData.fromJson(Map<String, dynamic> json) =>
      _$SatelliteDataFromJson(json);

  Map<String, dynamic> toJson() => _$SatelliteDataToJson(this);

  String get altitudeFormatted => '${altitude.toStringAsFixed(1)}°';
  String get azimuthFormatted => '${azimuth.toStringAsFixed(1)}°';
  String get elevationFormatted => '${elevation.toStringAsFixed(1)}°';
  String get rangeFormatted => '${range.toStringAsFixed(0)} km';

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'starlink':
        return Icons.satellite_alt;
      case 'iss':
        return Icons.public;
      default:
        return Icons.satellite;
    }
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'starlink':
        return Colors.blue;
      case 'iss':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

@JsonSerializable()
class ContentAnalysis {
  final bool isNsfw;
  final double nsfwConfidence;
  final List<String> detectedObjects;
  final List<String> suggestedTags;
  final double qualityScore;
  final bool isPotentiallyMisleading;
  final String? classificationNote;

  const ContentAnalysis({
    required this.isNsfw,
    required this.nsfwConfidence,
    required this.detectedObjects,
    required this.suggestedTags,
    required this.qualityScore,
    required this.isPotentiallyMisleading,
    this.classificationNote,
  });

  factory ContentAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ContentAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$ContentAnalysisToJson(this);

  String get qualityScoreFormatted => '${(qualityScore * 100).toStringAsFixed(0)}%';
  String get nsfwConfidenceFormatted => '${(nsfwConfidence * 100).toStringAsFixed(0)}%';

  bool get hasHighQuality => qualityScore >= 0.7;
  bool get hasObjects => detectedObjects.isNotEmpty;
  bool get hasTags => suggestedTags.isNotEmpty;
}