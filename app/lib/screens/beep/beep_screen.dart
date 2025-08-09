import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';
import '../../config/environment.dart';
import '../../services/sensor_service.dart';
import '../../services/plane_match_api_service.dart';
import '../../models/sensor_data.dart';
import '../../models/sighting_submission.dart';
import '../../models/alerts_filter.dart';
import '../../widgets/plane_badge.dart';
import '../../widgets/photo_preview.dart';

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
  
  SightingSubmission? _currentSubmission;
  bool _isCapturing = false;
  bool _isAnalyzingPlane = false;
  bool _sensorsAvailable = false;
  String? _errorMessage;
  String? _planeMatchError;
  
  // Form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = SightingCategory.ufo;
  LocationPrivacy _locationPrivacy = LocationPrivacy.jittered;

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

      // Create initial submission
      final submission = SightingSubmission(
        imageFile: File(image.path),
        title: '',
        description: '',
        category: _selectedCategory,
        sensorData: sensorData,
        locationPrivacy: _locationPrivacy,
        createdAt: DateTime.now(),
      );

      setState(() {
        _currentSubmission = submission;
        _isCapturing = false;
        _planeMatchError = null;
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

      // Create initial submission for gallery image
      final submission = SightingSubmission(
        imageFile: File(image.path),
        title: '',
        description: '',
        category: _selectedCategory,
        sensorData: null, // No real-time sensor data for gallery picks
        locationPrivacy: _locationPrivacy,
        createdAt: DateTime.now(),
      );

      setState(() {
        _currentSubmission = submission;
        _isCapturing = false;
        _planeMatchError = null;
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
      if (_currentSubmission != null) {
        setState(() {
          _currentSubmission = _currentSubmission!.copyWith(
            planeMatch: result,
          );
          _isAnalyzingPlane = false;
        });
      }

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
    if (_currentSubmission?.sensorData != null) {
      _performPlaneMatchAnalysis(_currentSubmission!.sensorData!);
    }
  }

  void _reclassifyAsUFO() {
    if (_currentSubmission != null) {
      setState(() {
        _currentSubmission = _currentSubmission!.copyWith(
          userReclassifiedAsUFO: true,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as UFO - plane classification overridden'),
          backgroundColor: AppColors.semanticWarning,
        ),
      );
    }
  }

  void _showCaptureReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildSubmissionForm(),
    );
  }

  Widget _buildSubmissionForm() {
    if (_currentSubmission == null) return const SizedBox();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Complete Sighting Report',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable form content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo preview
                      SizedBox(
                        height: 300,
                        child: PhotoPreview(
                          imageFile: _currentSubmission!.imageFile!,
                          onRetake: () {
                            Navigator.of(context).pop();
                            _clearCurrentSubmission();
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Plane matching results
                      if (_currentSubmission!.sensorData != null) ...[
                        if (_isAnalyzingPlane)
                          const PlaneMatchLoadingBadge()
                        else if (_planeMatchError != null)
                          PlaneMatchErrorBadge(
                            errorMessage: _planeMatchError!,
                            onRetry: _retryPlaneAnalysis,
                          )
                        else if (_currentSubmission!.planeMatch != null && 
                                 !_currentSubmission!.userReclassifiedAsUFO)
                          PlaneBadge(
                            planeMatch: _currentSubmission!.planeMatch!,
                            onReclassify: _reclassifyAsUFO,
                          )
                        else if (_currentSubmission!.userReclassifiedAsUFO)
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
                        const SizedBox(height: 20),
                      ],

                      // Category selection
                      _buildCategorySelection(),
                      const SizedBox(height: 20),

                      // Title input
                      _buildTitleInput(),
                      const SizedBox(height: 16),

                      // Description input
                      _buildDescriptionInput(),
                      const SizedBox(height: 20),

                      // Location privacy
                      _buildLocationPrivacySection(),
                      const SizedBox(height: 20),

                      // Sensor data info (collapsible)
                      if (_currentSubmission!.sensorData != null)
                        _buildSensorDataSection(),
                      
                      const SizedBox(height: 100), // Extra padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    if (_currentSubmission?.imageFile == null) return;

    try {
      // Determine sighting classification
      String classification = 'UFO';
      String additionalInfo = '';

      if (_currentSubmission!.userReclassifiedAsUFO) {
        additionalInfo = ' (plane match overridden by user)';
      } else if (_currentSubmission!.planeMatch?.isPlane == true && _currentSubmission!.planeMatch!.confidence > 0.7) {
        classification = 'Likely Aircraft';
        final flight = _currentSubmission!.planeMatch!.matchedFlight;
        if (flight != null) {
          additionalInfo = ' (${flight.displayName})';
        }
      } else if (_currentSubmission!.planeMatch?.isPlane == true) {
        classification = 'Possible Aircraft';
        additionalInfo = ' (low confidence: ${(_currentSubmission!.planeMatch!.confidence * 100).toInt()}%)';
      }

      // TODO: This will be implemented with the full sighting submission endpoint
      // For now, show comprehensive success message with plane matching results
      String message = 'Sighting "${_currentSubmission!.title}" submitted as $classification$additionalInfo';

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
      _clearCurrentSubmission();

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
        actions: [
          if (_currentSubmission != null)
            TextButton(
              onPressed: () {
                _clearCurrentSubmission();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
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
      floatingActionButton: _currentSubmission != null ? FloatingActionButton.extended(
        onPressed: _currentSubmission?.isReadyToSubmit == true ? _submitSighting : null,
        backgroundColor: _currentSubmission?.isReadyToSubmit == true 
            ? AppColors.brandPrimary 
            : AppColors.darkBorder,
        foregroundColor: _currentSubmission?.isReadyToSubmit == true 
            ? Colors.black 
            : AppColors.textSecondary,
        icon: _currentSubmission?.status == SubmissionStatus.validating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.send),
        label: Text(
          _currentSubmission?.status == SubmissionStatus.validating 
              ? 'Submitting...' 
              : 'Submit Report',
        ),
      ) : null,
    );
  }

  void _clearCurrentSubmission() {
    setState(() {
      _currentSubmission = null;
      _planeMatchError = null;
      _titleController.clear();
      _descriptionController.clear();
      _selectedCategory = SightingCategory.ufo;
      _locationPrivacy = LocationPrivacy.jittered;
    });
  }

  void _updateSubmission({
    String? title,
    String? description,
    String? category,
    LocationPrivacy? locationPrivacy,
  }) {
    if (_currentSubmission == null) return;
    
    setState(() {
      _currentSubmission = _currentSubmission!.copyWith(
        title: title ?? _currentSubmission!.title,
        description: description ?? _currentSubmission!.description,
        category: category ?? _currentSubmission!.category,
        locationPrivacy: locationPrivacy ?? _currentSubmission!.locationPrivacy,
      );
    });
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            dropdownColor: AppColors.darkSurface,
            style: const TextStyle(color: AppColors.textPrimary),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            items: SightingCategory.allCategories.map((category) {
              final categoryData = AlertCategory.getByKey(category);
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      categoryData?.icon ?? Icons.help,
                      color: AppColors.brandPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            SightingCategory.getDisplayName(category),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            SightingCategory.getDescription(category),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
                _updateSubmission(category: value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Brief description of what you saw...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.darkSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brandPrimary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterStyle: const TextStyle(color: AppColors.textSecondary),
          ),
          maxLength: SightingValidator.maxTitleLength,
          textInputAction: TextInputAction.next,
          onChanged: (value) => _updateSubmission(title: value),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Describe what you observed in detail...\n\nInclude details like:\n• Time of observation\n• Weather conditions\n• Object behavior\n• Duration of sighting',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.darkSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brandPrimary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterStyle: const TextStyle(color: AppColors.textSecondary),
          ),
          maxLines: 6,
          maxLength: SightingValidator.maxDescriptionLength,
          textInputAction: TextInputAction.newline,
          onChanged: (value) => _updateSubmission(description: value),
        ),
      ],
    );
  }

  Widget _buildLocationPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location Privacy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: LocationPrivacy.values.map((privacy) {
              final isSelected = _locationPrivacy == privacy;
              return InkWell(
                onTap: () {
                  setState(() {
                    _locationPrivacy = privacy;
                  });
                  _updateSubmission(locationPrivacy: privacy);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.brandPrimary.withOpacity(0.1) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        privacy.icon,
                        color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              privacy.displayName,
                              style: TextStyle(
                                color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              privacy.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.brandPrimary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorDataSection() {
    final sensorData = _currentSubmission!.sensorData;
    if (sensorData == null) return const SizedBox();

    return ExpansionTile(
      title: const Text(
        'Sensor Data',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: const Icon(Icons.sensors, color: AppColors.brandPrimary),
      iconColor: AppColors.textSecondary,
      collapsedIconColor: AppColors.textSecondary,
      backgroundColor: AppColors.darkSurface,
      collapsedBackgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInfoRow('Time', sensorData.utc.toLocal().toString().split('.')[0]),
              _buildInfoRow('Location', '${sensorData.latitude.toStringAsFixed(6)}, ${sensorData.longitude.toStringAsFixed(6)}'),
              _buildInfoRow('Accuracy', '${sensorData.accuracy?.toStringAsFixed(1)}m'),
              _buildInfoRow('Azimuth', '${sensorData.azimuthDeg.toStringAsFixed(1)}°'),
              _buildInfoRow('Pitch', '${sensorData.pitchDeg.toStringAsFixed(1)}°'),
              if (sensorData.rollDeg != null)
                _buildInfoRow('Roll', '${sensorData.rollDeg!.toStringAsFixed(1)}°'),
              if (sensorData.hfovDeg != null)
                _buildInfoRow('Camera HFOV', '${sensorData.hfovDeg!.toStringAsFixed(1)}°'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}