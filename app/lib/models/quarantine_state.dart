import 'package:json_annotation/json_annotation.dart';

part 'quarantine_state.g.dart';

/// Quarantine state for NSFW and inappropriate content handling
/// Allows hiding content from public view while preserving access for reporters and moderators
@JsonSerializable()
class QuarantineState {
  final QuarantineAction action;
  final List<QuarantineReason> reasons;
  final String? customReason;
  final String? moderatorId;
  final String? moderatorName;
  final DateTime? quarantinedAt;
  final DateTime? reviewedAt;
  final double? confidenceScore;
  final bool allowReporterAccess;
  final bool allowModeratorAccess;
  final Map<String, dynamic> metadata;

  const QuarantineState({
    this.action = QuarantineAction.none,
    this.reasons = const [],
    this.customReason,
    this.moderatorId,
    this.moderatorName,
    this.quarantinedAt,
    this.reviewedAt,
    this.confidenceScore,
    this.allowReporterAccess = true,
    this.allowModeratorAccess = true,
    this.metadata = const {},
  });

  factory QuarantineState.fromJson(Map<String, dynamic> json) =>
      _$QuarantineStateFromJson(json);

  Map<String, dynamic> toJson() => _$QuarantineStateToJson(this);

  /// Getters for quarantine status
  bool get isQuarantined => action != QuarantineAction.none;
  bool get isHiddenFromPublic => action == QuarantineAction.hidePublic || 
      action == QuarantineAction.remove || action == QuarantineAction.pendingReview;
  bool get isRemoved => action == QuarantineAction.remove;
  bool get isPendingReview => action == QuarantineAction.pendingReview;
  bool get isApproved => action == QuarantineAction.approved;
  bool get isAutoQuarantined => moderatorId == null && isQuarantined;
  bool get isManuallyQuarantined => moderatorId != null && isQuarantined;
  
  /// Check if user has access based on their role
  bool hasAccess({
    bool isPublic = true,
    bool isReporter = false, 
    bool isModerator = false,
    String? userId,
  }) {
    // Not quarantined - everyone has access
    if (!isQuarantined) return true;
    
    // Moderators always have access if allowed
    if (isModerator && allowModeratorAccess) return true;
    
    // Reporter has access if they reported it and it's allowed
    if (isReporter && allowReporterAccess) return true;
    
    // Approved content is accessible to everyone
    if (isApproved) return true;
    
    // Public users cannot access quarantined content
    if (isPublic && isHiddenFromPublic) return false;
    
    // Default allow if not hidden from public
    return !isHiddenFromPublic;
  }

  /// Get the primary reason for quarantine
  QuarantineReason get primaryReason => reasons.isNotEmpty ? reasons.first : QuarantineReason.other;

  /// Get display text for the quarantine action
  String get actionDisplayName {
    switch (action) {
      case QuarantineAction.none:
        return 'Not Quarantined';
      case QuarantineAction.pendingReview:
        return 'Pending Review';
      case QuarantineAction.hidePublic:
        return 'Hidden from Public';
      case QuarantineAction.approved:
        return 'Approved';
      case QuarantineAction.remove:
        return 'Removed';
    }
  }

  /// Get display text for reasons
  String get reasonsDisplayText {
    if (customReason?.isNotEmpty == true) {
      return customReason!;
    }
    if (reasons.isEmpty) return 'No reason specified';
    if (reasons.length == 1) return reasons.first.displayName;
    return '${reasons.first.displayName} and ${reasons.length - 1} more';
  }

  /// Create a quarantined state
  QuarantineState quarantine({
    required QuarantineAction action,
    required List<QuarantineReason> reasons,
    String? customReason,
    String? moderatorId,
    String? moderatorName,
    double? confidenceScore,
    bool? allowReporterAccess,
    bool? allowModeratorAccess,
    Map<String, dynamic>? metadata,
  }) {
    return QuarantineState(
      action: action,
      reasons: reasons,
      customReason: customReason,
      moderatorId: moderatorId,
      moderatorName: moderatorName,
      quarantinedAt: DateTime.now(),
      reviewedAt: moderatorId != null ? DateTime.now() : null,
      confidenceScore: confidenceScore,
      allowReporterAccess: allowReporterAccess ?? this.allowReporterAccess,
      allowModeratorAccess: allowModeratorAccess ?? this.allowModeratorAccess,
      metadata: {...this.metadata, ...?metadata},
    );
  }

  /// Create an approved state (after review)
  QuarantineState approve({
    String? moderatorId,
    String? moderatorName,
    Map<String, dynamic>? metadata,
  }) {
    return QuarantineState(
      action: QuarantineAction.approved,
      reasons: reasons,
      customReason: customReason,
      moderatorId: moderatorId ?? this.moderatorId,
      moderatorName: moderatorName ?? this.moderatorName,
      quarantinedAt: quarantinedAt,
      reviewedAt: DateTime.now(),
      confidenceScore: confidenceScore,
      allowReporterAccess: allowReporterAccess,
      allowModeratorAccess: allowModeratorAccess,
      metadata: {...this.metadata, ...?metadata},
    );
  }

