import 'package:json_annotation/json_annotation.dart';

part 'sensor_data.g.dart';

@JsonSerializable()
class SensorData {
  final DateTime utc;
  final double latitude;
  final double longitude;
  final double azimuthDeg;
  final double pitchDeg;
  final double? rollDeg;
  final double? hfovDeg;
  final double? accuracy;
  final double? altitude;

  const SensorData({
    required this.utc,
    required this.latitude,
    required this.longitude,
    required this.azimuthDeg,
    required this.pitchDeg,
    this.rollDeg,
    this.hfovDeg,
    this.accuracy,
    this.altitude,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) =>
      _$SensorDataFromJson(json);

  Map<String, dynamic> toJson() => _$SensorDataToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensorData &&
          runtimeType == other.runtimeType &&
          utc == other.utc &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          azimuthDeg == other.azimuthDeg &&
          pitchDeg == other.pitchDeg &&
          rollDeg == other.rollDeg &&
          hfovDeg == other.hfovDeg &&
          accuracy == other.accuracy &&
          altitude == other.altitude;

  @override
  int get hashCode => Object.hash(
        utc,
        latitude,
        longitude,
        azimuthDeg,
        pitchDeg,
        rollDeg,
        hfovDeg,
        accuracy,
        altitude,
      );

  @override
  String toString() {
    return 'SensorData{'
        'utc: $utc, '
        'lat: $latitude, '
        'lng: $longitude, '
        'azimuth: ${azimuthDeg}°, '
        'pitch: ${pitchDeg}°, '
        'roll: ${rollDeg}°, '
        'hfov: ${hfovDeg}°, '
        'accuracy: ${accuracy}m, '
        'altitude: ${altitude}m'
        '}';
  }

  SensorData copyWith({
    DateTime? utc,
    double? latitude,
    double? longitude,
    double? azimuthDeg,
    double? pitchDeg,
    double? rollDeg,
    double? hfovDeg,
    double? accuracy,
    double? altitude,
  }) {
    return SensorData(
      utc: utc ?? this.utc,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      azimuthDeg: azimuthDeg ?? this.azimuthDeg,
      pitchDeg: pitchDeg ?? this.pitchDeg,
      rollDeg: rollDeg ?? this.rollDeg,
      hfovDeg: hfovDeg ?? this.hfovDeg,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
    );
  }
}

@JsonSerializable()
class PlaneMatchRequest {
  final SensorData sensorData;
  final String? photoPath;
  final String? description;

  const PlaneMatchRequest({
    required this.sensorData,
    this.photoPath,
    this.description,
  });

  factory PlaneMatchRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaneMatchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PlaneMatchRequestToJson(this);
}

@JsonSerializable()
class PlaneMatchResponse {
  final bool isPlane;
  final PlaneMatchInfo? matchedFlight;
  final double confidence;
  final String reason;
  final DateTime timestamp;

  const PlaneMatchResponse({
    required this.isPlane,
    this.matchedFlight,
    required this.confidence,
    required this.reason,
    required this.timestamp,
  });

  factory PlaneMatchResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaneMatchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlaneMatchResponseToJson(this);
}

@JsonSerializable()
class PlaneMatchInfo {
  final String? callsign;
  final String? icao24;
  final String? aircraftType;
  final String? origin;
  final String? destination;
  final double? altitude;
  final double? velocity;
  final double angularError;

  const PlaneMatchInfo({
    this.callsign,
    this.icao24,
    this.aircraftType,
    this.origin,
    this.destination,
    this.altitude,
    this.velocity,
    required this.angularError,
  });

  factory PlaneMatchInfo.fromJson(Map<String, dynamic> json) =>
      _$PlaneMatchInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PlaneMatchInfoToJson(this);

  String get displayName {
    if (callsign?.isNotEmpty == true) {
      return callsign!;
    }
    if (aircraftType?.isNotEmpty == true) {
      return aircraftType!;
    }
    if (icao24?.isNotEmpty == true) {
      return 'Aircraft ${icao24!.toUpperCase()}';
    }
    return 'Unknown Aircraft';
  }

  String get displayRoute {
    if (origin?.isNotEmpty == true && destination?.isNotEmpty == true) {
      return '$origin → $destination';
    }
    return '';
  }
}