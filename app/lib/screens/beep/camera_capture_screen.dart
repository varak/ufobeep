import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:gal/gal.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../services/sound_service.dart';
import '../../services/permission_service.dart';
import '../../models/sensor_data.dart';

class CameraCaptureScreen extends StatefulWidget {
  final String? description;
  final String? attachToSightingId;
  final bool returnToComposition;
  
  const CameraCaptureScreen({
    super.key, 
    this.description,
    this.attachToSightingId,
    this.returnToComposition = false,
  });

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final SensorService _sensorService = SensorService();
  final PermissionService _permissionService = PermissionService();
  
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isRecording = false;
  bool _isVideoMode = false; // Toggle between photo and video mode
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      debugPrint('📸 CAMERA: Starting camera initialization...');
      
      // Check camera permission first
      final hasPermission = await _permissionService.requestCameraForCapture();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Camera permission is required. Please grant permission in settings and try again.';
        });
        return;
      }
      
      debugPrint('📸 CAMERA: Camera permission granted');
      
      // Get available cameras
      _cameras = await availableCameras();
      
      debugPrint('📸 CAMERA: Found ${_cameras?.length ?? 0} cameras');
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Use back camera if available, otherwise use first camera
      final camera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      debugPrint('📸 CAMERA: Selected camera: ${camera.name} (${camera.lensDirection})');

      // Create controller with maximum resolution
      _controller = CameraController(
        camera,
        ResolutionPreset.max,  // Use maximum resolution available
        enableAudio: _isVideoMode, // Enable audio for video mode
        imageFormatGroup: _isVideoMode ? null : ImageFormatGroup.jpeg,
      );

      debugPrint('📸 CAMERA: Controller created, initializing...');

      // Initialize controller
      await _controller!.initialize();

      if (!mounted) return;

      // Log the actual resolution we're using
      final size = _controller!.value.previewSize;
      debugPrint('📸 CAMERA: Initialized with resolution: ${size?.width}x${size?.height}');
      debugPrint('📸 CAMERA: Using camera: ${camera.name} (${camera.lensDirection})');

      setState(() {
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      debugPrint('📸 CAMERA: ERROR: $e');
      debugPrint('📸 CAMERA: Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _toggleMode() async {
    setState(() {
      _isVideoMode = !_isVideoMode;
      _isInitialized = false;
    });
    
    // Reinitialize camera with new settings
    await _controller?.dispose();
    await _initializeCamera();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Play camera shutter sound (both system and app sound)
      SystemSound.play(SystemSoundType.click);
      await SoundService.I.play(AlertSound.tap, haptic: true);
      
      // Take the picture at maximum quality
      final XFile image = await _controller!.takePicture();
      
      // Stop camera preview immediately after capture
      await _controller?.dispose();
      setState(() {
        _controller = null;
        _isInitialized = false;
      });
      
      // Get sensor data with retry for GPS
      SensorData? sensorData;
      try {
        debugPrint('🌍 CAMERA: Attempting to capture GPS and sensor data...');
        sensorData = await _sensorService.captureSensorData();
        if (sensorData != null && sensorData.latitude != 0.0 && sensorData.longitude != 0.0) {
          debugPrint('✅ CAMERA: Got valid sensor data - lat: ${sensorData.latitude}, lng: ${sensorData.longitude}, accuracy: ${sensorData.accuracy}m');
        } else {
          debugPrint('⚠️ CAMERA: Got invalid GPS coordinates (0,0) - GPS may have timed out');
          // Don't use 0,0 coordinates - better to have no location than wrong location
          sensorData = null;
        }
      } catch (e) {
        debugPrint('❌ CAMERA: Failed to capture sensor data: $e');
        sensorData = null;
        // Note: GPS errors are logged but not shown to user to avoid red flash
      }

      // Save to UFOBeep folder
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String ufobeepPath = path.join(appDocDir.path, 'UFOBeep');
      final Directory ufobeepDir = Directory(ufobeepPath);
      
      if (!await ufobeepDir.exists()) {
        await ufobeepDir.create(recursive: true);
      }

      final String fileName = 'UFOBeep_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = path.join(ufobeepPath, fileName);
      final File savedFile = await File(image.path).copy(savedPath);
      
      // Log file size and info
      final fileSize = await savedFile.length();
      debugPrint('📸 CAMERA: Captured photo saved as: $fileName');
      debugPrint('📸 CAMERA: File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('📸 CAMERA: Original path: ${image.path}');
      
      // Also save to phone's main gallery
      try {
        await Gal.putImage(savedFile.path, album: 'UFOBeep');
        debugPrint('Photo saved to gallery in UFOBeep album');
      } catch (e) {
        debugPrint('Failed to save to gallery: $e');
        // Continue even if gallery save fails
      }

      // Embed GPS data in photo EXIF if we have valid sensor data
      if (sensorData != null && sensorData.latitude != 0.0 && sensorData.longitude != 0.0) {
        try {
          debugPrint('📍 CAMERA: Embedding GPS coordinates in photo EXIF...');
          await PhotoMetadataService.embedGpsInImage(
            savedFile, 
            sensorData.latitude, 
            sensorData.longitude,
            altitude: sensorData.altitude != 0.0 ? sensorData.altitude : null,
          );
          debugPrint('✅ CAMERA: GPS embedded in photo EXIF successfully');
        } catch (e) {
          debugPrint('❌ CAMERA: Failed to embed GPS in photo EXIF: $e');
        }
      }

      // Extract comprehensive photo metadata for astronomical identification services
      Map<String, dynamic> photoMetadata = {};
      try {
        photoMetadata = await PhotoMetadataService.extractComprehensiveMetadata(savedFile);
        debugPrint('Extracted comprehensive photo metadata: ${photoMetadata.keys.length} categories');
        
        // Update sensor data with GPS from photo if available (fallback for when real-time GPS failed)
        final locationData = photoMetadata['location'];
        if (locationData != null && locationData['latitude'] != null && locationData['longitude'] != null) {
          if (sensorData != null) {
            // Update existing sensor data with GPS from photo (should match what we just embedded)
            sensorData = SensorData(
              utc: sensorData.utc,
              latitude: locationData['latitude'],
              longitude: locationData['longitude'],
              accuracy: 5.0,
              altitude: locationData['altitude'] ?? sensorData.altitude,
              azimuthDeg: sensorData.azimuthDeg,
              pitchDeg: sensorData.pitchDeg,
              rollDeg: sensorData.rollDeg,
              hfovDeg: sensorData.hfovDeg,
            );
          } else {
            // Create sensor data from photo EXIF if no sensor data exists
            sensorData = SensorData(
              utc: DateTime.now(),
              latitude: locationData['latitude'],
              longitude: locationData['longitude'],
              accuracy: 10.0, // Lower accuracy since it's from photo
              altitude: locationData['altitude'] ?? 0.0,
              azimuthDeg: 0.0, // No compass data available
              pitchDeg: 0.0,   // No compass data available
              rollDeg: 0.0,    // No compass data available
              hfovDeg: 60.0,   // Default camera FOV
            );
            debugPrint('🔄 CAMERA: Created sensor data from photo EXIF: lat=${locationData['latitude']}, lng=${locationData['longitude']}');
          }
        }
      } catch (e) {
        debugPrint('Failed to extract comprehensive photo metadata: $e');
        photoMetadata = {
          'exif_available': false,
          'extraction_error': e.toString(),
          'extraction_timestamp': DateTime.now().toIso8601String(),
        };
      }

      // Navigate appropriately based on mode
      if (mounted) {
        if (widget.returnToComposition) {
          // Return data to composition screen
          context.pop({
            'mediaFile': savedFile,
            'photoMetadata': photoMetadata,
          });
        } else {
          // Navigate directly to compose screen - no approval!
          context.go('/beep/compose', extra: {
            'mediaFile': savedFile,
            'isVideo': false,
            'sensorData': sensorData,
            'photoMetadata': photoMetadata, // Pass comprehensive metadata for storage
            'description': widget.description, // Pass description from previous screen
            'attachToSightingId': widget.attachToSightingId, // Pass alert ID for existing alert media
          });
        }
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to capture photo: $e';
      });
    }
  }

  Future<void> _startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized || _isRecording) {
      return;
    }

    setState(() {
      _isRecording = true;
    });

    try {
      // Play start recording sound
      await SoundService.I.play(AlertSound.tap, haptic: true);
      
      // Start recording
      await _controller!.startVideoRecording();
      debugPrint('🎥 VIDEO: Started recording');
      
      // Auto-stop after 30 seconds to keep videos short
      Future.delayed(const Duration(seconds: 30), () {
        if (_isRecording) {
          _stopVideoRecording();
        }
      });
      
    } catch (e) {
      setState(() {
        _isRecording = false;
        _errorMessage = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_controller == null || !_isRecording) {
      return;
    }

    setState(() {
      _isRecording = false;
      _isCapturing = true; // Show processing state
    });

    try {
      // Stop recording and get the file
      final XFile videoFile = await _controller!.stopVideoRecording();
      debugPrint('🎥 VIDEO: Stopped recording');
      
      // Stop camera preview immediately after recording ends
      await _controller?.dispose();
      setState(() {
        _controller = null;
        _isInitialized = false;
      });
      
      // Play stop sound
      await SoundService.I.play(AlertSound.gpsOk, haptic: true);

      // Get sensor data
      SensorData? sensorData;
      try {
        debugPrint('🌍 VIDEO: Capturing GPS and sensor data...');
        sensorData = await _sensorService.captureSensorData();
        if (sensorData != null && sensorData.latitude != 0.0 && sensorData.longitude != 0.0) {
          debugPrint('✅ VIDEO: Got valid sensor data - lat: ${sensorData.latitude}, lng: ${sensorData.longitude}');
        }
      } catch (e) {
        debugPrint('❌ VIDEO: Failed to capture sensor data: $e');
        sensorData = null;
      }

      // Save to UFOBeep folder
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String ufobeepPath = path.join(appDocDir.path, 'UFOBeep');
      final Directory ufobeepDir = Directory(ufobeepPath);
      
      if (!await ufobeepDir.exists()) {
        await ufobeepDir.create(recursive: true);
      }

      final String fileName = 'UFOBeep_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String savedPath = path.join(ufobeepPath, fileName);
      final File savedFile = await File(videoFile.path).copy(savedPath);
      
      // Log file info
      final fileSize = await savedFile.length();
      debugPrint('🎥 VIDEO: Saved as: $fileName');
      debugPrint('🎥 VIDEO: File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Save to phone's gallery
      try {
        await Gal.putVideo(savedFile.path, album: 'UFOBeep');
        debugPrint('Video saved to gallery in UFOBeep album');
      } catch (e) {
        debugPrint('Failed to save video to gallery: $e');
      }

      // Navigate appropriately based on mode (video)
      if (mounted) {
        if (widget.returnToComposition) {
          // Return video data to composition screen
          context.pop({
            'mediaFile': savedFile,
            'isVideo': true,
            'photoMetadata': {}, // Videos don't have EXIF data
          });
        } else {
          // Navigate to composition screen with video
          context.go('/beep/compose', extra: {
            'mediaFile': savedFile,
            'isVideo': true,
            'sensorData': sensorData,
            'description': widget.description,
            'attachToSightingId': widget.attachToSightingId, // Pass alert ID for existing alert media
          });
        }
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to save video: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: const Text('Camera'),
          backgroundColor: AppColors.darkSurface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                color: AppColors.semanticError,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/beep'),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.brandPrimary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          // Top overlay with back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/beep'),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            _isVideoMode ? 'Point and record (30s max)' : 'Point at the sky object',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_isRecording) ...[
                            const SizedBox(height: 4),
                            Text(
                              '🔴 RECORDING',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _isInitialized && !_isCapturing && !_isRecording ? _toggleMode : null,
                        icon: Icon(
                          _isVideoMode ? Icons.photo_camera : Icons.videocam,
                          color: _isInitialized && !_isCapturing && !_isRecording ? Colors.white : Colors.grey,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom capture button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Instructions
                      Text(
                        _isVideoMode 
                          ? (_isRecording ? 'Tap to stop recording' : 'Tap to start recording')
                          : 'Tap to capture',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Capture button
                      Center(
                        child: GestureDetector(
                          onTap: _isCapturing ? null : (_isVideoMode 
                            ? (_isRecording ? _stopVideoRecording : _startVideoRecording)
                            : _capturePhoto),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isRecording ? Colors.red : Colors.white,
                                width: 4,
                              ),
                              color: _isCapturing 
                                  ? Colors.grey.withOpacity(0.3)
                                  : (_isRecording ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.2)),
                            ),
                            child: _isCapturing
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isVideoMode 
                                      ? (_isRecording ? Icons.stop : Icons.videocam)
                                      : Icons.camera_alt,
                                    color: _isRecording ? Colors.red : Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}