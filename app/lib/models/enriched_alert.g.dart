// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enriched_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnrichedAlert _$EnrichedAlertFromJson(
  Map<String, dynamic> json,
) => EnrichedAlert(
  sighting: Sighting.fromJson(json['sighting'] as Map<String, dynamic>),
  enrichment: json['enrichment'] == null
      ? null
      : AlertEnrichment.fromJson(json['enrichment'] as Map<String, dynamic>),
  quarantine: json['quarantine'] == null
      ? const QuarantineState()
      : QuarantineState.fromJson(json['quarantine'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EnrichedAlertToJson(EnrichedAlert instance) =>
    <String, dynamic>{
      'sighting': instance.sighting,
      'enrichment': instance.enrichment,
      'quarantine': instance.quarantine,
    };
