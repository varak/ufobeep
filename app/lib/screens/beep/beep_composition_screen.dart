import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../models/sensor_data.dart';
import '../../models/api_models.dart' as api;
import '../../services/api_client.dart';
import '../../services/sound_service.dart';
import '../../services/anonymous_beep_service.dart';
import '../../providers/app_state.dart';
import '../../widgets/simple_photo_display.dart';

class BeepCompositionScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final SensorData? sensorData;
  final Map<String, dynamic>? photoMetadata;
  final String? description;

  const BeepCompositionScreen({
    super.key,
    required this.imageFile,
    this.sensorData,
    this.photoMetadata,
    this.description,
  });

  @override
  ConsumerState<BeepCompositionScreen> createState() => _BeepCompositionScreenState();
}

class _BeepCompositionScreenState extends ConsumerState<BeepCompositionScreen> {
  // Form controllers and state
  final TextEditingController _descriptionController = TextEditingController();
  // Location privacy is now handled in user profile settings
  
  // Store sensor data in state to preserve it during rebuilds
  SensorData? _sensorData;
  
  // Submission state
  bool _isSubmitting = false;
  String? _errorMessage;

  // Form validation - description is optional
  bool get _isFormValid {
    return true; // Always valid since description is optional
  }
  
  bool get _hasContent {
    final description = _descriptionController.text.trim();
    return description.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    
    // Store sensor data in state immediately to preserve it during rebuilds
    _sensorData = widget.sensorData;
    
    // Prepopulate description if provided
    if (widget.description != null && widget.description!.isNotEmpty) {
      _descriptionController.text = widget.description!;
    }
    
    debugPrint('BeepComposition: Image=${widget.imageFile.existsSync()}, Sensor=${_sensorData != null}');
    if (_sensorData != null) {
      debugPrint('BeepComposition: GPS coordinates: lat=${_sensorData!.latitude}, lng=${_sensorData!.longitude}');
    }
    
    // Add listener for real-time validation
    _descriptionController.addListener(_onFormFieldChanged);
  }

  void _onFormFieldChanged() {
    setState(() {});
    debugPrint('Form validation: desc=${_descriptionController.text.length} chars, valid=$_isFormValid');
    debugPrint('Form change - sensor data still present: ${_sensorData != null}, GPS: ${_sensorData?.latitude}, ${_sensorData?.longitude}');
  }

  Future<void> _submitBeep() async {
    
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    // Play sound feedback when sending
    await SoundService.I.play(AlertSound.tap, haptic: true);

    try {
      // Get description - optional
      final description = _descriptionController.text.trim();
      
      // Use default values if empty
      final finalTitle = 'UFO Sighting';
      final finalDescription = description.isEmpty ? 'UFO sighting captured with UFOBeep app' : description;

      // All beeps are UFO sightings - no classification
      const category = api.SightingCategory.ufo;
      final List<String> tags = [];

      debugPrint('Submitting sighting with sensor data: ${_sensorData != null}');
      
      // First, send the beep to create sighting and trigger alerts
      debugPrint('Creating sighting via sendBeep...');
      // Check for valid GPS coordinates (not 0,0 which is invalid)
      double? validLat = _sensorData?.latitude;
      double? validLon = _sensorData?.longitude;
      if (validLat == 0.0 && validLon == 0.0) {
        validLat = null;
        validLon = null;
        debugPrint('Invalid GPS coordinates (0,0) detected, will use current location');
      }
      
      final beepResult = await anonymousBeepService.sendBeep(
        description: finalDescription,
        latitude: validLat,
        longitude: validLon,
        heading: _sensorData?.azimuthDeg,
      );
      
      final sightingId = beepResult['sighting_id'];
      debugPrint('Sighting created with ID: $sightingId');
      
      // Now upload the media file to the sighting
      try {
        debugPrint('Uploading photo to sighting...');
        await ApiClient.instance.uploadMediaFileForSighting(
          sightingId,
          widget.imageFile,
        );
        debugPrint('Photo uploaded successfully');
      } catch (e) {
        debugPrint('Warning: Failed to upload photo: $e');
        // Don't fail completely if media upload fails
      }

      // Submit photo metadata if available (for astronomical identification)
      if (widget.photoMetadata != null) {
        try {
          debugPrint('Submitting comprehensive photo metadata for astronomical identification...');
          final metadataSubmitted = await ApiClient.instance.submitPhotoMetadata(
            sightingId, 
            widget.photoMetadata!
          );
          if (metadataSubmitted) {
            debugPrint('Photo metadata submitted successfully for external service analysis');
          } else {
            debugPrint('Warning: Photo metadata submission failed');
          }
        } catch (e) {
          debugPrint('Error submitting photo metadata: $e');
        }
      }

      // Set device ID as current user so navigation button is hidden
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      ref.read(appStateProvider.notifier).setCurrentUser(deviceId);
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beep sent successfully!'),
            backgroundColor: AppColors.brandPrimary,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to the specific alert that was just created
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (context.mounted) {
            context.go('/alert/$sightingId');
          }
        });
      }

    } catch (e) {
      debugPrint('Beep submission error: $e');
      
      setState(() {
        _errorMessage = e.toString();
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send beep: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  void _retakePhoto() {
    context.go('/beep');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Beep'),
        backgroundColor: AppColors.darkSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _retakePhoto,
          tooltip: 'Retake Photo',
        ),
      ),
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo section
                    _buildPhotoSection(),
                    const SizedBox(height: 24),
                    
                    
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
                                style: const TextStyle(color: AppColors.semanticError, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Form field
                    _buildDescriptionInput(),
                    const SizedBox(height: 16),
                    
                    // Photo quality info (after description)
                    _buildPhotoQualityInfo(),
                    const SizedBox(height: 32), // Space for bottom button
                  ],
                ),
              ),
            ),
            
            // Bottom action buttons
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 400,
        minHeight: 300,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          widget.imageFile,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildPhotoQualityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.brandPrimary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Photo Quality',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'UFOBeep captures photos at maximum device resolution for detailed analysis. For even higher quality images, you can also upload photos from your camera gallery.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
                ),
                child: const Text(
                  '💡 Tip',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Native camera photos often have higher megapixel counts',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'What did you see? (optional)',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintText: 'Bright light moving across sky, object hovering, strange shape...',
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      maxLines: 3,
      maxLength: 300,
      textInputAction: TextInputAction.done,
    );
  }



  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main Send button (full width)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: !_isSubmitting ? _submitBeep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_isSubmitting 
                      ? AppColors.brandPrimary 
                      : AppColors.darkBorder,
                  foregroundColor: !_isSubmitting 
                      ? Colors.black 
                      : AppColors.textSecondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Sending...'),
                        ],
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Send Beep!'),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Retake Photo button (smaller, secondary)
            TextButton.icon(
              onPressed: _isSubmitting ? null : _retakePhoto,
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Retake Photo'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onFormFieldChanged);
    _descriptionController.dispose();
    super.dispose();
  }
}