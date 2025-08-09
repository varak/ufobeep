// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorData _$SensorDataFromJson(Map<String, dynamic> json) => SensorData(
  utc: DateTime.parse(json['utc'] as String),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  azimuthDeg: (json['azimuthDeg'] as num).toDouble(),
  pitchDeg: (json['pitchDeg'] as num).toDouble(),
  rollDeg: (json['rollDeg'] as num?)?.toDouble(),
  hfovDeg: (json['hfovDeg'] as num?)?.toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SensorDataToJson(SensorData instance) =>
    <String, dynamic>{
      'utc': instance.utc.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'azimuthDeg': instance.azimuthDeg,
      'pitchDeg': instance.pitchDeg,
      'rollDeg': instance.rollDeg,
      'hfovDeg': instance.hfovDeg,
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
    };

PlaneMatchRequest _$PlaneMatchRequestFromJson(Map<String, dynamic> json) =>
    PlaneMatchRequest(
      sensorData: SensorData.fromJson(
        json['sensorData'] as Map<String, dynamic>,
      ),
      photoPath: json['photoPath'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PlaneMatchRequestToJson(PlaneMatchRequest instance) =>
    <String, dynamic>{
      'sensorData': instance.sensorData,
      'photoPath': instance.photoPath,
      'description': instance.description,
    };

PlaneMatchResponse _$PlaneMatchResponseFromJson(Map<String, dynamic> json) =>
    PlaneMatchResponse(
      isPlane: json['isPlane'] as bool,
      matchedFlight: json['matchedFlight'] == null
          ? null
          : PlaneMatchInfo.fromJson(
              json['matchedFlight'] as Map<String, dynamic>,
            ),
      confidence: (json['confidence'] as num).toDouble(),
      reason: json['reason'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$PlaneMatchResponseToJson(PlaneMatchResponse instance) =>
    <String, dynamic>{
      'isPlane': instance.isPlane,
      'matchedFlight': instance.matchedFlight,
      'confidence': instance.confidence,
      'reason': instance.reason,
      'timestamp': instance.timestamp.toIso8601String(),
    };

PlaneMatchInfo _$PlaneMatchInfoFromJson(Map<String, dynamic> json) =>
    PlaneMatchInfo(
      callsign: json['callsign'] as String?,
      icao24: json['icao24'] as String?,
      aircraftType: json['aircraftType'] as String?,
      origin: json['origin'] as String?,
      destination: json['destination'] as String?,
      altitude: (json['altitude'] as num?)?.toDouble(),
      velocity: (json['velocity'] as num?)?.toDouble(),
      angularError: (json['angularError'] as num).toDouble(),
    );

Map<String, dynamic> _$PlaneMatchInfoToJson(PlaneMatchInfo instance) =>
    <String, dynamic>{
      'callsign': instance.callsign,
      'icao24': instance.icao24,
      'aircraftType': instance.aircraftType,
      'origin': instance.origin,
      'destination': instance.destination,
      'altitude': instance.altitude,
      'velocity': instance.velocity,
      'angularError': instance.angularError,
    };
