import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/plane_match_api_service.dart';
import '../../models/sensor_data.dart';
import '../../widgets/plane_badge.dart';

class BeepScreen extends StatefulWidget {
  const BeepScreen({super.key});

  @override
  State<BeepScreen> createState() => _BeepScreenState();
}

class _BeepScreenState extends State<BeepScreen> {
  final ImagePicker _picker = ImagePicker();
  final SensorService _sensorService = SensorService();
  final PlaneMatchApiService _planeMatchService = AppEnvironment.debugMode 
      ? MockPlaneMatchApiService() 
      : PlaneMatchApiService();
  
  File? _capturedImage;
  SensorData? _capturedSensorData;
  PlaneMatchResponse? _planeMatch;
  bool _isCapturing = false;
  bool _isAnalyzingPlane = false;
  bool _sensorsAvailable = false;
  bool _userReclassifiedAsUFO = false;
  String? _errorMessage;
  String? _planeMatchError;

  @override
  void initState() {
    super.initState();
    _checkSensorAvailability();
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

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      // Capture photo from camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1440,
      );

      if (image == null) {
        setState(() {
          _isCapturing = false;
        });
        return;
      }

      // Capture sensor data simultaneously
      SensorData? sensorData;
      if (_sensorsAvailable) {
        try {
          sensorData = await _sensorService.captureSensorData();
        } catch (e) {
          // Continue without sensor data if capture fails
          debugPrint('Failed to capture sensor data: $e');
        }
      }

      setState(() {
        _capturedImage = File(image.path);
        _capturedSensorData = sensorData;
        _isCapturing = false;
        _planeMatch = null;
        _planeMatchError = null;
        _userReclassifiedAsUFO = false;
      });

      // Show captured data for review
      _showCaptureReview();

