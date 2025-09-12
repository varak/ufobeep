import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';
import '../../models/sensor_data.dart';
import '../../models/api_models.dart' as api;
import '../../services/api_client.dart';
import '../../services/comments_service.dart';
import '../../services/sound_service.dart';
import '../../services/beep_service.dart';
import '../../services/sensor_service.dart';
import '../../services/location_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../services/ui_feedback.dart';
import '../../providers/app_state.dart';
import '../../widgets/simple_photo_display.dart';
import '../../widgets/video_player_widget.dart';
import '../../widgets/multi_file_preview.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';

class BeepCompositionScreen extends ConsumerStatefulWidget {
  // Legacy single-file parameters (for backward compatibility)
  final File? mediaFile;
  final bool? isVideo;
  final Map<String, dynamic>? photoMetadata;
  
  // New multi-file parameters
  final List<Map<String, dynamic>>? mediaFiles;
  
  // Common parameters
  final SensorData? sensorData;
  final String? description;
  final String? attachToSightingId;

  const BeepCompositionScreen({
    super.key,
    // Legacy constructor
    this.mediaFile,
    this.isVideo,
    this.photoMetadata,
    // New constructor
    this.mediaFiles,
    // Common
    this.sensorData,
    this.description,
    this.attachToSightingId,
  });

  @override
  ConsumerState<BeepCompositionScreen> createState() => _BeepCompositionScreenState();
}

class _BeepCompositionScreenState extends ConsumerState<BeepCompositionScreen> {
  // Form controllers and state
  final TextEditingController _descriptionController = TextEditingController();
  // Location privacy is now handled in user profile settings
  
  // Store sensor data in state to preserve it during rebuilds
  SensorData? _sensorData;
  
  // Media files state - normalize both single and multi-file to List format
  List<Map<String, dynamic>> _mediaFiles = [];
  
  // Submission state
  bool _isSubmitting = false;
  String? _errorMessage;

  // Form validation - description is optional
  bool get _isFormValid {
    return true; // Always valid since description is optional
  }
  
