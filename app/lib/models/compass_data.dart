import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';

part 'compass_data.g.dart';

@JsonSerializable()
class CompassData {
  final double magneticHeading;    // 0-360 degrees from magnetic north
  final double trueHeading;        // 0-360 degrees from true north
  final double accuracy;           // Accuracy of the reading in degrees
  final DateTime timestamp;       // When the reading was taken
  final CompassCalibrationLevel calibration;
  final LocationData? location;   // Current location for true heading calculation

  const CompassData({
    required this.magneticHeading,
    required this.trueHeading,
    required this.accuracy,
    required this.timestamp,
    this.calibration = CompassCalibrationLevel.unknown,
    this.location,
  });

  factory CompassData.fromJson(Map<String, dynamic> json) =>
      _$CompassDataFromJson(json);

  Map<String, dynamic> toJson() => _$CompassDataToJson(this);

  CompassData copyWith({
    double? magneticHeading,
    double? trueHeading,
    double? accuracy,
    DateTime? timestamp,
    CompassCalibrationLevel? calibration,
    LocationData? location,
  }) {
    return CompassData(
      magneticHeading: magneticHeading ?? this.magneticHeading,
      trueHeading: trueHeading ?? this.trueHeading,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      calibration: calibration ?? this.calibration,
      location: location ?? this.location,
    );
  }

  // Calculate bearing to target from current position
  double bearingToTarget(LocationData target) {
    if (location == null) return 0.0;
    
    final lat1Rad = location!.latitude * math.pi / 180.0;
    final lat2Rad = target.latitude * math.pi / 180.0;
    final deltaLonRad = (target.longitude - location!.longitude) * math.pi / 180.0;
    
    final y = math.sin(deltaLonRad) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLonRad);
    
    double bearing = math.atan2(y, x) * 180.0 / math.pi;
    return (bearing + 360.0) % 360.0;
  }

  // Calculate relative bearing (difference between heading and target bearing)
  double relativeBearing(LocationData target) {
    final targetBearing = bearingToTarget(target);
    double relative = targetBearing - trueHeading;
    
    if (relative < -180.0) relative += 360.0;
    if (relative > 180.0) relative -= 360.0;
    
    return relative;
  }

  // Get cardinal direction as string
  String get cardinalDirection {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
                       'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    
    final index = ((trueHeading + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  // Format heading as string with degrees
  String get formattedHeading => '${trueHeading.toStringAsFixed(0)}°';
  
  String get formattedMagneticHeading => '${magneticHeading.toStringAsFixed(0)}°';
  
  // Get accuracy level description
  String get accuracyDescription {
    if (accuracy <= 5) return 'Excellent';
    if (accuracy <= 15) return 'Good';
    if (accuracy <= 30) return 'Fair';
    return 'Poor';
  }

  bool get isAccurate => accuracy <= 15.0;
  bool get needsCalibration => calibration == CompassCalibrationLevel.low ||
                               calibration == CompassCalibrationLevel.unknown;
}

@JsonSerializable()
class LocationData {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double accuracy;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.accuracy,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataToJson(this);

  // Calculate distance to another location in meters
  double distanceTo(LocationData other) {
    const earthRadius = 6371000.0; // meters
    
    final lat1Rad = latitude * math.pi / 180.0;
    final lat2Rad = other.latitude * math.pi / 180.0;
    final deltaLatRad = (other.latitude - latitude) * math.pi / 180.0;
    final deltaLonRad = (other.longitude - longitude) * math.pi / 180.0;
    
    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLonRad / 2) * math.sin(deltaLonRad / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  String get formattedCoordinates => 
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

@JsonSerializable()
class CompassTarget {
  final String id;
  final String name;
  final String? description;
  final LocationData location;
  final TargetType type;
  final DateTime? estimatedArrival;
  final double? distance; // in meters
  final CompassTargetStatus status;

  const CompassTarget({
    required this.id,
    required this.name,
    this.description,
    required this.location,
    this.type = TargetType.waypoint,
    this.estimatedArrival,
    this.distance,
    this.status = CompassTargetStatus.active,
  });

  factory CompassTarget.fromJson(Map<String, dynamic> json) =>
      _$CompassTargetFromJson(json);

  Map<String, dynamic> toJson() => _$CompassTargetToJson(this);

  String get formattedDistance {
    if (distance == null) return 'Unknown';
    
    if (distance! < 1000) {
      return '${distance!.toStringAsFixed(0)} m';
    } else if (distance! < 10000) {
      return '${(distance! / 1000).toStringAsFixed(1)} km';
    } else {
      return '${(distance! / 1000).toStringAsFixed(0)} km';
    }
  }

  String? get formattedETA {
    if (estimatedArrival == null) return null;
    
    final now = DateTime.now();
    final diff = estimatedArrival!.difference(now);
    
    if (diff.isNegative) return 'Arrived';
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    } else {
      return '${diff.inDays}d ${diff.inHours % 24}h';
    }
  }
}

enum CompassCalibrationLevel {
  unknown,
  low,
  medium,
  high,
}

enum TargetType {
  waypoint,
  alert,
  landmark,
  emergency,
}

enum CompassTargetStatus {
  active,
  reached,
  inactive,
}

extension CompassCalibrationLevelExtension on CompassCalibrationLevel {
  String get displayName {
    switch (this) {
      case CompassCalibrationLevel.unknown:
        return 'Unknown';
      case CompassCalibrationLevel.low:
        return 'Needs Calibration';
      case CompassCalibrationLevel.medium:
        return 'Fair';
      case CompassCalibrationLevel.high:
        return 'Good';
    }
  }
}

extension TargetTypeExtension on TargetType {
  String get displayName {
    switch (this) {
      case TargetType.waypoint:
        return 'Waypoint';
      case TargetType.alert:
        return 'Alert';
      case TargetType.landmark:
        return 'Landmark';
      case TargetType.emergency:
        return 'Emergency';
    }
  }
}