import 'package:flutter_test/flutter_test.dart';
import 'package:ufobeep/services/pilot_navigation_service.dart';
import 'package:ufobeep/models/compass_data.dart';
import 'package:ufobeep/models/pilot_data.dart';
import 'dart:math' as math;

void main() {
  group('PilotNavigationService', () {
    late PilotNavigationService service;

    setUp(() {
      service = PilotNavigationService();
    });

    group('Navigation Solution Calculations', () {
      test('calculates basic navigation solution correctly', () {
        final compass = CompassData(
          trueHeading: 0.0,
          magneticHeading: 350.0,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          calibration: CompassCalibrationLevel.high,
          location: LocationData(
            latitude: 37.7749,
            longitude: -122.4194,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
        );

        final target = CompassTarget(
          id: 'test-target',
          name: 'Test Target',
          location: LocationData(
            latitude: 37.8049,
            longitude: -122.4194,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
          type: TargetType.alert,
        );

        final solution = service.calculateNavigationSolution(
          compass: compass,
          target: target,
          groundSpeed: 50.0,
          magneticDeclination: 10.0,
        );

        expect(solution.target, equals(target));
        expect(solution.distance, greaterThan(0));
        expect(solution.bearing, isA<double>());
        expect(solution.magneticBearing, isA<double>());
        expect(solution.relativeBearing, isA<double>());
        expect(solution.estimatedTimeEnroute, isNotNull);
      });

      test('handles wind correction in navigation solution', () {
        final compass = CompassData(
          trueHeading: 0.0,
          magneticHeading: 350.0,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          calibration: CompassCalibrationLevel.high,
          location: LocationData(
            latitude: 37.7749,
            longitude: -122.4194,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
        );

        final target = CompassTarget(
          id: 'test-target',
          name: 'Test Target',
          location: LocationData(
            latitude: 37.8049,
            longitude: -122.4194,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
          type: TargetType.alert,
        );

        final wind = WindData(
          direction: 270.0,
          speed: 10.0,
          timestamp: DateTime.now(),
        );

        final solution = service.calculateNavigationSolution(
          compass: compass,
          target: target,
          groundSpeed: 50.0,
          trueAirspeed: 55.0,
          wind: wind,
          magneticDeclination: 10.0,
        );

        expect(solution.requiredHeading, isNotNull);
      });

      test('calculates ETE correctly', () {
        final compass = CompassData(
          trueHeading: 0.0,
          magneticHeading: 350.0,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          calibration: CompassCalibrationLevel.high,
          location: LocationData(
            latitude: 37.0,
            longitude: -122.0,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
        );

        // Target 5km north
        final target = CompassTarget(
          id: 'test-target',
          name: 'Test Target',
          location: LocationData(
            latitude: 37.045,
            longitude: -122.0,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
          type: TargetType.alert,
        );

        final solution = service.calculateNavigationSolution(
          compass: compass,
          target: target,
          groundSpeed: 50.0, // 50 m/s
        );

        expect(solution.estimatedTimeEnroute, isNotNull);
        // Should be around 100 seconds for 5km at 50 m/s
        expect(solution.estimatedTimeEnroute!.inSeconds, closeTo(100, 20));
      });
    });

    group('Bank Angle Calculations', () {
      test('calculates required bank angle for turn rate', () {
        final bankAngle = service.calculateRequiredBankAngle(
          desiredTurnRate: 3.0, // Standard rate turn
          groundSpeed: 50.0,
        );

        expect(bankAngle, greaterThan(0));
        expect(bankAngle, lessThan(45)); // Should be reasonable
      });

      test('calculates standard rate bank angle', () {
        final bankAngle = service.calculateStandardRateBankAngle(50.0);

        expect(bankAngle, greaterThan(0));
        expect(bankAngle, lessThan(30)); // Should be shallow for high speed
      });

      test('calculates turn radius correctly', () {
        final radius = service.calculateTurnRadius(
          bankAngle: 30.0,
          groundSpeed: 50.0,
        );

        expect(radius, greaterThan(0));
        expect(radius.isFinite, isTrue);
      });

      test('handles zero bank angle', () {
        final radius = service.calculateTurnRadius(
          bankAngle: 0.0,
          groundSpeed: 50.0,
        );

        expect(radius, equals(double.infinity));
      });
    });

    group('Ground Track Calculations', () {
      test('calculates ground track with wind', () {
        final result = service.calculateGroundTrack(
          heading: 0.0,
          trueAirspeed: 50.0,
          windDirection: 270.0,
          windSpeed: 10.0,
        );

        expect(result.groundTrack, isA<double>());
        expect(result.driftAngle, isA<double>());
        expect(result.driftAngle.abs(), lessThan(30)); // Reasonable drift
      });

      test('handles no wind condition', () {
        final result = service.calculateGroundTrack(
          heading: 90.0,
          trueAirspeed: 50.0,
          windDirection: 270.0,
          windSpeed: 0.0,
        );

        expect(result.groundTrack, closeTo(90.0, 0.1));
        expect(result.driftAngle, closeTo(0.0, 0.1));
      });
    });

    group('Altitude Change Calculations', () {
      test('calculates required vertical speed', () {
        final result = service.calculateAltitudeChange(
          currentAltitude: 1000.0,
          targetAltitude: 2000.0,
          groundSpeed: 50.0,
          distanceToTarget: 10000.0,
        );

        expect(result.requiredVerticalSpeed, greaterThan(0));
        expect(result.timeToAltitude.inSeconds, equals(200));
      });

      test('handles descent calculation', () {
        final result = service.calculateAltitudeChange(
          currentAltitude: 2000.0,
          targetAltitude: 1000.0,
          groundSpeed: 50.0,
          distanceToTarget: 10000.0,
        );

        expect(result.requiredVerticalSpeed, lessThan(0));
      });
    });

    group('Visual Range Detection', () {
      test('detects within visual range', () {
        expect(service.isWithinVisualRange(10000), isTrue);
        expect(service.isWithinVisualRange(25000), isFalse);
      });
    });

    group('Approach Guidance', () {
      test('provides appropriate guidance for different distances', () {
        final target = CompassTarget(
          id: 'test',
          name: 'Test',
          location: LocationData(
            latitude: 37.0,
            longitude: -122.0,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
          type: TargetType.alert,
        );

        // Very close
        final closeGuidance = service.getApproachGuidance(NavigationSolution(
          target: target,
          distance: 50.0,
          bearing: 0.0,
          magneticBearing: 0.0,
          relativeBearing: 0.0,
        ));
        expect(closeGuidance, contains('overhead'));

        // Medium distance
        final mediumGuidance = service.getApproachGuidance(NavigationSolution(
          target: target,
          distance: 2000.0,
          bearing: 0.0,
          magneticBearing: 0.0,
          relativeBearing: 45.0,
        ));
        expect(mediumGuidance, contains('heading'));

        // Far distance with turn needed
        final farGuidance = service.getApproachGuidance(NavigationSolution(
          target: target,
          distance: 10000.0,
          bearing: 0.0,
          magneticBearing: 0.0,
          relativeBearing: -30.0,
        ));
        expect(farGuidance, contains('left'));
      });
    });

    group('Pilot Navigation Data Creation', () {
      test('creates complete pilot navigation data', () {
        final compass = CompassData(
          trueHeading: 90.0,
          magneticHeading: 80.0,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          calibration: CompassCalibrationLevel.high,
          location: LocationData(
            latitude: 37.7749,
            longitude: -122.4194,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
        );

        final target = CompassTarget(
          id: 'test-target',
          name: 'Test Target',
          location: LocationData(
            latitude: 37.8049,
            longitude: -122.4194,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
          type: TargetType.alert,
        );

        final wind = WindData(
          direction: 270.0,
          speed: 5.0,
          timestamp: DateTime.now(),
        );

        final pilotData = service.createPilotNavigationData(
          compass: compass,
          target: target,
          groundSpeed: 50.0,
          trueAirspeed: 55.0,
          altitude: 1500.0,
          verticalSpeed: 2.0,
          bankAngle: 15.0,
          pitchAngle: 5.0,
          wind: wind,
          magneticDeclination: 10.0,
        );

        expect(pilotData.compass, equals(compass));
        expect(pilotData.groundSpeed, equals(50.0));
        expect(pilotData.trueAirspeed, equals(55.0));
        expect(pilotData.altitude, equals(1500.0));
        expect(pilotData.verticalSpeed, equals(2.0));
        expect(pilotData.bankAngle, equals(15.0));
        expect(pilotData.pitchAngle, equals(5.0));
        expect(pilotData.wind, equals(wind));
        expect(pilotData.solution, isNotNull);
        expect(pilotData.solution!.target, equals(target));
      });

      test('handles null target in pilot data', () {
        final compass = CompassData(
          trueHeading: 90.0,
          magneticHeading: 80.0,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          calibration: CompassCalibrationLevel.high,
        );

        final pilotData = service.createPilotNavigationData(
          compass: compass,
          groundSpeed: 50.0,
        );

        expect(pilotData.solution, isNull);
      });
    });

    group('Glide Range Calculations', () {
      test('calculates glide range without wind', () {
        final range = service.calculateGlideRange(
          altitude: 1000.0,
          glideRatio: 10.0,
        );

        expect(range, equals(10000.0));
      });

      test('calculates glide range with headwind', () {
        final wind = WindData(
          direction: 0.0, // Direct headwind
          speed: 10.0,
          timestamp: DateTime.now(),
        );

        final range = service.calculateGlideRange(
          altitude: 1000.0,
          glideRatio: 10.0,
          wind: wind,
          heading: 0.0,
        );

        expect(range, greaterThan(9500.0)); // Should be close to 10000 with wind effect
        expect(range, lessThan(10500.0));
      });

      test('calculates glide range with tailwind', () {
        final wind = WindData(
          direction: 180.0, // Direct tailwind  
          speed: 10.0,
          timestamp: DateTime.now(),
        );

        final range = service.calculateGlideRange(
          altitude: 1000.0,
          glideRatio: 10.0,
          wind: wind,
          heading: 0.0,
        );

        expect(range, greaterThan(9500.0)); // Should be close to 10000 with wind effect
        expect(range, lessThan(10500.0));
      });
    });

    group('Fuel Calculations', () {
      test('calculates fuel metrics', () {
        final result = service.calculateFuelMetrics(
          fuelRemaining: 100.0,
          fuelFlowRate: 20.0,
        );

        expect(result.fuelBurn, equals(20.0));
        expect(result.endurance.inHours, equals(5));
      });

      test('handles zero fuel flow', () {
        final result = service.calculateFuelMetrics(
          fuelRemaining: 100.0,
          fuelFlowRate: 0.0,
        );

        expect(result.fuelBurn, equals(0.0));
        expect(result.endurance.inHours, equals(99));
      });
    });
  });
}