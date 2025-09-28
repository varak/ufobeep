import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../models/sensor_data.dart';
import '../../models/camera_result.dart';
import '../../widgets/glass_card.dart';

class CameraChoiceScreen extends StatefulWidget {
  final String? description;
  final String? attachToSightingId;
  final bool returnToComposition;

  const CameraChoiceScreen({
    super.key,
    this.description,
    this.attachToSightingId,
    this.returnToComposition = false,
  });

  @override
  State<CameraChoiceScreen> createState() => _CameraChoiceScreenState();
}

class _CameraChoiceScreenState extends State<CameraChoiceScreen> {
  final ImagePicker _picker = ImagePicker();
  final SensorService _sensorService = SensorService();

  Future<void> _launchCamera({required bool isVideo}) async {
    try {
      XFile? capturedFile;

      if (isVideo) {
        capturedFile = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 30),
          preferredCameraDevice: CameraDevice.rear,
        );
      } else {
        capturedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 90,
          preferredCameraDevice: CameraDevice.rear,
        );
      }

      if (capturedFile != null && mounted) {
        await _processCapturedMedia(capturedFile, isVideo);
      } else if (mounted) {
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

  Future<void> _processCapturedMedia(XFile mediaFile, bool isVideo) async {
    // Same processing logic as before...
    try {
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
          context.pushReplacement('/beepscreen', extra: {
            'initialMediaFiles': [File(mediaFile.path)],
            'attachToSightingId': widget.attachToSightingId,
          });
        } else if (widget.returnToComposition) {
          context.pop({
            'mediaFile': File(mediaFile.path),
            'isVideo': isVideo,
            'photoMetadata': photoMetadata,
          });
        } else {
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
    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Choose Camera Mode',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Photo option
              GlassCard(
                onTap: () => _launchCamera(isVideo: false),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: AppColors.brandPrimary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Take Photo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Capture UFO sighting images',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Video option
              GlassCard(
                onTap: () => _launchCamera(isVideo: true),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.videocam,
                        size: 48,
                        color: AppColors.brandPrimary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Record Video',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Record UFO movement or testimonial',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NightSkyBackground extends StatelessWidget {
  final Widget child;

  const NightSkyBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.nightSkyTop,
            AppColors.nightSkyMiddle,
            AppColors.nightSkyBottom,
          ],
        ),
      ),
      child: child,
    );
  }
}