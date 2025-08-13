import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SimplePhotoDisplay extends StatelessWidget {
  final File imageFile;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const SimplePhotoDisplay({
    super.key,
    required this.imageFile,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Debug file existence
    final fileExists = imageFile.existsSync();
    debugPrint('SimplePhotoDisplay: File exists: $fileExists, Path: ${imageFile.path}');
    
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder, width: 2),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(11),
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.semanticError.withOpacity(0.2),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: AppColors.semanticError, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Image Load Error',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}