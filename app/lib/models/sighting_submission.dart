import 'dart:io';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'sensor_data.dart';
import 'alerts_filter.dart';
import 'user_preferences.dart';

part 'sighting_submission.g.dart';

@JsonSerializable()
class SightingSubmission {
  final String? id;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final File? imageFile;
  final String? imagePath;
  final String title;
  final String description;
  final String category;
  final SensorData? sensorData;
  final PlaneMatchResponse? planeMatch;
  final bool userReclassifiedAsUFO;
  final LocationPrivacy locationPrivacy;
  final SubmissionStatus status;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final String? errorMessage;
  final double? uploadProgress;

  const SightingSubmission({
    this.id,
    this.imageFile,
    this.imagePath,
    required this.title,
    required this.description,
    required this.category,
    this.sensorData,
    this.planeMatch,
    this.userReclassifiedAsUFO = false,
    this.locationPrivacy = LocationPrivacy.jittered,
    this.status = SubmissionStatus.draft,
    required this.createdAt,
    this.submittedAt,
    this.errorMessage,
    this.uploadProgress,
  });

  factory SightingSubmission.fromJson(Map<String, dynamic> json) =>
      _$SightingSubmissionFromJson(json);

  Map<String, dynamic> toJson() => _$SightingSubmissionToJson(this);

