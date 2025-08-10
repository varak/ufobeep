import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/compass_data.dart';
import '../models/pilot_data.dart';
import 'compass_math.dart';

/// Advanced pilot navigation service for vectoring and intercept calculations
class PilotNavigationService {
  static final PilotNavigationService _instance = PilotNavigationService._internal();
  factory PilotNavigationService() => _instance;
  PilotNavigationService._internal();

  /// Calculate complete navigation solution for pilot mode
  NavigationSolution calculateNavigationSolution({
    required CompassData compass,
    required CompassTarget target,
    required double groundSpeed,
    double? trueAirspeed,
    WindData? wind,
    double? magneticDeclination,
  }) {
    if (compass.location == null) {
      throw Exception('Current location required for navigation solution');
    }

    // Calculate basic navigation parameters
    final distance = compass.location!.distanceTo(target.location);
    final bearing = CompassMath.calculateBearing(
      compass.location!.latitude,
      compass.location!.longitude,
      target.location.latitude,
      target.location.longitude,
    );
    
    final magneticBearing = CompassMath.normalizeHeading(
      bearing - (magneticDeclination ?? 0)
    );
    
    final relativeBearing = CompassMath.relativeBearing(
      compass.trueHeading,
      bearing,
    );

    // Calculate ETE (Estimated Time Enroute)
    Duration? ete;
    if (groundSpeed > 0) {
      final timeSeconds = distance / groundSpeed;
      ete = Duration(seconds: timeSeconds.round());
    }

    // Calculate wind-corrected heading if wind data available
    double? requiredHeading;
    if (wind != null && trueAirspeed != null && trueAirspeed > 0) {
      requiredHeading = CompassMath.calculateRequiredHeading(
        bearing,
        trueAirspeed,
        wind.direction,
        wind.speed,
      );
    }

    // Calculate intercept solution if target is moving or for optimal approach
    InterceptSolution? intercept;
    if (target.type == TargetType.alert && groundSpeed > 0) {
      intercept = _calculateInterceptSolution(
        currentLocation: compass.location!,
        targetLocation: target.location,
        currentHeading: compass.trueHeading,
        groundSpeed: groundSpeed,
        wind: wind,
      );
    }

    return NavigationSolution(
      target: target,
      distance: distance,
      bearing: bearing,
      magneticBearing: magneticBearing,
      relativeBearing: relativeBearing,
      estimatedTimeEnroute: ete,
      desiredTrack: bearing,
      trackError: 0.0, // Would need previous positions to calculate
      requiredHeading: requiredHeading,
      intercept: intercept,
    );
  }

  /// Calculate intercept solution for moving or stationary target
  InterceptSolution? _calculateInterceptSolution({
    required LocationData currentLocation,
    required LocationData targetLocation,
    required double currentHeading,
    required double groundSpeed,
    WindData? wind,
  }) {
    // For stationary targets, calculate optimal intercept angle
    // This provides the most efficient approach path
    
    final directBearing = CompassMath.calculateBearing(
      currentLocation.latitude,
      currentLocation.longitude,
      targetLocation.latitude,
      targetLocation.longitude,
    );
    
    final directDistance = currentLocation.distanceTo(targetLocation);
    
    // Calculate optimal intercept angle (typically 30-45 degrees for visibility)
    final interceptAngle = _calculateOptimalInterceptAngle(
      directDistance,
      groundSpeed,
    );
    
    // Calculate intercept heading
    final relativeBearing = CompassMath.relativeBearing(currentHeading, directBearing);
    double interceptHeading;
    
    if (relativeBearing.abs() < 90) {
      // Target is ahead - use optimal intercept angle
      interceptHeading = CompassMath.normalizeHeading(
        directBearing + (relativeBearing > 0 ? -interceptAngle : interceptAngle)
      );
    } else {
      // Target is behind - turn towards it first
      interceptHeading = directBearing;
    }
    
    // Calculate intercept point (for visualization)
    final interceptDistance = directDistance * math.cos(interceptAngle * math.pi / 180);
    final interceptTime = Duration(seconds: (interceptDistance / groundSpeed).round());
    
    // Calculate intercept point coordinates
    final interceptPoint = _calculateInterceptPoint(
      currentLocation,
      targetLocation,
      interceptDistance / directDistance,
    );
    
    return InterceptSolution(
      interceptHeading: interceptHeading,
      interceptDistance: interceptDistance,
      interceptTime: interceptTime,
      interceptPoint: interceptPoint,
    );
  }

