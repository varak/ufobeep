// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compass_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompassData _$CompassDataFromJson(Map<String, dynamic> json) => CompassData(
  magneticHeading: (json['magneticHeading'] as num).toDouble(),
  trueHeading: (json['trueHeading'] as num).toDouble(),
  accuracy: (json['accuracy'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  calibration:
      $enumDecodeNullable(
        _$CompassCalibrationLevelEnumMap,
        json['calibration'],
      ) ??
      CompassCalibrationLevel.unknown,
  location: json['location'] == null
      ? null
      : LocationData.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CompassDataToJson(CompassData instance) =>
    <String, dynamic>{
      'magneticHeading': instance.magneticHeading,
      'trueHeading': instance.trueHeading,
      'accuracy': instance.accuracy,
      'timestamp': instance.timestamp.toIso8601String(),
      'calibration': _$CompassCalibrationLevelEnumMap[instance.calibration]!,
      'location': instance.location,
    };

const _$CompassCalibrationLevelEnumMap = {
  CompassCalibrationLevel.unknown: 'unknown',
  CompassCalibrationLevel.low: 'low',
  CompassCalibrationLevel.medium: 'medium',
  CompassCalibrationLevel.high: 'high',
};

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
  accuracy: (json['accuracy'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'accuracy': instance.accuracy,
      'timestamp': instance.timestamp.toIso8601String(),
    };

CompassTarget _$CompassTargetFromJson(Map<String, dynamic> json) =>
    CompassTarget(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      location: LocationData.fromJson(json['location'] as Map<String, dynamic>),
      type:
          $enumDecodeNullable(_$TargetTypeEnumMap, json['type']) ??
          TargetType.waypoint,
      estimatedArrival: json['estimatedArrival'] == null
          ? null
          : DateTime.parse(json['estimatedArrival'] as String),
      distance: (json['distance'] as num?)?.toDouble(),
      status:
          $enumDecodeNullable(_$CompassTargetStatusEnumMap, json['status']) ??
          CompassTargetStatus.active,
    );

Map<String, dynamic> _$CompassTargetToJson(CompassTarget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'location': instance.location,
      'type': _$TargetTypeEnumMap[instance.type]!,
      'estimatedArrival': instance.estimatedArrival?.toIso8601String(),
      'distance': instance.distance,
      'status': _$CompassTargetStatusEnumMap[instance.status]!,
    };

const _$TargetTypeEnumMap = {
  TargetType.waypoint: 'waypoint',
  TargetType.alert: 'alert',
  TargetType.landmark: 'landmark',
  TargetType.emergency: 'emergency',
};

const _$CompassTargetStatusEnumMap = {
  CompassTargetStatus.active: 'active',
  CompassTargetStatus.reached: 'reached',
  CompassTargetStatus.inactive: 'inactive',
};
