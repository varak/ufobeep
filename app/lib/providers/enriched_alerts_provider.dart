import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/api_models.dart';
import '../models/alert_enrichment.dart';
import '../models/enriched_alert.dart';
import '../models/quarantine_state.dart';
import '../models/alerts_filter.dart';
import '../services/api_client.dart';

part 'enriched_alerts_provider.g.dart';

/// Provider for enriched alerts with quarantine handling
@riverpod
class EnrichedAlertsList extends _$EnrichedAlertsList {
  @override
  Future<List<EnrichedAlert>> build() async {
    return await _fetchEnrichedAlertsFromApi();
  }

  Future<List<EnrichedAlert>> _fetchEnrichedAlertsFromApi({
    int limit = 20,
    int offset = 0,
    SightingCategory? category,
    AlertLevel? minAlertLevel,
    double? maxDistanceKm,
    double? latitude,
    double? longitude,
    int? recentHours,
    bool verifiedOnly = false,
    bool includeQuarantined = false,
  }) async {
    try {
      final apiClient = ApiClient.instance;
      
      // Build query parameters
      final query = AlertsQuery(
        centerLat: latitude,
        centerLng: longitude,
        radiusKm: maxDistanceKm,
        category: category,
        minAlertLevel: minAlertLevel,
        verifiedOnly: verifiedOnly,
        limit: limit,
        offset: offset,
        since: recentHours != null 
            ? DateTime.now().subtract(Duration(hours: recentHours))
            : null,
      );

      final response = await apiClient.getAlerts(query);
      
      if (response.success) {
        final sightings = response.data.sightings;
        final enrichedAlerts = <EnrichedAlert>[];
        
        for (final sighting in sightings) {
          // Create enriched alert from sighting
          var enrichedAlert = EnrichedAlert.fromSighting(sighting);
          
          // Apply auto-quarantine if content analysis indicates NSFW
          if (sighting.enrichment?.contentAnalysis != null) {
            final enrichment = AlertEnrichment(
              alertId: sighting.id,
              contentAnalysis: _convertContentAnalysis(sighting.enrichment!.contentAnalysis!),
              status: EnrichmentStatus.completed,
              processedAt: sighting.enrichment?.processedAt ?? DateTime.now(),
            );
            
            enrichedAlert = enrichedAlert.copyWith(enrichment: enrichment);
            enrichedAlert = enrichedAlert.autoQuarantineFromAnalysis();
          }
          
          // Check visibility based on quarantine settings
          if (includeQuarantined || _isAlertVisible(enrichedAlert)) {
            enrichedAlerts.add(enrichedAlert);
          }
        }
        
        return enrichedAlerts;
      } else {
        throw Exception('Failed to fetch alerts: ${response.message}');
      }
    } catch (e) {
      print('Error fetching enriched alerts: $e');
      return [];
    }
  }

  /// Convert API ContentAnalysis to local ContentAnalysis
  ContentAnalysis _convertContentAnalysis(dynamic apiAnalysis) {
    // This would depend on the actual API structure
    // For now, create a basic conversion
    return const ContentAnalysis(
      isNsfw: false,
      nsfwConfidence: 0.0,
      detectedObjects: [],
      suggestedTags: [],
      qualityScore: 1.0,
      isPotentiallyMisleading: false,
    );
  }

  /// Check if alert should be visible based on quarantine and user context
  bool _isAlertVisible(EnrichedAlert alert) {
    // For now, assume public context - this could be parameterized
    return alert.isVisibleTo(
      isPublic: true,
      isReporter: false,
      isModerator: false,
    );
  }

  /// Refresh alerts with optional filtering
  Future<void> refresh({
    SightingCategory? category,
    AlertLevel? minAlertLevel,
    double? maxDistanceKm,
    double? latitude,
    double? longitude,
    int? recentHours,
    bool verifiedOnly = false,
    bool includeQuarantined = false,
  }) async {
    state = const AsyncLoading();
    
    final alerts = await _fetchEnrichedAlertsFromApi(
      category: category,
      minAlertLevel: minAlertLevel,
      maxDistanceKm: maxDistanceKm,
      latitude: latitude,
      longitude: longitude,
      recentHours: recentHours,
      verifiedOnly: verifiedOnly,
      includeQuarantined: includeQuarantined,
    );
    
    state = AsyncData(alerts);
  }

  /// Load more alerts for pagination
  Future<void> loadMore({
    SightingCategory? category,
    AlertLevel? minAlertLevel,
    double? maxDistanceKm,
    double? latitude,
    double? longitude,
    int? recentHours,
    bool verifiedOnly = false,
    bool includeQuarantined = false,
  }) async {
    final currentAlerts = state.value ?? [];
    
    final newAlerts = await _fetchEnrichedAlertsFromApi(
      offset: currentAlerts.length,
      category: category,
      minAlertLevel: minAlertLevel,
      maxDistanceKm: maxDistanceKm,
      latitude: latitude,
      longitude: longitude,
      recentHours: recentHours,
      verifiedOnly: verifiedOnly,
      includeQuarantined: includeQuarantined,
    );
    
    state = AsyncData([...currentAlerts, ...newAlerts]);
  }

