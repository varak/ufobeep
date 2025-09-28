import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camerawesome/camerawesome.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../models/sensor_data.dart';
import '../../models/camera_result.dart';

class NativeCameraScreen extends StatefulWidget {
  final String? description;
  final String? attachToSightingId;
  final bool returnToComposition;
  final bool isVideoMode;

  const NativeCameraScreen({
    super.key,
    this.description,
    this.attachToSightingId,
    this.returnToComposition = false,
    this.isVideoMode = false,
  });

  @override
  State<NativeCameraScreen> createState() => _NativeCameraScreenState();
}

class _NativeCameraScreenState extends State<NativeCameraScreen> {
  final SensorService _sensorService = SensorService();

  @override
  void initState() {
    super.initState();
    // Auto-launch native camera after route transition
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
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

      // Launch native camera with both photo and video options
      final capturedFile = await _picker.pickMedia(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

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
          _errorMessage = 'Camera error: $e';
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _processCapturedMedia(XFile mediaFile) async {
    try {
      // Detect if it's a video based on file extension
      final isVideo = mediaFile.path.toLowerCase().endsWith('.mp4') ||
                     mediaFile.path.toLowerCase().endsWith('.mov') ||
                     mediaFile.path.toLowerCase().endsWith('.avi') ||
                     mediaFile.mimeType?.startsWith('video/') == true;

      debugPrint('📸 NATIVE CAMERA: Processing ${isVideo ? 'video' : 'photo'}: ${mediaFile.path}');

      // Get sensor data for location/orientation
      SensorData? sensorData;
      try {
        sensorData = await _sensorService.captureSensorData();
        debugPrint('📸 NATIVE CAMERA: Sensor data collected');
      } catch (e) {
        debugPrint('⚠️ NATIVE CAMERA: Sensor data collection failed: $e');
      }

      // Extract photo metadata if it's an image
      Map<String, dynamic> photoMetadata = {};
      if (!isVideo) {
        try {
          photoMetadata = await PhotoMetadataService.extractComprehensiveMetadata(File(mediaFile.path));
          debugPrint('📸 NATIVE CAMERA: Photo metadata extracted');
        } catch (e) {
          debugPrint('⚠️ NATIVE CAMERA: Metadata extraction failed: $e');
        }
      }

      // Create result for the calling screen
      final result = CameraCaptureResult(
        path: mediaFile.path,
        isVideo: isVideo,
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
        photoMetadata: photoMetadata,
      );

      if (mounted) {
        debugPrint('📸 NATIVE CAMERA: returnToComposition=${widget.returnToComposition}, attachToSightingId=${widget.attachToSightingId}');

        if (widget.returnToComposition && widget.attachToSightingId != null) {
          // Navigate to beep screen with captured media for attachment
          debugPrint('📸 NATIVE CAMERA: Navigating to beepscreen for attachment');
          context.pushReplacement('/beepscreen', extra: {
            'initialMediaFiles': [File(mediaFile.path)],
            'attachToSightingId': widget.attachToSightingId,
          });
        } else if (widget.returnToComposition) {
          // AttachMediaScreen expects Map format
          debugPrint('📸 NATIVE CAMERA: Returning Map for AttachMediaScreen');
          context.pop({
            'mediaFile': File(mediaFile.path),
            'isVideo': isVideo,
            'photoMetadata': photoMetadata,
          });
        } else {
          // BeepScreen expects CameraCaptureResult
          debugPrint('📸 NATIVE CAMERA: Returning CameraCaptureResult for BeepScreen');
          context.pop(result);
        }
      }

    } catch (e) {
      debugPrint('❌ NATIVE CAMERA: Failed to process media: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to process ${widget.isVideoMode ? 'video' : 'photo'}: $e';
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _launchNativeCamera(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: AppColors.darkBackground,
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading screen while native camera launches
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.brandPrimary),
            SizedBox(height: 16),
            Text(
              'Opening camera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 32),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}