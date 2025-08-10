import 'dart:math' as math;

/// Advanced compass mathematics for precise navigation calculations
class CompassMath {
  static const double _earthRadius = 6371000.0; // meters
  static const double _degToRad = math.pi / 180.0;
  static const double _radToDeg = 180.0 / math.pi;

  /// Calculate magnetic declination using a simplified World Magnetic Model
  /// This is a basic approximation - production apps should use the full WMM
  static double calculateMagneticDeclination(double latitude, double longitude) {
    // Simplified magnetic declination model based on location
    // Real implementation would use IGRF (International Geomagnetic Reference Field)
    
    // Convert to radians for calculations
    final latRad = latitude * _degToRad;
    final lonRad = longitude * _degToRad;
    
    // Basic model coefficients (very simplified)
    // These approximate the magnetic field variations
    final a = -0.2; // Dipole tilt effect
    final b = 0.1;  // Longitude variation
    final c = 0.05; // Higher order terms
    
    // Calculate declination components
    final dipoleComponent = a * math.sin(2 * latRad);
    final longitudeComponent = b * math.sin(lonRad) * math.cos(latRad);
    final correctionComponent = c * math.sin(3 * latRad) * math.cos(2 * lonRad);
    
    double declination = dipoleComponent + longitudeComponent + correctionComponent;
    
    // Add regional variations for major magnetic anomalies
    declination += _getRegionalMagneticVariation(latitude, longitude);
    
    // Convert to degrees and clamp to reasonable range
    declination *= _radToDeg;
    return math.max(-180, math.min(180, declination));
  }
  
  /// Get regional magnetic variations for known anomaly areas
  static double _getRegionalMagneticVariation(double latitude, double longitude) {
    // Magnetic anomalies in specific regions
    
    // North American magnetic anomaly
    if (latitude > 40 && latitude < 70 && longitude > -140 && longitude < -60) {
      final centerLat = 55.0;
      final centerLon = -100.0;
      final distance = greatCircleDistance(latitude, longitude, centerLat, centerLon);
      if (distance < 2000000) { // Within 2000km
        return -0.3 * math.exp(-distance / 1000000); // Negative declination
      }
    }
    
    // European magnetic variation
    if (latitude > 35 && latitude < 70 && longitude > -10 && longitude < 40) {
      final centerLat = 52.0;
      final centerLon = 15.0;
      final distance = greatCircleDistance(latitude, longitude, centerLat, centerLon);
      if (distance < 1500000) { // Within 1500km
        return 0.15 * math.exp(-distance / 800000); // Positive declination
      }
    }
    
    return 0.0;
  }

