import 'dart:io';
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
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(11),
        child: Image.file(
          imageFile,
          fit: BoxFit.contain, // Prevents distortion while filling the container
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}