import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../services/anonymous_beep_service.dart';
import '../../services/sound_service.dart';
import '../../services/permission_service.dart';
import '../../models/sensor_data.dart';
import '../../models/sighting_submission.dart' as local;
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/beep_button.dart';

class BeepScreen extends ConsumerStatefulWidget {
  const BeepScreen({super.key});

  @override
  ConsumerState<BeepScreen> createState() => _BeepScreenState();
}

class _BeepScreenState extends ConsumerState<BeepScreen> {
  final ImagePicker _picker = ImagePicker();
  final SensorService _sensorService = SensorService();
  
  local.SightingSubmission? _currentSubmission;
  bool _isCapturing = false;
  bool _sensorsAvailable = false;
  String? _errorMessage;
  bool _isBeeping = false;
  final TextEditingController _descriptionController = TextEditingController();
  

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
    final description = _descriptionController.text.trim();
    context.go('/beep/camera', extra: {
      'description': description,
    });
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

      // Navigate to composition screen with metadata and description
      final description = _descriptionController.text.trim();
      context.go('/beep/compose', extra: {
        'imageFile': submission.imageFile,
        'sensorData': sensorDataFromPhoto,
        'photoMetadata': photoMetadata,
        'description': description,
      });

    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }



  Future<void> _sendQuickBeep() async {
    if (_isBeeping) return;
    
    setState(() {
      _isBeeping = true;
      _errorMessage = null;
    });
    
    // Play sound feedback
    await SoundService.I.play(AlertSound.tap, haptic: true);
    
    // Proactive GPS permission check with inline request
    if (!permissionService.locationGranted) {
      setState(() {
        _errorMessage = 'Getting location permission...';
      });
      
      await permissionService.refreshPermissions();
      
      if (!permissionService.locationGranted) {
        // Show inline permission request
        final shouldRequest = await _showLocationPermissionDialog();
        if (!shouldRequest) {
          setState(() {
            _isBeeping = false;
            _errorMessage = 'Location permission is required to send beeps';
          });
          return;
        }
        
        // Open system settings for user to grant permission
        await permissionService.openPermissionSettings();
        
        // After user returns from settings, refresh permissions
        await permissionService.refreshPermissions();
        
        if (!permissionService.locationGranted) {
          setState(() {
            _isBeeping = false;
            _errorMessage = 'Location permission is still denied. UFOBeep needs location access to work.';
          });
          return;
        }
      }
    }
    
    try {
      // Get description from text field if provided, otherwise use default
      final description = _descriptionController.text.trim();
      final beepDescription = description.isEmpty 
          ? 'Quick beep - something in the sky!' 
          : description;
          
      // Send anonymous beep with description
      final beepResult = await anonymousBeepService.sendBeep(
        description: beepDescription,
      );
      
      // Set the device ID as current user so navigation button is hidden
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      ref.read(appStateProvider.notifier).setCurrentUser(deviceId);
      
      // Clear the text field if description was used
      if (description.isNotEmpty) {
        _descriptionController.clear();
      }
      
      // Show success and navigate to sighting detail
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert sent! Sighting ID: ${beepResult['sighting_id']}'),
            backgroundColor: AppColors.semanticSuccess,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate to the sighting detail screen
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/alert/${beepResult['sighting_id']}');
          }
        });
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send beep: $e'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    } finally {
      setState(() {
        _isBeeping = false;
      });
    }
  }
  
  Future<void> _sendBeepWithDescription() async {
    if (_isBeeping) return;
    
    setState(() {
      _isBeeping = true;
      _errorMessage = null;
    });
    
    // Play sound feedback
    await SoundService.I.play(AlertSound.tap, haptic: true);
    
    try {
      final description = _descriptionController.text.trim();
      final beepDescription = description.isEmpty 
          ? 'Something in the sky!' 
          : description;
      
      // Send anonymous beep with description
      final beepResult = await anonymousBeepService.sendBeep(
        description: beepDescription,
      );
      
      // Set the device ID as current user so navigation button is hidden
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      ref.read(appStateProvider.notifier).setCurrentUser(deviceId);
      
      // Clear the text field
      _descriptionController.clear();
      
      // Show success and navigate to sighting detail
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert sent! Sighting ID: ${beepResult['sighting_id']}'),
            backgroundColor: AppColors.semanticSuccess,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate to the sighting detail screen
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/alert/${beepResult['sighting_id']}');
          }
        });
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send beep: $e'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    } finally {
      setState(() {
        _isBeeping = false;
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Big BEEP button
              Center(
                child: Column(
                  children: [
                    BeepButton(
                      onPressed: _sendQuickBeep,
                      isLoading: _isBeeping,
                      size: 200,
                      text: 'QUICK BEEP',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Instant alert • Add description below (optional)',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          permissionService.locationGranted 
                              ? Icons.location_on 
                              : Icons.location_off,
                          size: 12,
                          color: permissionService.locationGranted 
                              ? AppColors.semanticSuccess 
                              : AppColors.semanticWarning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          permissionService.locationGranted 
                              ? 'Location ready' 
                              : 'Location needed',
                          style: TextStyle(
                            color: permissionService.locationGranted 
                                ? AppColors.semanticSuccess 
                                : AppColors.semanticWarning,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Divider with text
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.darkBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ADD DESCRIPTION (OPTIONAL)',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.darkBorder)),
                ],
              ),
              
              const SizedBox(height: 16),

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
                  children: [
                    const SizedBox(height: 24),
                    
                    // What do you see input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'What do you see?',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Describe what you\'re seeing in the sky...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: AppColors.darkBackground.withOpacity(0.5),
                              contentPadding: const EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.darkBorder.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.brandPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Send with description button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isBeeping ? null : _sendBeepWithDescription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: _isBeeping
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Sending Alert...'),
                                ],
                              )
                            : const Text('Send Alert'),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Or continue to photo options
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.darkBorder)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ACCESS CAMERA OR ATTACH MEDIA',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.darkBorder)),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Photo options with glow effects
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandPrimary.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: OutlinedButton.icon(
                              onPressed: _isCapturing ? null : _capturePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.brandPrimary,
                                backgroundColor: AppColors.brandPrimary.withOpacity(0.1),
                                side: const BorderSide(color: AppColors.brandPrimary, width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandPrimary.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: OutlinedButton.icon(
                              onPressed: _isCapturing ? null : _pickFromGallery,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Attach'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.brandPrimary,
                                backgroundColor: AppColors.brandPrimary.withOpacity(0.1),
                                side: const BorderSide(color: AppColors.brandPrimary, width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


  Future<bool> _showLocationPermissionDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.brandPrimary),
            const SizedBox(width: 8),
            const Text(
              'Location Required',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: const Text(
          'UFOBeep needs your location to:\n\n'
          '• Send alerts to nearby people\n'
          '• Help others navigate to the sighting\n'
          '• Provide accurate distance information\n\n'
          'Your exact location is never shared publicly.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Allow Location'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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