  /// Calculate optimal intercept angle based on distance and speed
  double _calculateOptimalInterceptAngle(double distance, double groundSpeed) {
    // Closer targets need wider intercept angles for better visibility
    // Farther targets can use shallower angles for efficiency
    
    if (distance < 1000) {
      return 45.0; // Wide angle for close targets
    } else if (distance < 5000) {
      return 30.0; // Medium angle
    } else if (distance < 10000) {
      return 20.0; // Shallow angle
    } else {
      return 15.0; // Very shallow for distant targets
    }
  }

  /// Calculate intercept point coordinates
  LocationData _calculateInterceptPoint(
    LocationData start,
    LocationData end,
    double fraction,
  ) {
    // Linear interpolation between start and end
    final lat = start.latitude + (end.latitude - start.latitude) * fraction;
    final lon = start.longitude + (end.longitude - start.longitude) * fraction;
    
    return LocationData(
      latitude: lat,
      longitude: lon,
      accuracy: 10.0,
      timestamp: DateTime.now(),
    );
  }

  /// Calculate required bank angle for a desired turn rate
  double calculateRequiredBankAngle({
    required double desiredTurnRate, // degrees per second
    required double groundSpeed, // meters per second
  }) {
    if (groundSpeed < 1.0) return 0.0;
    
    const g = 9.81; // gravity m/s²
    final turnRateRad = desiredTurnRate * math.pi / 180;
    final bankRad = math.atan((turnRateRad * groundSpeed) / g);
    return bankRad * 180 / math.pi;
  }

  /// Calculate standard rate turn bank angle
  double calculateStandardRateBankAngle(double groundSpeed) {
    // Standard rate is 3 degrees per second
    return calculateRequiredBankAngle(
      desiredTurnRate: 3.0,
      groundSpeed: groundSpeed,
    );
  }

  /// Calculate turn radius for given bank angle and speed
  double calculateTurnRadius({
    required double bankAngle, // degrees
    required double groundSpeed, // meters per second
  }) {
    if (bankAngle.abs() < 0.1) return double.infinity;
    
    const g = 9.81; // gravity m/s²
    final bankRad = bankAngle * math.pi / 180;
    return (groundSpeed * groundSpeed) / (g * math.tan(bankRad));
  }

  /// Calculate time to complete turn
  Duration calculateTurnTime({
    required double headingChange, // degrees
    required double turnRate, // degrees per second
  }) {
    if (turnRate.abs() < 0.1) return const Duration(days: 999);
    
    final seconds = headingChange.abs() / turnRate.abs();
    return Duration(seconds: seconds.round());
  }

  /// Create pilot navigation data with all calculations
  PilotNavigationData createPilotNavigationData({
    required CompassData compass,
    CompassTarget? target,
    double groundSpeed = 50.0, // Default ~100 knots
    double trueAirspeed = 52.0, // Default ~100 knots
    double altitude = 1000.0, // Default ~3000 feet
    double verticalSpeed = 0.0,
    double bankAngle = 0.0,
    double pitchAngle = 0.0,
    WindData? wind,
    double? magneticDeclination,
  }) {
    NavigationSolution? solution;
    
    if (target != null && compass.location != null) {
      solution = calculateNavigationSolution(
        compass: compass,
        target: target,
        groundSpeed: groundSpeed,
        trueAirspeed: trueAirspeed,
        wind: wind,
        magneticDeclination: magneticDeclination,
      );
    }
    
    return PilotNavigationData(
      compass: compass,
      groundSpeed: groundSpeed,
      trueAirspeed: trueAirspeed,
      altitude: altitude,
      verticalSpeed: verticalSpeed,
      bankAngle: bankAngle,
      pitchAngle: pitchAngle,
      wind: wind,
      solution: solution,
    );
  }

