import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../models/sensor_data.dart';
import '../../models/sighting_submission.dart' as local;
import '../../models/alerts_filter.dart';
import '../../models/api_models.dart' as api;
import '../../services/api_client.dart';
import '../../widgets/plane_badge.dart';
import '../../widgets/simple_photo_display.dart';

class BeepCompositionScreen extends StatefulWidget {
  final File imageFile;
  final SensorData? sensorData;
  final PlaneMatchResponse? planeMatch;

  const BeepCompositionScreen({
    super.key,
    required this.imageFile,
    this.sensorData,
    this.planeMatch,
  });

  @override
  State<BeepCompositionScreen> createState() => _BeepCompositionScreenState();
}

class _BeepCompositionScreenState extends State<BeepCompositionScreen> {
  // Form controllers and state
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = local.SightingCategory.ufo;
  // Use default privacy setting - will be moved to user profile
  local.LocationPrivacy _locationPrivacy = local.LocationPrivacy.jittered;
  
  // Submission state
  bool _isSubmitting = false;
  PlaneMatchResponse? _planeMatch;
  bool _userReclassifiedAsUFO = false;
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
    _planeMatch = widget.planeMatch;
    
    // Add listeners for real-time validation
    _titleController.addListener(_onFormFieldChanged);
    _descriptionController.addListener(_onFormFieldChanged);
  }

  void _onFormFieldChanged() {
    setState(() {});
    debugPrint('Form validation: title=${_titleController.text.length} chars, desc=${_descriptionController.text.length} chars, valid=$_isFormValid');
  }

  Future<void> _submitBeep() async {
    if (!_isFormValid || _isSubmitting) return;

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

      // Determine category based on plane match results
      api.SightingCategory category = api.SightingCategory.ufo;
      List<String> tags = [];
      
      if (_userReclassifiedAsUFO) {
        category = api.SightingCategory.ufo;
        tags.add('user-reclassified');
      } else if (_planeMatch?.isPlane == true && _planeMatch!.confidence > 0.7) {
        category = api.SightingCategory.anomaly; // Classify likely planes as anomalies for review
        tags.add('likely-aircraft');
        final flight = _planeMatch!.matchedFlight;
        if (flight != null) {
          tags.add('flight-${flight.callsign}');
        }
      } else if (_planeMatch?.isPlane == true) {
        category = api.SightingCategory.ufo; // Low confidence planes still get UFO category
        tags.add('possible-aircraft');
      }

      // Add plane match confidence as tag
      if (_planeMatch != null) {
        final confidence = (_planeMatch!.confidence * 100).round();
        tags.add('confidence-$confidence');
      }

      // Submit sighting with media using API client
      final sightingId = await ApiClient.instance.submitSightingWithMedia(
        title: title,
        description: description,
        category: category,
        sensorData: widget.sensorData,
        mediaFiles: [widget.imageFile],
        witnessCount: 1,
        tags: tags,
        isPublic: _locationPrivacy != local.LocationPrivacy.hidden,
        onProgress: (progress) {
          debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      // Determine classification for user feedback
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

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beep "$title" sent successfully as $classification$additionalInfo\n\nSighting ID: $sightingId'),
            backgroundColor: classification.contains('Aircraft') 
                ? AppColors.semanticWarning 
                : AppColors.brandPrimary,
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate back to beep screen
        context.go('/beep');
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

  void _retakePhoto() {
    context.go('/beep');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=== BeepCompositionScreen.build() START ===');
    debugPrint('ImageFile exists: ${widget.imageFile.existsSync()}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Beep'),
        backgroundColor: Colors.red, // Bright red for visibility test
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _retakePhoto,
          tooltip: 'Retake Photo',
        ),
      ),
      backgroundColor: Colors.green, // Bright green background for visibility test
      body: Container(
        color: Colors.yellow, // Bright yellow container
        child: Column(
          children: [
            Container(
              height: 100,
              color: Colors.blue,
              child: Center(
                child: Text(
                  'PHOTO SECTION TEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.orange,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPhotoSection(),
                      SizedBox(height: 10),
                      
                      // Add simple form fields with bright backgrounds
                      Container(
                        width: 300,
                        padding: EdgeInsets.all(12),
                        color: Colors.purple,
                        child: Column(
                          children: [
                            Text('FORM FIELDS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            TextField(
                              controller: _titleController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Title...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _descriptionController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Description...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isFormValid && !_isSubmitting ? () async {
                          debugPrint('Submit button pressed');
                          debugPrint('Title: ${_titleController.text}');
                          debugPrint('Description: ${_descriptionController.text}');
                          await _submitBeep();
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid && !_isSubmitting ? Colors.blue : Colors.grey,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: _isSubmitting 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _isFormValid ? 'SEND BEEP' : 'FILL FORM',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
    );
  }

  Widget _buildPhotoSection() {
    debugPrint('=== PHOTO SECTION DEBUG ===');
    debugPrint('Image file exists: ${widget.imageFile.existsSync()}');
    debugPrint('Image file path: ${widget.imageFile.path}');
    debugPrint('Image file size: ${widget.imageFile.lengthSync()} bytes');
    debugPrint('===========================');
    
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

  Widget _buildPlaneMatchSection() {
    if (_planeMatch == null) return const SizedBox();

    if (_userReclassifiedAsUFO) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.semanticWarning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.semanticWarning, width: 1.5),
        ),
        child: const Row(
          children: [
            Icon(Icons.flag, color: AppColors.semanticWarning),
            SizedBox(width: 12),
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
      );
    }

    return PlaneBadge(
      planeMatch: _planeMatch!,
      onReclassify: _reclassifyAsUFO,
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
          maxLength: local.SightingValidator.maxTitleLength,
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
          maxLength: local.SightingValidator.maxDescriptionLength,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
            ),
            dropdownColor: AppColors.darkSurface,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            items: local.SightingCategory.allCategories.map((category) {
              final categoryData = AlertCategory.getByKey(category);
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: categoryData?.icon != null
                          ? Text(
                              categoryData!.icon,
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            )
                          : const Icon(
                              Icons.help,
                              color: AppColors.brandPrimary,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            local.SightingCategory.getDisplayName(category),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            local.SightingCategory.getDescription(category),
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
              }
            },
          ),
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
            fontSize: 18,
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
            children: local.LocationPrivacy.values.map((privacy) {
              final isSelected = _locationPrivacy == privacy;
              return InkWell(
                onTap: () {
                  setState(() {
                    _locationPrivacy = privacy;
                  });
                },
                borderRadius: BorderRadius.circular(12),
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
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              privacy.displayName,
                              style: TextStyle(
                                color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              privacy.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.brandPrimary,
                          size: 24,
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
                onPressed: (!_isSubmitting && _isFormValid) ? _submitBeep : null,
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