      // If we have sensor data, start plane matching analysis
      if (sensorData != null) {
        _performPlaneMatchAnalysis(sensorData);
      }

    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to capture photo: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1440,
      );

      if (image == null) {
        setState(() {
          _isCapturing = false;
        });
        return;
      }

      setState(() {
        _capturedImage = File(image.path);
        _capturedSensorData = null; // No real-time sensor data for gallery picks
        _isCapturing = false;
        _planeMatch = null;
        _planeMatchError = null;
        _userReclassifiedAsUFO = false;
      });

      _showCaptureReview();

    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _performPlaneMatchAnalysis(SensorData sensorData) async {
    setState(() {
      _isAnalyzingPlane = true;
      _planeMatchError = null;
    });

    try {
      final result = await _planeMatchService.matchPlane(sensorData);
      setState(() {
        _planeMatch = result;
        _isAnalyzingPlane = false;
      });

      debugPrint('Plane match result: ${result.isPlane ? "Plane found" : "No plane"} (confidence: ${result.confidence})');

    } catch (e) {
      setState(() {
        _isAnalyzingPlane = false;
        _planeMatchError = e.toString();
      });

      debugPrint('Plane match error: $e');
    }
  }

  void _retryPlaneAnalysis() {
    if (_capturedSensorData != null) {
      _performPlaneMatchAnalysis(_capturedSensorData!);
    }
  }

  void _reclassifyAsUFO() {
    setState(() {
      _userReclassifiedAsUFO = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marked as UFO - plane classification overridden'),
        backgroundColor: AppColors.semanticWarning,
      ),
    );
  }

  void _showCaptureReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      builder: (context) => _buildCaptureReview(),
    );
  }

  Widget _buildCaptureReview() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          const Text(
            'Review Capture',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Image preview
          if (_capturedImage != null) ...[
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _capturedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Plane matching results
          if (_capturedSensorData != null) ...[
            if (_isAnalyzingPlane)
              const PlaneMatchLoadingBadge()
            else if (_planeMatchError != null)
              PlaneMatchErrorBadge(
                errorMessage: _planeMatchError!,
                onRetry: _retryPlaneAnalysis,
              )
            else if (_planeMatch != null && !_userReclassifiedAsUFO)
              PlaneBadge(
                planeMatch: _planeMatch!,
                onReclassify: _reclassifyAsUFO,
              )
            else if (_userReclassifiedAsUFO)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.semanticWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.semanticWarning, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flag, color: AppColors.semanticWarning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Classified as UFO (plane match overridden)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],

          // Sensor data info
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Capture Information',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_capturedSensorData != null) ...[
                    _buildInfoRow('Time', _capturedSensorData!.utc.toLocal().toString().split('.')[0]),
                    _buildInfoRow('Location', '${_capturedSensorData!.latitude.toStringAsFixed(6)}, ${_capturedSensorData!.longitude.toStringAsFixed(6)}'),
                    _buildInfoRow('Accuracy', '${_capturedSensorData!.accuracy?.toStringAsFixed(1)}m'),
                    _buildInfoRow('Azimuth', '${_capturedSensorData!.azimuthDeg.toStringAsFixed(1)}°'),
                    _buildInfoRow('Pitch', '${_capturedSensorData!.pitchDeg.toStringAsFixed(1)}°'),
                    if (_capturedSensorData!.rollDeg != null)
                      _buildInfoRow('Roll', '${_capturedSensorData!.rollDeg!.toStringAsFixed(1)}°'),
                    if (_capturedSensorData!.hfovDeg != null)
                      _buildInfoRow('Camera HFOV', '${_capturedSensorData!.hfovDeg!.toStringAsFixed(1)}°'),
                  ] else ...[
                    const Text(
                      'No sensor data captured\n(Gallery image or sensors unavailable)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _capturedImage = null;
                      _capturedSensorData = null;
                      _planeMatch = null;
                      _planeMatchError = null;
                      _userReclassifiedAsUFO = false;
                    });
                  },
                  child: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _submitSighting();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                  ),
                  child: const Text(
                    'Submit Sighting',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitSighting() async {
    if (_capturedImage == null) return;

    try {
      // Determine sighting classification
      String classification = 'UFO';
      String additionalInfo = '';

      if (_userReclassifiedAsUFO) {
        additionalInfo = ' (plane match overridden by user)';
      } else if (_planeMatch?.isPlane == true && _planeMatch!.confidence > 0.7) {
        classification = 'Likely Aircraft';
        final flight = _planeMatch!.matchedFlight;
        if (flight != null) {
          additionalInfo = ' (${flight.displayName})';
        }
      } else if (_planeMatch?.isPlane == true) {
        classification = 'Possible Aircraft';
        additionalInfo = ' (low confidence: ${(_planeMatch!.confidence * 100).toInt()}%)';
      }

      // TODO: This will be implemented with the full sighting submission endpoint
      // For now, show comprehensive success message with plane matching results
      String message = 'Sighting submitted as $classification$additionalInfo';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: classification.contains('Aircraft') 
              ? AppColors.semanticWarning 
              : AppColors.brandPrimary,
          duration: const Duration(seconds: 4),
        ),
      );

      // Reset state
      setState(() {
        _capturedImage = null;
        _capturedSensorData = null;
        _planeMatch = null;
        _planeMatchError = null;
        _userReclassifiedAsUFO = false;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit sighting: $e'),
          backgroundColor: AppColors.semanticError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Sighting'),
        backgroundColor: AppColors.darkSurface,
      ),
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Status indicator
              if (!_sensorsAvailable) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.semanticWarning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.semanticWarning.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.semanticWarning, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Device sensors not available. Plane matching will be limited.',
                          style: TextStyle(
                            color: AppColors.semanticWarning,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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
                          style: const TextStyle(
                            color: AppColors.semanticError,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Camera icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.brandPrimary.withOpacity(0.2),
                            AppColors.brandPrimary.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: AppColors.brandPrimary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Instructions
                    const Text(
                      'Capture or Select Sighting',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Point your camera at the sky object and tap capture.\nSensor data will be collected for plane matching.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Action buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isCapturing ? null : _capturePhoto,
                            icon: _isCapturing 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.camera_alt),
                            label: Text(_isCapturing ? 'Capturing...' : 'Capture Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPrimary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isCapturing ? null : _pickFromGallery,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Choose from Gallery'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brandPrimary,
                              side: const BorderSide(color: AppColors.brandPrimary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer info
              if (_sensorsAvailable)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sensors, color: AppColors.brandPrimary, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Sensors ready for plane matching',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}