  SightingSubmission copyWith({
    String? id,
    File? imageFile,
    String? imagePath,
    String? title,
    String? description,
    String? category,
    SensorData? sensorData,
    PlaneMatchResponse? planeMatch,
    bool? userReclassifiedAsUFO,
    LocationPrivacy? locationPrivacy,
    SubmissionStatus? status,
    DateTime? createdAt,
    DateTime? submittedAt,
    String? errorMessage,
    double? uploadProgress,
  }) {
    return SightingSubmission(
      id: id ?? this.id,
      imageFile: imageFile ?? this.imageFile,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      sensorData: sensorData ?? this.sensorData,
      planeMatch: planeMatch ?? this.planeMatch,
      userReclassifiedAsUFO: userReclassifiedAsUFO ?? this.userReclassifiedAsUFO,
      locationPrivacy: locationPrivacy ?? this.locationPrivacy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  bool get isReadyToSubmit {
    return imageFile != null &&
           title.trim().isNotEmpty &&
           description.trim().isNotEmpty &&
           category.isNotEmpty &&
           status == SubmissionStatus.draft;
  }

  bool get hasLocation => sensorData?.latitude != null && sensorData?.longitude != null;

  String get categoryDisplayName {
    final categoryData = AlertCategory.getByKey(category);
    return categoryData?.displayName ?? 'Unknown';
  }

  String get statusDisplayName {
    switch (status) {
      case SubmissionStatus.draft:
        return 'Draft';
      case SubmissionStatus.validating:
        return 'Validating...';
      case SubmissionStatus.uploading:
        return 'Uploading...';
      case SubmissionStatus.processing:
        return 'Processing...';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.failed:
        return 'Failed';
      case SubmissionStatus.retry:
        return 'Ready to Retry';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SightingSubmission &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          category == other.category &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, title, description, category, status);

  @override
  String toString() {
    return 'SightingSubmission{'
        'id: $id, '
        'title: $title, '
        'category: $category, '
        'status: $status, '
        'hasImage: ${imageFile != null}, '
        'hasLocation: $hasLocation'
        '}';
  }
}

enum SubmissionStatus {
  draft,
  validating,
  uploading,
  processing,
  submitted,
  failed,
  retry,
}


@JsonSerializable()
class ImageValidationResult {
  final bool isValid;
  final List<String> issues;
  final Map<String, dynamic> metadata;
  final double? qualityScore;

  const ImageValidationResult({
    required this.isValid,
    this.issues = const [],
    this.metadata = const {},
    this.qualityScore,
  });

  factory ImageValidationResult.fromJson(Map<String, dynamic> json) =>
      _$ImageValidationResultFromJson(json);

  Map<String, dynamic> toJson() => _$ImageValidationResultToJson(this);

  String get summary {
    if (isValid) {
      return qualityScore != null 
          ? 'Good quality (${(qualityScore! * 100).toInt()}%)'
          : 'Valid image';
    } else {
      return issues.isNotEmpty ? issues.first : 'Invalid image';
    }
  }
}

// Predefined categories for sighting submissions
class SightingCategory {
  static const String ufo = 'ufo';
  static const String missingPet = 'missing_pet';
  static const String missingPerson = 'missing_person';
  static const String suspicious = 'suspicious';
  static const String other = 'other';

  static List<String> get allCategories => [
    ufo,
    missingPet,
    missingPerson,
    suspicious,
    other,
  ];

  static String getDisplayName(String category) {
    final categoryData = AlertCategory.getByKey(category);
    return categoryData?.displayName ?? 'Other';
  }

  static String getDescription(String category) {
    final categoryData = AlertCategory.getByKey(category);
    return categoryData?.description ?? 'Other type of sighting';
  }
}

// Validation helpers
class SightingValidator {
  static const int minTitleLength = 5;
  static const int maxTitleLength = 100;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 1000;
  static const int maxImageSizeMB = 10;

  static List<String> validateTitle(String title) {
    final issues = <String>[];
    
    if (title.trim().isEmpty) {
      issues.add('Title is required');
    } else if (title.trim().length < minTitleLength) {
      issues.add('Title must be at least $minTitleLength characters');
    } else if (title.trim().length > maxTitleLength) {
      issues.add('Title must be no more than $maxTitleLength characters');
    }
    
    return issues;
  }

  static List<String> validateDescription(String description) {
    final issues = <String>[];
    
    if (description.trim().isEmpty) {
      issues.add('Description is required');
    } else if (description.trim().length < minDescriptionLength) {
      issues.add('Description must be at least $minDescriptionLength characters');
    } else if (description.trim().length > maxDescriptionLength) {
      issues.add('Description must be no more than $maxDescriptionLength characters');
    }
    
    return issues;
  }

  static List<String> validateCategory(String category) {
    final issues = <String>[];
    
    if (category.isEmpty) {
      issues.add('Category is required');
    } else if (!SightingCategory.allCategories.contains(category)) {
      issues.add('Invalid category selected');
    }
    
    return issues;
  }

  static Future<ImageValidationResult> validateImage(File imageFile) async {
    final issues = <String>[];
    final metadata = <String, dynamic>{};
    
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        issues.add('Image file not found');
        return ImageValidationResult(isValid: false, issues: issues);
      }

      // Check file size
      final fileSize = await imageFile.length();
      final fileSizeMB = fileSize / (1024 * 1024);
      metadata['fileSizeMB'] = fileSizeMB;
      
      if (fileSizeMB > maxImageSizeMB) {
        issues.add('Image size (${fileSizeMB.toStringAsFixed(1)}MB) exceeds limit of ${maxImageSizeMB}MB');
      }

      // Check file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      metadata['extension'] = extension;
      
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        issues.add('Unsupported image format: $extension');
      }

      // Calculate basic quality score based on file size and format
      double qualityScore = 0.5;
      if (fileSizeMB > 0.5 && fileSizeMB < 5) qualityScore += 0.3;
      if (['jpg', 'jpeg'].contains(extension)) qualityScore += 0.2;
      qualityScore = qualityScore.clamp(0.0, 1.0);

      return ImageValidationResult(
        isValid: issues.isEmpty,
        issues: issues,
        metadata: metadata,
        qualityScore: qualityScore,
      );

    } catch (e) {
      issues.add('Failed to validate image: $e');
      return ImageValidationResult(isValid: false, issues: issues);
    }
  }

  static List<String> validateSubmission(SightingSubmission submission) {
    final issues = <String>[];
    
    issues.addAll(validateTitle(submission.title));
    issues.addAll(validateDescription(submission.description));
    issues.addAll(validateCategory(submission.category));
    
    if (submission.imageFile == null) {
      issues.add('Image is required');
    }
    
    return issues;
  }
}