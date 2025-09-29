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
  bool _isPhotoMode = true;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  double _currentZoom = 1.0;

  void _zoomIn(state) {
    final newZoom = (_currentZoom + 0.2).clamp(0.1, 20.0);
    setState(() {
      _currentZoom = newZoom;
    });
    state.sensorConfig.setZoom(_currentZoom);
  }

  void _zoomOut(state) {
    final newZoom = (_currentZoom - 0.2).clamp(0.1, 20.0);
    setState(() {
      _currentZoom = newZoom;
    });
    state.sensorConfig.setZoom(_currentZoom);
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _handleVideoCapture(captureRequest) {
    // Handle video capture completion
    String? filePath;
    captureRequest.when(
      single: (single) {
        filePath = single.file?.path;
      },
      multiple: (multiple) {
        filePath = multiple.fileBySensor.values.first?.path;
      },
    );

    if (filePath != null) {
      debugPrint('📸 AWESOME CAMERA: Video completed: $filePath');
      setState(() {
        _capturedFiles.add(filePath!);
        _isAttaching = true;
      });
      _processCapturedMedia(filePath!, true);
    }
  }

  void _handleMediaCapture(captureRequest) {
    debugPrint('📸 AWESOME CAMERA: Photo captured: $captureRequest');

    String? filePath;

    captureRequest.when(
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
          initialCaptureMode: _isPhotoMode ? CaptureMode.photo : CaptureMode.video,
        ),
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          flashMode: FlashMode.auto,
          aspectRatio: CameraAspectRatios.ratio_16_9,
          zoom: 0.0,
        ),
        enablePhysicalButton: true,
        availableFilters: [], // Remove filters - keep original only
        onPreviewScaleBuilder: (state) => OnPreviewScale(
          onScale: (scale) {
            // Use camera's actual min/max zoom capabilities - no artificial limits
            final minZoom = state.sensorConfig.minZoom;
            final maxZoom = state.sensorConfig.maxZoom;
            if (minZoom != null && maxZoom != null) {
              final newZoom = scale.clamp(minZoom, maxZoom);
              state.sensorConfig.setZoom(newZoom);
            }
          },
        ),
        onMediaCaptureEvent: (event) {
          switch ((event.status, event.isPicture, event.isVideo)) {
            case (MediaCaptureStatus.capturing, false, true):
              // Video recording started
              setState(() {
                _isRecording = true;
                _recordingSeconds = 0;
              });
              _startRecordingTimer();
              break;
            case (MediaCaptureStatus.success, true, false):
              // Photo captured
              _handleMediaCapture(event.captureRequest);
              break;
            case (MediaCaptureStatus.success, false, true):
              // Video completed
              setState(() {
                _isRecording = false;
              });
              _stopRecordingTimer();
              _handleVideoCapture(event.captureRequest);
              break;
            default:
              debugPrint('📸 AWESOME CAMERA: Event: ${event.status}');
          }
        },
        topActionsBuilder: (state) {
          return _capturedFiles.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isAttaching ? Colors.black : AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
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
                  ),
                )
              : const SizedBox.shrink();
        },
        middleContentBuilder: (state) {
          return Column(
            children: [
              // Slider-style photo/video toggle
              Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Sliding indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: _isPhotoMode ? 4 : 96,
                      top: 4,
                      child: Container(
                        width: 96,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _isPhotoMode ? AppColors.brandPrimary : Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    // Photo button
                    Positioned(
                      left: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPhotoMode = true;
                          });
                          // Switch camera to photo mode
                          state.setState(CaptureMode.photo);
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: _isPhotoMode ? Colors.black : Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PHOTO',
                                style: TextStyle(
                                  color: _isPhotoMode ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Video button
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPhotoMode = false;
                          });
                          // Switch camera to video mode
                          state.setState(CaptureMode.video);
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 16,
                                color: !_isPhotoMode ? Colors.white : Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'VIDEO',
                                style: TextStyle(
                                  color: !_isPhotoMode ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Video recording timer - prominent display
              if (_isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pulsing red dot
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'REC ${_recordingSeconds ~/ 60}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
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