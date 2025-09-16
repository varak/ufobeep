// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pilot_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PilotNavigationData _$PilotNavigationDataFromJson(Map<String, dynamic> json) =>
    PilotNavigationData(
      compass: CompassData.fromJson(json['compass'] as Map<String, dynamic>),
      groundSpeed: (json['groundSpeed'] as num?)?.toDouble(),
      trueAirspeed: (json['trueAirspeed'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      verticalSpeed: (json['verticalSpeed'] as num?)?.toDouble(),
      bankAngle: (json['bankAngle'] as num?)?.toDouble(),
      pitchAngle: (json['pitchAngle'] as num?)?.toDouble(),
      wind: json['wind'] == null
          ? null
          : WindData.fromJson(json['wind'] as Map<String, dynamic>),
      solution: json['solution'] == null
          ? null
          : NavigationSolution.fromJson(
              json['solution'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PilotNavigationDataToJson(
  PilotNavigationData instance,
) => <String, dynamic>{
  'compass': instance.compass,
  'groundSpeed': instance.groundSpeed,
  'trueAirspeed': instance.trueAirspeed,
  'altitude': instance.altitude,
  'verticalSpeed': instance.verticalSpeed,
  'bankAngle': instance.bankAngle,
  'pitchAngle': instance.pitchAngle,
  'wind': instance.wind,
  'solution': instance.solution,
};

WindData _$WindDataFromJson(Map<String, dynamic> json) => WindData(
  direction: (json['direction'] as num).toDouble(),
  speed: (json['speed'] as num).toDouble(),
  gust: (json['gust'] as num?)?.toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  accuracy:
      $enumDecodeNullable(_$WindAccuracyEnumMap, json['accuracy']) ??
      WindAccuracy.estimated,
);

Map<String, dynamic> _$WindDataToJson(WindData instance) => <String, dynamic>{
  'direction': instance.direction,
  'speed': instance.speed,
  'gust': instance.gust,
  'timestamp': instance.timestamp.toIso8601String(),
  'accuracy': _$WindAccuracyEnumMap[instance.accuracy]!,
};

const _$WindAccuracyEnumMap = {
  WindAccuracy.measured: 'measured',
  WindAccuracy.estimated: 'estimated',
  WindAccuracy.forecast: 'forecast',
  WindAccuracy.unknown: 'unknown',
};

NavigationSolution _$NavigationSolutionFromJson(
  Map<String, dynamic> json,
) => NavigationSolution(
  target: CompassTarget.fromJson(json['target'] as Map<String, dynamic>),
  distance: (json['distance'] as num).toDouble(),
  bearing: (json['bearing'] as num).toDouble(),
  magneticBearing: (json['magneticBearing'] as num).toDouble(),
  relativeBearing: (json['relativeBearing'] as num).toDouble(),
  estimatedTimeEnroute: json['estimatedTimeEnroute'] == null
      ? null
      : Duration(microseconds: (json['estimatedTimeEnroute'] as num).toInt()),
  desiredTrack: (json['desiredTrack'] as num?)?.toDouble(),
  trackError: (json['trackError'] as num?)?.toDouble(),
  requiredHeading: (json['requiredHeading'] as num?)?.toDouble(),
  intercept: json['intercept'] == null
      ? null
      : InterceptSolution.fromJson(json['intercept'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NavigationSolutionToJson(NavigationSolution instance) =>
    <String, dynamic>{
      'target': instance.target,
      'distance': instance.distance,
      'bearing': instance.bearing,
      'magneticBearing': instance.magneticBearing,
      'relativeBearing': instance.relativeBearing,
      'estimatedTimeEnroute': instance.estimatedTimeEnroute?.inMicroseconds,
      'desiredTrack': instance.desiredTrack,
      'trackError': instance.trackError,
      'requiredHeading': instance.requiredHeading,
      'intercept': instance.intercept,
    };

InterceptSolution _$InterceptSolutionFromJson(Map<String, dynamic> json) =>
    InterceptSolution(
      interceptHeading: (json['interceptHeading'] as num).toDouble(),
      interceptDistance: (json['interceptDistance'] as num).toDouble(),
      interceptTime: Duration(
        microseconds: (json['interceptTime'] as num).toInt(),
      ),
      interceptPoint: LocationData.fromJson(
        json['interceptPoint'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$InterceptSolutionToJson(InterceptSolution instance) =>
    <String, dynamic>{
      'interceptHeading': instance.interceptHeading,
      'interceptDistance': instance.interceptDistance,
      'interceptTime': instance.interceptTime.inMicroseconds,
      'interceptPoint': instance.interceptPoint,
    };