  /// Calculate great circle distance between two points using Haversine formula
  static double greatCircleDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    final lat1Rad = lat1 * _degToRad;
    final lat2Rad = lat2 * _degToRad;
    final deltaLatRad = (lat2 - lat1) * _degToRad;
    final deltaLonRad = (lon2 - lon1) * _degToRad;

    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLonRad / 2) * math.sin(deltaLonRad / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadius * c;
  }

  /// Calculate initial bearing from point 1 to point 2
  static double calculateBearing(
    double lat1, double lon1,
    double lat2, double lon2
  ) {
    final lat1Rad = lat1 * _degToRad;
    final lat2Rad = lat2 * _degToRad;
    final deltaLonRad = (lon2 - lon1) * _degToRad;

    final y = math.sin(deltaLonRad) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLonRad);

    final bearing = math.atan2(y, x) * _radToDeg;
    return (bearing + 360) % 360;
  }

  /// Calculate destination point given start point, bearing, and distance
  static ({double latitude, double longitude}) calculateDestination(
    double lat1, double lon1,
    double bearing, double distance
  ) {
    final lat1Rad = lat1 * _degToRad;
    final lon1Rad = lon1 * _degToRad;
    final bearingRad = bearing * _degToRad;
    final angularDistance = distance / _earthRadius;

    final lat2Rad = math.asin(
      math.sin(lat1Rad) * math.cos(angularDistance) +
      math.cos(lat1Rad) * math.sin(angularDistance) * math.cos(bearingRad)
    );

    final lon2Rad = lon1Rad + math.atan2(
      math.sin(bearingRad) * math.sin(angularDistance) * math.cos(lat1Rad),
      math.cos(angularDistance) - math.sin(lat1Rad) * math.sin(lat2Rad)
    );

    return (
      latitude: lat2Rad * _radToDeg,
      longitude: ((lon2Rad * _radToDeg + 540) % 360) - 180
    );
  }

  /// Normalize heading to 0-360 range
  static double normalizeHeading(double heading) {
    while (heading < 0) heading += 360;
    while (heading >= 360) heading -= 360;
    return heading;
  }

  /// Calculate relative bearing (-180 to +180)
  static double relativeBearing(double fromHeading, double toHeading) {
    double relative = toHeading - fromHeading;
    while (relative < -180) relative += 360;
    while (relative > 180) relative -= 360;
    return relative;
  }

  /// Convert magnetometer readings to heading with tilt compensation
  static double calculateHeadingFromMagnetometer(
    double mx, double my, double mz,
    {double? accelerometerX, double? accelerometerY, double? accelerometerZ}
  ) {
    // Basic calculation without tilt compensation
    if (accelerometerX == null || accelerometerY == null || accelerometerZ == null) {
      return math.atan2(my, mx) * _radToDeg;
    }

    // Tilt compensation using accelerometer data
    final axNorm = accelerometerX;
    final ayNorm = accelerometerY;
    final azNorm = accelerometerZ;

    // Normalize accelerometer readings
    final accelMagnitude = math.sqrt(axNorm * axNorm + ayNorm * ayNorm + azNorm * azNorm);
    if (accelMagnitude == 0) {
      return math.atan2(my, mx) * _radToDeg;
    }

    final ax = axNorm / accelMagnitude;
    final ay = ayNorm / accelMagnitude;
    final az = azNorm / accelMagnitude;

    // Calculate tilt-compensated magnetic field components
    final pitch = math.asin(-ax);
    final roll = math.asin(ay / math.cos(pitch));

    // Tilt compensation matrix
    final cosRoll = math.cos(roll);
    final sinRoll = math.sin(roll);
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);

    final mxComp = mx * cosPitch + mz * sinPitch;
    final myComp = mx * sinRoll * sinPitch + my * cosRoll - mz * sinRoll * cosPitch;

    // Calculate heading
    final heading = math.atan2(myComp, mxComp) * _radToDeg;
    return normalizeHeading(heading);
  }

  /// Calculate compass accuracy based on magnetic field strength and stability
  static double calculateCompassAccuracy(
    double magneticFieldStrength,
    List<double> recentReadings,
    {double nominalFieldStrength = 50.0}
  ) {
    // Accuracy based on field strength
    double strengthAccuracy = 45.0; // Default poor accuracy
    
    if (magneticFieldStrength > nominalFieldStrength * 0.5 &&
        magneticFieldStrength < nominalFieldStrength * 2.0) {
      final strengthRatio = (magneticFieldStrength - nominalFieldStrength).abs() / nominalFieldStrength;
      strengthAccuracy = 5.0 + (strengthRatio * 40.0);
    }

    // Accuracy based on reading stability
    double stabilityAccuracy = 45.0;
    if (recentReadings.length >= 5) {
      final mean = recentReadings.reduce((a, b) => a + b) / recentReadings.length;
      final variance = recentReadings
          .map((x) => math.pow(x - mean, 2))
          .reduce((a, b) => a + b) / recentReadings.length;
      final standardDeviation = math.sqrt(variance);
      
      // Lower deviation = higher accuracy
      stabilityAccuracy = math.min(45.0, standardDeviation * 2.0);
    }

    // Return the worse of the two (more conservative estimate)
    return math.max(strengthAccuracy, stabilityAccuracy);
  }

  /// Calculate cross track error for navigation
  static double calculateCrossTrackError(
    double currentLat, double currentLon,
    double startLat, double startLon,
    double endLat, double endLon
  ) {
    final d13 = greatCircleDistance(startLat, startLon, currentLat, currentLon) / _earthRadius;
    final bearing13 = calculateBearing(startLat, startLon, currentLat, currentLon) * _degToRad;
    final bearing12 = calculateBearing(startLat, startLon, endLat, endLon) * _degToRad;
    
    final crossTrackDistance = math.asin(math.sin(d13) * math.sin(bearing13 - bearing12));
    return crossTrackDistance * _earthRadius;
  }

  /// Calculate along track distance for navigation
  static double calculateAlongTrackDistance(
    double currentLat, double currentLon,
    double startLat, double startLon,
    double endLat, double endLon
  ) {
    final d13 = greatCircleDistance(startLat, startLon, currentLat, currentLon) / _earthRadius;
    final crossTrackDistance = calculateCrossTrackError(
      currentLat, currentLon, startLat, startLon, endLat, endLon
    ) / _earthRadius;
    
    final alongTrackDistance = math.acos(math.cos(d13) / math.cos(crossTrackDistance));
    return alongTrackDistance * _earthRadius;
  }

  /// Convert degrees to cardinal direction
  static String degreesToCardinal(double degrees, {bool useIntercardinals = true}) {
    final normalizedDegrees = normalizeHeading(degrees);
    
    if (useIntercardinals) {
      const directions = [
        'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
        'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
      ];
      final index = ((normalizedDegrees + 11.25) / 22.5).floor() % 16;
      return directions[index];
    } else {
      if (normalizedDegrees < 45 || normalizedDegrees >= 315) return 'N';
      if (normalizedDegrees < 135) return 'E';
      if (normalizedDegrees < 225) return 'S';
      return 'W';
    }
  }

  /// Calculate wind triangle for pilot mode
  static ({double groundSpeed, double trackAngle, double driftAngle}) calculateWindTriangle(
    double trueAirspeed,
    double heading,
    double windDirection,
    double windSpeed
  ) {
    final headingRad = heading * _degToRad;
    final windDirRad = windDirection * _degToRad;
    
    // Wind components
    final windNorth = windSpeed * math.cos(windDirRad);
    final windEast = windSpeed * math.sin(windDirRad);
    
    // Aircraft velocity components (through the air)
    final aircraftNorth = trueAirspeed * math.cos(headingRad);
    final aircraftEast = trueAirspeed * math.sin(headingRad);
    
    // Ground velocity components (over the ground)
    final groundNorth = aircraftNorth + windNorth;
    final groundEast = aircraftEast + windEast;
    
    // Calculate results
    final groundSpeed = math.sqrt(groundNorth * groundNorth + groundEast * groundEast);
    final trackAngle = normalizeHeading(math.atan2(groundEast, groundNorth) * _radToDeg);
    final driftAngle = relativeBearing(heading, trackAngle);
    
    return (groundSpeed: groundSpeed, trackAngle: trackAngle, driftAngle: driftAngle);
  }

  /// Calculate required heading for desired track (wind correction angle)
  static double calculateRequiredHeading(
    double desiredTrack,
    double trueAirspeed,
    double windDirection,
    double windSpeed
  ) {
    if (windSpeed == 0 || trueAirspeed == 0) return desiredTrack;
    
    final trackRad = desiredTrack * _degToRad;
    final windDirRad = windDirection * _degToRad;
    
    // Wind components relative to desired track
    final headwind = windSpeed * math.cos(windDirRad - trackRad);
    final crosswind = windSpeed * math.sin(windDirRad - trackRad);
    
    // Calculate drift angle
    final driftAngle = math.asin(crosswind / trueAirspeed) * _radToDeg;
    
    // Required heading is desired track minus drift angle
    return normalizeHeading(desiredTrack - driftAngle);
  }
}