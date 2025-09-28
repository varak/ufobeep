import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../services/sound_service.dart';
import '../../services/permission_service.dart';
import '../../models/sensor_data.dart';
import '../../models/camera_result.dart';

class CameraCaptureScreen extends StatefulWidget {
  final String? description;
  final String? attachToSightingId;
  final bool returnToComposition;
  final Map<String, double>? preFetchedGPS;

  CameraCaptureScreen({
    super.key,
    this.description,
    this.attachToSightingId,
    this.returnToComposition = false,
    this.preFetchedGPS,
  }) {
    debugPrint('📸📸📸 PRODUCTION CAMERA CAPTURE SCREEN CONSTRUCTED 📸📸📸');
    debugPrint('📸 Parameters: description="$description", attachTo="$attachToSightingId", returnTo=$returnToComposition');
    debugPrint('🌍 Pre-fetched GPS available: ${preFetchedGPS != null}');
  }

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final SensorService _sensorService = SensorService();

  bool _isCapturing = false;
  bool _isVideoMode = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-launch native camera after route transition
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        _launchNativeCamera();
      }
    });
  }

  Future<void> _launchNativeCamera() async {
    try {
      setState(() {
        _isCapturing = true;
        _errorMessage = null;
      });

      XFile? capturedFile;

      if (_isVideoMode) {
        // Launch native camera for video
        capturedFile = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 30),
        );
      } else {
        // Launch native camera for photo
        capturedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
      }

      if (capturedFile != null && mounted) {
        // Process the captured media and return result
        await _processCapturedMedia(capturedFile);
      } else if (mounted) {
        // User cancelled - go back
        context.pop();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera failed: $e';
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _processCapturedMedia(XFile mediaFile) async {
    try {
      // Get sensor data
      SensorData? sensorData;
      try {
        sensorData = await _sensorService.captureSensorData();
      } catch (e) {
        debugPrint('Warning: Sensor data collection failed: $e');
      }

      // Create result for the calling screen
      final result = CameraCaptureResult(
        path: mediaFile.path,
        isVideo: _isVideoMode,
        sensorData: sensorData != null ? {
          'latitude': sensorData.latitude,
          'longitude': sensorData.longitude,
          'accuracy': sensorData.accuracy,
          'altitude': sensorData.altitude,
          'azimuth': sensorData.azimuthDeg,
          'pitch': sensorData.pitchDeg,
          'roll': sensorData.rollDeg,
          'hfov': sensorData.hfovDeg,
          'timestamp': sensorData.utc.toIso8601String(),
        } : null,
        photoMetadata: _isVideoMode ? {} : await PhotoMetadataService.extractComprehensiveMetadata(File(mediaFile.path)),
      );

      if (mounted) {
        if (widget.returnToComposition && widget.attachToSightingId != null) {
          // Navigate to beep screen with captured media for attachment
          context.pushReplacement('/beepscreen', extra: {
            'initialMediaFiles': [File(mediaFile.path)],
            'attachToSightingId': widget.attachToSightingId,
          });
        } else {
          // Return result to calling screen
          context.pop(result);
        }
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to process media: $e';
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final camStatus = await Permission.camera.request();

      if (!await Permission.camera.isGranted) {
        setState(() {
          _errorMessage = 'Camera permission required';
        });
        return;
      }

      // Request microphone permission for video mode
      if (_isVideoMode) {
        final micStatus = await Permission.microphone.request();
        if (!await Permission.microphone.isGranted) {
          setState(() {
            _errorMessage = 'Microphone permission required for video recording';
          });
          return;
        }
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      _controller = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.low,
        enableAudio: _isVideoMode // Enable audio only for video mode
      );
      await _controller!.initialize();

      _isInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera initialization failed: $e';
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

      // Check if this is front camera and needs mirroring
      final isFrontCamera = _cameras![_selectedCameraIndex].lensDirection == CameraLensDirection.front;

      // Use the original image file (no mirroring needed)
      final finalImageFile = File(image.path);

      // Stop camera preview immediately after capture
      await _controller?.dispose();
      setState(() {
        _controller = null;
        _isInitialized = false;
      });
      
      // Get sensor data with retry for GPS - use pre-fetched GPS if available
      SensorData? sensorData;
      try {
        // Check if we have pre-fetched GPS coordinates
        if (widget.preFetchedGPS != null) {
          debugPrint('🌍 CAMERA: Using pre-fetched GPS coordinates');
          debugPrint('✅ CAMERA: Pre-fetched GPS - lat: ${widget.preFetchedGPS!['lat']}, lng: ${widget.preFetchedGPS!['lon']}');

          // Create SensorData with pre-fetched GPS and real-time sensors
          try {
            final fullSensorData = await _sensorService.captureSensorData();
            sensorData = SensorData(
              latitude: widget.preFetchedGPS!['lat']!,
              longitude: widget.preFetchedGPS!['lon']!,
              accuracy: fullSensorData?.accuracy ?? 0.0,
              altitude: fullSensorData?.altitude ?? 0.0,
              azimuthDeg: fullSensorData?.azimuthDeg ?? 0.0,
              pitchDeg: fullSensorData?.pitchDeg ?? 0.0,
              hfovDeg: fullSensorData?.hfovDeg ?? 66.0,
              utc: DateTime.now(),
            );
            debugPrint('✅ CAMERA: Combined pre-fetched GPS with sensor data');
          } catch (e) {
            // If sensor collection fails, just use GPS coordinates
            sensorData = SensorData(
              latitude: widget.preFetchedGPS!['lat']!,
              longitude: widget.preFetchedGPS!['lon']!,
              accuracy: 0.0,
              altitude: 0.0,
              azimuthDeg: 0.0,
              pitchDeg: 0.0,
              hfovDeg: 66.0,
              utc: DateTime.now(),
            );
            debugPrint('⚠️ CAMERA: Using pre-fetched GPS only, sensor collection failed: $e');
          }
        } else {
          debugPrint('🌍 CAMERA: No pre-fetched GPS, attempting to capture GPS and sensor data...');
          sensorData = await _sensorService.captureSensorData();
          if (sensorData != null && sensorData.latitude != 0.0 && sensorData.longitude != 0.0) {
            debugPrint('✅ CAMERA: Got valid sensor data - lat: ${sensorData.latitude}, lng: ${sensorData.longitude}, accuracy: ${sensorData.accuracy}m');
          } else {
            debugPrint('⚠️ CAMERA: Got invalid GPS coordinates (0,0) - GPS may have timed out');
            // Don't use 0,0 coordinates - better to have no location than wrong location
            sensorData = null;
          }
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
      if (!mounted) {
        debugPrint('📸 CAMERA: Widget not mounted, skipping return');
        return;
      }
      
      final result = CameraCaptureResult(
        path: savedFile.path,
        isVideo: false,
        sensorData: sensorData != null ? {
          'latitude': sensorData.latitude,
          'longitude': sensorData.longitude,
          'accuracy': sensorData.accuracy,
          'altitude': sensorData.altitude,
          'azimuthDeg': sensorData.azimuthDeg,
          'utc': sensorData.utc.toIso8601String(),
        } : null,
        photoMetadata: photoMetadata,
        description: widget.description,
        attachToSightingId: widget.attachToSightingId,
      );
      
      debugPrint('📸 CAMERA -> pop result: ${result.path}');
      debugPrint('📸 CAMERA: Result details - isVideo: ${result.isVideo}, hasMetadata: ${result.photoMetadata != null}, hasSensorData: ${result.sensorData != null}');
      
      if (widget.returnToComposition && widget.attachToSightingId != null) {
        // Navigate to beep screen with captured media for attachment
        context.pushReplacement('/beepscreen', extra: {
          'initialMediaFiles': [savedFile],
          'attachToSightingId': widget.attachToSightingId,
        });
      } else if (widget.returnToComposition) {
        // Return data to composition screen (legacy behavior)
        context.pop({
          'mediaFile': savedFile,
          'photoMetadata': photoMetadata,
        });
      } else {
        // Return typed result to beep screen
        Navigator.of(context).pop(result);
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

      // Get sensor data - use pre-fetched GPS if available
      SensorData? sensorData;
      try {
        // Check if we have pre-fetched GPS coordinates
        if (widget.preFetchedGPS != null) {
          debugPrint('🌍 VIDEO: Using pre-fetched GPS coordinates');
          debugPrint('✅ VIDEO: Pre-fetched GPS - lat: ${widget.preFetchedGPS!['lat']}, lng: ${widget.preFetchedGPS!['lon']}');

          // Create SensorData with pre-fetched GPS and real-time sensors
          try {
            final fullSensorData = await _sensorService.captureSensorData();
            sensorData = SensorData(
              latitude: widget.preFetchedGPS!['lat']!,
              longitude: widget.preFetchedGPS!['lon']!,
              accuracy: fullSensorData?.accuracy ?? 0.0,
              altitude: fullSensorData?.altitude ?? 0.0,
              azimuthDeg: fullSensorData?.azimuthDeg ?? 0.0,
              pitchDeg: fullSensorData?.pitchDeg ?? 0.0,
              hfovDeg: fullSensorData?.hfovDeg ?? 66.0,
              utc: DateTime.now(),
            );
            debugPrint('✅ VIDEO: Combined pre-fetched GPS with sensor data');
          } catch (e) {
            // If sensor collection fails, just use GPS coordinates
            sensorData = SensorData(
              latitude: widget.preFetchedGPS!['lat']!,
              longitude: widget.preFetchedGPS!['lon']!,
              accuracy: 0.0,
              altitude: 0.0,
              azimuthDeg: 0.0,
              pitchDeg: 0.0,
              hfovDeg: 66.0,
              utc: DateTime.now(),
            );
            debugPrint('⚠️ VIDEO: Using pre-fetched GPS only, sensor collection failed: $e');
          }
        } else {
          debugPrint('🌍 VIDEO: No pre-fetched GPS, capturing GPS and sensor data...');
          sensorData = await _sensorService.captureSensorData();
          if (sensorData != null && sensorData.latitude != 0.0 && sensorData.longitude != 0.0) {
            debugPrint('✅ VIDEO: Got valid sensor data - lat: ${sensorData.latitude}, lng: ${sensorData.longitude}');
          }
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
        if (widget.returnToComposition && widget.attachToSightingId != null) {
          // Navigate to beep screen with captured video for attachment
          context.pushReplacement('/beepscreen', extra: {
            'initialMediaFiles': [savedFile],
            'attachToSightingId': widget.attachToSightingId,
          });
        } else if (widget.returnToComposition) {
          // Return video data to composition screen (legacy behavior)
          context.pop({
            'mediaFile': savedFile,
            'isVideo': true,
            'photoMetadata': {}, // Videos don't have EXIF data
          });
        } else {
          // Return video data using consistent CameraCaptureResult type
          final result = CameraCaptureResult(
            path: savedFile.path,
            isVideo: true,
            sensorData: sensorData != null ? {
              'latitude': sensorData.latitude,
              'longitude': sensorData.longitude,
              'accuracy': sensorData.accuracy,
              'altitude': sensorData.altitude,
              'azimuthDeg': sensorData.azimuthDeg,
              'utc': sensorData.utc.toIso8601String(),
            } : null,
            photoMetadata: {}, // Videos don't have EXIF data
            description: widget.description,
            attachToSightingId: widget.attachToSightingId,
          );

          debugPrint('🎥 CAMERA -> pop result: ${result.path}');
          debugPrint('🎥 CAMERA: Result details - isVideo: ${result.isVideo}, hasMetadata: ${result.photoMetadata != null}, hasSensorData: ${result.sensorData != null}');

          Navigator.of(context).pop(result);
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
                onPressed: () => Navigator.of(context).pop(),
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
          // WYSIWYG camera preview using ChatGPT's solution
          Positioned.fill(
            child: CameraPreviewBox(service: CameraService.instance),
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
                        onPressed: () => Navigator.of(context).pop(),
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
                      // Camera switch button
                      if (_cameras != null && _cameras!.length > 1)
                        IconButton(
                          onPressed: _isInitialized && !_isCapturing && !_isRecording ? _switchCamera : null,
                          icon: Icon(
                            Icons.flip_camera_ios,
                            color: _isInitialized && !_isCapturing && !_isRecording ? Colors.white : Colors.grey,
                            size: 28,
                          ),
                        ),
                      // Photo/Video mode toggle
                      // Camera switch button (if multiple cameras available)
                      if (_cameras != null && _cameras!.length > 1)
                        IconButton(
                          onPressed: _isInitialized && !_isCapturing && !_isRecording ? _switchCamera : null,
                          icon: Icon(
                            Icons.cameraswitch,
                            color: _isInitialized && !_isCapturing && !_isRecording ? Colors.white : Colors.grey,
                            size: 28,
                          ),
                        ),
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

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    // Dispose current controller
    await _controller?.dispose();

    // Switch to next camera
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;

    // Reinitialize with new camera
    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.low,
      enableAudio: _isVideoMode
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error switching camera: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to switch camera';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}