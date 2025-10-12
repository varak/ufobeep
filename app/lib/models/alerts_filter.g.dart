// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertsFilter _$AlertsFilterFromJson(Map<String, dynamic> json) => AlertsFilter(
  categories:
      (json['categories'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const {},
  maxDistanceKm: (json['maxDistanceKm'] as num?)?.toDouble(),
  maxAgeHours: (json['maxAgeHours'] as num?)?.toInt(),
  verifiedOnly: json['verifiedOnly'] as bool?,
  showUfoBeepOnly: json['showUfoBeepOnly'] as bool?,
  alertRangeKm: (json['alertRangeKm'] as num?)?.toDouble(),
  sortBy:
      $enumDecodeNullable(_$AlertSortByEnumMap, json['sortBy']) ??
      AlertSortBy.newest,
  ascending: json['ascending'] as bool? ?? false,
);

Map<String, dynamic> _$AlertsFilterToJson(AlertsFilter instance) =>
    <String, dynamic>{
      'categories': instance.categories.toList(),
      'maxDistanceKm': instance.maxDistanceKm,
      'maxAgeHours': instance.maxAgeHours,
      'verifiedOnly': instance.verifiedOnly,
      'showUfoBeepOnly': instance.showUfoBeepOnly,
      'alertRangeKm': instance.alertRangeKm,
      'sortBy': _$AlertSortByEnumMap[instance.sortBy]!,
      'ascending': instance.ascending,
    };

const _$AlertSortByEnumMap = {
  AlertSortBy.newest: 'newest',
  AlertSortBy.oldest: 'oldest',
  AlertSortBy.distance: 'distance',
  AlertSortBy.category: 'category',
  AlertSortBy.verified: 'verified',
};
