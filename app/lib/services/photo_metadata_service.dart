import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';

class PhotoMetadataService {
  /// Extract GPS coordinates from image EXIF data
  static Future<Map<String, double>?> extractGpsCoordinates(File imageFile) async {
    try {
      // Read image bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Extract EXIF data
      final Map<String, IfdTag> exifData = await readExifFromBytes(imageBytes);
      
      if (exifData.isEmpty) {
        debugPrint('No EXIF data found in image');
        return null;
      }
      
      // Extract GPS coordinates
      final double? latitude = _extractGpsCoordinate(exifData, 'GPS GPSLatitude', 'GPS GPSLatitudeRef');
      final double? longitude = _extractGpsCoordinate(exifData, 'GPS GPSLongitude', 'GPS GPSLongitudeRef');
      final double? altitude = _extractGpsAltitude(exifData);
      
      if (latitude != null && longitude != null) {
        debugPrint('Extracted GPS coordinates: lat=$latitude, lng=$longitude, alt=$altitude');
        return {
          'latitude': latitude,
          'longitude': longitude,
          if (altitude != null) 'altitude': altitude,
        };
      } else {
        debugPrint('No GPS coordinates found in EXIF data');
        return null;
      }
    } catch (e) {
      debugPrint('Error extracting GPS coordinates from image: $e');
      return null;
    }
  }
  
  /// Extract GPS coordinate (latitude or longitude) from EXIF data
  static double? _extractGpsCoordinate(Map<String, IfdTag> exifData, String coordKey, String refKey) {
    try {
      final IfdTag? coordTag = exifData[coordKey];
      final IfdTag? refTag = exifData[refKey];
      
      if (coordTag == null || refTag == null) {
        return null;
      }
      
      // GPS coordinates are stored as [degrees, minutes, seconds] as ratios
      final List<dynamic> coordValues = coordTag.values.toList();
      final String ref = refTag.printable;
      
      if (coordValues.length != 3) {
        return null;
      }
      
      // Convert degrees, minutes, seconds to decimal degrees
      final double degrees = _ratioToDouble(coordValues[0]);
      final double minutes = _ratioToDouble(coordValues[1]);
      final double seconds = _ratioToDouble(coordValues[2]);
      
      double decimalDegrees = degrees + (minutes / 60.0) + (seconds / 3600.0);
      
      // Apply hemisphere correction
      if (ref == 'S' || ref == 'W') {
        decimalDegrees = -decimalDegrees;
      }
      
      return decimalDegrees;
    } catch (e) {
      debugPrint('Error parsing GPS coordinate: $e');
      return null;
    }
  }
  
  /// Extract GPS altitude from EXIF data
  static double? _extractGpsAltitude(Map<String, IfdTag> exifData) {
    try {
      final IfdTag? altTag = exifData['GPS GPSAltitude'];
      final IfdTag? altRefTag = exifData['GPS GPSAltitudeRef'];
      
      if (altTag == null) {
        return null;
      }
      
      double altitude = _ratioToDouble(altTag.values.toList().first);
      
      // Apply altitude reference (0 = above sea level, 1 = below sea level)
      if (altRefTag != null && altRefTag.values.toList().first == 1) {
        altitude = -altitude;
      }
      
      return altitude;
    } catch (e) {
      debugPrint('Error parsing GPS altitude: $e');
      return null;
    }
  }
  
  /// Convert EXIF ratio to double
  static double _ratioToDouble(dynamic ratio) {
    if (ratio is int) {
      return ratio.toDouble();
    } else if (ratio is double) {
      return ratio;
    } else if (ratio is Ratio) {
      return ratio.numerator / ratio.denominator;
    } else {
      // Try to parse as string "numerator/denominator"
      final String ratioStr = ratio.toString();
      if (ratioStr.contains('/')) {
        final parts = ratioStr.split('/');
        if (parts.length == 2) {
          final num = double.tryParse(parts[0]);
          final den = double.tryParse(parts[1]);
          if (num != null && den != null && den != 0) {
            return num / den;
          }
        }
      }
      // Try direct parse
      return double.tryParse(ratioStr) ?? 0.0;
    }
  }
  
  /// Extract image timestamp from EXIF data
  static DateTime? extractDateTime(Map<String, IfdTag> exifData) {
    try {
      // Try different timestamp fields
      const timestampKeys = [
        'EXIF DateTimeOriginal',
        'EXIF DateTime',
        'Image DateTime',
      ];
      
      for (final key in timestampKeys) {
        final IfdTag? tag = exifData[key];
        if (tag != null) {
          final String timestampStr = tag.printable;
          // EXIF timestamp format: "2023:12:25 14:30:45"
          try {
            final String isoStr = timestampStr.replaceFirst(':', '-').replaceFirst(':', '-').replaceFirst(' ', 'T');
            return DateTime.parse(isoStr);
          } catch (e) {
            continue;
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error extracting image timestamp: $e');
      return null;
    }
  }
}