  /// Add a new alert
  void addAlert(EnrichedAlert alert) {
    final currentAlerts = state.value ?? [];
    state = AsyncData([alert, ...currentAlerts]);
  }

  /// Remove an alert
  void removeAlert(String alertId) {
    final currentAlerts = state.value ?? [];
    state = AsyncData(currentAlerts.where((alert) => alert.id != alertId).toList());
  }

  /// Update an existing alert
  void updateAlert(EnrichedAlert updatedAlert) {
    final currentAlerts = state.value ?? [];
    state = AsyncData(currentAlerts.map((alert) {
      return alert.id == updatedAlert.id ? updatedAlert : alert;
    }).toList());
  }

  /// Apply quarantine action to an alert
  Future<void> quarantineAlert({
    required String alertId,
    required QuarantineAction action,
    required List<QuarantineReason> reasons,
    String? customReason,
    required String moderatorId,
    required String moderatorName,
    bool? allowReporterAccess,
    bool? allowModeratorAccess,
  }) async {
    final currentAlerts = state.value ?? [];
    final updatedAlerts = currentAlerts.map((alert) {
      if (alert.id == alertId) {
        return alert.applyQuarantine(
          action: action,
          reasons: reasons,
          customReason: customReason,
          moderatorId: moderatorId,
          moderatorName: moderatorName,
          allowReporterAccess: allowReporterAccess,
          allowModeratorAccess: allowModeratorAccess,
        );
      }
      return alert;
    }).toList();
    
    state = AsyncData(updatedAlerts);
    
    // TODO: Sync quarantine state with API
    await _syncQuarantineWithApi(alertId, action, reasons, customReason);
  }

  /// Approve a quarantined alert
  Future<void> approveAlert({
    required String alertId,
    required String moderatorId,
    required String moderatorName,
  }) async {
    final currentAlerts = state.value ?? [];
    final updatedAlerts = currentAlerts.map((alert) {
      if (alert.id == alertId) {
        return alert.approve(
          moderatorId: moderatorId,
          moderatorName: moderatorName,
        );
      }
      return alert;
    }).toList();
    
    state = AsyncData(updatedAlerts);
    
    // TODO: Sync approval with API
    await _syncApprovalWithApi(alertId, moderatorId, moderatorName);
  }

  /// Sync quarantine action with API (placeholder)
  Future<void> _syncQuarantineWithApi(
    String alertId,
    QuarantineAction action,
    List<QuarantineReason> reasons,
    String? customReason,
  ) async {
    // TODO: Implement API call to sync quarantine state
    // This would send the quarantine action to the backend
    print('Syncing quarantine for $alertId: $action, reasons: $reasons');
  }

  /// Sync approval with API (placeholder)
  Future<void> _syncApprovalWithApi(
    String alertId,
    String moderatorId,
    String moderatorName,
  ) async {
    // TODO: Implement API call to sync approval
    // This would update the backend that content was approved
    print('Syncing approval for $alertId by $moderatorName');
  }
}

/// Single enriched alert provider
@riverpod
Future<EnrichedAlert?> enrichedAlertById(EnrichedAlertByIdRef ref, String alertId) async {
  try {
    // First try to get from cached alerts
    final alertsAsync = ref.watch(enrichedAlertsListProvider);
    if (alertsAsync.hasValue) {
      final alerts = alertsAsync.value!;
      for (final alert in alerts) {
        if (alert.id == alertId) {
          return alert;
        }
      }
    }
    
    // If not found in cache, fetch from API
    final apiClient = ApiClient.instance;
    // TODO: This would need to be updated to use the new API client
    // For now, return null to indicate not found
    return null;
  } catch (e) {
    print('Error fetching enriched alert $alertId: $e');
    return null;
  }
}

