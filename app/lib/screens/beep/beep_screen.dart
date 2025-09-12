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
import '../../l10n/app_localizations.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../services/beep_service.dart';
import '../../services/sound_service.dart';
import '../../services/permission_service.dart';
import '../../services/api_client.dart';
import '../../services/comments_service.dart';
import '../../services/location_service.dart';
import '../../debug/stuck_watchdog.dart';
import '../../widgets/dev_menu_button.dart';
import '../../services/ui_feedback.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/sensor_data.dart';
import '../../models/camera_result.dart';
import '../../models/sighting_submission.dart' as local;
import '../../models/user_preferences.dart';
import '../../providers/app_state.dart';
import '../../widgets/beep_button.dart';
import '../../widgets/glass_card.dart';

class BeepScreen extends ConsumerStatefulWidget {
  final String? attachToSightingId;
  final bool autoOpenGallery;
  final File? initialMediaFile;
  final List<File>? initialMediaFiles; // Support multiple files from share intent
  final SensorData? initialSensorData;
  final Map<String, dynamic>? initialPhotoMetadata;
  
  const BeepScreen({
    super.key, 
    this.attachToSightingId,
    this.autoOpenGallery = false,
    this.initialMediaFile,
    this.initialSensorData,
    this.initialPhotoMetadata,
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
  bool _isNavigating = false;
  int _currentUploadIndex = -1; // Track which file is currently uploading
  Set<int> _completedUploads = {}; // Track completed uploads
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _capturedMedia = [];
  

  @override
  void initState() {
    super.initState();
    debugPrint('🏗️ BEEP SCREEN CONSTRUCTOR: Creating new BeepScreen instance');
    debugPrint('🏗️ Initial media count: ${widget.initialMediaFile != null ? 1 : 0}');
    _checkSensorAvailability();
    
    // Handle initial media file from camera
    if (widget.initialMediaFile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInitialMediaFile();
      });
    }
    // Auto-open gallery if requested (for adding media to existing alerts)
    else if (widget.autoOpenGallery) {
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

  Future<void> _handleInitialMediaFile() async {
    if (widget.initialMediaFile == null) return;
    
    try {
      debugPrint('📸 BEEP: Processing initial media file from camera');
      
      // Create a sighting submission with the camera data
      final submission = local.SightingSubmission(
        title: 'UFO Sighting',
        description: '', // User will add description later
        category: 'ufo_sighting',
        imageFile: widget.initialMediaFile,
        imagePath: widget.initialMediaFile!.path,
        sensorData: widget.initialSensorData,
        createdAt: DateTime.now(),
      );
      
      setState(() {
        _currentSubmission = submission;
      });
      
      debugPrint('📸 BEEP: Created submission with camera photo - ${widget.initialMediaFile!.path}');
    } catch (e) {
      debugPrint('❌ BEEP: Failed to process initial media file: $e');
      setState(() {
        _errorMessage = 'Failed to load captured photo';
      });
    }
  }

  Future<void> _capturePhoto() async {
    // Avoid double taps racing navigation
    if (Navigator.of(context).userGestureInProgress) return;
    
    // Navigate to camera screen and await the result
    final description = _descriptionController.text.trim();
    debugPrint('🎯 CAMERA BUTTON: Navigating to /beep/camera with description: $description');
    
    final result = await context.push<CameraCaptureResult>('/beep/camera', extra: {
      'description': description,
    });
    
    debugPrint('📸 BEEP <- result: $result');
    
    if (!mounted) {
      debugPrint('📸 BEEP: Widget not mounted after camera return');
      return;
    }
    
    // Handle the returned photo data
    if (result != null) {
      debugPrint('📸 BEEP: Received photo from camera: ${result.path}');
      debugPrint('📸 BEEP: Result details - isVideo: ${result.isVideo}, hasMetadata: ${result.photoMetadata != null}, hasSensorData: ${result.sensorData != null}');
      
      final mediaFile = File(result.path);
      
      // Add to captured media list
      setState(() {
        _capturedMedia.add(mediaFile);
        _errorMessage = null;
      });
      
      debugPrint('✅ BEEP: Photo added to media list. Total: ${_capturedMedia.length}');
    } else {
      debugPrint('❌ BEEP: No photo returned from camera (result is null - user canceled or handoff failed)');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;
    
    // Check photo gallery permission first
    final hasPermission = await permissionService.requestPhotosForGallery();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo library permission is required to select media'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      debugPrint('📱 GALLERY: Starting file picker...');
      
      // Use the cleaner file_picker approach instead of photo_manager
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media, // This handles both images and videos
        allowMultiple: true,  // Enable multi-file selection
        withData: false, // Don't load file data into memory
        withReadStream: false,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('📱 GALLERY: Timeout waiting for file picker');
          throw Exception('File picker timeout - please try again');
        },
      );
      
      debugPrint('📱 GALLERY: File picker completed');

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

      // Add selected files to captured media list instead of navigating
      final List<File> newMediaFiles = mediaFiles.map((m) => m['mediaFile'] as File).toList();
      
      setState(() {
        _capturedMedia.addAll(newMediaFiles);
      });
      
      debugPrint('✅ BEEP: Added ${newMediaFiles.length} files from gallery. Total: ${_capturedMedia.length}');

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
    debugPrint('🔴 _sendQuickBeep CALLED: _isBeeping=$_isBeeping, _isNavigating=$_isNavigating');
    if (_isBeeping || _isNavigating) {
      debugPrint('🔴 BLOCKED: _isBeeping=$_isBeeping or _isNavigating=$_isNavigating');
      return;
    }
    
    setState(() {
      _isBeeping = true;
      _isNavigating = true;
      _errorMessage = null;
    });
    
    // Play sound feedback
    await SoundService.I.play(AlertSound.tap, haptic: true);
    
    try {
      final description = _descriptionController.text.trim();
      
      // If we have captured media, submit directly without navigation
      if (_capturedMedia.isNotEmpty) {
        debugPrint('📸 BEEP: Submitting beep with ${_capturedMedia.length} media files directly');
        
        try {
          await _submitBeepWithMedia(description);
        } catch (e) {
          debugPrint('❌ Media beep submission failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send beep: $e'),
                backgroundColor: AppColors.semanticError,
              ),
            );
          }
        }
        return;
      }
      
