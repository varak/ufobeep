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
import '../../services/api_client.dart';
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
      // Use the cleaner file_picker approach instead of photo_manager
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media, // This handles both images and videos
        allowMultiple: false,
        withData: false, // Don't load file data into memory
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isCapturing = false;
        });
        return;
      }

      final PlatformFile platformFile = result.files.first;
      final String? filePath = platformFile.path;
      
      if (filePath == null) {
        setState(() {
          _isCapturing = false;
          _errorMessage = 'Could not access selected file';
        });
        return;
      }

      final File mediaFile = File(filePath);
      
      // Determine if this is a video based on file extension and mime type
      final String fileName = platformFile.name.toLowerCase();
      final bool isVideo = fileName.endsWith('.mp4') || 
                          fileName.endsWith('.mov') || 
                          fileName.endsWith('.avi') || 
                          fileName.endsWith('.webm') ||
                          fileName.endsWith('.3gp') ||
                          platformFile.extension?.toLowerCase() == 'mp4' ||
                          platformFile.extension?.toLowerCase() == 'mov' ||
                          platformFile.extension?.toLowerCase() == 'avi' ||
                          platformFile.extension?.toLowerCase() == 'webm' ||
                          platformFile.extension?.toLowerCase() == '3gp';

      debugPrint('Selected ${isVideo ? 'video' : 'image'} file: ${mediaFile.path}');
      debugPrint('File size: ${platformFile.size} bytes');
      debugPrint('File extension: ${platformFile.extension}');
      
      // Extract metadata only for images (videos rarely have useful EXIF)
      Map<String, dynamic> mediaMetadata = {};
      SensorData? sensorDataFromMedia;
      
      if (!isVideo) {
        try {
          debugPrint('Extracting metadata from image file...');
          mediaMetadata = await PhotoMetadataService.extractComprehensiveMetadata(mediaFile);
          debugPrint('Extracted metadata: ${mediaMetadata.keys.length} categories');
          
          // Create sensor data from image EXIF if GPS is available
          final gpsData = mediaMetadata['location'] as Map<String, dynamic>?;
          
          if (gpsData != null && gpsData['latitude'] != null && gpsData['longitude'] != null) {
            debugPrint('✅ Found GPS data: ${gpsData['latitude']}, ${gpsData['longitude']}');
            
            sensorDataFromMedia = SensorData(
              latitude: gpsData['latitude'],
              longitude: gpsData['longitude'],
              altitude: gpsData['altitude'] ?? 0.0,
              accuracy: 10.0, // Lower accuracy since it's from gallery
              utc: DateTime.now(),
              azimuthDeg: 0.0, // Default values since this is from gallery
              pitchDeg: 0.0,
              rollDeg: 0.0,
              hfovDeg: 60.0,
            );
            debugPrint('Created sensor data from image EXIF');
          } else {
            debugPrint('No GPS coordinates found in image EXIF');
          }
        } catch (e) {
          debugPrint('Warning: Failed to extract metadata: $e');
        }
      } else {
        debugPrint('Skipping metadata extraction for video file');
      }

      setState(() {
        _isCapturing = false;
      });

      // Navigate directly to composition screen
      final description = _descriptionController.text.trim();
      context.go('/beep/compose', extra: {
        'mediaFile': mediaFile,
        'isVideo': isVideo,
        'sensorData': sensorDataFromMedia,
        'photoMetadata': mediaMetadata,
        'description': description,
      });

    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to pick media: $e';
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
      if (mounted) {
        setState(() {
          _isBeeping = false;
        });
      }
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
              // What do you see input - moved to top
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

              // Big BEEP button - moved lower on page
              Center(
                child: Column(
                  children: [
                    BeepButton(
                      onPressed: _sendQuickBeep,
                      isLoading: _isBeeping,
                      size: 200,
                      text: 'QUICK BEEP',
                    ),
                    const SizedBox(height: 12),
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