/// Filtered enriched alerts provider with quarantine handling
@riverpod
Future<List<EnrichedAlert>> filteredEnrichedAlerts(
  FilteredEnrichedAlertsRef ref, {
  bool includeQuarantined = false,
  bool isPublicContext = true,
  String? currentUserId,
  bool isModerator = false,
}) async {
  final alertsAsync = ref.watch(enrichedAlertsListProvider);
  final filter = ref.watch(alertsFilterStateProvider);
  
  if (!alertsAsync.hasValue) {
    return [];
  }
  
  final alerts = alertsAsync.value!;
  
  // Apply visibility filtering based on quarantine state
  var filteredAlerts = alerts.where((alert) {
    // Check quarantine visibility first
    if (!includeQuarantined && !alert.isVisibleTo(
      isPublic: isPublicContext,
      isReporter: currentUserId == alert.reporterId,
      isModerator: isModerator,
      userId: currentUserId,
    )) {
      return false;
    }
    
    // Apply standard alert filters using the enriched alert's matchesFilter method
    return alert.matchesFilter(
      category: filter.categories.isNotEmpty 
          ? _convertStringToCategory(filter.categories.first)
          : null,
      status: filter.verifiedOnly == true ? SightingStatus.verified : null,
      includeQuarantined: includeQuarantined,
      isPublicContext: isPublicContext,
      userId: currentUserId,
      isModerator: isModerator,
    );
  }).toList();

  // Apply sorting
  filteredAlerts.sort((a, b) {
    int comparison;
    
    switch (filter.sortBy) {
      case AlertSortBy.newest:
        comparison = b.createdAt.compareTo(a.createdAt);
        break;
      case AlertSortBy.oldest:
        comparison = a.createdAt.compareTo(b.createdAt);
        break;
      case AlertSortBy.distance:
        // Use jittered location for distance calculation
        // For now, sort by creation time if no distance available
        comparison = b.createdAt.compareTo(a.createdAt);
        break;
      case AlertSortBy.category:
        comparison = a.category.toString().compareTo(b.category.toString());
        break;
      case AlertSortBy.verified:
        // Verified first, then by creation time
        if (a.status != b.status) {
          comparison = a.status == SightingStatus.verified ? -1 : 1;
        } else {
          comparison = b.createdAt.compareTo(a.createdAt);
        }
        break;
    }
    
    return filter.ascending ? comparison : -comparison;
  });

  return filteredAlerts;
}

/// Convert string category to enum (helper function)
SightingCategory? _convertStringToCategory(String category) {
  switch (category.toLowerCase()) {
    case 'ufo':
      return SightingCategory.ufo;
    case 'anomaly':
      return SightingCategory.anomaly;
    case 'unknown':
      return SightingCategory.unknown;
    default:
      return null;
  }
}

/// Quarantine summary provider for moderation dashboard
@riverpod
Future<QuarantineSummary> quarantineSummary(QuarantineSummaryRef ref) async {
  final alertsAsync = ref.watch(enrichedAlertsListProvider);
  
  if (!alertsAsync.hasValue) {
    return const QuarantineSummary();
  }
  
  final alerts = alertsAsync.value!;
  
  int totalQuarantined = 0;
  int nsfwQuarantined = 0;
  int pendingReview = 0;
  int autoQuarantined = 0;
  
  for (final alert in alerts) {
    if (alert.isQuarantined) {
      totalQuarantined++;
      
      if (alert.isNsfwQuarantined) {
        nsfwQuarantined++;
      }
      
      if (alert.isAwaitingReview) {
        pendingReview++;
      }
      
      if (alert.quarantine.isAutoQuarantined) {
        autoQuarantined++;
      }
    }
  }
  
  return QuarantineSummary(
    totalQuarantined: totalQuarantined,
    nsfwQuarantined: nsfwQuarantined,
    pendingReview: pendingReview,
    autoQuarantined: autoQuarantined,
    totalAlerts: alerts.length,
  );
}

/// Quarantine summary data class
class QuarantineSummary {
  final int totalQuarantined;
  final int nsfwQuarantined;
  final int pendingReview;
  final int autoQuarantined;
  final int totalAlerts;

  const QuarantineSummary({
    this.totalQuarantined = 0,
    this.nsfwQuarantined = 0,
    this.pendingReview = 0,
    this.autoQuarantined = 0,
    this.totalAlerts = 0,
  });

  double get quarantineRate => 
      totalAlerts > 0 ? (totalQuarantined / totalAlerts) : 0.0;

  double get nsfwRate => 
      totalAlerts > 0 ? (nsfwQuarantined / totalAlerts) : 0.0;

  double get autoQuarantineRate => 
      totalQuarantined > 0 ? (autoQuarantined / totalQuarantined) : 0.0;
}

/// User context provider for quarantine filtering
@riverpod
class UserContext extends _$UserContext {
  @override
  UserContextData build() {
    return const UserContextData();
  }

  void updateContext({
    String? userId,
    bool? isModerator,
    bool? includeQuarantined,
  }) {
    state = state.copyWith(
      userId: userId,
      isModerator: isModerator,
      includeQuarantined: includeQuarantined,
    );
  }
}

/// User context data for quarantine filtering
class UserContextData {
  final String? userId;
  final bool isModerator;
  final bool includeQuarantined;

  const UserContextData({
    this.userId,
    this.isModerator = false,
    this.includeQuarantined = false,
  });

  UserContextData copyWith({
    String? userId,
    bool? isModerator,
    bool? includeQuarantined,
  }) {
    return UserContextData(
      userId: userId ?? this.userId,
      isModerator: isModerator ?? this.isModerator,
      includeQuarantined: includeQuarantined ?? this.includeQuarantined,
    );
  }
}