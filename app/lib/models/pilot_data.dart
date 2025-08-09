import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';
import 'compass_data.dart';

part 'pilot_data.g.dart';

@JsonSerializable()
class PilotNavigationData {
  final CompassData compass;
  final double? groundSpeed;          // Speed over ground in m/s
  final double? trueAirspeed;         // True airspeed in m/s
  final double? altitude;             // Altitude in meters
  final double? verticalSpeed;        // Vertical speed in m/s
  final double? bankAngle;            // Bank angle in degrees (-180 to +180)
  final double? pitchAngle;           // Pitch angle in degrees (-90 to +90)
  final WindData? wind;               // Wind data
  final NavigationSolution? solution; // Navigation solution to target

  const PilotNavigationData({
    required this.compass,
    this.groundSpeed,
    this.trueAirspeed,
    this.altitude,
    this.verticalSpeed,
    this.bankAngle,
    this.pitchAngle,
    this.wind,
    this.solution,
  });

  factory PilotNavigationData.fromJson(Map<String, dynamic> json) =>
      _$PilotNavigationDataFromJson(json);

  Map<String, dynamic> toJson() => _$PilotNavigationDataToJson(this);

  // Calculate heading rate of turn
  double get turnRate {
    if (bankAngle == null || groundSpeed == null || groundSpeed! < 1.0) {
      return 0.0;
    }
    
    // Standard rate turn formula: rate = (g * tan(bank)) / speed
    const g = 9.81; // gravity
    final bankRad = bankAngle! * math.pi / 180.0;
    final rate = (g * math.tan(bankRad)) / groundSpeed!;
    return rate * 180.0 / math.pi; // Convert to degrees per second
  }

  // Get bank angle description
  String get bankDescription {
    if (bankAngle == null) return 'Level';
    
    final abs = bankAngle!.abs();
    final direction = bankAngle! > 0 ? 'Right' : 'Left';
    
    if (abs < 5) return 'Level';
    if (abs < 15) return 'Shallow $direction';
    if (abs < 30) return 'Medium $direction';
    if (abs < 45) return 'Steep $direction';
    return 'Extreme $direction';
  }

  // Get formatted speeds
  String get groundSpeedFormatted {
    if (groundSpeed == null) return '--';
    final knots = groundSpeed! * 1.94384; // m/s to knots
    return '${knots.toStringAsFixed(0)} kts';
  }

  String get trueAirspeedFormatted {
    if (trueAirspeed == null) return '--';
    final knots = trueAirspeed! * 1.94384; // m/s to knots
    return '${knots.toStringAsFixed(0)} kts';
  }

  String get altitudeFormatted {
    if (altitude == null) return '--';
    final feet = altitude! * 3.28084; // meters to feet
    return '${feet.toStringAsFixed(0)} ft';
  }

  String get verticalSpeedFormatted {
    if (verticalSpeed == null) return '--';
    final fpm = verticalSpeed! * 196.85; // m/s to feet per minute
    final sign = fpm >= 0 ? '+' : '';
    return '$sign${fpm.toStringAsFixed(0)} fpm';
  }
}

@JsonSerializable()
class WindData {
  final double direction;    // Wind direction in degrees (where wind is coming from)
  final double speed;        // Wind speed in m/s
  final double? gust;        // Gust speed in m/s
  final DateTime timestamp;
  final WindAccuracy accuracy;

  const WindData({
    required this.direction,
    required this.speed,
    this.gust,
    required this.timestamp,
    this.accuracy = WindAccuracy.estimated,
  });

  factory WindData.fromJson(Map<String, dynamic> json) =>
      _$WindDataFromJson(json);

  Map<String, dynamic> toJson() => _$WindDataToJson(this);

  // Calculate headwind/tailwind component for a given heading
  double headwindComponent(double heading) {
    final windAngle = (direction - heading) * math.pi / 180.0;
    return speed * math.cos(windAngle);
  }

  // Calculate crosswind component for a given heading
  double crosswindComponent(double heading) {
    final windAngle = (direction - heading) * math.pi / 180.0;
    return speed * math.sin(windAngle);
  }

  String get formattedWind {
    final knots = speed * 1.94384; // m/s to knots
    if (gust != null) {
      final gustKnots = gust! * 1.94384;
      return '${direction.toStringAsFixed(0)}°/${knots.toStringAsFixed(0)}G${gustKnots.toStringAsFixed(0)}';
    }
    return '${direction.toStringAsFixed(0)}°/${knots.toStringAsFixed(0)}';
  }

  String getWindComponent(double heading) {
    final headwind = headwindComponent(heading);
    final crosswind = crosswindComponent(heading);
    final crosswindKnots = crosswind.abs() * 1.94384;
    final headwindKnots = headwind * 1.94384;
    
    String result = '';
    
    if (headwind.abs() > 0.5) {
      if (headwind > 0) {
        result += 'H${headwindKnots.toStringAsFixed(0)}';
      } else {
        result += 'T${headwindKnots.abs().toStringAsFixed(0)}';
      }
    }
    
    if (crosswindKnots > 1) {
      if (result.isNotEmpty) result += ' ';
      final direction = crosswind > 0 ? 'R' : 'L';
      result += 'X${crosswindKnots.toStringAsFixed(0)}$direction';
    }
    
    return result.isEmpty ? 'Calm' : result;
  }
}

