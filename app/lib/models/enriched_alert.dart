import 'package:json_annotation/json_annotation.dart';
import 'api_models.dart';
import 'alert_enrichment.dart';
import 'quarantine_state.dart';

part 'enriched_alert.g.dart';

/// Enriched Alert that combines API Sighting with local enrichment and quarantine data
/// This allows us to add NSFW quarantine handling without modifying the shared API contracts
@JsonSerializable()
class EnrichedAlert {
  final Sighting sighting;
  final AlertEnrichment? enrichment;
  final QuarantineState quarantine;

  const EnrichedAlert({
    required this.sighting,
    this.enrichment,
    this.quarantine = const QuarantineState(),
  });

  factory EnrichedAlert.fromJson(Map<String, dynamic> json) =>
      _$EnrichedAlertFromJson(json);

  Map<String, dynamic> toJson() => _$EnrichedAlertToJson(this);

  /// Create from a raw Sighting (from API)
  factory EnrichedAlert.fromSighting(
    Sighting sighting, {
    AlertEnrichment? enrichment,
    QuarantineState? quarantine,
  }) {
    return EnrichedAlert(
      sighting: sighting,
      enrichment: enrichment,
      quarantine: quarantine ?? const QuarantineState(),
    );
  }

  /// Delegate properties from the underlying sighting
  String get id => sighting.id;
  String get title => sighting.title;
  String get description => sighting.description;
  SightingCategory get category => sighting.category;
  SensorDataApi get sensorData => sighting.sensorData;
  List<MediaFile> get mediaFiles => sighting.mediaFiles;
  SightingStatus get status => sighting.status;
  GeoCoordinates get jitteredLocation => sighting.jitteredLocation;
  AlertLevel get alertLevel => sighting.alertLevel;
  String? get reporterId => sighting.reporterId;
  int get witnessCount => sighting.witnessCount;
  int get viewCount => sighting.viewCount;
  double get verificationScore => sighting.verificationScore;
  String? get matrixRoomId => sighting.matrixRoomId;
  DateTime get submittedAt => sighting.submittedAt;
  DateTime? get processedAt => sighting.processedAt;
  DateTime? get verifiedAt => sighting.verifiedAt;
  DateTime get createdAt => sighting.createdAt;
  DateTime get updatedAt => sighting.updatedAt;

  /// Enhanced properties that consider quarantine state
  bool get isQuarantined => quarantine.isQuarantined;
  bool get isHiddenFromPublic => quarantine.isHiddenFromPublic;
  bool get isNsfwQuarantined => quarantine.reasons.contains(QuarantineReason.nsfw);
  bool get isAwaitingReview => quarantine.isPendingReview;
  bool get isApproved => quarantine.isApproved;

  /// Check if alert should be visible based on user context
  bool isVisibleTo({
    bool isPublic = true,
    bool isReporter = false,
    bool isModerator = false,
    String? userId,
    bool showQuarantined = false,
  }) {
    // If user explicitly wants to see quarantined content and has permission
    if (showQuarantined && (isModerator || (isReporter && userId == reporterId))) {
      return true;
    }

    // Use quarantine access control
    return quarantine.hasAccess(
      isPublic: isPublic,
      isReporter: isReporter && userId == reporterId,
      isModerator: isModerator,
      userId: userId,
    );
  }

  /// Get content warning message for quarantined content
  String? get contentWarning {
    if (!isQuarantined) return null;
    
    if (isNsfwQuarantined) {
      return 'This content may contain explicit or sensitive material';
    }
    
    return 'This content has been quarantined: ${quarantine.reasonsDisplayText}';
  }

  /// Check if content analysis indicates NSFW
  bool get hasNsfwAnalysis {
    return enrichment?.contentAnalysis?.isNsfw ?? false;
  }

  /// Get NSFW confidence from content analysis
  double get nsfwConfidence {
    return enrichment?.contentAnalysis?.nsfwConfidence ?? 0.0;
  }

  /// Auto-quarantine based on content analysis
  EnrichedAlert autoQuarantineFromAnalysis({
    double nsfwThreshold = 0.7,
    double misleadingThreshold = 0.8,
  }) {
    if (enrichment?.contentAnalysis == null) return this;
    
    final analysis = enrichment!.contentAnalysis!;
    final autoQuarantine = QuarantineStateFromContentAnalysis.fromContentAnalysis(
      isNsfw: analysis.isNsfw,
      nsfwConfidence: analysis.nsfwConfidence,
      isPotentiallyMisleading: analysis.isPotentiallyMisleading,
      nsfwThreshold: nsfwThreshold,
      misleadingThreshold: misleadingThreshold,
    );

    // Only apply auto-quarantine if not already manually quarantined
    if (quarantine.isManuallyQuarantined) return this;
    
    return copyWith(quarantine: autoQuarantine);
  }

  /// Apply manual quarantine action
  EnrichedAlert applyQuarantine({
    required QuarantineAction action,
    required List<QuarantineReason> reasons,
    String? customReason,
    required String moderatorId,
    required String moderatorName,
    bool? allowReporterAccess,
    bool? allowModeratorAccess,
    Map<String, dynamic>? metadata,
  }) {
    final newQuarantine = this.quarantine.quarantine(
      action: action,
      reasons: reasons,
      customReason: customReason,
      moderatorId: moderatorId,
      moderatorName: moderatorName,
      allowReporterAccess: allowReporterAccess,
      allowModeratorAccess: allowModeratorAccess,
      metadata: metadata,
    );

    return copyWith(quarantine: newQuarantine);
  }

  /// Approve quarantined content
  EnrichedAlert approve({
    required String moderatorId,
    required String moderatorName,
    Map<String, dynamic>? metadata,
  }) {
    final approvedQuarantine = quarantine.approve(
      moderatorId: moderatorId,
      moderatorName: moderatorName,
      metadata: metadata,
    );

    return copyWith(quarantine: approvedQuarantine);
  }

  EnrichedAlert copyWith({
    Sighting? sighting,
    AlertEnrichment? enrichment,
    QuarantineState? quarantine,
  }) {
    return EnrichedAlert(
      sighting: sighting ?? this.sighting,
      enrichment: enrichment ?? this.enrichment,
      quarantine: quarantine ?? this.quarantine,
    );
  }

  /// Helper for sorting/filtering
  bool matchesFilter({
    SightingCategory? category,
    SightingStatus? status,
    AlertLevel? minAlertLevel,
    bool? verifiedOnly,
    bool includeQuarantined = false,
    bool isPublicContext = true,
    String? userId,
    bool isModerator = false,
  }) {
    // Category filter
    if (category != null && this.category != category) return false;

    // Status filter
    if (status != null && this.status != status) return false;

    // Alert level filter
    if (minAlertLevel != null) {
      final levels = AlertLevel.values;
      final currentIndex = levels.indexOf(alertLevel);
      final minIndex = levels.indexOf(minAlertLevel);
      if (currentIndex < minIndex) return false;
    }

    // Verified only filter
    if (verifiedOnly == true && status != SightingStatus.verified) return false;

    // Quarantine visibility filter
    if (!includeQuarantined && !isVisibleTo(
      isPublic: isPublicContext,
      isReporter: userId == reporterId,
      isModerator: isModerator,
      userId: userId,
    )) return false;

    return true;
  }
}