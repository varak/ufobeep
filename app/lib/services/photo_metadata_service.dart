import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';

class PhotoMetadataService {
  /// Extract comprehensive photo metadata for astronomical/aircraft identification services
  static Future<Map<String, dynamic>> extractComprehensiveMetadata(File imageFile) async {
    try {
      // Read image bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Extract EXIF data
      final Map<String, IfdTag> exifData = await readExifFromBytes(imageBytes);
      
      final metadata = <String, dynamic>{
        'exif_available': exifData.isNotEmpty,
        'extraction_timestamp': DateTime.now().toIso8601String(),
      };
      
      if (exifData.isNotEmpty) {
        // GPS and location data
        final locationData = _extractLocationData(exifData);
        if (locationData != null) {
          metadata['location'] = locationData;
        }
        
        // Camera settings and technical data
        metadata['camera'] = _extractCameraData(exifData);
        
        // Device orientation and compass data (if available in EXIF)
        metadata['orientation'] = _extractOrientationData(exifData);
        
        // Timestamp data
        metadata['timestamps'] = _extractTimestampData(exifData);
        
        // Image properties
        metadata['image_properties'] = _extractImageProperties(exifData);
        
        // Device and software info
        metadata['device_info'] = _extractDeviceInfo(exifData);
        
        // Raw EXIF for debugging/advanced processing
        metadata['raw_exif_keys'] = exifData.keys.toList();
      }
      
      return metadata;
    } catch (e) {
      debugPrint('Error extracting comprehensive metadata: $e');
      return {
        'exif_available': false,
        'extraction_error': e.toString(),
        'extraction_timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Extract GPS coordinates from image EXIF data (backward compatibility)
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

  // Comprehensive metadata extraction methods for astronomical/aircraft identification

  /// Extract detailed location and GPS data
  static Map<String, dynamic>? _extractLocationData(Map<String, IfdTag> exifData) {
    try {
      final data = <String, dynamic>{};
      
      // GPS coordinates
      final latitude = _extractGpsCoordinate(exifData, 'GPS GPSLatitude', 'GPS GPSLatitudeRef');
      final longitude = _extractGpsCoordinate(exifData, 'GPS GPSLongitude', 'GPS GPSLongitudeRef');
      final altitude = _extractGpsAltitude(exifData);
      
      if (latitude != null && longitude != null) {
        data['latitude'] = latitude;
        data['longitude'] = longitude;
        if (altitude != null) data['altitude'] = altitude;
      }
      
      // Additional GPS metadata
      _addExifField(exifData, data, 'GPS GPSSpeedRef', 'gps_speed_ref');
      _addExifField(exifData, data, 'GPS GPSSpeed', 'gps_speed');
      _addExifField(exifData, data, 'GPS GPSTrackRef', 'gps_track_ref');
      _addExifField(exifData, data, 'GPS GPSTrack', 'gps_track');
      _addExifField(exifData, data, 'GPS GPSImgDirectionRef', 'gps_img_direction_ref');
      _addExifField(exifData, data, 'GPS GPSImgDirection', 'gps_img_direction');
      _addExifField(exifData, data, 'GPS GPSDestBearingRef', 'gps_dest_bearing_ref');
      _addExifField(exifData, data, 'GPS GPSDestBearing', 'gps_dest_bearing');
      _addExifField(exifData, data, 'GPS GPSDateStamp', 'gps_date_stamp');
      _addExifField(exifData, data, 'GPS GPSTimeStamp', 'gps_time_stamp');
      _addExifField(exifData, data, 'GPS GPSMapDatum', 'gps_map_datum');
      _addExifField(exifData, data, 'GPS GPSProcessingMethod', 'gps_processing_method');
      _addExifField(exifData, data, 'GPS GPSAreaInformation', 'gps_area_info');
      _addExifField(exifData, data, 'GPS GPSDifferential', 'gps_differential');
      _addExifField(exifData, data, 'GPS GPSHPositioningError', 'gps_h_positioning_error');
      
      return data.isNotEmpty ? data : null;
    } catch (e) {
      debugPrint('Error extracting location data: $e');
      return null;
    }
  }

  /// Extract camera settings and technical data
  static Map<String, dynamic> _extractCameraData(Map<String, IfdTag> exifData) {
    final data = <String, dynamic>{};
    
    // Camera settings crucial for astronomical analysis
    _addExifField(exifData, data, 'EXIF ExposureTime', 'exposure_time');
    _addExifField(exifData, data, 'EXIF FNumber', 'f_number');
    _addExifField(exifData, data, 'EXIF ISOSpeedRatings', 'iso_speed');
    _addExifField(exifData, data, 'EXIF FocalLength', 'focal_length');
    _addExifField(exifData, data, 'EXIF FocalLengthIn35mmFilm', 'focal_length_35mm');
    _addExifField(exifData, data, 'EXIF MaxApertureValue', 'max_aperture');
    _addExifField(exifData, data, 'EXIF SubjectDistance', 'subject_distance');
    _addExifField(exifData, data, 'EXIF Flash', 'flash');
    _addExifField(exifData, data, 'EXIF WhiteBalance', 'white_balance');
    _addExifField(exifData, data, 'EXIF ExposureMode', 'exposure_mode');
    _addExifField(exifData, data, 'EXIF ExposureProgram', 'exposure_program');
    _addExifField(exifData, data, 'EXIF MeteringMode', 'metering_mode');
    _addExifField(exifData, data, 'EXIF LightSource', 'light_source');
    _addExifField(exifData, data, 'EXIF SceneCaptureType', 'scene_capture_type');
    _addExifField(exifData, data, 'EXIF GainControl', 'gain_control');
    _addExifField(exifData, data, 'EXIF Contrast', 'contrast');
    _addExifField(exifData, data, 'EXIF Saturation', 'saturation');
    _addExifField(exifData, data, 'EXIF Sharpness', 'sharpness');
    _addExifField(exifData, data, 'EXIF DigitalZoomRatio', 'digital_zoom_ratio');
    
    // Lens information
    _addExifField(exifData, data, 'EXIF LensSpecification', 'lens_specification');
    _addExifField(exifData, data, 'EXIF LensMake', 'lens_make');
    _addExifField(exifData, data, 'EXIF LensModel', 'lens_model');
    
    return data;
  }

  /// Extract orientation and compass data
  static Map<String, dynamic> _extractOrientationData(Map<String, IfdTag> exifData) {
    final data = <String, dynamic>{};
    
    // Image orientation
    _addExifField(exifData, data, 'Image Orientation', 'image_orientation');
    
    // GPS direction information (compass bearings)
    _addExifField(exifData, data, 'GPS GPSImgDirection', 'camera_direction');
    _addExifField(exifData, data, 'GPS GPSImgDirectionRef', 'camera_direction_ref');
    _addExifField(exifData, data, 'GPS GPSTrack', 'movement_direction');
    _addExifField(exifData, data, 'GPS GPSTrackRef', 'movement_direction_ref');
    
    return data;
  }

  /// Extract timestamp data
  static Map<String, dynamic> _extractTimestampData(Map<String, IfdTag> exifData) {
    final data = <String, dynamic>{};
    
    _addExifField(exifData, data, 'EXIF DateTimeOriginal', 'datetime_original');
    _addExifField(exifData, data, 'EXIF DateTime', 'datetime');
    _addExifField(exifData, data, 'EXIF DateTimeDigitized', 'datetime_digitized');
    _addExifField(exifData, data, 'Image DateTime', 'image_datetime');
    _addExifField(exifData, data, 'EXIF SubSecTime', 'subsec_time');
    _addExifField(exifData, data, 'EXIF SubSecTimeOriginal', 'subsec_time_original');
    _addExifField(exifData, data, 'EXIF SubSecTimeDigitized', 'subsec_time_digitized');
    _addExifField(exifData, data, 'EXIF TimeZoneOffset', 'timezone_offset');
    _addExifField(exifData, data, 'GPS GPSTimeStamp', 'gps_time');
    _addExifField(exifData, data, 'GPS GPSDateStamp', 'gps_date');
    
    return data;
  }

  /// Extract image properties
  static Map<String, dynamic> _extractImageProperties(Map<String, IfdTag> exifData) {
    final data = <String, dynamic>{};
    
    _addExifField(exifData, data, 'EXIF PixelXDimension', 'pixel_x_dimension');
    _addExifField(exifData, data, 'EXIF PixelYDimension', 'pixel_y_dimension');
    _addExifField(exifData, data, 'Image ImageWidth', 'image_width');
    _addExifField(exifData, data, 'Image ImageLength', 'image_length');
    _addExifField(exifData, data, 'Image BitsPerSample', 'bits_per_sample');
    _addExifField(exifData, data, 'Image PhotometricInterpretation', 'photometric_interpretation');
    _addExifField(exifData, data, 'Image SamplesPerPixel', 'samples_per_pixel');
    _addExifField(exifData, data, 'Image XResolution', 'x_resolution');
    _addExifField(exifData, data, 'Image YResolution', 'y_resolution');
    _addExifField(exifData, data, 'Image ResolutionUnit', 'resolution_unit');
    _addExifField(exifData, data, 'EXIF ColorSpace', 'color_space');
    _addExifField(exifData, data, 'EXIF ComponentsConfiguration', 'components_configuration');
    _addExifField(exifData, data, 'EXIF CompressedBitsPerPixel', 'compressed_bits_per_pixel');
    
    return data;
  }

  /// Extract device and software information
  static Map<String, dynamic> _extractDeviceInfo(Map<String, IfdTag> exifData) {
    final data = <String, dynamic>{};
    
    _addExifField(exifData, data, 'Image Make', 'device_make');
    _addExifField(exifData, data, 'Image Model', 'device_model');
    _addExifField(exifData, data, 'Image Software', 'software');
    _addExifField(exifData, data, 'EXIF ExifVersion', 'exif_version');
    _addExifField(exifData, data, 'EXIF FlashpixVersion', 'flashpix_version');
    _addExifField(exifData, data, 'Image Artist', 'artist');
    _addExifField(exifData, data, 'Image Copyright', 'copyright');
    _addExifField(exifData, data, 'Image ImageDescription', 'image_description');
    _addExifField(exifData, data, 'EXIF UserComment', 'user_comment');
    _addExifField(exifData, data, 'EXIF MakerNote', 'maker_note');
    
    return data;
  }

  /// Helper method to add EXIF field to data map
  static void _addExifField(Map<String, IfdTag> exifData, Map<String, dynamic> data, String exifKey, String dataKey) {
    try {
      final tag = exifData[exifKey];
      if (tag != null) {
        final value = tag.printable.trim();
        if (value.isNotEmpty && value != 'None' && value != 'null') {
          data[dataKey] = value;
        }
      }
    } catch (e) {
      // Ignore individual field extraction errors
    }
  }
}