@JsonSerializable()
class NavigationSolution {
  final CompassTarget target;
  final double distance;              // Distance to target in meters
  final double bearing;               // True bearing to target
  final double magneticBearing;       // Magnetic bearing to target
  final double relativeBearing;       // Relative bearing (-180 to +180)
  final Duration? estimatedTimeEnroute; // ETE to target
  final double? desiredTrack;         // Desired track to target
  final double? trackError;           // Cross-track error in meters
  final double? requiredHeading;      // Required heading accounting for wind
  final InterceptSolution? intercept; // Intercept solution if applicable

  const NavigationSolution({
    required this.target,
    required this.distance,
    required this.bearing,
    required this.magneticBearing,
    required this.relativeBearing,
    this.estimatedTimeEnroute,
    this.desiredTrack,
    this.trackError,
    this.requiredHeading,
    this.intercept,
  });

  factory NavigationSolution.fromJson(Map<String, dynamic> json) =>
      _$NavigationSolutionFromJson(json);

  Map<String, dynamic> toJson() => _$NavigationSolutionToJson(this);

  String get distanceFormatted {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      final km = distance / 1000;
      if (km < 10) {
        return '${km.toStringAsFixed(1)} km';
      } else {
        return '${km.toStringAsFixed(0)} km';
      }
    }
  }

  String get bearingFormatted => '${bearing.toStringAsFixed(0)}°';
  String get magneticBearingFormatted => '${magneticBearing.toStringAsFixed(0)}°';

  String get relativeBearingFormatted {
    final abs = relativeBearing.abs();
    final direction = relativeBearing >= 0 ? 'R' : 'L';
    return '${abs.toStringAsFixed(0)}° $direction';
  }

  String? get estimatedTimeEnrouteFormatted {
    if (estimatedTimeEnroute == null) return null;
    
    final minutes = estimatedTimeEnroute!.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  String? get trackErrorFormatted {
    if (trackError == null) return null;
    
    final abs = trackError!.abs();
    final direction = trackError! > 0 ? 'R' : 'L';
    
    if (abs < 1000) {
      return '${abs.toStringAsFixed(0)}m $direction';
    } else {
      return '${(abs / 1000).toStringAsFixed(1)}km $direction';
    }
  }

  // Get turn direction to target
  String get turnDirection {
    if (relativeBearing.abs() < 5) return 'On heading';
    if (relativeBearing > 0) return 'Turn right';
    return 'Turn left';
  }

  // Get navigation guidance
  String get navigationGuidance {
    final abs = relativeBearing.abs();
    
    if (abs < 5) return 'On course';
    if (abs < 15) return 'Minor correction ${relativeBearing > 0 ? 'right' : 'left'}';
    if (abs < 30) return 'Turn ${relativeBearing > 0 ? 'right' : 'left'}';
    if (abs < 90) return 'Major turn ${relativeBearing > 0 ? 'right' : 'left'}';
    if (abs < 135) return 'Sharp turn ${relativeBearing > 0 ? 'right' : 'left'}';
    return 'Reverse course';
  }
}

@JsonSerializable()
class InterceptSolution {
  final double interceptHeading;      // Heading to intercept target's path
  final double interceptDistance;     // Distance to intercept point
  final Duration interceptTime;       // Time to intercept
  final LocationData interceptPoint;  // Intercept coordinates

  const InterceptSolution({
    required this.interceptHeading,
    required this.interceptDistance,
    required this.interceptTime,
    required this.interceptPoint,
  });

  factory InterceptSolution.fromJson(Map<String, dynamic> json) =>
      _$InterceptSolutionFromJson(json);

  Map<String, dynamic> toJson() => _$InterceptSolutionToJson(this);

  String get headingFormatted => '${interceptHeading.toStringAsFixed(0)}°';
  String get distanceFormatted => '${(interceptDistance / 1000).toStringAsFixed(1)} km';
  String get timeFormatted {
    final minutes = interceptTime.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }
}

enum WindAccuracy {
  measured,
  estimated,
  forecast,
  unknown,
}

extension WindAccuracyExtension on WindAccuracy {
  String get displayName {
    switch (this) {
      case WindAccuracy.measured:
        return 'Measured';
      case WindAccuracy.estimated:
        return 'Estimated';
      case WindAccuracy.forecast:
        return 'Forecast';
      case WindAccuracy.unknown:
        return 'Unknown';
    }
  }

  String get shortName {
    switch (this) {
      case WindAccuracy.measured:
        return 'METAR';
      case WindAccuracy.estimated:
        return 'EST';
      case WindAccuracy.forecast:
        return 'FC';
      case WindAccuracy.unknown:
        return '--';
    }
  }
}