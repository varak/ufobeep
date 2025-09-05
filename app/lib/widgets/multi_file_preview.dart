import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MultiFilePreview extends StatelessWidget {
  final List<Map<String, dynamic>> mediaFiles;
  final Function(int index)? onRemove;
  final Function(int oldIndex, int newIndex)? onReorder;
  final bool allowEdit;

  const MultiFilePreview({
    super.key,
    required this.mediaFiles,
    this.onRemove,
    this.onReorder,
    this.allowEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with file count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.photo_library,
                color: AppColors.brandPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${mediaFiles.length} ${mediaFiles.length == 1 ? 'file' : 'files'} selected',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (allowEdit && mediaFiles.length > 1) ...[
                const Spacer(),
                Text(
                  'Tap to remove',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Horizontal scrollable preview
        Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mediaFiles.length,
            itemBuilder: (context, index) {
              final fileData = mediaFiles[index];
              final File mediaFile = fileData['mediaFile'];
              final bool isVideo = fileData['isVideo'] ?? false;
              final String fileName = mediaFile.path.split('/').last;
              
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: index == 0 
                        ? AppColors.brandPrimary 
                        : AppColors.darkBorder,
                    width: index == 0 ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // File preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: AppColors.darkBackground,
                        child: _buildFilePreview(mediaFile, isVideo),
                      ),
                    ),
                    
                    // Primary indicator
                    if (index == 0)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4, 
                            vertical: 2
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    
                    // Video indicator
                    if (isVideo)
                      const Positioned(
                        bottom: 4,
                        left: 4,
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    
                    // Remove button
                    if (allowEdit && mediaFiles.length > 1)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => onRemove?.call(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.semanticError,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // File details
        if (mediaFiles.length == 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _buildFileDetails(mediaFiles.first),
          ),
      ],
    );
  }

  Widget _buildFilePreview(File mediaFile, bool isVideo) {
    if (isVideo) {
      // Show video icon for videos
      return const Center(
        child: Icon(
          Icons.videocam,
          color: AppColors.brandPrimary,
          size: 24,
        ),
      );
    } else {
      // Show image thumbnail for images
      return Image.file(
        mediaFile,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.broken_image,
              color: AppColors.textTertiary,
              size: 24,
            ),
          );
        },
      );
    }
  }

  Widget _buildFileDetails(Map<String, dynamic> fileData) {
    final File mediaFile = fileData['mediaFile'];
    final bool isVideo = fileData['isVideo'] ?? false;
    
    // Generate user-friendly display name instead of technical filename
    String displayName;
    if (isVideo) {
      displayName = 'Video';
    } else {
      displayName = 'Photo';
    }
    
    // Add number if we have multiple files of same type
    // This will be handled by parent widget context if needed
    
    // Get file size
    String fileSize = '';
    try {
      final int bytes = mediaFile.lengthSync();
      if (bytes < 1024) {
        fileSize = '$bytes B';
      } else if (bytes < 1024 * 1024) {
        fileSize = '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      fileSize = 'Unknown size';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(
            isVideo ? Icons.videocam : Icons.image,
            color: AppColors.brandPrimary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$fileSize • ${isVideo ? 'Video' : 'Image'}',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}