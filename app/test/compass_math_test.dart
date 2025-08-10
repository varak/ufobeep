import 'package:flutter_test/flutter_test.dart';
import 'package:ufobeep/services/compass_math.dart';

void main() {
  group('CompassMath Tests', () {
    test('Calculate distance between two points', () {
      // San Francisco to Los Angeles (approximately 559 km)
      final distance = CompassMath.greatCircleDistance(
        37.7749, -122.4194, // SF
        34.0522, -118.2437, // LA
      );
      
      // Should be approximately 559 km (559,000 meters)
      expect(distance, greaterThan(558000));
      expect(distance, lessThan(560000));
    });

    test('Calculate bearing between two points', () {
      // North bearing (0 degrees)
      final northBearing = CompassMath.calculateBearing(
        0.0, 0.0,  // Origin
        1.0, 0.0,  // 1 degree north
      );
      expect(northBearing, closeTo(0, 1));

      // East bearing (90 degrees)
      final eastBearing = CompassMath.calculateBearing(
        0.0, 0.0,  // Origin
        0.0, 1.0,  // 1 degree east
      );
      expect(eastBearing, closeTo(90, 1));

      // South bearing (180 degrees)
      final southBearing = CompassMath.calculateBearing(
        1.0, 0.0,  // 1 degree north
        0.0, 0.0,  // Origin
      );
      expect(southBearing, closeTo(180, 1));

      // West bearing (270 degrees)
      final westBearing = CompassMath.calculateBearing(
        0.0, 1.0,  // 1 degree east
        0.0, 0.0,  // Origin
      );
      expect(westBearing, closeTo(270, 1));
    });

    test('Normalize heading to 0-360 range', () {
      expect(CompassMath.normalizeHeading(0), equals(0));
      expect(CompassMath.normalizeHeading(180), equals(180));
      expect(CompassMath.normalizeHeading(360), equals(0));
      expect(CompassMath.normalizeHeading(720), equals(0));
      expect(CompassMath.normalizeHeading(-90), equals(270));
      expect(CompassMath.normalizeHeading(-180), equals(180));
      expect(CompassMath.normalizeHeading(-360), equals(0));
    });

    test('Calculate relative bearing', () {
      // Straight ahead
      expect(CompassMath.relativeBearing(0, 0), equals(0));
      
      // 45 degrees to the right
      expect(CompassMath.relativeBearing(0, 45), equals(45));
      
      // 45 degrees to the left
      expect(CompassMath.relativeBearing(45, 0), equals(-45));
      
      // Behind (180 degrees)
      expect(CompassMath.relativeBearing(0, 180), equals(180));
      expect(CompassMath.relativeBearing(180, 0), equals(-180));
      
      // Wrap around cases
      expect(CompassMath.relativeBearing(350, 10), equals(20));
      expect(CompassMath.relativeBearing(10, 350), equals(-20));
    });

    test('Convert degrees to cardinal directions', () {
      expect(CompassMath.degreesToCardinal(0), equals('N'));
      expect(CompassMath.degreesToCardinal(22.5), equals('NNE'));
      expect(CompassMath.degreesToCardinal(45), equals('NE'));
      expect(CompassMath.degreesToCardinal(67.5), equals('ENE'));
      expect(CompassMath.degreesToCardinal(90), equals('E'));
      expect(CompassMath.degreesToCardinal(112.5), equals('ESE'));
      expect(CompassMath.degreesToCardinal(135), equals('SE'));
      expect(CompassMath.degreesToCardinal(157.5), equals('SSE'));
      expect(CompassMath.degreesToCardinal(180), equals('S'));
      expect(CompassMath.degreesToCardinal(202.5), equals('SSW'));
      expect(CompassMath.degreesToCardinal(225), equals('SW'));
      expect(CompassMath.degreesToCardinal(247.5), equals('WSW'));
      expect(CompassMath.degreesToCardinal(270), equals('W'));
      expect(CompassMath.degreesToCardinal(292.5), equals('WNW'));
      expect(CompassMath.degreesToCardinal(315), equals('NW'));
      expect(CompassMath.degreesToCardinal(337.5), equals('NNW'));
      expect(CompassMath.degreesToCardinal(359), equals('N'));
    });

    test('Calculate magnetic declination', () {
      // San Francisco (should be around -13 to -14 degrees)
      final sfDeclination = CompassMath.calculateMagneticDeclination(
        37.7749, -122.4194
      );
      expect(sfDeclination, isNotNull);
      expect(sfDeclination.abs(), lessThan(30)); // Reasonable range
      
      // New York (should be around -13 degrees)
      final nyDeclination = CompassMath.calculateMagneticDeclination(
        40.7128, -74.0060
      );
      expect(nyDeclination, isNotNull);
      expect(nyDeclination.abs(), lessThan(30)); // Reasonable range
      
      // London (should be around -1 degree)
      final londonDeclination = CompassMath.calculateMagneticDeclination(
        51.5074, -0.1278
      );
      expect(londonDeclination, isNotNull);
      expect(londonDeclination.abs(), lessThan(30)); // Reasonable range
    });

    test('Calculate destination from bearing and distance', () {
      // Start at origin, go 111,120 meters (1 degree) north
      final northDest = CompassMath.calculateDestination(
        0.0, 0.0,
        0.0, // North bearing
        111120, // ~1 degree in meters
      );
      expect(northDest.latitude, closeTo(1.0, 0.01));
      expect(northDest.longitude, closeTo(0.0, 0.01));

      // Start at origin, go 111,120 meters (1 degree) east
      final eastDest = CompassMath.calculateDestination(
        0.0, 0.0,
        90.0, // East bearing
        111120, // ~1 degree in meters
      );
      expect(eastDest.latitude, closeTo(0.0, 0.01));
      expect(eastDest.longitude, closeTo(1.0, 0.01));
    });

    test('Calculate compass accuracy from field strength', () {
      // Normal field strength (50 μT) - should have good accuracy
      final normalAccuracy = CompassMath.calculateCompassAccuracy(
        50.0,
        [49.8, 50.1, 50.0, 49.9, 50.2], // Stable readings
      );
      expect(normalAccuracy, lessThan(10)); // Good accuracy

      // Weak field strength - should have poor accuracy
      final weakAccuracy = CompassMath.calculateCompassAccuracy(
        15.0,
        [14.5, 15.5, 14.8, 15.2, 15.0],
      );
      expect(weakAccuracy, greaterThan(30)); // Poor accuracy

      // Unstable readings - should have poor accuracy
      final unstableAccuracy = CompassMath.calculateCompassAccuracy(
        50.0,
        [30.0, 70.0, 45.0, 60.0, 35.0], // Very unstable
      );
      expect(unstableAccuracy, greaterThan(20)); // Poor accuracy
    });

    test('Calculate wind triangle for pilot mode', () {
      // No wind case
      final noWind = CompassMath.calculateWindTriangle(
        100.0, // True airspeed
        0.0,   // Heading north
        0.0,   // Wind from north
        0.0,   // No wind speed
      );
      expect(noWind.groundSpeed, equals(100.0));
      expect(noWind.trackAngle, equals(0.0));
      expect(noWind.driftAngle, equals(0.0));

      // Headwind case
      final headwind = CompassMath.calculateWindTriangle(
        100.0, // True airspeed
        0.0,   // Heading north
        180.0, // Wind from south (headwind)
        20.0,  // Wind speed
      );
      expect(headwind.groundSpeed, closeTo(80.0, 1.0));
      expect(headwind.trackAngle, closeTo(0.0, 1.0));
      expect(headwind.driftAngle, closeTo(0.0, 1.0));

      // Tailwind case
      final tailwind = CompassMath.calculateWindTriangle(
        100.0, // True airspeed
        0.0,   // Heading north
        0.0,   // Wind from north (tailwind)
        20.0,  // Wind speed
      );
      expect(tailwind.groundSpeed, closeTo(120.0, 1.0));
      expect(tailwind.trackAngle, closeTo(0.0, 1.0));
      expect(tailwind.driftAngle, closeTo(0.0, 1.0));

      // Crosswind case
      final crosswind = CompassMath.calculateWindTriangle(
        100.0, // True airspeed
        0.0,   // Heading north
        90.0,  // Wind from east (right crosswind)
        20.0,  // Wind speed
      );
      expect(crosswind.groundSpeed, greaterThan(95.0));
      expect(crosswind.groundSpeed, lessThan(105.0));
      expect(crosswind.driftAngle, greaterThan(5.0));
      expect(crosswind.driftAngle, lessThan(15.0));
    });

    test('Calculate cross track error', () {
      // On track - should be zero
      final onTrack = CompassMath.calculateCrossTrackError(
        0.5, 0.0,  // Current position (halfway)
        0.0, 0.0,  // Start
        1.0, 0.0,  // End
      );
      expect(onTrack.abs(), lessThan(100)); // Within 100 meters

      // Off track to the right
      final offTrackRight = CompassMath.calculateCrossTrackError(
        0.5, 0.1,  // Current position (right of track)
        0.0, 0.0,  // Start
        1.0, 0.0,  // End
      );
      expect(offTrackRight, greaterThan(10000)); // More than 10km off

      // Off track to the left
      final offTrackLeft = CompassMath.calculateCrossTrackError(
        0.5, -0.1,  // Current position (left of track)
        0.0, 0.0,   // Start
        1.0, 0.0,   // End
      );
      expect(offTrackLeft, lessThan(-10000)); // More than 10km off (negative)
    });
  });
}