  /// Calculate ground track and drift angle
  ({double groundTrack, double driftAngle}) calculateGroundTrack({
    required double heading,
    required double trueAirspeed,
    required double windDirection,
    required double windSpeed,
  }) {
    if (trueAirspeed < 0.1) {
      return (groundTrack: heading, driftAngle: 0.0);
    }
    
    final result = CompassMath.calculateWindTriangle(
      trueAirspeed,
      heading,
      windDirection,
      windSpeed,
    );
    
    return (
      groundTrack: result.trackAngle,
      driftAngle: result.driftAngle,
    );
  }

  /// Calculate climb/descent profile
  ({double requiredVerticalSpeed, Duration timeToAltitude}) calculateAltitudeChange({
    required double currentAltitude,
    required double targetAltitude,
    required double groundSpeed,
    required double distanceToTarget,
  }) {
    final altitudeChange = targetAltitude - currentAltitude;
    
    if (groundSpeed < 0.1 || distanceToTarget < 1.0) {
      return (requiredVerticalSpeed: 0.0, timeToAltitude: Duration.zero);
    }
    
    final timeToTarget = distanceToTarget / groundSpeed;
    final requiredVS = altitudeChange / timeToTarget;
    
    return (
      requiredVerticalSpeed: requiredVS,
      timeToAltitude: Duration(seconds: timeToTarget.round()),
    );
  }

  /// Calculate glide ratio and range
  double calculateGlideRange({
    required double altitude,
    required double glideRatio,
    WindData? wind,
    double? heading,
  }) {
    // Basic glide range without wind
    double range = altitude * glideRatio;
    
    // Adjust for wind if available
    if (wind != null && heading != null) {
      final headwindComponent = wind.headwindComponent(heading);
      // Simplified wind effect on glide range
      final windEffect = headwindComponent * (altitude / 100); // Rough approximation
      range += windEffect;
    }
    
    return math.max(0, range);
  }

  /// Calculate fuel burn and endurance (mock implementation)
  ({double fuelBurn, Duration endurance}) calculateFuelMetrics({
    required double fuelRemaining, // liters
    required double fuelFlowRate, // liters per hour
  }) {
    if (fuelFlowRate <= 0) {
      return (fuelBurn: 0.0, endurance: const Duration(hours: 99));
    }
    
    final hoursRemaining = fuelRemaining / fuelFlowRate;
    final endurance = Duration(
      hours: hoursRemaining.floor(),
      minutes: ((hoursRemaining % 1) * 60).round(),
    );
    
    return (fuelBurn: fuelFlowRate, endurance: endurance);
  }

  /// Determine if within visual range of target
  bool isWithinVisualRange(double distance) {
    // Standard visual range conditions
    const excellentVisibility = 50000.0; // 50km in excellent conditions
    const goodVisibility = 20000.0; // 20km in good conditions
    const fairVisibility = 10000.0; // 10km in fair conditions
    const poorVisibility = 5000.0; // 5km in poor conditions
    
    // For now, assume good conditions
    return distance <= goodVisibility;
  }

  /// Get approach guidance text
  String getApproachGuidance(NavigationSolution solution) {
    final distance = solution.distance;
    final relativeBearing = solution.relativeBearing;
    
    if (distance < 100) {
      return 'Target overhead - maintain visual';
    } else if (distance < 500) {
      return 'Very close - reduce speed and maintain visual';
    } else if (distance < 1000) {
      return 'Close approach - prepare for visual identification';
    } else if (distance < 5000) {
      if (relativeBearing.abs() < 30) {
        return 'On approach - maintain heading';
      } else {
        return 'Adjust heading ${solution.turnDirection.toLowerCase()}';
      }
    } else {
      if (relativeBearing.abs() < 15) {
        return 'On course to target';
      } else {
        return 'Turn ${relativeBearing > 0 ? 'right' : 'left'} to intercept';
      }
    }
  }
}