  bool get _hasContent {
    final description = _descriptionController.text.trim();
    return description.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 BEEP SCREEN INIT: _isSubmitting=$_isSubmitting');
    
    // Wrap initialization in try-catch to prevent crashes
    try {
      // Store sensor data in state immediately to preserve it during rebuilds
      _sensorData = widget.sensorData;
    
    // Normalize media files format - handle both legacy single-file and new multi-file
    if (widget.mediaFiles != null) {
      // New multi-file format
      _mediaFiles = List.from(widget.mediaFiles!);
      debugPrint('BeepComposition: Multi-file mode with ${_mediaFiles.length} files');
    } else if (widget.mediaFile != null) {
      // Legacy single-file format - convert to multi-file format
      _mediaFiles = [{
        'mediaFile': widget.mediaFile!,
        'isVideo': widget.isVideo ?? false,
        'photoMetadata': widget.photoMetadata ?? {},
      }];
      debugPrint('BeepComposition: Legacy single-file mode converted to multi-file');
    }
    
    // Warm up native UI feedback
    UiFeedback.init();
    
    // Proactively collect location data with timeout for faster GPS lock
    _collectLocationDataWithTimeout();
    
    // Prepopulate description if provided
    if (widget.description != null && widget.description!.isNotEmpty) {
      _descriptionController.text = widget.description!;
    }
    
    debugPrint('BeepComposition: ${_mediaFiles.length} files, Sensor=${_sensorData != null}');
    if (_sensorData != null) {
      debugPrint('BeepComposition: GPS coordinates: lat=${_sensorData!.latitude}, lng=${_sensorData!.longitude}');
    } else {
      // Fallback: collect location data if not provided (e.g., from share intent)
      debugPrint('BeepComposition: No sensor data provided, attempting to collect location as fallback');
      _collectFallbackLocationData();
    }
    
    // Add listener for real-time validation
    _descriptionController.addListener(_onFormFieldChanged);
    } catch (e, stackTrace) {
      debugPrint('❌ BEEP COMPOSITION INIT ERROR: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      // Set error state but don't crash the app
      if (mounted) {
        setState(() {
          _errorMessage = 'Initialization failed: ${e.toString()}';
        });
      }
    }
  }
  

  void _onFormFieldChanged() {
    setState(() {});
    debugPrint('Form validation: desc=${_descriptionController.text.length} chars, valid=$_isFormValid');
    debugPrint('Form change - sensor data still present: ${_sensorData != null}, GPS: ${_sensorData?.latitude}, ${_sensorData?.longitude}');
  }

  /// Collect location data as fallback when sensorData is null (e.g., share intent flow)
  Future<void> _collectFallbackLocationData() async {
    try {
      debugPrint('BeepComposition: Starting fallback location collection...');
      final sensorService = SensorService();
      final collectedData = await sensorService.captureSensorData();
      
      if (mounted) {
        setState(() {
          _sensorData = collectedData;
        });
      }
      
      if (collectedData.latitude != null && collectedData.longitude != null) {
        debugPrint('BeepComposition: ✅ Fallback location collected - GPS: ${collectedData.latitude}, ${collectedData.longitude}');
      } else {
        debugPrint('BeepComposition: ⚠️ Fallback sensor data collected but no GPS coordinates available');
      }
    } catch (e, stackTrace) {
      debugPrint('BeepComposition: ❌ Error during fallback location collection: $e');
      debugPrint('BeepComposition: ❌ Stack trace: $stackTrace');
      // Don't crash the app, just log the error
      if (mounted) {
        setState(() {
          _errorMessage = 'Location collection failed: ${e.toString()}';
        });
      }
    }
  }

  /// Proactively collect location data with timeout for faster GPS lock
  Future<void> _collectLocationDataWithTimeout() async {
    try {
      debugPrint('BeepComposition: Starting proactive location collection with 8s timeout...');
      final sensorService = SensorService();
      final collectedData = await sensorService.captureSensorData();
      
      if (mounted) {
        setState(() {
          _sensorData = collectedData;
        });
      }
      
      if (collectedData.latitude != null && collectedData.longitude != null) {
        debugPrint('BeepComposition: ✅ Proactive location collected - GPS: ${collectedData.latitude}, ${collectedData.longitude}');
      } else {
        debugPrint('BeepComposition: ⚠️ Proactive sensor data collected but no GPS coordinates available');
      }
    } catch (e, stackTrace) {
      debugPrint('BeepComposition: ❌ Error during proactive location collection: $e');
      debugPrint('BeepComposition: ❌ Stack trace: $stackTrace');
      // Don't crash the app for location errors
      if (mounted) {
        setState(() {
          _errorMessage = 'Location collection failed: ${e.toString()}';
        });
      }
    }
  }

  // 🔥 ChatGPT's Bulletproof Logger
  void _log(String msg) => debugPrint('⏺️ [BeepSubmit] $msg');

  // 🔥 ChatGPT's Bulletproof Submit Function with 20-second timeout
  Future<void> _submitBeep() async {
    _log('Starting submission...');
    
    if (_isSubmitting) {
      _log('Already submitting, skipping');
      return;
    }
    
    // Single state update point
    _log('Setting isSubmitting = true');
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    
    try {
      // 20-second timeout to kill infinite hangs
      await Future.any([
        _actualSubmitLogic(),
        Future.delayed(Duration(seconds: 20), () => throw TimeoutException('Submission timeout', Duration(seconds: 20))),
      ]);
      
      _log('SUCCESS: Submission completed');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beep sent successfully!'),
            backgroundColor: AppColors.brandPrimary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      _log('ERROR: $e');
      
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send beep: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // SINGLE point of _isSubmitting management
      _log('FINALLY: Setting isSubmitting = false');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  // The actual submission logic separated for timeout handling
  Future<void> _actualSubmitLogic() async {
    _log('Starting actual submit logic');
    
    // Validate location data BEFORE creating sighting (only for NEW sightings)
    if (widget.attachToSightingId == null && 
        (_sensorData?.latitude == null || _sensorData?.longitude == null)) {
      throw Exception(AppLocalizations.of(context)!.errorNoLocation);
    }

    // Play sound feedback when sending
    await SoundService.I.play(AlertSound.tap, haptic: true);

    // Get description - optional
    final description = _descriptionController.text.trim();
    final finalDescription = description.isEmpty ? null : description;

    String sightingId;
    
    if (widget.attachToSightingId != null) {
      // Adding to existing sighting
      sightingId = widget.attachToSightingId!;
      _log('Adding media to existing sighting: $sightingId');
    } else {
      // Create new sighting (existing logic)
      _log('Creating new sighting with media pending...');
      
      // Check for valid GPS coordinates (REQUIRED for new alerts)
      double? validLat = _sensorData?.latitude;
      double? validLon = _sensorData?.longitude;
      
      // If sensor GPS is missing or invalid, try to extract from photo EXIF as fallback
      if (validLat == null || validLon == null || (validLat == 0.0 && validLon == 0.0)) {
        _log('Sensor GPS invalid, attempting to extract from photo EXIF...');
        
        // Try to extract GPS from any attached photos
        for (final fileData in _mediaFiles) {
          final File mediaFile = fileData['mediaFile'];
          final bool isVideo = fileData['isVideo'] ?? false;
          
          if (!isVideo) { // Only photos have EXIF GPS data
            try {
              final photoMetadata = await PhotoMetadataService.extractComprehensiveMetadata(mediaFile);
              final locationData = photoMetadata['location'];
              
              if (locationData != null && 
                  locationData['latitude'] != null && 
                  locationData['longitude'] != null &&
                  locationData['latitude'] != 0.0 &&
                  locationData['longitude'] != 0.0) {
                
                validLat = locationData['latitude'];
                validLon = locationData['longitude'];
                _log('Extracted GPS from photo: lat=$validLat, lon=$validLon');
                
                // Update sensor data with extracted coordinates
                _sensorData = SensorData(
                  utc: _sensorData?.utc ?? DateTime.now(),
                  latitude: validLat!,
                  longitude: validLon!,
                  accuracy: 10.0, // Lower accuracy since from photo
                  altitude: locationData['altitude'] ?? _sensorData?.altitude ?? 0.0,
                  azimuthDeg: _sensorData?.azimuthDeg ?? 0.0,
                  pitchDeg: _sensorData?.pitchDeg ?? 0.0,
                  rollDeg: _sensorData?.rollDeg ?? 0.0,
                  hfovDeg: _sensorData?.hfovDeg ?? 60.0,
                );
                break; // Found valid GPS, stop searching
              }
            } catch (e) {
              _log('Failed to extract GPS from photo: $e');
            }
          }
        }
      }
      
      // Final validation - only fail if we absolutely have no GPS data
      if (validLat == null || validLon == null || (validLat == 0.0 && validLon == 0.0)) {
        throw Exception('GPS location required. Please enable GPS or take photos with location enabled.');
      }
      
      _log('Final GPS coordinates: lat=$validLat, lon=$validLon');
      
      final beepResult = await BeepService().sendBeep(
        description: finalDescription,
        latitude: validLat,
        longitude: validLon,
        heading: _sensorData?.azimuthDeg,
        hasMedia: true, // This will defer alerts until media upload completes
      );
      
      final sightingIdFromResponse = beepResult['sighting_id']?.toString();
      if (sightingIdFromResponse == null) {
        throw Exception('Failed to get sighting ID from API response');
      }
      sightingId = sightingIdFromResponse;
      _log('Sighting created with ID: $sightingId (alerts deferred)');
    }
    
    // Now upload all media files, then trigger alerts
    _log('Uploading ${_mediaFiles.length} files to sighting...');
    
    int uploadedCount = 0;
    int photoCount = 0;
    int videoCount = 0;
    
    // Upload all files sequentially
    for (int i = 0; i < _mediaFiles.length; i++) {
      final fileData = _mediaFiles[i];
      final File mediaFile = fileData['mediaFile'];
      final bool isVideo = fileData['isVideo'] ?? false;
      
      try {
        _log('Uploading file ${i + 1}/${_mediaFiles.length}: ${mediaFile.path}');
        _log('File exists: ${await mediaFile.exists()}');
        _log('File size: ${await mediaFile.length()} bytes');
        
        _log('Calling uploadMediaToSighting...');
        await ApiClient.instance.uploadMediaToSighting(
          sightingId,
          mediaFile,
        );
        _log('Upload successful for file ${i + 1}');
        
        uploadedCount++;
        if (isVideo) {
          videoCount++;
        } else {
          photoCount++;
        }
        
      } catch (e) {
        _log('Failed to upload file ${mediaFile.path}: $e');
        // Continue with other files - don't fail entire submission
      }
    }
    
    _log('Upload completed: $uploadedCount/${_mediaFiles.length} files uploaded');
    
    // Create auto-comment for existing sightings
    if (widget.attachToSightingId != null && uploadedCount > 0) {
      try {
        final commentsService = CommentsService();
        String commentText = 'Added ';
        
        if (photoCount > 0 && videoCount > 0) {
          commentText += '$photoCount ${photoCount == 1 ? 'photo' : 'photos'} and $videoCount ${videoCount == 1 ? 'video' : 'videos'}';
        } else if (photoCount > 0) {
          commentText += '$photoCount more ${photoCount == 1 ? 'photo' : 'photos'}';
        } else {
          commentText += '$videoCount more ${videoCount == 1 ? 'video' : 'videos'}';
        }
        
        await commentsService.postComment(sightingId, commentText);
        _log('Created auto-comment for added media: $commentText');
      } catch (e) {
        _log('Failed to create auto-comment: $e');
        // Don't fail the whole upload for comment failure
      }
    }
    
    // Check if any files failed to upload
    if (uploadedCount == 0) {
      throw Exception('No files could be uploaded');
    } else if (uploadedCount < _mediaFiles.length) {
      // Some files failed - show warning but continue
      _log('Warning: ${_mediaFiles.length - uploadedCount} files failed to upload');
    }
    
    // Trigger alerts only for new sightings
    if (widget.attachToSightingId == null) {
      _log('Triggering proximity alerts...');
      // Get coordinates from the sensor data for alert triggering
      final validLat = _sensorData?.latitude == 0.0 ? null : _sensorData?.latitude;
      final validLon = _sensorData?.longitude == 0.0 ? null : _sensorData?.longitude;
      
      // Get reliable coordinates for proximity alerts using LocationService
      final alertCoordinates = await LocationService.I.getReliableCoordinates(
        preferredLat: validLat,
        preferredLon: validLon,
        timeout: const Duration(seconds: 5),
      );
      
      if (alertCoordinates != null) {
        await ApiClient.instance.triggerAlertsForSighting(
          sightingId, 
          alertCoordinates['lat']!, 
          alertCoordinates['lon']!
        );
      } else {
        _log('No valid coordinates available - proximity alerts skipped');
      }
      _log('Proximity alerts sent successfully!');
    }

    // Submit photo metadata if available (for astronomical identification)
    if (widget.photoMetadata != null) {
      try {
        _log('Submitting comprehensive metadata for analysis...');
        final metadataSubmitted = await ApiClient.instance.submitPhotoMetadata(
          sightingId, 
          widget.photoMetadata!
        );
        if (metadataSubmitted) {
          _log('Metadata submitted successfully for external service analysis');
        } else {
          _log('Warning: Metadata submission failed');
        }
      } catch (e) {
        _log('Error submitting metadata: $e');
      }
    }

    // Set device ID as current user so navigation button is hidden
    final deviceId = await BeepService().getOrCreateDeviceId();
    ref.read(appStateProvider.notifier).setCurrentUser(deviceId);
    
    // Navigate to the specific beep that was just created
    if (context.mounted) {
      _log('Scheduling navigation to /beep/$sightingId');
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (context.mounted) {
          _log('Navigating to /beep/$sightingId');
          context.go('/beep/$sightingId');
        } else {
          _log('Context not mounted, skipping navigation');
        }
      });
    }
  }

  // Helper methods for managing media files
  void _removeMediaFile(int index) {
    if (index >= 0 && index < _mediaFiles.length) {
      setState(() {
        _mediaFiles.removeAt(index);
      });
      debugPrint('Removed file at index $index, ${_mediaFiles.length} files remaining');
      
      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.delete),
            backgroundColor: AppColors.textSecondary,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _reorderMediaFiles(int oldIndex, int newIndex) {
    setState(() {
      final item = _mediaFiles.removeAt(oldIndex);
      _mediaFiles.insert(newIndex, item);
    });
    debugPrint('Reordered file from index $oldIndex to $newIndex');
  }

  // Get submit button text based on file count
  String get _submitButtonText {
    if (_mediaFiles.isEmpty) return 'Send Beep';
    if (_mediaFiles.length == 1) return 'Send Beep';
    return 'Send Beep + ${_mediaFiles.length} Files';
  }

  void _retakeMedia() async {
    // Add haptic feedback
    await SoundService.I.play(AlertSound.tap, haptic: true);
    context.go('/beep');
  }

  void _addMoreMedia() async {
    // Add haptic feedback
    await SoundService.I.play(AlertSound.tap, haptic: true);
    
    // Show dialog to choose between camera or gallery with proper styling
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
                  AppLocalizations.of(context)!.addMedia,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Camera and Gallery buttons matching beep screen style
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
                                AppLocalizations.of(context)!.capturePhoto,
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
                                AppLocalizations.of(context)!.pickFromGallery,
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
                    AppLocalizations.of(context)!.cancel,
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
      await _takeCameraPhoto();
    } else if (choice == 'gallery') {
      await _pickFromGallery();
    }
  }

  Future<void> _takeCameraPhoto() async {
    try {
      // Navigate to custom camera screen with return-to-composition mode
      final result = await context.push<Map<String, dynamic>>('/beep/camera', extra: {
        'returnToComposition': true,
        'attachToSightingId': widget.attachToSightingId,
      });
      
      if (result == null) return;
      
      final File? mediaFile = result['mediaFile'] as File?;
      final Map<String, dynamic>? photoMetadata = result['photoMetadata'] as Map<String, dynamic>?;
      
      if (mediaFile == null) return;
      
      if (!await mediaFile.exists()) {
        debugPrint('Camera photo file does not exist: ${mediaFile.path}');
        return;
      }

      debugPrint('Adding camera photo: ${mediaFile.path}');
      
      // Use metadata from camera screen if available, otherwise extract it
      Map<String, dynamic> mediaMetadata = photoMetadata ?? {};
      if (mediaMetadata.isEmpty) {
        try {
          mediaMetadata = await PhotoMetadataService.extractComprehensiveMetadata(mediaFile);
          debugPrint('Extracted metadata: ${mediaMetadata.keys.length} categories');
        } catch (e) {
          debugPrint('Warning: Failed to extract metadata from camera photo: $e');
        }
      }
      
      // Add camera photo to media files list
      setState(() {
        _mediaFiles.add({
          'mediaFile': mediaFile,
          'isVideo': false,
          'photoMetadata': mediaMetadata,
        });
      });
      
      debugPrint('Added camera photo, total files: ${_mediaFiles.length}');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.beepSent),
            backgroundColor: AppColors.brandPrimary,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      debugPrint('Error taking camera photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.beepFailed),
            backgroundColor: AppColors.semanticError,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      // Use FilePicker to select additional media files
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      debugPrint('Adding ${result.files.length} more files to composition');
      
      // Process new files with the same logic as gallery selection
      final List<Map<String, dynamic>> newMediaFiles = [];
      
      for (final PlatformFile platformFile in result.files) {
        try {
          final String? filePath = platformFile.path;
          
          if (filePath == null || filePath.isEmpty) {
            debugPrint('Skipping file with null/empty path: ${platformFile.name}');
            continue;
          }

          final File mediaFile = File(filePath);
          
          if (!await mediaFile.exists()) {
            debugPrint('Skipping non-existent file: $filePath');
            continue;
          }

          // Determine if this is a video
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

          debugPrint('Adding ${isVideo ? 'video' : 'image'} file: ${mediaFile.path}');
          
          // Extract metadata only for images
          Map<String, dynamic> mediaMetadata = {};
          
          if (!isVideo) {
            try {
              mediaMetadata = await PhotoMetadataService.extractComprehensiveMetadata(mediaFile);
              debugPrint('Extracted metadata: ${mediaMetadata.keys.length} categories');
            } catch (e) {
              debugPrint('Warning: Failed to extract metadata from ${mediaFile.path}: $e');
            }
          }
          
          // Add to new files list
          newMediaFiles.add({
            'mediaFile': mediaFile,
            'isVideo': isVideo,
            'photoMetadata': mediaMetadata,
            'platformFile': platformFile,
          });
          
        } catch (e) {
          debugPrint('Error processing additional file ${platformFile.name}: $e');
          continue;
        }
      }

      // Add new files to existing media files list
      if (newMediaFiles.isNotEmpty) {
        setState(() {
          _mediaFiles.addAll(newMediaFiles);
        });
        debugPrint('Added ${newMediaFiles.length} files, total now: ${_mediaFiles.length}');
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${newMediaFiles.length} more ${newMediaFiles.length == 1 ? 'file' : 'files'}'),
              backgroundColor: AppColors.brandPrimary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      
    } catch (e) {
      debugPrint('Error adding more media: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add media: $e'),
            backgroundColor: AppColors.semanticError,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NightSkyBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.tabBeep,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _retakeMedia,
            tooltip: 'Retake ${widget.isVideo ?? false ? 'Video' : 'Photo'}',
          ),
        ),
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media section (photo or video)
                    _buildMediaSection(),
                    const SizedBox(height: 24),
                    
                    // Form field - make it more prominent
                    _buildDescriptionInput(),
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
                                style: const TextStyle(color: AppColors.semanticError, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32), // Space for bottom button
                  ],
                ),
              ),
            ),
            
            // Bottom action buttons
            _buildBottomActions(),
          ],
        ),
      ),
    ), // Close Scaffold
    ); // Close NightSkyBackground
  }

  Widget _buildMediaSection() {
    if (_mediaFiles.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return MultiFilePreview(
      mediaFiles: _mediaFiles,
      onRemove: _removeMediaFile,
      onReorder: _reorderMediaFiles,
      allowEdit: true,
    );
  }
  





  Widget _buildDescriptionInput() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.whatDoYouSee,
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
            maxLength: 300,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.descriptionHint,
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
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }



  Widget _buildBottomActions() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main Send button (full width)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: GestureDetector(
                onTapDown: _isSubmitting ? null : (_) async {
                  await UiFeedback.click(); // immediate feedback
                },
                child: Builder(
                  builder: (context) {
                    debugPrint('🚀 BUTTON BUILD: _isSubmitting=$_isSubmitting, enabled=${!_isSubmitting}');
                    return OutlinedButton(
                      onPressed: !_isSubmitting ? () {
                        debugPrint('🚀 BUTTON PRESSED: _isSubmitting=$_isSubmitting, mediaFiles=${_mediaFiles.length}');
                        _submitBeep();
                      } : null,
                      style: OutlinedButton.styleFrom(
                  foregroundColor: !_isSubmitting 
                      ? AppColors.brandPrimary 
                      : AppColors.textSecondary,
                  side: BorderSide(
                    color: !_isSubmitting 
                        ? AppColors.brandPrimary 
                        : AppColors.darkBorder,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.processing),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.attachToSightingId != null 
                              ? Icons.add_photo_alternate_rounded 
                              : Icons.send_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(widget.attachToSightingId != null 
                              ? AppLocalizations.of(context)!.addMedia 
                              : l10n.submitBeep),
                        ],
                      ),
                );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Secondary action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Add More Media button
                TextButton.icon(
                  onPressed: _isSubmitting ? null : () async {
                    await SoundService.I.play(AlertSound.tap, haptic: true);
                    _addMoreMedia();
                  },
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: Text(AppLocalizations.of(context)!.addMoreMedia),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brandPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                
                // Retake Media button
                TextButton.icon(
                  onPressed: _isSubmitting ? null : () async {
                    await SoundService.I.play(AlertSound.tap, haptic: true);
                    _retakeMedia();
                  },
                  icon: Icon(widget.isVideo ?? false ? Icons.videocam : Icons.camera_alt, size: 18),
                  label: Text(
                    widget.isVideo ?? false 
                      ? AppLocalizations.of(context)!.retakeVideo 
                      : AppLocalizations.of(context)!.retakePhoto
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onFormFieldChanged);
    _descriptionController.dispose();
    super.dispose();
  }

}
