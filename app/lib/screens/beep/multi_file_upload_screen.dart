import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/comments_service.dart';
import '../../services/ui_feedback.dart';

class MultiFileUploadScreen extends StatefulWidget {
  const MultiFileUploadScreen({
    super.key,
    required this.files,
    required this.alertId,
    this.onUploadComplete,
  });

  final List<PlatformFile> files;
  final String alertId;
  final VoidCallback? onUploadComplete;

  @override
  State<MultiFileUploadScreen> createState() => _MultiFileUploadScreenState();
}

class _MultiFileUploadScreenState extends State<MultiFileUploadScreen> {
  List<PlatformFile> _selectedFiles = [];
  Map<String, double> _uploadProgress = {};
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedFiles = List.from(widget.files);
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _uploadProgress.clear();
    });

    try {
      int successCount = 0;
      
      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        final fileName = file.name;
        
        if (file.path == null) {
          debugPrint('Skipping file $fileName: No file path available');
          continue;
        }

        setState(() {
          _uploadProgress[fileName] = 0.0;
        });

        try {
          debugPrint('Uploading file ${i + 1}/${_selectedFiles.length}: $fileName');
          
          await ApiClient.instance.uploadMediaToSighting(
            widget.alertId, 
            File(file.path!)
          );
          
          setState(() {
            _uploadProgress[fileName] = 1.0;
          });
          
          successCount++;
          debugPrint('Successfully uploaded $fileName');
          
        } catch (e) {
          debugPrint('Failed to upload $fileName: $e');
          setState(() {
            _uploadProgress[fileName] = -1.0; // Mark as error
          });
        }
      }

      // Create auto-comment if any files uploaded successfully
      if (successCount > 0) {
        try {
          final commentsService = CommentsService();
          final mediaType = successCount == 1 ? 'file' : 'files';
          await commentsService.postComment(
            widget.alertId, 
            'Added $successCount more $mediaType'
          );
          debugPrint('Created auto-comment for $successCount uploaded files');
        } catch (e) {
          debugPrint('Failed to create auto-comment: $e');
        }
      }

      // Show success message and navigate back
      if (successCount > 0) {
        await UiFeedback.click();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully uploaded $successCount file${successCount == 1 ? '' : 's'}'),
              backgroundColor: AppColors.semanticSuccess,
            ),
          );
          widget.onUploadComplete?.call(); // Trigger refresh callback
          context.pop(); // Return to alert detail screen
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to upload any files. Please try again.';
        });
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'Upload failed: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Add Media to Alert'),
        backgroundColor: AppColors.darkSurface,
        leading: _isUploading ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.semanticError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.semanticError.withOpacity(0.3)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.semanticError),
              ),
            ),
          
          Expanded(
            child: _selectedFiles.isEmpty
                ? const Center(
                    child: Text(
                      'No files selected',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      return _buildFilePreview(index);
                    },
                  ),
          ),
          
          // Upload button
          if (_selectedFiles.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Uploading...', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : Text(
                        'Upload ${_selectedFiles.length} file${_selectedFiles.length == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(int index) {
    final file = _selectedFiles[index];
    final fileName = file.name;
    final fileSize = file.size;
    final progress = _uploadProgress[fileName];
    
    // Determine if it's an image or video
    final isImage = file.extension?.toLowerCase() != null && 
        ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(file.extension!.toLowerCase());
    final isVideo = file.extension?.toLowerCase() != null && 
        ['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', '3gp'].contains(file.extension!.toLowerCase());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: progress != null && progress < 0 
              ? AppColors.semanticError.withOpacity(0.3)
              : AppColors.darkBorder,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // File preview/icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: file.path != null && isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(file.path!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image,
                                color: AppColors.textSecondary,
                                size: 30,
                              );
                            },
                          ),
                        )
                      : Icon(
                          isVideo ? Icons.video_file : Icons.insert_drive_file,
                          color: AppColors.textSecondary,
                          size: 30,
                        ),
                ),
                
                const SizedBox(width: 12),
                
                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(fileSize),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      
                      // Progress indicator
                      if (progress != null) ...[
                        const SizedBox(height: 8),
                        if (progress >= 0 && progress < 1)
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.darkBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                          )
                        else if (progress == 1.0)
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: AppColors.semanticSuccess, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Uploaded',
                                style: TextStyle(color: AppColors.semanticSuccess, fontSize: 12),
                              ),
                            ],
                          )
                        else if (progress < 0)
                          const Row(
                            children: [
                              Icon(Icons.error, color: AppColors.semanticError, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Failed',
                                style: TextStyle(color: AppColors.semanticError, fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ],
                  ),
                ),
                
                // Remove button (only show if not uploading)
                if (!_isUploading && progress == null)
                  IconButton(
                    onPressed: () => _removeFile(index),
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.semanticError,
                    ),
                  ),
              ],
            ),
          ),
          
          // Upload overlay
          if (progress != null && progress >= 0 && progress < 1)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}