import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../models/sighting_submission.dart';

class PhotoPreview extends StatefulWidget {
  final File imageFile;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRetake;

  const PhotoPreview({
    super.key,
    required this.imageFile,
    this.onEdit,
    this.onDelete,
    this.onRetake,
  });

  @override
  State<PhotoPreview> createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<PhotoPreview> {
  ImageValidationResult? _validationResult;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _validateImage();
  }

  Future<void> _validateImage() async {
    setState(() {
      _isValidating = true;
    });

    try {
      final result = await SightingValidator.validateImage(widget.imageFile);
      setState(() {
        _validationResult = result;
        _isValidating = false;
      });
    } catch (e) {
      setState(() {
        _validationResult = ImageValidationResult(
          isValid: false,
          issues: ['Validation failed: $e'],
        );
        _isValidating = false;
      });
    }
  }

  void _showFullScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenPhotoViewer(
          imageFile: widget.imageFile,
          validationResult: _validationResult,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Image preview with overlay
          Expanded(
            child: Stack(
              children: [
                // Main image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: GestureDetector(
                    onTap: _showFullScreen,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Validation overlay
                if (_isValidating)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.brandPrimary),
                          SizedBox(height: 12),
                          Text(
                            'Validating image...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Top overlay with actions
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      // Validation status
                      if (_validationResult != null && !_isValidating)
                        _buildValidationBadge(),
                      
                      const Spacer(),
                      
                      // Action buttons
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _showFullScreen,
                              icon: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                              tooltip: 'View full screen',
                            ),
                            if (widget.onEdit != null)
                              IconButton(
                                onPressed: widget.onEdit,
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Edit photo',
                              ),
                            if (widget.onDelete != null)
                              IconButton(
                                onPressed: () => _showDeleteConfirmation(),
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.semanticError,
                                  size: 20,
                                ),
                                tooltip: 'Delete photo',
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom overlay with image info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: _buildImageInfo(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                // Explanatory text
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.brandPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.send,
                        color: AppColors.brandPrimary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'This will be sent with your beep',
                        style: TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Action buttons
                Row(
                  children: [
                    if (widget.onRetake != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onRetake,
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Retake'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.darkBorder),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    
                    if (widget.onRetake != null) const SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _validationResult?.isValid == true 
                            ? _showFullScreen 
                            : null,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Preview'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationBadge() {
    final result = _validationResult!;
    final isValid = result.isValid;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isValid ? AppColors.brandPrimary : AppColors.semanticError,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: isValid ? Colors.black : Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            result.summary,
            style: TextStyle(
              color: isValid ? Colors.black : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageInfo() {
    return FutureBuilder<int>(
      future: widget.imageFile.length(),
      builder: (context, snapshot) {
        final fileSize = snapshot.data;
        final fileSizeMB = fileSize != null ? fileSize / (1024 * 1024) : null;
        
        return Row(
          children: [
            const Icon(
              Icons.image,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.imageFile.path.split('/').last,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileSizeMB != null)
                    Text(
                      '${fileSizeMB.toStringAsFixed(1)} MB',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getBorderColor() {
    if (_isValidating) return AppColors.brandPrimary;
    if (_validationResult?.isValid == true) return AppColors.brandPrimary;
    if (_validationResult?.isValid == false) return AppColors.semanticError;
    return AppColors.darkBorder;
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Delete Photo?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This action cannot be undone. You\'ll need to take a new photo.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.semanticError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class FullScreenPhotoViewer extends StatefulWidget {
  final File imageFile;
  final ImageValidationResult? validationResult;

  const FullScreenPhotoViewer({
    super.key,
    required this.imageFile,
    this.validationResult,
  });

  @override
  State<FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<FullScreenPhotoViewer> {
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Full screen image
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showOverlay = !_showOverlay;
                  });
                },
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Overlay controls
            if (_showOverlay) ...[
              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _shareImage(),
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.validationResult != null) ...[
                        Row(
                          children: [
                            Icon(
                              widget.validationResult!.isValid 
                                  ? Icons.check_circle 
                                  : Icons.error,
                              color: widget.validationResult!.isValid 
                                  ? AppColors.brandPrimary 
                                  : AppColors.semanticError,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.validationResult!.summary,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        
                        if (widget.validationResult!.issues.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...widget.validationResult!.issues.map((issue) => 
                            Padding(
                              padding: const EdgeInsets.only(left: 28, bottom: 4),
                              child: Text(
                                '• $issue',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 12),
                      ],
                      
                      const Text(
                        'Tap to hide controls • Pinch to zoom',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _shareImage() {
    // TODO: Implement image sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image sharing coming soon'),
        backgroundColor: AppColors.brandPrimary,
      ),
    );
  }
}