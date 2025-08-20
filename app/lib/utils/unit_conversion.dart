/// Unit conversion utilities for displaying data in metric or imperial units
class UnitConversion {
  static const String metric = 'metric';
  static const String imperial = 'imperial';

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