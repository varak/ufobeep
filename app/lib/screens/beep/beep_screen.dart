import 'dart:io';
import 'dart:async';
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
import '../../services/beep_service.dart';
import '../../services/sound_service.dart';
import '../../services/permission_service.dart';
import '../../services/api_client.dart';
import '../../services/comments_service.dart';
import '../../services/ui_feedback.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/sensor_data.dart';
import '../../models/sighting_submission.dart' as local;
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/beep_button.dart';
import '../../widgets/glass_card.dart';

class BeepScreen extends ConsumerStatefulWidget {
  final String? attachToSightingId;
  final bool autoOpenGallery;
  
  const BeepScreen({
    super.key, 
    this.attachToSightingId,
    this.autoOpenGallery = false,
  });

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
    
    // Auto-open gallery if requested (for adding media to existing alerts)
    if (widget.autoOpenGallery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickFromGallery();
      });
    }
    
    // Warm up native UI feedback
    UiFeedback.init();
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
        allowMultiple: true,  // Enable multi-file selection
        withData: false, // Don't load file data into memory
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isCapturing = false;
        });
        return;
      }

      debugPrint('Selected ${result.files.length} files');
      
      // Process all selected files with better error handling
      final List<Map<String, dynamic>> mediaFiles = [];
      
      // Get current location once for all files
      SensorData? currentSensorData;
      try {
        final currentLocation = await permissionService.getCurrentLocation();
        if (currentLocation != null) {
          currentSensorData = SensorData(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            altitude: currentLocation.altitude,
            accuracy: currentLocation.accuracy,
            utc: DateTime.now(),
            azimuthDeg: 0.0,
            pitchDeg: 0.0,
            rollDeg: 0.0,
            hfovDeg: 60.0,
          );
          debugPrint('📍 Using current location for media beep: ${currentLocation.latitude}, ${currentLocation.longitude}');
        } else {
          debugPrint('❌ Failed to get current location for media beep');
        }
      } catch (e) {
        debugPrint('Warning: Location access failed: $e');
        // Continue without location - composition screen will handle this
      }
      
      // Process files one by one with individual error handling
      for (final PlatformFile platformFile in result.files) {
        try {
          final String? filePath = platformFile.path;
          
          if (filePath == null || filePath.isEmpty) {
            debugPrint('Skipping file with null/empty path: ${platformFile.name}');
            continue;
          }

          final File mediaFile = File(filePath);
          
          // Verify file exists and is readable
          if (!await mediaFile.exists()) {
            debugPrint('Skipping non-existent file: $filePath');
            continue;
          }

          // Determine if this is a video with more robust detection
          final String fileName = platformFile.name.toLowerCase();
          final String? extension = platformFile.extension?.toLowerCase();
          final bool isVideo = fileName.endsWith('.mp4') || 
                              fileName.endsWith('.mov') || 
                              fileName.endsWith('.avi') || 
                              fileName.endsWith('.webm') ||
                              fileName.endsWith('.3gp') ||
                              fileName.endsWith('.mkv') ||
                              extension == 'mp4' ||
                              extension == 'mov' ||
                              extension == 'avi' ||
                              extension == 'webm' ||
                              extension == '3gp' ||
                              extension == 'mkv';

          debugPrint('Processing ${isVideo ? 'video' : 'image'} file: ${mediaFile.path}');
          debugPrint('File size: ${platformFile.size} bytes');
          
          // Extract metadata only for images with error handling
          Map<String, dynamic> mediaMetadata = {};
          
          if (!isVideo) {
            try {
              debugPrint('Extracting metadata from image file...');
              mediaMetadata = await PhotoMetadataService.extractComprehensiveMetadata(mediaFile);
              debugPrint('Extracted metadata: ${mediaMetadata.keys.length} categories');
            } catch (e) {
              debugPrint('Warning: Failed to extract metadata from ${mediaFile.path}: $e');
              // Continue without metadata
            }
          }
          
          // Add to files list
          mediaFiles.add({
            'mediaFile': mediaFile,
            'isVideo': isVideo,
            'photoMetadata': mediaMetadata,
            'platformFile': platformFile,
          });
          
        } catch (e) {
          debugPrint('Error processing file ${platformFile.name}: $e');
          // Skip this file and continue with others
          continue;
        }
      }

      setState(() {
        _isCapturing = false;
      });

      if (mediaFiles.isEmpty) {
        setState(() {
          _errorMessage = 'No valid files could be processed. Please check file permissions and try again.';
        });
        return;
      }

      final description = _descriptionController.text.trim();
      
      debugPrint('Navigating to composition screen with ${mediaFiles.length} files');
      
      // Always route to composition screen - handles both single and multiple files
      if (mounted) {
        context.go('/beep/compose', extra: {
          'mediaFiles': mediaFiles, // Pass all files as array
          'sensorData': currentSensorData,
          'description': description,
          'attachToSightingId': widget.attachToSightingId, // Pass through for existing alerts
        });
      }

    } catch (e, stackTrace) {
      debugPrint('Critical error in _pickFromGallery: $e');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to access gallery. Please check app permissions and try again.';
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
    
    // BeepService now handles location permission directly - no need for complex checks
    setState(() {
      _errorMessage = 'Getting location...';
    });
    
    try {
      // Get description from text field if provided, otherwise null
      final description = _descriptionController.text.trim();
      final beepDescription = description.isEmpty ? null : description;
          
      // Send anonymous beep with description
      final beepResult = await beepService.sendBeep(
        description: beepDescription,
      );
      
      // Set the device ID as current user so navigation button is hidden
      final deviceId = await beepService.getOrCreateDeviceId();
      ref.read(appStateProvider.notifier).setCurrentUser(deviceId);
      
      // Clear the text field if description was used
      if (description.isNotEmpty) {
        _descriptionController.clear();
      }
      
      // Show success and navigate to sighting detail
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert sent successfully!'),
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
    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Beep',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Description input in glass card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What do you see?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Describe what you\'re seeing in the sky...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.brandPrimary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Error message in glass card
                if (_errorMessage != null) ...[
                  GlassCard(
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: AppColors.error, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons in glass cards
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        onTap: _isCapturing ? null : () async {
                          await UiFeedback.click();
                          _capturePhoto();
                        },
                        child: const Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Camera',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        onTap: _isCapturing ? null : () async {
                          await UiFeedback.click();
                          _pickFromGallery();
                        },
                        child: const Column(
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Gallery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // Send Beep button
                GlassCard(
                  onTap: _isBeeping ? null : () async {
                    await UiFeedback.click();
                    _sendQuickBeep();
                  },
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.brandPrimary,
                        width: 2,
                      ),
                    ),
                    child: _isBeeping
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.brandPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send Beep',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
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

  Future<bool> _showSettingsDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Row(
          children: [
            const Icon(Icons.settings, color: AppColors.semanticWarning),
            const SizedBox(width: 8),
            const Text(
              'Settings Required',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: const Text(
          'Location permission was permanently denied. To use UFOBeep, you must enable location access in your device Settings.\n\n'
          'UFOBeep requires location to send and receive sighting alerts.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.semanticWarning,
              foregroundColor: Colors.black,
            ),
            child: const Text('Open Settings'),
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

