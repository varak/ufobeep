/// Unit conversion utilities for displaying data in metric or imperial units
/// with automatic language/region detection
class UnitConversion {
  static const String metric = 'metric';
  static const String imperial = 'imperial';

  /// Map of language codes to their typical unit systems
  /// Imperial: US, UK (partially), Myanmar, Liberia  
  /// Metric: Most of the world
  static const Map<String, String> _languageToUnits = {
    'en': imperial,  // English (primarily US/UK)
    'es': metric,    // Spanish
    'de': metric,    // German
    'fr': metric,    // French
    'it': metric,    // Italian
    'pt': metric,    // Portuguese
    'ru': metric,    // Russian
    'zh': metric,    // Chinese
    'ja': metric,    // Japanese
    'ko': metric,    // Korean
    'ar': metric,    // Arabic
    'hi': metric,    // Hindi
    'tr': metric,    // Turkish
    'nl': metric,    // Dutch
    'sv': metric,    // Swedish
    'da': metric,    // Danish
    'no': metric,    // Norwegian
    'fi': metric,    // Finnish
    'pl': metric,    // Polish
    'cs': metric,    // Czech
    'el': metric,    // Greek
    'he': metric,    // Hebrew
  };

  /// Get the default unit system for a language code
  /// Falls back to metric if language not found
  static String getDefaultUnitsForLanguage(String languageCode) {
    return _languageToUnits[languageCode.toLowerCase()] ?? metric;
  }

  /// Check if a language typically uses imperial units
  static bool languageUsesImperial(String languageCode) {
    return _languageToUnits[languageCode.toLowerCase()] == imperial;
  }

  /// Format distance with automatic unit detection from language
  static String formatDistanceAuto(double distanceM, String languageCode, {String? overrideUnits}) {
    final units = overrideUnits ?? getDefaultUnitsForLanguage(languageCode);
    return formatDistance(distanceM, units);
  }

  /// Format temperature with automatic unit detection from language  
  static String formatTemperatureAuto(dynamic tempC, String languageCode, {String? overrideUnits}) {
    final units = overrideUnits ?? getDefaultUnitsForLanguage(languageCode);
    return formatTemperature(tempC, units);
  }

  /// Format speed with automatic unit detection from language
  static String formatSpeedAuto(double speedMs, String languageCode, {String? overrideUnits}) {
    final units = overrideUnits ?? getDefaultUnitsForLanguage(languageCode);
    return formatSpeed(speedMs, units);
  }

  /// Format altitude with automatic unit detection from language
  static String formatAltitudeAuto(double altitudeM, String languageCode, {String? overrideUnits}) {
    final units = overrideUnits ?? getDefaultUnitsForLanguage(languageCode);
    return formatAltitude(altitudeM, units);
  }

  /// Get distance unit label with automatic detection from language
  static String getDistanceUnitAuto(String languageCode, {String? overrideUnits}) {
    final units = overrideUnits ?? getDefaultUnitsForLanguage(languageCode);
    return getDistanceUnit(units);
  }

  /// Convert temperature from Celsius to the preferred unit
  static String formatTemperature(dynamic tempC, String units) {
    if (tempC == null) return units == imperial ? '--°F' : '--°C';
    
    final double temp = tempC.toDouble();
    if (units == imperial) {
      final tempF = (temp * 9 / 5) + 32;
      return '${tempF.toStringAsFixed(1)}°F';
    } else {
      return '${temp.toStringAsFixed(1)}°C';
    }
  }

  /// Convert wind speed from m/s to the preferred unit
  static String formatWindSpeed(dynamic speedMs, String units) {
    if (speedMs == null) return '--';
    
    final double speed = speedMs.toDouble();
    if (units == imperial) {
      final speedMph = speed * 2.237; // m/s to mph
      return '${speedMph.toStringAsFixed(1)} mph';
    } else {
      return '${speed.toStringAsFixed(1)} m/s';
    }
  }

  /// Convert visibility from km to the preferred unit
  static String formatVisibility(dynamic visibilityKm, String units) {
    if (visibilityKm == null) return '--';
    
    final double visibility = visibilityKm.toDouble();
    if (units == imperial) {
      final visibilityMiles = visibility * 0.621371; // km to miles
      return '${visibilityMiles.toStringAsFixed(1)} mi';
    } else {
      return '${visibility.toStringAsFixed(1)} km';
    }
  }

  /// Convert distance from meters to the preferred unit
  static String formatDistance(double distanceM, String units) {
    if (units == imperial) {
      if (distanceM < 1609.34) { // Less than 1 mile, show in feet
        final distanceFt = distanceM * 3.28084;
        return '${distanceFt.toStringAsFixed(0)} ft';
      } else {
        final distanceMiles = distanceM / 1609.34;
        return '${distanceMiles.toStringAsFixed(1)} mi';
      }
    } else {
      if (distanceM < 1000) {
        return '${distanceM.toStringAsFixed(0)} m';
      } else {
        final distanceKm = distanceM / 1000;
        return '${distanceKm.toStringAsFixed(1)} km';
      }
    }
  }

  /// Convert altitude from meters to the preferred unit
  static String formatAltitude(double altitudeM, String units) {
    if (units == imperial) {
      final altitudeFt = altitudeM * 3.28084;
      return '${altitudeFt.toStringAsFixed(0)} ft';
    } else {
      return '${altitudeM.toStringAsFixed(0)} m';
    }
  }

  /// Format speed in the preferred unit (for general use)
  static String formatSpeed(double speedMs, String units) {
    if (units == imperial) {
      final speedMph = speedMs * 2.237;
      return '${speedMph.toStringAsFixed(1)} mph';
    } else {
      final speedKmh = speedMs * 3.6;
      return '${speedKmh.toStringAsFixed(1)} km/h';
    }
  }

  /// Get the appropriate distance unit label
  static String getDistanceUnit(String units) {
    return units == imperial ? 'mi' : 'km';
  }

  /// Get the appropriate speed unit label
  static String getSpeedUnit(String units) {
    return units == imperial ? 'mph' : 'km/h';
  }

  /// Get the appropriate temperature unit label
  static String getTemperatureUnit(String units) {
    return units == imperial ? '°F' : '°C';
  }
}