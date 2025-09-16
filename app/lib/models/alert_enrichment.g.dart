// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_enrichment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertEnrichment _$AlertEnrichmentFromJson(Map<String, dynamic> json) =>
    AlertEnrichment(
      id: json['id'] as String?,
      alertId: json['alertId'] as String,
      weather: json['weather'] == null
          ? null
          : WeatherData.fromJson(json['weather'] as Map<String, dynamic>),
      celestial: json['celestial'] == null
          ? null
          : CelestialData.fromJson(json['celestial'] as Map<String, dynamic>),
      satellites:
          (json['satellites'] as List<dynamic>?)
              ?.map((e) => SatelliteData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      contentAnalysis: json['contentAnalysis'] == null
          ? null
          : ContentAnalysis.fromJson(
              json['contentAnalysis'] as Map<String, dynamic>,
            ),
      status:
          $enumDecodeNullable(_$EnrichmentStatusEnumMap, json['status']) ??
          EnrichmentStatus.pending,
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$AlertEnrichmentToJson(AlertEnrichment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alertId': instance.alertId,
      'weather': instance.weather,
      'celestial': instance.celestial,
      'satellites': instance.satellites,
      'contentAnalysis': instance.contentAnalysis,
      'status': _$EnrichmentStatusEnumMap[instance.status]!,
      'processedAt': instance.processedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

const _$EnrichmentStatusEnumMap = {
  EnrichmentStatus.pending: 'pending',
  EnrichmentStatus.processing: 'processing',
  EnrichmentStatus.completed: 'completed',
  EnrichmentStatus.failed: 'failed',
};

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) => WeatherData(
  condition: json['condition'] as String,
  description: json['description'] as String,
  temperature: (json['temperature'] as num).toDouble(),
  humidity: (json['humidity'] as num).toDouble(),
  windSpeed: (json['windSpeed'] as num).toDouble(),
  windDirection: (json['windDirection'] as num).toDouble(),
  visibility: (json['visibility'] as num).toDouble(),
  cloudCoverage: (json['cloudCoverage'] as num).toDouble(),
  iconCode: json['iconCode'] as String,
);

Map<String, dynamic> _$WeatherDataToJson(WeatherData instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'description': instance.description,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'windSpeed': instance.windSpeed,
      'windDirection': instance.windDirection,
      'visibility': instance.visibility,
      'cloudCoverage': instance.cloudCoverage,
      'iconCode': instance.iconCode,
    };

CelestialData _$CelestialDataFromJson(Map<String, dynamic> json) =>
    CelestialData(
      sun: SunData.fromJson(json['sun'] as Map<String, dynamic>),
      moon: MoonData.fromJson(json['moon'] as Map<String, dynamic>),
      visiblePlanets: (json['visiblePlanets'] as List<dynamic>)
          .map((e) => PlanetData.fromJson(e as Map<String, dynamic>))
          .toList(),
      brightStars: (json['brightStars'] as List<dynamic>)
          .map((e) => StarData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CelestialDataToJson(CelestialData instance) =>
    <String, dynamic>{
      'sun': instance.sun,
      'moon': instance.moon,
      'visiblePlanets': instance.visiblePlanets,
      'brightStars': instance.brightStars,
    };

SunData _$SunDataFromJson(Map<String, dynamic> json) => SunData(
  altitude: (json['altitude'] as num).toDouble(),
  azimuth: (json['azimuth'] as num).toDouble(),
  sunrise: json['sunrise'] == null
      ? null
      : DateTime.parse(json['sunrise'] as String),
  sunset: json['sunset'] == null
      ? null
      : DateTime.parse(json['sunset'] as String),
  isVisible: json['isVisible'] as bool,
);

Map<String, dynamic> _$SunDataToJson(SunData instance) => <String, dynamic>{
  'altitude': instance.altitude,
  'azimuth': instance.azimuth,
  'sunrise': instance.sunrise?.toIso8601String(),
  'sunset': instance.sunset?.toIso8601String(),
  'isVisible': instance.isVisible,
};

MoonData _$MoonDataFromJson(Map<String, dynamic> json) => MoonData(
  altitude: (json['altitude'] as num).toDouble(),
  azimuth: (json['azimuth'] as num).toDouble(),
  phase: (json['phase'] as num).toDouble(),
  phaseName: json['phaseName'] as String,
  isVisible: json['isVisible'] as bool,
);

Map<String, dynamic> _$MoonDataToJson(MoonData instance) => <String, dynamic>{
  'altitude': instance.altitude,
  'azimuth': instance.azimuth,
  'phase': instance.phase,
  'phaseName': instance.phaseName,
  'isVisible': instance.isVisible,
};

PlanetData _$PlanetDataFromJson(Map<String, dynamic> json) => PlanetData(
  name: json['name'] as String,
  altitude: (json['altitude'] as num).toDouble(),
  azimuth: (json['azimuth'] as num).toDouble(),
  magnitude: (json['magnitude'] as num).toDouble(),
  isVisible: json['isVisible'] as bool,
);

Map<String, dynamic> _$PlanetDataToJson(PlanetData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'altitude': instance.altitude,
      'azimuth': instance.azimuth,
      'magnitude': instance.magnitude,
      'isVisible': instance.isVisible,
    };

StarData _$StarDataFromJson(Map<String, dynamic> json) => StarData(
  name: json['name'] as String,
  altitude: (json['altitude'] as num).toDouble(),
  azimuth: (json['azimuth'] as num).toDouble(),
  magnitude: (json['magnitude'] as num).toDouble(),
);

Map<String, dynamic> _$StarDataToJson(StarData instance) => <String, dynamic>{
  'name': instance.name,
  'altitude': instance.altitude,
  'azimuth': instance.azimuth,
  'magnitude': instance.magnitude,
};

SatelliteData _$SatelliteDataFromJson(Map<String, dynamic> json) =>
    SatelliteData(
      name: json['name'] as String,
      noradId: json['noradId'] as String,
      altitude: (json['altitude'] as num).toDouble(),
      azimuth: (json['azimuth'] as num).toDouble(),
      elevation: (json['elevation'] as num).toDouble(),
      range: (json['range'] as num).toDouble(),
      isVisible: json['isVisible'] as bool,
      category: json['category'] as String,
      nextPass: json['nextPass'] == null
          ? null
          : DateTime.parse(json['nextPass'] as String),
    );

Map<String, dynamic> _$SatelliteDataToJson(SatelliteData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'noradId': instance.noradId,
      'altitude': instance.altitude,
      'azimuth': instance.azimuth,
      'elevation': instance.elevation,
      'range': instance.range,
      'isVisible': instance.isVisible,
      'category': instance.category,
      'nextPass': instance.nextPass?.toIso8601String(),
    };

ContentAnalysis _$ContentAnalysisFromJson(Map<String, dynamic> json) =>
    ContentAnalysis(
      isNsfw: json['isNsfw'] as bool,
      nsfwConfidence: (json['nsfwConfidence'] as num).toDouble(),
      detectedObjects: (json['detectedObjects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suggestedTags: (json['suggestedTags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      qualityScore: (json['qualityScore'] as num).toDouble(),
      isPotentiallyMisleading: json['isPotentiallyMisleading'] as bool,
      classificationNote: json['classificationNote'] as String?,
    );

Map<String, dynamic> _$ContentAnalysisToJson(ContentAnalysis instance) =>
    <String, dynamic>{
      'isNsfw': instance.isNsfw,
      'nsfwConfidence': instance.nsfwConfidence,
      'detectedObjects': instance.detectedObjects,
      'suggestedTags': instance.suggestedTags,
      'qualityScore': instance.qualityScore,
      'isPotentiallyMisleading': instance.isPotentiallyMisleading,
      'classificationNote': instance.classificationNote,
    };
