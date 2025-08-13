import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../models/sensor_data.dart';
import '../../models/api_models.dart' as api;
import '../../services/api_client.dart';
import '../../widgets/simple_photo_display.dart';

class BeepCompositionScreen extends StatefulWidget {
  final File imageFile;
  final SensorData? sensorData;

  const BeepCompositionScreen({
    super.key,
    required this.imageFile,
    this.sensorData,
  });

  @override
  State<BeepCompositionScreen> createState() => _BeepCompositionScreenState();
}

class _BeepCompositionScreenState extends State<BeepCompositionScreen> {
  // Form controllers and state
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // Location privacy is now handled in user profile settings
  
  // Submission state
  bool _isSubmitting = false;
  String? _errorMessage;

  // Form validation
  bool get _isFormValid {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    return title.length >= 5 && description.length >= 10;
  }

  @override
  void initState() {
    super.initState();
    
    debugPrint('=== BEEP COMPOSITION SCREEN - NO CLASSIFICATION ===');
    debugPrint('Image file: ${widget.imageFile.path}');
    debugPrint('Image file exists: ${widget.imageFile.existsSync()}');
    debugPrint('Sensor data available: ${widget.sensorData != null}');
    debugPrint('========================================');
    
    // Add listeners for real-time validation
    _titleController.addListener(_onFormFieldChanged);
    _descriptionController.addListener(_onFormFieldChanged);
  }

  void _onFormFieldChanged() {
    setState(() {});
    debugPrint('Form validation: title=${_titleController.text.length} chars, desc=${_descriptionController.text.length} chars, valid=$_isFormValid');
  }

  Future<void> _submitBeep() async {
    // Check if form is valid and show helpful message if not
    if (!_isFormValid) {
      String message = '';
      final titleLength = _titleController.text.trim().length;
      final descLength = _descriptionController.text.trim().length;
      
      if (titleLength < 5) {
        message = 'Title needs at least 5 characters (currently $titleLength)';
      } else if (descLength < 10) {
        message = 'Description needs at least 10 characters (currently $descLength)';
      }
      
      if (message.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.semanticWarning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Validate required fields
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      if (title.isEmpty || title.length < 5) {
        throw Exception('Title must be at least 5 characters long');
      }
      
      if (description.isEmpty || description.length < 10) {
        throw Exception('Description must be at least 10 characters long');
      }

      // All beeps are UFO sightings - no classification
      const category = api.SightingCategory.ufo;
      final List<String> tags = [];

      // Submit sighting with media using API client
      final sightingId = await ApiClient.instance.submitSightingWithMedia(
        title: title,
        description: description,
        category: category,
        sensorData: widget.sensorData,
        mediaFiles: [widget.imageFile],
        witnessCount: 1,
        tags: tags,
        isPublic: true, // TODO: Use user profile location privacy setting
        onProgress: (progress) {
          debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beep "$title" sent successfully!'),
            backgroundColor: AppColors.brandPrimary,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to the alert detail page
        // Add a small delay to allow backend to process the sighting
        Future.delayed(const Duration(milliseconds: 500), () {
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
                    const SizedBox(height: 16),
                    
                    // Explanation message
                    _buildExplanationMessage(),
                    const SizedBox(height: 20),
                    
                    
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
                    
                    // Form fields
                    _buildTitleInput(),
                    const SizedBox(height: 20),
                    _buildDescriptionInput(),
                    const SizedBox(height: 100), // Space for bottom button
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
    return SimplePhotoDisplay(
      imageFile: widget.imageFile,
      height: 200,
      width: double.infinity,
    );
  }

  Widget _buildExplanationMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brandPrimary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.send,
            color: AppColors.brandPrimary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This photo will be sent with your beep',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add details below to complete your submission',
                  style: TextStyle(
                    color: AppColors.brandPrimary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Brief description of what you saw...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            helperText: 'Minimum 5 characters',
            helperStyle: TextStyle(
              color: _titleController.text.trim().length >= 5 
                ? AppColors.brandPrimary 
                : AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.grey[700], // Visible grey input background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _titleController.text.trim().length >= 5 
                  ? AppColors.brandPrimary.withOpacity(0.5) 
                  : AppColors.darkBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brandPrimary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            counterStyle: const TextStyle(color: AppColors.textSecondary),
          ),
          maxLength: 100,
          textInputAction: TextInputAction.next,
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Describe what you observed in detail...\n\nInclude details like:\n• Time of observation\n• Weather conditions\n• Object behavior\n• Duration of sighting',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            helperText: 'Minimum 10 characters',
            helperStyle: TextStyle(
              color: _descriptionController.text.trim().length >= 10 
                ? AppColors.brandPrimary 
                : AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.grey[700], // Visible grey input background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _descriptionController.text.trim().length >= 10 
                  ? AppColors.brandPrimary.withOpacity(0.5) 
                  : AppColors.darkBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brandPrimary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            counterStyle: const TextStyle(color: AppColors.textSecondary),
          ),
          maxLines: 6,
          maxLength: 1000,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }



  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Retake Photo button
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _retakePhoto,
                icon: const Icon(Icons.camera_alt, size: 20),
                label: const Text('Retake'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.darkBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Send Beep! button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: !_isSubmitting ? _submitBeep : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.send, size: 20),
                label: Text(
                  _isSubmitting 
                      ? 'Sending...' 
                      : _isFormValid 
                        ? 'Send Beep!' 
                        : 'Complete Form',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (!_isSubmitting && _isFormValid) 
                      ? AppColors.brandPrimary 
                      : AppColors.darkBorder,
                  foregroundColor: (!_isSubmitting && _isFormValid) 
                      ? Colors.black 
                      : AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormFieldChanged);
    _descriptionController.removeListener(_onFormFieldChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}