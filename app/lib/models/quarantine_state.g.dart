// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quarantine_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuarantineState _$QuarantineStateFromJson(Map<String, dynamic> json) =>
    QuarantineState(
      action:
          $enumDecodeNullable(_$QuarantineActionEnumMap, json['action']) ??
          QuarantineAction.none,
      reasons:
          (json['reasons'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$QuarantineReasonEnumMap, e))
              .toList() ??
          const [],
      customReason: json['customReason'] as String?,
      moderatorId: json['moderatorId'] as String?,
      moderatorName: json['moderatorName'] as String?,
      quarantinedAt: json['quarantinedAt'] == null
          ? null
          : DateTime.parse(json['quarantinedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      allowReporterAccess: json['allowReporterAccess'] as bool? ?? true,
      allowModeratorAccess: json['allowModeratorAccess'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$QuarantineStateToJson(QuarantineState instance) =>
    <String, dynamic>{
      'action': _$QuarantineActionEnumMap[instance.action]!,
      'reasons': instance.reasons
          .map((e) => _$QuarantineReasonEnumMap[e]!)
          .toList(),
      'customReason': instance.customReason,
      'moderatorId': instance.moderatorId,
      'moderatorName': instance.moderatorName,
      'quarantinedAt': instance.quarantinedAt?.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'confidenceScore': instance.confidenceScore,
      'allowReporterAccess': instance.allowReporterAccess,
      'allowModeratorAccess': instance.allowModeratorAccess,
      'metadata': instance.metadata,
    };

const _$QuarantineActionEnumMap = {
  QuarantineAction.none: 'none',
  QuarantineAction.pendingReview: 'pendingReview',
  QuarantineAction.hidePublic: 'hidePublic',
  QuarantineAction.approved: 'approved',
  QuarantineAction.remove: 'remove',
};

const _$QuarantineReasonEnumMap = {
  QuarantineReason.nsfw: 'nsfw',
  QuarantineReason.inappropriate: 'inappropriate',
  QuarantineReason.violence: 'violence',
  QuarantineReason.harassment: 'harassment',
  QuarantineReason.misinformation: 'misinformation',
  QuarantineReason.spam: 'spam',
  QuarantineReason.copyright: 'copyright',
  QuarantineReason.privacy: 'privacy',
  QuarantineReason.lowQuality: 'lowQuality',
  QuarantineReason.irrelevant: 'irrelevant',
  QuarantineReason.hoax: 'hoax',
  QuarantineReason.automated: 'automated',
  QuarantineReason.reported: 'reported',
  QuarantineReason.other: 'other',
};
