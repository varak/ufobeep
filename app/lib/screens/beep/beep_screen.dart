import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../models/sensor_data.dart';
import '../../models/sighting_submission.dart' as local;
import '../../models/user_preferences.dart';

class BeepScreen extends StatefulWidget {
  const BeepScreen({super.key});

  @override
  State<BeepScreen> createState() => _BeepScreenState();
}

class _BeepScreenState extends State<BeepScreen> {
  final ImagePicker _picker = ImagePicker();
  final SensorService _sensorService = SensorService();
  
  local.SightingSubmission? _currentSubmission;
  bool _isCapturing = false;
  bool _sensorsAvailable = false;
  String? _errorMessage;
  

  @override
  void initState() {
    super.initState();
    _checkSensorAvailability();
  }

  Future<void> _checkSensorAvailability() async {
    try {
      final available = await _sensorService.checkSensorAvailability();
      setState(() {
        _sensorsAvailable = available;
      });
    } catch (e) {
      setState(() {
        _sensorsAvailable = false;
        _errorMessage = 'Sensor check failed: $e';
      });
    }
  }

  Future<void> _capturePhoto() async {
    // Navigate to custom camera screen that skips approval
    context.go('/beep/camera');
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      // Request photo library permission first
      final PermissionState ps = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          iosAccessLevel: IosAccessLevel.readWrite,
          androidPermission: AndroidPermission(
            type: RequestType.image,
            mediaLocation: true,  // Important for EXIF GPS data
          ),
        ),
      );
      
      if (!ps.isAuth) {
        debugPrint('Photo permission state: ${ps.name}');
        // Show settings dialog if permission was previously denied
        if (mounted) {
          final bool? openSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Photo Access Required'),
              content: const Text('UFOBeep needs access to your photos to select images for sighting reports. Please grant permission in Settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
          
          if (openSettings == true) {
            await PhotoManager.openSetting();
          }
        }
        
        setState(() {
          _isCapturing = false;
          _errorMessage = 'Photo library access denied. Please grant permission in Settings.';
        });
        return;
      }

      // Get ALL photo albums from device
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
        onlyAll: false,  // Show all albums, not just "Recent"
      );
      
      if (albums.isEmpty) {
        setState(() {
          _isCapturing = false;
          _errorMessage = 'No photo albums found';
        });
        return;
      }

      // Debug: Show all available albums
      for (var album in albums) {
        final count = await album.assetCountAsync;
        debugPrint('Album: ${album.name} (${album.id}) - $count photos');
      }

      // Find the Camera album or use Recent/All
      AssetPathEntity? targetAlbum;
      
      // Try to find Camera album first
      targetAlbum = albums.firstWhere(
        (album) => album.name.toLowerCase().contains('camera') || 
                   album.name.toLowerCase().contains('dcim'),
        orElse: () => albums.firstWhere(
          (album) => album.name.toLowerCase().contains('recent') || 
                     album.name.toLowerCase().contains('all'),
          orElse: () => albums.first,
        ),
      );

      debugPrint('Using album: ${targetAlbum.name}');
      
      // Get photos from selected album
      final List<AssetEntity> photos = await targetAlbum.getAssetListPaged(
        page: 0,
        size: 200,  // Get more photos
      );

      if (photos.isEmpty) {
        setState(() {
          _isCapturing = false;
          _errorMessage = 'No photos found';
        });
        return;
      }

      // Show photo picker dialog
      final AssetEntity? selectedAsset = await showDialog<AssetEntity>(
        context: context,
        builder: (context) => _PhotoPickerDialog(photos: photos),
      );

      if (selectedAsset == null) {
        setState(() {
          _isCapturing = false;
        });
        return;
      }

      // Get the ORIGINAL file with all EXIF data preserved
      final File? originalFile = await selectedAsset.originFile;
      
      if (originalFile == null) {
        setState(() {
          _isCapturing = false;
          _errorMessage = 'Could not access original photo file';
        });
        return;
      }

      final imageFile = originalFile;
      debugPrint('Got original photo file: ${imageFile.path}');
      debugPrint('File size: ${await imageFile.length()} bytes');
      
      // Double-check that we're getting the real file
      final String? originalPath = await selectedAsset.getMediaUrl();
      debugPrint('Asset media URL: $originalPath');
      
      // Extract comprehensive photo metadata for astronomical identification services
      Map<String, dynamic> photoMetadata = {};
      SensorData? sensorDataFromPhoto;
      
      try {
        debugPrint('Extracting metadata from file: ${imageFile.path}');
        photoMetadata = await PhotoMetadataService.extractComprehensiveMetadata(imageFile);
        debugPrint('Extracted comprehensive photo metadata from gallery image: ${photoMetadata.keys.length} categories');
        debugPrint('Metadata keys: ${photoMetadata.keys.toList()}');
        
        // Create sensor data from photo EXIF if GPS is available
        final gpsData = photoMetadata['location'] as Map<String, dynamic>?;
        debugPrint('Location data extracted: $gpsData');
        
        if (gpsData != null && gpsData['latitude'] != null && gpsData['longitude'] != null) {
          debugPrint('✅ Found GPS data in gallery image: ${gpsData['latitude']}, ${gpsData['longitude']}');
          
          sensorDataFromPhoto = SensorData(
            latitude: gpsData['latitude'],
            longitude: gpsData['longitude'],
            altitude: gpsData['altitude'] ?? 0.0,
            accuracy: 10.0, // Lower accuracy since it's from gallery photo
            utc: DateTime.now(),
            azimuthDeg: 0.0, // Default values since this is from gallery
            pitchDeg: 0.0,
            rollDeg: 0.0,
            hfovDeg: 60.0,
          );
          debugPrint('Created sensor data from gallery image EXIF');
        } else {
          debugPrint('No GPS coordinates found in gallery image EXIF data');
        }
      } catch (e) {
        debugPrint('Warning: Failed to extract metadata from gallery image: $e');
      }

      // Create initial submission for gallery image
      debugPrint('Creating submission with sensorData: ${sensorDataFromPhoto?.latitude}, ${sensorDataFromPhoto?.longitude}');
      final submission = local.SightingSubmission(
        imageFile: imageFile,
        title: '',
        description: '',
        category: local.SightingCategory.ufo,
        sensorData: sensorDataFromPhoto,
        locationPrivacy: LocationPrivacy.jittered,
        createdAt: DateTime.now(),
      );
      debugPrint('Submission created with sensorData: ${submission.sensorData?.latitude}, ${submission.sensorData?.longitude}');

      setState(() {
        _currentSubmission = submission;
        _isCapturing = false;
      });

      // Navigate to composition screen with metadata
      context.go('/beep/compose', extra: {
        'imageFile': submission.imageFile,
        'sensorData': sensorDataFromPhoto,
        'photoMetadata': photoMetadata,
      });

    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Beep'),
        backgroundColor: AppColors.darkSurface,
      ),
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Status indicator
              if (!_sensorsAvailable) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.semanticWarning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.semanticWarning.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.semanticWarning, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Device sensors not available. Plane matching will be limited.',
                          style: TextStyle(
                            color: AppColors.semanticWarning,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.semanticError.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.semanticError.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: AppColors.semanticError, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.semanticError,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Camera icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.brandPrimary.withOpacity(0.2),
                            AppColors.brandPrimary.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: AppColors.brandPrimary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Instructions
                    const Text(
                      'Capture or Select Sighting',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Point your camera at the sky object and tap capture.\nSensor data will be collected for plane matching.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Action buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isCapturing ? null : _capturePhoto,
                            icon: _isCapturing 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.camera_alt),
                            label: Text(_isCapturing ? 'Capturing...' : 'Capture Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPrimary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isCapturing ? null : _pickFromGallery,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Choose from Gallery'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brandPrimary,
                              side: const BorderSide(color: AppColors.brandPrimary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer info
              if (_sensorsAvailable)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sensors, color: AppColors.brandPrimary, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Sensors ready for plane matching',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
  }
}

// Simple photo picker dialog that shows thumbnails
class _PhotoPickerDialog extends StatelessWidget {
  final List<AssetEntity> photos;

  const _PhotoPickerDialog({required this.photos});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            AppBar(
              title: const Text('Select Photo'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final asset = photos[index];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pop(asset),
                    child: FutureBuilder<Uint8List?>(
                      future: asset.thumbnailDataWithSize(
                        const ThumbnailSize(200, 200),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        }
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}