      // Send text-only beep if no media
      final beepDescription = description.isEmpty ? null : description;
      final beepResult = await beepService.sendBeep(
        description: beepDescription,
      );
      
      // Set the device ID as current user so navigation button is hidden
      final deviceId = await beepService.getOrCreateDeviceId();
      ref.read(appStateProvider.notifier).setCurrentUser(deviceId);
      
      // Clear the text field and media
      _descriptionController.clear();
      setState(() {
        _capturedMedia.clear();
        _errorMessage = null;
      });
      
      // Show success with short URL and navigate to sighting detail
      if (mounted) {
        final shortUrl = beepResult['short_url'] as String?;
        final l10n = AppLocalizations.of(context)!;
        final successMessage = l10n.beepSent;
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppColors.semanticSuccess,
            duration: const Duration(seconds: 3),
          ),
        );
        
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
          _isNavigating = false;
          _currentUploadIndex = -1;
          _completedUploads.clear();
        });
      }
    }
  }

  /// Submit beep with media files directly (copied from BeepCompositionScreen._actualSubmitLogic)
  Future<void> _submitBeepWithMedia(String description) async {
    final wd = StuckWatchdog();
    try {
      wd.mark("_submitBeepWithMedia method entry");
      debugPrint('🔴 BEEP: Starting media beep submission with ${_capturedMedia.length} files');
      
      wd.mark("collecting GPS data");
      // Collect GPS data
      SensorData? sensorData;
      try {
        sensorData = await _sensorService.captureSensorData();
        debugPrint('🔴 BEEP: GPS collected - lat=${sensorData.latitude}, lon=${sensorData.longitude}');
      } catch (e) {
        debugPrint('🔴 BEEP: GPS collection failed: $e');
        throw Exception('GPS location required. Please enable GPS or take photos with location enabled.');
      }
      
      wd.mark("validating GPS coordinates");
      // Validate GPS coordinates
      double? validLat = sensorData.latitude;
      double? validLon = sensorData.longitude;
      
      // If sensor GPS is missing or invalid, try to extract from photo EXIF as fallback
      if (validLat == null || validLon == null || (validLat == 0.0 && validLon == 0.0)) {
        wd.mark("extracting GPS from photo EXIF");
        debugPrint('🔴 BEEP: Sensor GPS invalid, attempting to extract from photo EXIF...');
        
        // Try to extract GPS from any attached photos
        for (final mediaFile in _capturedMedia) {
          try {
            wd.mark("extracting metadata from ${mediaFile.path}");
            final photoMetadata = await PhotoMetadataService.extractComprehensiveMetadata(mediaFile);
            final locationData = photoMetadata['location'];
            
            if (locationData != null && 
                locationData['latitude'] != null && 
                locationData['longitude'] != null &&
                locationData['latitude'] != 0.0 &&
                locationData['longitude'] != 0.0) {
              
              validLat = locationData['latitude'];
              validLon = locationData['longitude'];
              debugPrint('🔴 BEEP: Extracted GPS from photo: lat=$validLat, lon=$validLon');
              
              // Update sensor data with extracted coordinates
              sensorData = SensorData(
                utc: sensorData?.utc ?? DateTime.now(),
                latitude: validLat!,
                longitude: validLon!,
                accuracy: 10.0, // Lower accuracy since from photo
                altitude: locationData['altitude'] ?? sensorData?.altitude ?? 0.0,
                azimuthDeg: sensorData?.azimuthDeg ?? 0.0,
                pitchDeg: sensorData?.pitchDeg ?? 0.0,
                rollDeg: sensorData?.rollDeg ?? 0.0,
                hfovDeg: sensorData?.hfovDeg ?? 60.0,
              );
              break; // Found valid GPS, stop searching
            }
          } catch (e) {
            debugPrint('🔴 BEEP: Failed to extract GPS from photo: $e');
          }
        }
      }
      
      // Final validation - only fail if we absolutely have no GPS data
      if (validLat == null || validLon == null || (validLat == 0.0 && validLon == 0.0)) {
        throw Exception('GPS location required. Please enable GPS or take photos with location enabled.');
      }
      
      debugPrint('🔴 BEEP: Final GPS coordinates: lat=$validLat, lon=$validLon');
      
      wd.mark("sending beep to API");
      // Create new sighting with media
      final beepResult = await BeepService().sendBeep(
        description: description.isEmpty ? null : description,
        latitude: validLat,
        longitude: validLon,
        heading: sensorData?.azimuthDeg,
        hasMedia: true, // This will defer alerts until media upload completes
      );
      
      final sightingIdFromResponse = beepResult['sighting_id']?.toString();
      if (sightingIdFromResponse == null) {
        throw Exception('Failed to get sighting ID from API response');
      }
      final sightingId = sightingIdFromResponse;
      debugPrint('🔴 BEEP: Sighting created with ID: $sightingId (alerts deferred)');
    
      wd.mark("starting media upload phase");
      // Now upload all media files, then trigger alerts
      debugPrint('🔴 BEEP: Uploading ${_capturedMedia.length} files to sighting...');
      
      int uploadedCount = 0;
      
      // Upload all files sequentially with progress tracking
      for (int i = 0; i < _capturedMedia.length; i++) {
        final mediaFile = _capturedMedia[i];
        
        // Update UI to show current upload
        if (mounted) {
          setState(() {
            _currentUploadIndex = i;
          });
        }
        
        try {
          wd.mark("processing file ${i + 1}/${_capturedMedia.length}");
          debugPrint('🔴 BEEP: Uploading file ${i + 1}/${_capturedMedia.length}: ${mediaFile.path}');
          debugPrint('🔴 BEEP: File exists: ${await mediaFile.exists()}');
          
          wd.mark("checking file length for ${mediaFile.path}");
          debugPrint('🔴 BEEP: File size: ${await mediaFile.length()} bytes');
          
          wd.mark("calling uploadMediaToSighting API");
          debugPrint('🔴 BEEP: Calling uploadMediaToSighting...');
          await ApiClient.instance.uploadMediaToSighting(
            sightingId,
            mediaFile,
          );
          wd.mark("upload completed for file ${i + 1}");
          debugPrint('🔴 BEEP: Upload successful for file ${i + 1}');
          
          uploadedCount++;
          
          // Mark as completed and update UI
          if (mounted) {
            setState(() {
              _completedUploads.add(i);
            });
          }
          
        } catch (e) {
          debugPrint('🔴 BEEP: Failed to upload file ${mediaFile.path}: $e');
          // Continue with other files - don't fail entire submission
        }
      }
      
      wd.mark("all uploads completed");
      debugPrint('🔴 BEEP: Upload completed: $uploadedCount/${_capturedMedia.length} files uploaded');
      
      // Check if any files failed to upload
      if (uploadedCount == 0) {
        throw Exception('No files could be uploaded');
      } else if (uploadedCount < _capturedMedia.length) {
        // Some files failed - show warning but continue
        debugPrint('🔴 BEEP: Warning: ${_capturedMedia.length - uploadedCount} files failed to upload');
      }
      
      wd.mark("triggering proximity alerts");
      debugPrint('🔴 BEEP: Triggering proximity alerts...');
      // Get coordinates from the sensor data for alert triggering
      final alertValidLat = sensorData?.latitude == 0.0 ? null : sensorData?.latitude;
      final alertValidLon = sensorData?.longitude == 0.0 ? null : sensorData?.longitude;
      
      // Get reliable coordinates for proximity alerts using LocationService
      final alertCoordinates = await LocationService.I.getReliableCoordinates(
        preferredLat: alertValidLat,
        preferredLon: alertValidLon,
        timeout: const Duration(seconds: 5),
      );
      
      if (alertCoordinates != null) {
        await ApiClient.instance.triggerAlertsForSighting(
          sightingId, 
          alertCoordinates['lat']!, 
          alertCoordinates['lon']!
        );
        debugPrint('🔴 BEEP: Proximity alerts sent successfully!');
      } else {
        debugPrint('🔴 BEEP: No valid coordinates available - proximity alerts skipped');
      }

      // SUCCESS: Show success and navigate to sighting detail
      debugPrint('🔴 BEEP: Media beep created successfully with ID: $sightingId');
      
      // Set the device ID as current user so navigation button is hidden
      final deviceId = await beepService.getOrCreateDeviceId();
      ref.read(appStateProvider.notifier).setCurrentUser(deviceId);
      
      // Clear the text field and media
      _descriptionController.clear();
      setState(() {
        _capturedMedia.clear();
        _errorMessage = null;
      });
      
      // Show success message
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.beepSent),
            backgroundColor: AppColors.semanticSuccess,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate to sighting detail after brief delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/alert/$sightingId');
          }
        });
      }
      
      wd.mark("submission completed successfully");
    } catch (e) {
      debugPrint('🔴 BEEP: Media submission error: $e');
      rethrow; // Re-throw to be caught by caller
    } finally {
      wd.dispose();
    }
  }

  /// Show dialog to add more media (camera or gallery)
  void _addMoreMedia() async {
    // Add haptic feedback
    await SoundService.I.play(AlertSound.tap, haptic: true);
    
    // Show dialog to choose between camera or gallery
    final choice = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.brandPrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Media',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Camera and Gallery buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop('camera'),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.brandPrimary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: AppColors.brandPrimary,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Camera',
                                style: const TextStyle(
                                  color: AppColors.brandPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop('gallery'),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.brandPrimary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library,
                                color: AppColors.brandPrimary,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gallery',
                                style: const TextStyle(
                                  color: AppColors.brandPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (choice == null) return;

    if (choice == 'camera') {
      await _capturePhoto();
    } else if (choice == 'gallery') {
      await _pickFromGallery();
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.tabBeep,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: const [
            DevMenuButton(),
          ],
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
                      Text(
                        l10n.whatDoYouSee,
                        style: const TextStyle(
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
                          hintText: l10n.descriptionHint,
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

                // Media thumbnails
                if (_capturedMedia.isNotEmpty) ...[
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _isBeeping ? _capturedMedia.length : _capturedMedia.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 8),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Stack(
                                    children: [
                                      _isBeeping 
                                        ? Container(
                                            color: _completedUploads.contains(index) 
                                              ? Colors.green.withOpacity(0.3)  // Completed: green tint
                                              : (index == _currentUploadIndex 
                                                ? Colors.blue.withOpacity(0.3)  // Uploading: blue tint
                                                : Colors.black.withOpacity(0.8)), // Waiting: black
                                            child: index == _currentUploadIndex 
                                              ? Icon(Icons.upload, color: Colors.white70, size: 20)
                                              : (_completedUploads.contains(index) 
                                                ? Icon(Icons.check, color: Colors.white70, size: 20)
                                                : null),
                                          )
                                        : Image.file(
                                            _capturedMedia[index],
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.white.withOpacity(0.1),
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white.withOpacity(0.5),
                                                  size: 20,
                                                ),
                                              );
                                            },
                                          ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: _isBeeping ? null : () {
                                            setState(() {
                                              _capturedMedia.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

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

                // Action buttons removed - Camera/Gallery now always visible below
                
                // Always show Camera/Gallery buttons (whether media present or not)
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        onTap: _isCapturing ? null : () async {
                          await UiFeedback.click();
                          _capturePhoto();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              l10n.camera,
                              style: const TextStyle(
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
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              l10n.gallery,
                              style: const TextStyle(
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
                    debugPrint('🔴 BUTTON TAP: _isBeeping=$_isBeeping, _capturedMedia=${_capturedMedia.length}');
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
                        : Text(
                            l10n.submitBeep,
                            style: const TextStyle(
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
            Text(
              AppLocalizations.of(context)!.locationPermissionTitle,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.locationPermissionBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.black,
            ),
            child: Text(AppLocalizations.of(context)!.openSettings),
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
            Text(
              AppLocalizations.of(context)!.permissionsRequired,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.locationPermissionBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.semanticWarning,
              foregroundColor: Colors.black,
            ),
            child: Text(AppLocalizations.of(context)!.openSettings),
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
