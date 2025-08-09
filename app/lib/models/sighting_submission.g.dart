// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sighting_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SightingSubmission _$SightingSubmissionFromJson(
  Map<String, dynamic> json,
) => SightingSubmission(
  id: json['id'] as String?,
  imagePath: json['imagePath'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  sensorData: json['sensorData'] == null
      ? null
      : SensorData.fromJson(json['sensorData'] as Map<String, dynamic>),
  planeMatch: json['planeMatch'] == null
      ? null
      : PlaneMatchResponse.fromJson(json['planeMatch'] as Map<String, dynamic>),
  userReclassifiedAsUFO: json['userReclassifiedAsUFO'] as bool? ?? false,
  locationPrivacy:
      $enumDecodeNullable(_$LocationPrivacyEnumMap, json['locationPrivacy']) ??
      LocationPrivacy.jittered,
  status:
      $enumDecodeNullable(_$SubmissionStatusEnumMap, json['status']) ??
      SubmissionStatus.draft,
  createdAt: DateTime.parse(json['createdAt'] as String),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  errorMessage: json['errorMessage'] as String?,
  uploadProgress: (json['uploadProgress'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SightingSubmissionToJson(SightingSubmission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imagePath': instance.imagePath,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'sensorData': instance.sensorData,
      'planeMatch': instance.planeMatch,
      'userReclassifiedAsUFO': instance.userReclassifiedAsUFO,
      'locationPrivacy': _$LocationPrivacyEnumMap[instance.locationPrivacy]!,
      'status': _$SubmissionStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'uploadProgress': instance.uploadProgress,
    };

const _$LocationPrivacyEnumMap = {
  LocationPrivacy.exact: 'exact',
  LocationPrivacy.jittered: 'jittered',
  LocationPrivacy.approximate: 'approximate',
  LocationPrivacy.hidden: 'hidden',
};

const _$SubmissionStatusEnumMap = {
  SubmissionStatus.draft: 'draft',
  SubmissionStatus.validating: 'validating',
  SubmissionStatus.uploading: 'uploading',
  SubmissionStatus.processing: 'processing',
  SubmissionStatus.submitted: 'submitted',
  SubmissionStatus.failed: 'failed',
  SubmissionStatus.retry: 'retry',
};

ImageValidationResult _$ImageValidationResultFromJson(
  Map<String, dynamic> json,
) => ImageValidationResult(
  isValid: json['isValid'] as bool,
  issues:
      (json['issues'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  qualityScore: (json['qualityScore'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ImageValidationResultToJson(
  ImageValidationResult instance,
) => <String, dynamic>{
  'isValid': instance.isValid,
  'issues': instance.issues,
  'metadata': instance.metadata,
  'qualityScore': instance.qualityScore,
};
