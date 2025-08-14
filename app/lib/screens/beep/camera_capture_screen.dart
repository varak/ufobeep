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
import '../../models/sensor_data.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final SensorService _sensorService = SensorService();
  
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      
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

      // Create controller with maximum resolution
      _controller = CameraController(
        camera,
        ResolutionPreset.max,  // Use maximum resolution available
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,  // Ensure JPEG format for quality
      );

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
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Play camera shutter sound
      SystemSound.play(SystemSoundType.click);
      
      // Take the picture at maximum quality
      final XFile image = await _controller!.takePicture();
      
      // Get sensor data
      SensorData? sensorData;
      try {
        debugPrint('🌍 CAMERA: Attempting to capture GPS and sensor data...');
        sensorData = await _sensorService.captureSensorData();
        if (sensorData != null) {
          debugPrint('✅ CAMERA: Got sensor data - lat: ${sensorData.latitude}, lng: ${sensorData.longitude}, accuracy: ${sensorData.accuracy}m');
        } else {
          debugPrint('⚠️ CAMERA: Sensor service returned null data');
        }
      } catch (e) {
        debugPrint('❌ CAMERA: Failed to capture sensor data: $e');
        // Show user-friendly message about location
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location not available: $e'),
              backgroundColor: AppColors.semanticError,
              duration: const Duration(seconds: 3),
            ),
          );
        }
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

      // Extract comprehensive photo metadata for astronomical identification services
      Map<String, dynamic> photoMetadata = {};
      try {
        photoMetadata = await PhotoMetadataService.extractComprehensiveMetadata(savedFile);
        debugPrint('Extracted comprehensive photo metadata: ${photoMetadata.keys.length} categories');
        
        // Update sensor data with GPS from photo if available
        final locationData = photoMetadata['location'];
        if (locationData != null && locationData['latitude'] != null && locationData['longitude'] != null) {
          if (sensorData != null) {
            // Update existing sensor data with GPS from photo
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
            debugPrint('Created sensor data from photo EXIF: lat=${locationData['latitude']}, lng=${locationData['longitude']}');
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

      // Navigate directly to compose screen - no approval!
      if (mounted) {
        context.go('/beep/compose', extra: {
          'imageFile': savedFile,
          'sensorData': sensorData,
          'photoMetadata': photoMetadata, // Pass comprehensive metadata for storage
        });
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to capture photo: $e';
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
                      const Text(
                        'Point at the sky object',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44), // Balance the back button
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
                      const Text(
                        'Tap to capture',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Capture button
                      Center(
                        child: GestureDetector(
                          onTap: _isCapturing ? null : _capturePhoto,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              color: _isCapturing 
                                  ? Colors.grey.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.2),
                            ),
                            child: _isCapturing
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
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