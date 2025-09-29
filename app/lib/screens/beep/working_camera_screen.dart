import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../models/sensor_data.dart';
import '../../models/camera_result.dart';

class WorkingCameraScreen extends StatefulWidget {
  final String? description;
  final String? attachToSightingId;
  final bool returnToComposition;

  const WorkingCameraScreen({
    super.key,
    this.description,
    this.attachToSightingId,
    this.returnToComposition = false,
  });

  @override
  State<WorkingCameraScreen> createState() => _WorkingCameraScreenState();
}

class _WorkingCameraScreenState extends State<WorkingCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final SensorService _sensorService = SensorService();

  @override
  void initState() {
    super.initState();
    // Auto-launch native camera with both photo and video options
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        _launchNativeCameraWithBothModes();
      }
    });
  }

  Future<void> _launchNativeCameraWithBothModes() async {
    try {
      // Use pickMedia - gives both photo and video options in native camera
      final XFile? capturedFile = await _picker.pickMedia(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (capturedFile != null && mounted) {
        await _processCapturedMedia(capturedFile);
      } else if (mounted) {
        // User cancelled - go back
        context.pop();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _processCapturedMedia(XFile mediaFile) async {
    try {
      // Detect if video based on file extension
      final isVideo = mediaFile.path.toLowerCase().endsWith('.mp4') ||
                     mediaFile.path.toLowerCase().endsWith('.mov') ||
                     mediaFile.path.toLowerCase().endsWith('.avi') ||
                     mediaFile.mimeType?.startsWith('video/') == true;

      // Get sensor data
      SensorData? sensorData;
      try {
        sensorData = await _sensorService.captureSensorData();
      } catch (e) {
        debugPrint('Warning: Sensor data collection failed: $e');
      }

      // Extract photo metadata if it's an image
      Map<String, dynamic> photoMetadata = {};
      if (!isVideo) {
        try {
          photoMetadata = await PhotoMetadataService.extractComprehensiveMetadata(File(mediaFile.path));
        } catch (e) {
          debugPrint('Warning: Metadata extraction failed: $e');
        }
      }

      if (mounted) {
        if (widget.returnToComposition && widget.attachToSightingId != null) {
          // Navigate to beep screen with captured media for attachment
          context.pushReplacement('/beepscreen', extra: {
            'initialMediaFiles': [File(mediaFile.path)],
            'attachToSightingId': widget.attachToSightingId,
          });
        } else if (widget.returnToComposition) {
          // Return Map for AttachMediaScreen
          context.pop({
            'mediaFile': File(mediaFile.path),
            'isVideo': isVideo,
            'photoMetadata': photoMetadata,
          });
        } else {
          // Return CameraCaptureResult for BeepScreen
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
          context.pop(result);
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process media: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.brandPrimary),
            const SizedBox(height: 16),
            const Text(
              'Opening camera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
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