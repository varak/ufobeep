import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../services/sensor_service.dart';
import '../../services/photo_metadata_service.dart';
import '../../models/sensor_data.dart';
import '../../models/sighting_submission.dart' as local;
import '../../models/user_preferences.dart';

class BeepScreen extends StatefulWidget {
  const BeepScreen({super.key});

  @override
  State<BeepScreen> createState() => _BeepScreenState();
}

class _BeepScreenState extends State<BeepScreen> {
  final ImagePicker _picker = ImagePicker();
  final SensorService _sensorService = SensorService();
  
  local.SightingSubmission? _currentSubmission;
  bool _isCapturing = false;
  bool _sensorsAvailable = false;
  String? _errorMessage;
  

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
    // Navigate to custom camera screen that skips approval
    context.go('/beep/camera');
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

      // Create initial submission for gallery image
      final submission = local.SightingSubmission(
        imageFile: File(image.path),
        title: '',
        description: '',
        category: local.SightingCategory.ufo,
        sensorData: null, // No real-time sensor data for gallery picks
        locationPrivacy: LocationPrivacy.jittered,
        createdAt: DateTime.now(),
      );

      setState(() {
        _currentSubmission = submission;
        _isCapturing = false;
      });

      // Navigate to composition screen
      context.go('/beep/compose', extra: {
        'imageFile': submission.imageFile,
        'sensorData': null, // No real-time sensor data for gallery picks
      });

    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Beep'),
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


  @override
  void dispose() {
    super.dispose();
  }
}