  QuarantineState copyWith({
    QuarantineAction? action,
    List<QuarantineReason>? reasons,
    String? customReason,
    String? moderatorId,
    String? moderatorName,
    DateTime? quarantinedAt,
    DateTime? reviewedAt,
    double? confidenceScore,
    bool? allowReporterAccess,
    bool? allowModeratorAccess,
    Map<String, dynamic>? metadata,
  }) {
    return QuarantineState(
      action: action ?? this.action,
      reasons: reasons ?? this.reasons,
      customReason: customReason ?? this.customReason,
      moderatorId: moderatorId ?? this.moderatorId,
      moderatorName: moderatorName ?? this.moderatorName,
      quarantinedAt: quarantinedAt ?? this.quarantinedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      allowReporterAccess: allowReporterAccess ?? this.allowReporterAccess,
      allowModeratorAccess: allowModeratorAccess ?? this.allowModeratorAccess,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Actions that can be taken for quarantined content
enum QuarantineAction {
  none,           // Not quarantined
  pendingReview,  // Automatically quarantined, pending manual review
  hidePublic,     // Hidden from public view, but accessible to reporter/mods
  approved,       // Reviewed and approved for public display
  remove,         // Completely removed (but kept for audit trail)
}

/// Reasons why content might be quarantined
enum QuarantineReason {
  nsfw,                 // Sexually explicit or suggestive content
  inappropriate,        // Generally inappropriate but not explicit
  violence,            // Contains violent or disturbing imagery
  harassment,          // Targets or harasses individuals
  misinformation,      // Contains false or misleading information
  spam,               // Low quality or repetitive content
  copyright,          // Potential copyright violation
  privacy,            // Contains personal/private information
  lowQuality,         // Poor image quality or unclear content
  irrelevant,         // Not related to UAP/UFO sightings
  hoax,              // Likely fabricated or staged content
  automated,         // Flagged by automated systems
  reported,          // User reported content
  other,             // Other reason (custom reason should be provided)
}

extension QuarantineReasonExtension on QuarantineReason {
  String get displayName {
    switch (this) {
      case QuarantineReason.nsfw:
        return 'Explicit Content';
      case QuarantineReason.inappropriate:
        return 'Inappropriate';
      case QuarantineReason.violence:
        return 'Violent Content';
      case QuarantineReason.harassment:
        return 'Harassment';
      case QuarantineReason.misinformation:
        return 'Misinformation';
      case QuarantineReason.spam:
        return 'Spam';
      case QuarantineReason.copyright:
        return 'Copyright';
      case QuarantineReason.privacy:
        return 'Privacy Violation';
      case QuarantineReason.lowQuality:
        return 'Low Quality';
      case QuarantineReason.irrelevant:
        return 'Off Topic';
      case QuarantineReason.hoax:
        return 'Likely Hoax';
      case QuarantineReason.automated:
        return 'Auto-Flagged';
      case QuarantineReason.reported:
        return 'User Reported';
      case QuarantineReason.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case QuarantineReason.nsfw:
        return 'Content contains sexually explicit or suggestive material';
      case QuarantineReason.inappropriate:
        return 'Content is inappropriate for general audiences';
      case QuarantineReason.violence:
        return 'Content contains violent or disturbing imagery';
      case QuarantineReason.harassment:
        return 'Content targets or harasses individuals or groups';
      case QuarantineReason.misinformation:
        return 'Content contains false or misleading information';
      case QuarantineReason.spam:
        return 'Low quality, repetitive, or spam content';
      case QuarantineReason.copyright:
        return 'Content may violate copyright or intellectual property';
      case QuarantineReason.privacy:
        return 'Content exposes private or personal information';
      case QuarantineReason.lowQuality:
        return 'Poor image quality or unclear content';
      case QuarantineReason.irrelevant:
        return 'Content is not related to UAP/UFO sightings';
      case QuarantineReason.hoax:
        return 'Content appears to be fabricated or staged';
      case QuarantineReason.automated:
        return 'Content was flagged by automated content analysis';
      case QuarantineReason.reported:
        return 'Content was reported by community members';
      case QuarantineReason.other:
        return 'Other policy violation or concern';
    }
  }

  /// Get severity level for UI styling (0-3, higher is more severe)
  int get severity {
    switch (this) {
      case QuarantineReason.nsfw:
      case QuarantineReason.violence:
      case QuarantineReason.harassment:
        return 3; // High severity
      case QuarantineReason.inappropriate:
      case QuarantineReason.misinformation:
      case QuarantineReason.privacy:
      case QuarantineReason.copyright:
        return 2; // Medium severity
      case QuarantineReason.spam:
      case QuarantineReason.hoax:
      case QuarantineReason.irrelevant:
      case QuarantineReason.reported:
        return 1; // Low severity
      case QuarantineReason.lowQuality:
      case QuarantineReason.automated:
      case QuarantineReason.other:
        return 0; // Minimal severity
    }
  }
}

/// Extension to help with NSFW auto-quarantine from ContentAnalysis
extension QuarantineStateFromContentAnalysis on QuarantineState {
  /// Create quarantine state from content analysis results
  static QuarantineState fromContentAnalysis({
    required bool isNsfw,
    required double nsfwConfidence,
    required bool isPotentiallyMisleading,
    double nsfwThreshold = 0.7,
    double misleadingThreshold = 0.8,
  }) {
    final reasons = <QuarantineReason>[];
    var action = QuarantineAction.none;
    
    if (isNsfw && nsfwConfidence >= nsfwThreshold) {
      reasons.add(QuarantineReason.nsfw);
      action = QuarantineAction.hidePublic;
    }
    
    if (isPotentiallyMisleading) {
      reasons.add(QuarantineReason.misinformation);
      if (action == QuarantineAction.none) {
        action = QuarantineAction.pendingReview;
      }
    }
    
    return QuarantineState(
      action: action,
      reasons: reasons,
      quarantinedAt: action != QuarantineAction.none ? DateTime.now() : null,
      confidenceScore: nsfwConfidence,
      metadata: {
        'auto_quarantine': true,
        'nsfw_confidence': nsfwConfidence,
        'misleading_detected': isPotentiallyMisleading,
      },
    );
  }
}