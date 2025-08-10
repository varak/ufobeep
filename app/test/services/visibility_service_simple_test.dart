import 'package:flutter_test/flutter_test.dart';
import 'package:ufobeep/services/visibility_service.dart';
import 'package:ufobeep/models/user_preferences.dart';
import 'package:ufobeep/models/alert_enrichment.dart';

void main() {
  group('VisibilityService', () {
    late VisibilityService service;

    setUp(() {
      service = VisibilityService();
    });

    group('Effective Range Calculations', () {
      test('uses fallback visibility when weather is unavailable', () {
        final preferences = UserPreferences(alertRangeKm: 15.0);
        
        final effectiveRange = service.calculateEffectiveRange(
          preferences: preferences,
          weather: null,
        );
        
        // Should use min(15.0, 2×30.0) = min(15.0, 60.0) = 15.0
        expect(effectiveRange, equals(15.0));
      });

      test('applies min(profile, 2×visibility) formula correctly', () {
        final preferences = UserPreferences(alertRangeKm: 25.0);
        final weather = WeatherData(
          condition: 'clear',
          description: 'clear sky',
          temperature: 20.0,
          humidity: 60.0,
          windSpeed: 5.0,
          windDirection: 90.0,
          visibility: 8.0, // 8 km visibility
          cloudCoverage: 10.0,
          iconCode: '01d',
        );
        
        final effectiveRange = service.calculateEffectiveRange(
          preferences: preferences,
          weather: weather,
        );
        
        // Should use min(25.0, 2×8.0) = min(25.0, 16.0) = 16.0
        expect(effectiveRange, equals(16.0));
      });

      test('uses profile range when weather visibility is high', () {
        final preferences = UserPreferences(alertRangeKm: 10.0);
        final weather = WeatherData(
          condition: 'clear',
          description: 'clear sky',
          temperature: 20.0,
          humidity: 40.0,
          windSpeed: 3.0,
          windDirection: 180.0,
          visibility: 20.0, // High visibility
          cloudCoverage: 5.0,
          iconCode: '01d',
        );
        
        final effectiveRange = service.calculateEffectiveRange(
          preferences: preferences,
          weather: weather,
        );
        
        // Should use min(10.0, 2×20.0) = min(10.0, 40.0) = 10.0
        expect(effectiveRange, equals(10.0));
      });

      test('limits range to minimum threshold', () {
        final preferences = UserPreferences(alertRangeKm: 0.1);
        final weather = WeatherData(
          condition: 'fog',
          description: 'heavy fog',
          temperature: 15.0,
          humidity: 95.0,
          windSpeed: 1.0,
          windDirection: 0.0,
          visibility: 0.1, // Very poor visibility
          cloudCoverage: 100.0,
          iconCode: '50d',
        );
        
        final effectiveRange = service.calculateEffectiveRange(
          preferences: preferences,
          weather: weather,
        );
        
        // Should be clamped to minimum 0.5 km
        expect(effectiveRange, equals(0.5));
      });

      test('limits range to maximum threshold', () {
        final preferences = UserPreferences(alertRangeKm: 150.0);
        final weather = WeatherData(
          condition: 'clear',
          description: 'perfectly clear',
          temperature: 25.0,
          humidity: 30.0,
          windSpeed: 0.0,
          windDirection: 0.0,
          visibility: 100.0, // Extreme visibility
          cloudCoverage: 0.0,
          iconCode: '01d',
        );
        
        final effectiveRange = service.calculateEffectiveRange(
          preferences: preferences,
          weather: weather,
        );
        
        // Should be clamped to maximum 100 km
        expect(effectiveRange, equals(100.0));
      });
    });

    group('Visibility Categories', () {
      test('categorizes excellent visibility correctly', () {
        final category = service.getVisibilityCategory(15.0);
        expect(category, equals(VisibilityCategory.excellent));
      });

      test('categorizes good visibility correctly', () {
        final category = service.getVisibilityCategory(7.0);
        expect(category, equals(VisibilityCategory.good));
      });

      test('categorizes fair visibility correctly', () {
        final category = service.getVisibilityCategory(3.5);
        expect(category, equals(VisibilityCategory.fair));
      });

      test('categorizes poor visibility correctly', () {
        final category = service.getVisibilityCategory(1.5);
        expect(category, equals(VisibilityCategory.poor));
      });

      test('categorizes very poor visibility correctly', () {
        final category = service.getVisibilityCategory(0.8);
        expect(category, equals(VisibilityCategory.veryPoor));
      });
    });

    group('Visibility Impact Analysis', () {
      test('calculates impact correctly when visibility reduces range', () {
        final preferences = UserPreferences(alertRangeKm: 30.0);
        final weather = WeatherData(
          condition: 'rain',
          description: 'light rain',
          temperature: 15.0,
          humidity: 85.0,
          windSpeed: 10.0,
          windDirection: 200.0,
          visibility: 5.0, // Reduces effective range
          cloudCoverage: 80.0,
          iconCode: '10d',
        );
        
        final impact = service.calculateVisibilityImpact(
          preferences: preferences,
          weather: weather,
        );
        
        expect(impact.profileRangeKm, equals(30.0));
        expect(impact.effectiveRangeKm, equals(10.0)); // min(30, 2×5)
        expect(impact.weatherVisibilityKm, equals(5.0));
        expect(impact.isReduced, isTrue);
        expect(impact.reductionPercent, closeTo(66.7, 0.1)); // (30-10)/30 * 100
        expect(impact.category, equals(VisibilityCategory.good));
      });

      test('shows no reduction when weather does not limit range', () {
        final preferences = UserPreferences(alertRangeKm: 8.0);
        final weather = WeatherData(
          condition: 'clear',
          description: 'clear sky',
          temperature: 22.0,
          humidity: 45.0,
          windSpeed: 8.0,
          windDirection: 270.0,
          visibility: 25.0, // High visibility
          cloudCoverage: 5.0,
          iconCode: '01d',
        );
        
        final impact = service.calculateVisibilityImpact(
          preferences: preferences,
          weather: weather,
        );
        
        expect(impact.profileRangeKm, equals(8.0));
        expect(impact.effectiveRangeKm, equals(8.0)); // min(8, 2×25) = min(8, 50)
        expect(impact.isReduced, isFalse);
        expect(impact.reductionPercent, equals(0.0));
        expect(impact.category, equals(VisibilityCategory.excellent));
      });
    });

    group('Visibility Status', () {
      test('returns critical status for very poor visibility', () {
        final preferences = UserPreferences(alertRangeKm: 10.0);
        final weather = WeatherData(
          condition: 'fog',
          description: 'dense fog',
          temperature: 12.0,
          humidity: 99.0,
          windSpeed: 1.0,
          windDirection: 0.0,
          visibility: 0.2,
          cloudCoverage: 100.0,
          iconCode: '50n',
        );
        
        final status = service.getVisibilityStatus(
          preferences: preferences,
          weather: weather,
        );
        
        expect(status, equals(VisibilityStatus.critical));
      });

      test('returns warning status for poor visibility', () {
        final preferences = UserPreferences(alertRangeKm: 15.0);
        final weather = WeatherData(
          condition: 'mist',
          description: 'mist',
          temperature: 16.0,
          humidity: 90.0,
          windSpeed: 2.0,
          windDirection: 45.0,
          visibility: 1.5,
          cloudCoverage: 90.0,
          iconCode: '50d',
        );
        
        final status = service.getVisibilityStatus(
          preferences: preferences,
          weather: weather,
        );
        
        expect(status, equals(VisibilityStatus.warning));
      });

      test('returns good status for excellent conditions', () {
        final preferences = UserPreferences(alertRangeKm: 12.0);
        final weather = WeatherData(
          condition: 'clear',
          description: 'clear sky',
          temperature: 24.0,
          humidity: 35.0,
          windSpeed: 4.0,
          windDirection: 180.0,
          visibility: 30.0,
          cloudCoverage: 0.0,
          iconCode: '01d',
        );
        
        final status = service.getVisibilityStatus(
          preferences: preferences,
          weather: weather,
        );
        
        expect(status, equals(VisibilityStatus.good));
      });
    });

    group('Visibility Recommendations', () {
      test('provides appropriate recommendations for very poor conditions', () {
        final preferences = UserPreferences(alertRangeKm: 10.0);
        final weather = WeatherData(
          condition: 'fog',
          description: 'heavy fog',
          temperature: 8.0,
          humidity: 99.0,
          windSpeed: 0.0,
          windDirection: 0.0,
          visibility: 0.1,
          cloudCoverage: 100.0,
          iconCode: '50n',
        );
        
        final recommendations = service.getVisibilityRecommendations(
          preferences: preferences,
          weather: weather,
        );
        
        expect(recommendations.length, greaterThan(2));
        expect(recommendations.any((r) => r.contains('500m')), isTrue);
        expect(recommendations.any((r) => r.contains('caution')), isTrue);
      });

      test('provides minimal recommendations for excellent conditions', () {
        final preferences = UserPreferences(alertRangeKm: 15.0);
        final weather = WeatherData(
          condition: 'clear',
          description: 'perfect visibility',
          temperature: 25.0,
          humidity: 30.0,
          windSpeed: 2.0,
          windDirection: 90.0,
          visibility: 50.0,
          cloudCoverage: 0.0,
          iconCode: '01d',
        );
        
        final recommendations = service.getVisibilityRecommendations(
          preferences: preferences,
          weather: weather,
        );
        
        expect(recommendations.length, greaterThan(0));
        expect(recommendations.any((r) => r.contains('Excellent')), isTrue);
      });
    });

    group('Visibility Advice', () {
      test('provides advice when visibility reduces range', () {
        final preferences = UserPreferences(alertRangeKm: 25.0);
        final weather = WeatherData(
          condition: 'rain',
          description: 'moderate rain',
          temperature: 14.0,
          humidity: 88.0,
          windSpeed: 12.0,
          windDirection: 210.0,
          visibility: 4.0,
          cloudCoverage: 85.0,
          iconCode: '10d',
        );
        
        final advice = service.getVisibilityAdvice(
          preferences: preferences,
          weather: weather,
        );
        
        expect(advice, contains('reduced'));
        expect(advice, contains('8.0 km')); // Effective range
      });

      test('provides standard advice when weather unavailable', () {
        final preferences = UserPreferences(alertRangeKm: 10.0);
        
        final advice = service.getVisibilityAdvice(
          preferences: preferences,
          weather: null,
        );
        
        expect(advice, contains('standard'));
        expect(advice, contains('10.0 km'));
      });

      test('provides positive advice for good conditions', () {
        final preferences = UserPreferences(alertRangeKm: 8.0);
        final weather = WeatherData(
          condition: 'clear',
          description: 'clear',
          temperature: 21.0,
          humidity: 50.0,
          windSpeed: 5.0,
          windDirection: 135.0,
          visibility: 20.0,
          cloudCoverage: 10.0,
          iconCode: '02d',
        );
        
        final advice = service.getVisibilityAdvice(
          preferences: preferences,
          weather: weather,
        );
        
        expect(advice, contains('Good'));
        expect(advice, contains('8.0 km'));
      });
    });
  });

  group('VisibilityCategory Extensions', () {
    test('provides correct display names', () {
      expect(VisibilityCategory.excellent.displayName, equals('Excellent'));
      expect(VisibilityCategory.good.displayName, equals('Good'));
      expect(VisibilityCategory.fair.displayName, equals('Fair'));
      expect(VisibilityCategory.poor.displayName, equals('Poor'));
      expect(VisibilityCategory.veryPoor.displayName, equals('Very Poor'));
    });

    test('provides appropriate descriptions', () {
      expect(VisibilityCategory.excellent.description, contains('clear'));
      expect(VisibilityCategory.veryPoor.description, contains('fog'));
      expect(VisibilityCategory.poor.description, contains('rain'));
    });

    test('provides weather emojis', () {
      expect(VisibilityCategory.excellent.emoji, equals('☀️'));
      expect(VisibilityCategory.veryPoor.emoji, equals('🌫️'));
    });
  });

  group('VisibilityStatus Extensions', () {
    test('provides correct display names', () {
      expect(VisibilityStatus.critical.displayName, equals('Critical'));
      expect(VisibilityStatus.warning.displayName, equals('Warning'));
      expect(VisibilityStatus.reduced.displayName, equals('Reduced'));
      expect(VisibilityStatus.good.displayName, equals('Good'));
    });
  });

  group('VisibilityImpact', () {
    test('formats values correctly', () {
      final impact = VisibilityImpact(
        profileRangeKm: 20.0,
        effectiveRangeKm: 12.5,
        weatherVisibilityKm: 6.25,
        reductionPercent: 37.5,
        category: VisibilityCategory.good,
        isReduced: true,
        advice: 'Test advice',
      );
      
      expect(impact.formattedReduction, equals('38% reduction'));
      expect(impact.effectiveRangeFormatted, equals('12.5 km'));
      expect(impact.profileRangeFormatted, equals('20.0 km'));
      expect(impact.weatherVisibilityFormatted, equals('6.3 km'));
    });

    test('handles no reduction correctly', () {
      final impact = VisibilityImpact(
        profileRangeKm: 15.0,
        effectiveRangeKm: 15.0,
        weatherVisibilityKm: 25.0,
        reductionPercent: 0.0,
        category: VisibilityCategory.excellent,
        isReduced: false,
        advice: 'Good conditions',
      );
      
      expect(impact.formattedReduction, equals('No reduction'));
    });
  });
}