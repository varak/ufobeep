import 'package:flutter_test/flutter_test.dart';
import 'package:ufobeep/models/api_models.dart';
import 'package:ufobeep/models/alert_enrichment.dart';
import 'package:ufobeep/models/enriched_alert.dart';
import 'package:ufobeep/models/quarantine_state.dart';

void main() {
  group('NSFW Quarantine System Tests', () {
    late Sighting baseSighting;
    late EnrichedAlert baseAlert;

    setUp(() {
      baseSighting = Sighting(
        id: 'test-alert-1',
        title: 'UFO Sighting',
        description: 'Observed bright light in sky',
        category: SightingCategory.ufo,
        sensorData: SensorDataApi(
          timestamp: DateTime.now(),
          location: const GeoCoordinates(latitude: 40.7128, longitude: -74.0060),
          azimuthDeg: 90.0,
          pitchDeg: 45.0,
        ),
        status: SightingStatus.pending,
        jitteredLocation: const GeoCoordinates(latitude: 40.7128, longitude: -74.0060),
        alertLevel: AlertLevel.medium,
        witnessCount: 1,
        viewCount: 0,
        verificationScore: 0.5,
        reporterId: 'reporter-123',
        submittedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      baseAlert = EnrichedAlert.fromSighting(baseSighting);
    });

    group('QuarantineState Model Tests', () {
      test('creates default non-quarantined state', () {
        const quarantine = QuarantineState();
        
        expect(quarantine.isQuarantined, isFalse);
        expect(quarantine.isHiddenFromPublic, isFalse);
        expect(quarantine.action, equals(QuarantineAction.none));
        expect(quarantine.reasons, isEmpty);
      });

      test('correctly identifies quarantine states', () {
        const nsfwQuarantine = QuarantineState(
          action: QuarantineAction.hidePublic,
          reasons: [QuarantineReason.nsfw],
        );

        expect(nsfwQuarantine.isQuarantined, isTrue);
        expect(nsfwQuarantine.isHiddenFromPublic, isTrue);
        expect(nsfwQuarantine.primaryReason, equals(QuarantineReason.nsfw));
        expect(nsfwQuarantine.actionDisplayName, equals('Hidden from Public'));
      });

      test('handles access control correctly', () {
        const quarantine = QuarantineState(
          action: QuarantineAction.hidePublic,
          reasons: [QuarantineReason.nsfw],
        );

        // Public users should not have access
        expect(quarantine.hasAccess(isPublic: true), isFalse);
        
        // Moderators should have access
        expect(quarantine.hasAccess(isModerator: true), isTrue);
        
        // Reporters should have access (if allowed)
        expect(quarantine.hasAccess(isReporter: true, isPublic: false), isTrue);
        
        // Approved content should be accessible
        const approved = QuarantineState(action: QuarantineAction.approved);
        expect(approved.hasAccess(isPublic: true), isTrue);
      });

      test('creates quarantine from content analysis', () {
        final autoQuarantine = QuarantineStateFromContentAnalysis.fromContentAnalysis(
          isNsfw: true,
          nsfwConfidence: 0.85,
          isPotentiallyMisleading: false,
        );

        expect(autoQuarantine.isQuarantined, isTrue);
        expect(autoQuarantine.action, equals(QuarantineAction.hidePublic));
        expect(autoQuarantine.reasons, contains(QuarantineReason.nsfw));
        expect(autoQuarantine.confidenceScore, equals(0.85));
        expect(autoQuarantine.isAutoQuarantined, isTrue);
      });

      test('handles low confidence NSFW content', () {
        final lowConfidence = QuarantineStateFromContentAnalysis.fromContentAnalysis(
          isNsfw: true,
          nsfwConfidence: 0.5, // Below default threshold of 0.7
          isPotentiallyMisleading: false,
        );

        expect(lowConfidence.isQuarantined, isFalse);
        expect(lowConfidence.action, equals(QuarantineAction.none));
      });

      test('quarantines misleading content for review', () {
        final misleading = QuarantineStateFromContentAnalysis.fromContentAnalysis(
          isNsfw: false,
          nsfwConfidence: 0.3,
          isPotentiallyMisleading: true,
        );

        expect(misleading.isQuarantined, isTrue);
        expect(misleading.action, equals(QuarantineAction.pendingReview));
        expect(misleading.reasons, contains(QuarantineReason.misinformation));
      });
    });

    group('QuarantineReason Extension Tests', () {
      test('provides correct display names', () {
        expect(QuarantineReason.nsfw.displayName, equals('Explicit Content'));
        expect(QuarantineReason.violence.displayName, equals('Violent Content'));
        expect(QuarantineReason.harassment.displayName, equals('Harassment'));
        expect(QuarantineReason.spam.displayName, equals('Spam'));
      });

      test('provides correct severity levels', () {
        expect(QuarantineReason.nsfw.severity, equals(3)); // High severity
        expect(QuarantineReason.violence.severity, equals(3)); // High severity
        expect(QuarantineReason.inappropriate.severity, equals(2)); // Medium severity
        expect(QuarantineReason.spam.severity, equals(1)); // Low severity
        expect(QuarantineReason.lowQuality.severity, equals(0)); // Minimal severity
      });

      test('provides helpful descriptions', () {
        expect(QuarantineReason.nsfw.description, contains('sexually explicit'));
        expect(QuarantineReason.harassment.description, contains('targets or harasses'));
        expect(QuarantineReason.misinformation.description, contains('false or misleading'));
      });
    });

    group('EnrichedAlert Quarantine Tests', () {
      test('creates alert without quarantine by default', () {
        expect(baseAlert.isQuarantined, isFalse);
        expect(baseAlert.isHiddenFromPublic, isFalse);
        expect(baseAlert.contentWarning, isNull);
      });

      test('applies auto-quarantine from content analysis', () {
        final analysis = ContentAnalysis(
          isNsfw: true,
          nsfwConfidence: 0.9,
          detectedObjects: ['explicit_content'],
          suggestedTags: ['adult'],
          qualityScore: 0.8,
          isPotentiallyMisleading: false,
        );

        final enrichment = AlertEnrichment(
          alertId: baseAlert.id,
          contentAnalysis: analysis,
          status: EnrichmentStatus.completed,
          processedAt: DateTime.now(),
        );

        final alertWithEnrichment = baseAlert.copyWith(enrichment: enrichment);
        final quarantinedAlert = alertWithEnrichment.autoQuarantineFromAnalysis();

        expect(quarantinedAlert.isQuarantined, isTrue);
        expect(quarantinedAlert.isNsfwQuarantined, isTrue);
        expect(quarantinedAlert.quarantine.confidenceScore, equals(0.9));
        expect(quarantinedAlert.contentWarning, isNotNull);
        expect(quarantinedAlert.contentWarning, contains('explicit or sensitive material'));
      });

      test('respects manual quarantine over auto-quarantine', () {
        // First apply auto-quarantine
        final analysis = ContentAnalysis(
          isNsfw: true,
          nsfwConfidence: 0.8,
          detectedObjects: [],
          suggestedTags: [],
          qualityScore: 0.5,
          isPotentiallyMisleading: false,
        );

        final enrichment = AlertEnrichment(
          alertId: baseAlert.id,
          contentAnalysis: analysis,
          status: EnrichmentStatus.completed,
          processedAt: DateTime.now(),
        );

        var alert = baseAlert.copyWith(enrichment: enrichment);
        
        // Apply manual quarantine first
        alert = alert.applyQuarantine(
          action: QuarantineAction.approved,
          reasons: [],
          moderatorId: 'mod-123',
          moderatorName: 'Test Moderator',
        );

        // Auto-quarantine should not override manual action
        final finalAlert = alert.autoQuarantineFromAnalysis();
        expect(finalAlert.quarantine.action, equals(QuarantineAction.approved));
        expect(finalAlert.quarantine.isManuallyQuarantined, isTrue);
      });

      test('checks visibility correctly based on user context', () {
        final quarantinedAlert = baseAlert.applyQuarantine(
          action: QuarantineAction.hidePublic,
          reasons: [QuarantineReason.nsfw],
          moderatorId: 'mod-123',
          moderatorName: 'Test Moderator',
        );

        // Public users should not see quarantined content
        expect(quarantinedAlert.isVisibleTo(isPublic: true), isFalse);
        
        // Moderators should see quarantined content
        expect(quarantinedAlert.isVisibleTo(
          isPublic: false,
          isModerator: true,
        ), isTrue);
        
        // Reporters should see their own quarantined content
        expect(quarantinedAlert.isVisibleTo(
          isPublic: false,
          isReporter: true,
          userId: baseAlert.reporterId,
        ), isTrue);
        
        // Other reporters should not see quarantined content
        expect(quarantinedAlert.isVisibleTo(
          isPublic: false,
          isReporter: true,
          userId: 'other-reporter',
        ), isFalse);
      });

      test('allows showing quarantined content with explicit permission', () {
        final quarantinedAlert = baseAlert.applyQuarantine(
          action: QuarantineAction.hidePublic,
          reasons: [QuarantineReason.inappropriate],
          moderatorId: 'mod-123',
          moderatorName: 'Test Moderator',
        );

        // Should be visible when explicitly requesting quarantined content as moderator
        expect(quarantinedAlert.isVisibleTo(
          isPublic: false,
          isModerator: true,
          showQuarantined: true,
        ), isTrue);

        // Should be visible when explicitly requesting as reporter
        expect(quarantinedAlert.isVisibleTo(
          isPublic: false,
          isReporter: true,
          userId: baseAlert.reporterId,
          showQuarantined: true,
        ), isTrue);
      });

      test('applies approval correctly', () {
        final quarantinedAlert = baseAlert.applyQuarantine(
          action: QuarantineAction.hidePublic,
          reasons: [QuarantineReason.nsfw],
          moderatorId: 'mod-123',
          moderatorName: 'Test Moderator',
        );

        final approvedAlert = quarantinedAlert.approve(
          moderatorId: 'mod-456',
          moderatorName: 'Approving Moderator',
        );

        expect(approvedAlert.isApproved, isTrue);
        expect(approvedAlert.quarantine.action, equals(QuarantineAction.approved));
        expect(approvedAlert.quarantine.moderatorName, equals('Approving Moderator'));
        expect(approvedAlert.quarantine.reviewedAt, isNotNull);
        
        // Approved content should be visible to public
        expect(approvedAlert.isVisibleTo(isPublic: true), isTrue);
      });

      test('filters alerts correctly using matchesFilter', () {
        final nsfwAlert = baseAlert.applyQuarantine(
          action: QuarantineAction.hidePublic,
          reasons: [QuarantineReason.nsfw],
          moderatorId: 'mod-123',
          moderatorName: 'Test Moderator',
        );

        // Should not match filter in public context without including quarantined
        expect(nsfwAlert.matchesFilter(
          includeQuarantined: false,
          isPublicContext: true,
        ), isFalse);

        // Should match filter when including quarantined
        expect(nsfwAlert.matchesFilter(
          includeQuarantined: true,
          isPublicContext: true,
        ), isTrue);

        // Should match for moderators even in public context
        expect(nsfwAlert.matchesFilter(
          includeQuarantined: false,
          isPublicContext: true,
          isModerator: true,
        ), isTrue);
      });
    });

    group('Quarantine Actions Tests', () {
      test('creates custom quarantine with multiple reasons', () {
        final customQuarantine = baseAlert.applyQuarantine(
          action: QuarantineAction.remove,
          reasons: [
            QuarantineReason.nsfw,
            QuarantineReason.violence,
            QuarantineReason.inappropriate,
          ],
          customReason: 'Contains extremely inappropriate content violating multiple policies',
          moderatorId: 'senior-mod-789',
          moderatorName: 'Senior Moderator',
          allowReporterAccess: false,
        );

        expect(customQuarantine.quarantine.reasons.length, equals(3));
        expect(customQuarantine.quarantine.customReason, isNotNull);
        expect(customQuarantine.quarantine.allowReporterAccess, isFalse);
        expect(customQuarantine.quarantine.reasonsDisplayText, 
               equals('Contains extremely inappropriate content violating multiple policies'));
      });

      test('handles pending review state correctly', () {
        final pendingAlert = baseAlert.applyQuarantine(
          action: QuarantineAction.pendingReview,
          reasons: [QuarantineReason.reported],
          moderatorId: 'auto-mod',
          moderatorName: 'Auto Moderator',
        );

        expect(pendingAlert.isAwaitingReview, isTrue);
        expect(pendingAlert.quarantine.isPendingReview, isTrue);
        
        // Should not be visible to public while pending review
        expect(pendingAlert.isVisibleTo(isPublic: true), isFalse);
        
        // But should be accessible to moderators
        expect(pendingAlert.isVisibleTo(isModerator: true), isTrue);
      });

      test('copyWith preserves quarantine state', () {
        final quarantinedAlert = baseAlert.applyQuarantine(
          action: QuarantineAction.hidePublic,
          reasons: [QuarantineReason.nsfw],
          moderatorId: 'mod-123',
          moderatorName: 'Test Moderator',
        );

        // Create a new sighting with updated title
        final updatedSighting = Sighting(
          id: quarantinedAlert.sighting.id,
          title: 'Updated Title',
          description: quarantinedAlert.sighting.description,
          category: quarantinedAlert.sighting.category,
          sensorData: quarantinedAlert.sighting.sensorData,
          status: quarantinedAlert.sighting.status,
          jitteredLocation: quarantinedAlert.sighting.jitteredLocation,
          alertLevel: quarantinedAlert.sighting.alertLevel,
          witnessCount: quarantinedAlert.sighting.witnessCount,
          viewCount: quarantinedAlert.sighting.viewCount,
          verificationScore: quarantinedAlert.sighting.verificationScore,
          reporterId: quarantinedAlert.sighting.reporterId,
          submittedAt: quarantinedAlert.sighting.submittedAt,
          createdAt: quarantinedAlert.sighting.createdAt,
          updatedAt: quarantinedAlert.sighting.updatedAt,
        );

        final copiedAlert = quarantinedAlert.copyWith(sighting: updatedSighting);

        expect(copiedAlert.title, equals('Updated Title'));
        expect(copiedAlert.isQuarantined, isTrue);
        expect(copiedAlert.quarantine.action, equals(QuarantineAction.hidePublic));
        expect(copiedAlert.quarantine.moderatorName, equals('Test Moderator'));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('handles missing content analysis gracefully', () {
        final alertWithoutAnalysis = baseAlert.autoQuarantineFromAnalysis();
        
        expect(alertWithoutAnalysis.isQuarantined, isFalse);
        expect(alertWithoutAnalysis.hasNsfwAnalysis, isFalse);
        expect(alertWithoutAnalysis.nsfwConfidence, equals(0.0));
      });

      test('handles empty quarantine reasons', () {
        expect(() => baseAlert.applyQuarantine(
          action: QuarantineAction.hidePublic,
          reasons: [], // Empty reasons
          moderatorId: 'mod-123',
          moderatorName: 'Test Moderator',
        ), returnsNormally);
      });

      test('handles null or empty moderator information', () {
        const autoQuarantine = QuarantineState(
          action: QuarantineAction.hidePublic,
          reasons: [QuarantineReason.automated],
        );

        expect(autoQuarantine.isAutoQuarantined, isTrue);
        expect(autoQuarantine.isManuallyQuarantined, isFalse);
      });

      test('handles extreme confidence values', () {
        final highConfidence = QuarantineStateFromContentAnalysis.fromContentAnalysis(
          isNsfw: true,
          nsfwConfidence: 1.0, // Maximum confidence
          isPotentiallyMisleading: false,
        );

        final lowConfidence = QuarantineStateFromContentAnalysis.fromContentAnalysis(
          isNsfw: true,
          nsfwConfidence: 0.0, // Minimum confidence
          isPotentiallyMisleading: false,
        );

        expect(highConfidence.isQuarantined, isTrue);
        expect(lowConfidence.isQuarantined, isFalse);
      });
    });

    group('Integration Scenarios', () {
      test('full quarantine workflow: auto-detect -> manual review -> approval', () {
        // 1. Auto-detection phase
        final analysis = ContentAnalysis(
          isNsfw: true,
          nsfwConfidence: 0.85,
          detectedObjects: ['explicit_content'],
          suggestedTags: ['adult'],
          qualityScore: 0.7,
          isPotentiallyMisleading: false,
        );

        final enrichment = AlertEnrichment(
          alertId: baseAlert.id,
          contentAnalysis: analysis,
          status: EnrichmentStatus.completed,
          processedAt: DateTime.now(),
        );

        var alert = baseAlert.copyWith(enrichment: enrichment);
        alert = alert.autoQuarantineFromAnalysis();

        expect(alert.isQuarantined, isTrue);
        expect(alert.quarantine.isAutoQuarantined, isTrue);
        expect(alert.isVisibleTo(isPublic: true), isFalse);

        // 2. Manual review phase
        alert = alert.applyQuarantine(
          action: QuarantineAction.pendingReview,
          reasons: [QuarantineReason.nsfw, QuarantineReason.reported],
          customReason: 'Under manual review for NSFW content',
          moderatorId: 'human-mod-456',
          moderatorName: 'Human Moderator',
        );

        expect(alert.isAwaitingReview, isTrue);
        expect(alert.quarantine.isManuallyQuarantined, isTrue);

        // 3. Approval phase
        alert = alert.approve(
          moderatorId: 'senior-mod-789',
          moderatorName: 'Senior Moderator',
        );

        expect(alert.isApproved, isTrue);
        expect(alert.isVisibleTo(isPublic: true), isTrue);
        expect(alert.quarantine.reviewedAt, isNotNull);
      });

      test('reporter workflow: submit -> auto-quarantine -> reporter access', () {
        // Simulate reporter submitting potentially NSFW content
        final reporterSighting = Sighting(
          id: 'reporter-alert-1',
          title: 'Unusual Lights',
          description: 'Strange lights in the sky',
          category: SightingCategory.ufo,
          sensorData: SensorDataApi(
            timestamp: DateTime.now(),
            location: const GeoCoordinates(latitude: 40.7128, longitude: -74.0060),
            azimuthDeg: 90.0,
            pitchDeg: 45.0,
          ),
          status: SightingStatus.pending,
          jitteredLocation: const GeoCoordinates(latitude: 40.7128, longitude: -74.0060),
          alertLevel: AlertLevel.medium,
          witnessCount: 1,
          viewCount: 0,
          verificationScore: 0.5,
          reporterId: 'reporter-456',
          submittedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final reporterAlert = EnrichedAlert.fromSighting(reporterSighting);

        // Auto-quarantine due to NSFW detection
        final analysis = ContentAnalysis(
          isNsfw: true,
          nsfwConfidence: 0.75,
          detectedObjects: [],
          suggestedTags: [],
          qualityScore: 0.6,
          isPotentiallyMisleading: false,
        );

        final enrichment = AlertEnrichment(
          alertId: reporterAlert.id,
          contentAnalysis: analysis,
          status: EnrichmentStatus.completed,
          processedAt: DateTime.now(),
        );

        final quarantinedAlert = reporterAlert
            .copyWith(enrichment: enrichment)
            .autoQuarantineFromAnalysis();

        // Reporter should still be able to see their own content
        expect(quarantinedAlert.isVisibleTo(
          isReporter: true,
          userId: 'reporter-456',
        ), isTrue);

        // Other users should not see it
        expect(quarantinedAlert.isVisibleTo(isPublic: true), isFalse);
        expect(quarantinedAlert.isVisibleTo(
          isReporter: true,
          userId: 'other-reporter',
        ), isFalse);
      });

      test('moderator dashboard workflow: filter quarantined content', () {
        final alerts = [
          baseAlert, // Normal alert
          baseAlert.applyQuarantine( // NSFW quarantined
            action: QuarantineAction.hidePublic,
            reasons: [QuarantineReason.nsfw],
            moderatorId: 'mod-1',
            moderatorName: 'Mod 1',
          ),
          baseAlert.applyQuarantine( // Pending review
            action: QuarantineAction.pendingReview,
            reasons: [QuarantineReason.reported],
            moderatorId: 'mod-2',
            moderatorName: 'Mod 2',
          ),
          baseAlert.approve( // Approved after review
            moderatorId: 'mod-3',
            moderatorName: 'Mod 3',
          ),
        ];

        // Public view should only show normal and approved alerts
        final publicAlerts = alerts.where((alert) => 
            alert.isVisibleTo(isPublic: true)).toList();
        expect(publicAlerts.length, equals(2)); // Normal + approved

        // Moderator view should show all alerts
        final moderatorAlerts = alerts.where((alert) => 
            alert.isVisibleTo(isModerator: true)).toList();
        expect(moderatorAlerts.length, equals(4)); // All alerts

        // Count quarantine types
        final quarantinedAlerts = alerts.where((a) => a.isQuarantined).toList();
        final hiddenAlerts = alerts.where((a) => a.isHiddenFromPublic).toList();
        final nsfwAlerts = alerts.where((a) => a.isNsfwQuarantined).toList();
        final pendingAlerts = alerts.where((a) => a.isAwaitingReview).toList();

        expect(quarantinedAlerts.length, equals(3)); // NSFW + pending + approved
        expect(hiddenAlerts.length, equals(2)); // NSFW + pending (approved is not hidden)
        expect(nsfwAlerts.length, equals(1));
        expect(pendingAlerts.length, equals(1));
      });
    });
  });
}