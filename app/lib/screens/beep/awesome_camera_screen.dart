import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:path_provider/path_provider.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../models/sensor_data.dart' as ufo;
import '../../models/camera_result.dart';

class AwesomeCameraScreen extends StatefulWidget {
  final String? description;
  final String? attachToSightingId;
  final bool returnToComposition;

  const AwesomeCameraScreen({
    super.key,
    this.description,
    this.attachToSightingId,
    this.returnToComposition = false,
  });

  @override
  State<AwesomeCameraScreen> createState() => _AwesomeCameraScreenState();
}

class _AwesomeCameraScreenState extends State<AwesomeCameraScreen> {
  final SensorService _sensorService = SensorService();
  List<String> _capturedFiles = [];
  bool _isRecording = false;
  bool _isAttaching = false;
  int _recordingSeconds = 0;
  late Timer? _recordingTimer;

  void _handleMediaCapture(mediaCapture) {
    debugPrint('📸 AWESOME CAMERA: MediaCapture received: $mediaCapture');

    String? filePath;

    mediaCapture.captureRequest.when(
      single: (single) {
        filePath = single.file?.path;
        debugPrint('📸 AWESOME CAMERA: Single file path: $filePath');
      },
      multiple: (multiple) {
        filePath = multiple.fileBySensor.values.first?.path;
        debugPrint('📸 AWESOME CAMERA: Multiple file path: $filePath');
      },
    );

    if (filePath != null) {
      // Detect if video based on file extension
      final isVideo = filePath!.toLowerCase().endsWith('.mp4') ||
                     filePath!.toLowerCase().endsWith('.mov') ||
                     filePath!.toLowerCase().endsWith('.avi');

      debugPrint('📸 AWESOME CAMERA: Processing file: $filePath (isVideo: $isVideo)');

      setState(() {
        _capturedFiles.add(filePath!);
        _isAttaching = true;
      });

      // Auto-submit
      _processCapturedMedia(filePath!, isVideo);
    } else {
      debugPrint('❌ AWESOME CAMERA: No file path found in MediaCapture');
    }
  }

  Future<void> _processCapturedMedia(String filePath, bool isVideo) async {
    try {
      debugPrint('📸 AWESOME CAMERA: Processing ${isVideo ? 'video' : 'photo'}: $filePath');

      // Get sensor data for location/orientation
      ufo.SensorData? sensorData;
      try {
        sensorData = await _sensorService.captureSensorData();
        debugPrint('📸 AWESOME CAMERA: Sensor data collected');
      } catch (e) {
        debugPrint('⚠️ AWESOME CAMERA: Sensor data collection failed: $e');
      }

      // Extract photo metadata if it's an image
      Map<String, dynamic> photoMetadata = {};
      if (!isVideo) {
        try {
          photoMetadata = await PhotoMetadataService.extractComprehensiveMetadata(File(filePath));
          debugPrint('📸 AWESOME CAMERA: Photo metadata extracted');
        } catch (e) {
          debugPrint('⚠️ AWESOME CAMERA: Metadata extraction failed: $e');
        }
      }

      if (mounted) {
        if (widget.returnToComposition && widget.attachToSightingId != null) {
          // Navigate to beep screen with captured media for attachment
          debugPrint('📸 AWESOME CAMERA: Navigating to beepscreen for attachment');
          context.pushReplacement('/beepscreen', extra: {
            'initialMediaFiles': [File(filePath)],
            'attachToSightingId': widget.attachToSightingId,
          });
        } else if (widget.returnToComposition) {
          // AttachMediaScreen expects Map format
          debugPrint('📸 AWESOME CAMERA: Returning Map for AttachMediaScreen');
          context.pop({
            'mediaFile': File(filePath),
            'isVideo': isVideo,
            'photoMetadata': photoMetadata,
          });
        } else {
          // BeepScreen expects CameraCaptureResult
          final result = CameraCaptureResult(
            path: filePath,
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
          debugPrint('📸 AWESOME CAMERA: Returning CameraCaptureResult for BeepScreen');
          context.pop(result);
        }
      }

    } catch (e) {
      debugPrint('❌ AWESOME CAMERA: Failed to process media: $e');
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
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photoAndVideo(
          initialCaptureMode: CaptureMode.photo,
        ),
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          flashMode: FlashMode.auto,
          aspectRatio: CameraAspectRatios.ratio_16_9,
          zoom: 0.0,
        ),
        enablePhysicalButton: true,
        availableFilters: [], // Remove filters - keep original only
        onMediaTap: (mediaCapture) {
          // Auto-submit when user taps their captured media
          _handleMediaCapture(mediaCapture);
        },
        topActionsBuilder: (state) {
          return _capturedFiles.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _isAttaching
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Attaching...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: () => _submitCapturedMedia(),
                          child: Text(
                            'Done (${_capturedFiles.length})',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                )
              : const SizedBox.shrink();
        },
        middleContentBuilder: (state) {
          return Column(
            children: [
              // Photo/Video mode selector
              AwesomeCameraModeSelector(state: state),

              const SizedBox(height: 20),

              // Recording timer when recording video
              if (_isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '🔴 ${_recordingSeconds ~/ 60}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _submitCapturedMedia() {
    if (_capturedFiles.isNotEmpty) {
      // Process first captured file and return to UFOBeep
      final firstFile = _capturedFiles.first;
      _processCapturedMedia(firstFile, firstFile.toLowerCase().contains('.mp4'));
    }
  }
}