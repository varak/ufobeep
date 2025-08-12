import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/alerts_filter.dart';
import '../services/api_client.dart';

part 'alerts_provider.g.dart';

// Alert Model
class Alert {
  const Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.distance,
    this.bearing,
    this.category = 'unknown',
    this.alertLevel = 'low',
    this.status = 'pending',
    this.witnessCount = 1,
    this.viewCount = 0,
    this.verificationScore = 0.0,
    this.mediaFiles = const [],
    this.tags = const [],
    this.isPublic = true,
    this.submittedAt,
    this.processedAt,
    this.matrixRoomId,
    this.reporterId,
  });

  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final double? distance;
  final double? bearing;
  final String category;
  final String alertLevel;
  final String status;
  final int witnessCount;
  final int viewCount;
  final double verificationScore;
  final List<Map<String, dynamic>> mediaFiles;
  final List<String> tags;
  final bool isPublic;
  final DateTime? submittedAt;
  final DateTime? processedAt;
  final String? matrixRoomId;
  final String? reporterId;

  // Computed properties
  bool get isVerified => status == 'verified';
  bool get hasMedia => mediaFiles.isNotEmpty;
  String get mediaUrl => hasMedia ? (mediaFiles.first['url'] ?? '') : '';

  Alert copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    double? distance,
    double? bearing,
    String? category,
    String? alertLevel,
    String? status,
    int? witnessCount,
    int? viewCount,
    double? verificationScore,
    List<Map<String, dynamic>>? mediaFiles,
    List<String>? tags,
    bool? isPublic,
    DateTime? submittedAt,
    DateTime? processedAt,
    String? matrixRoomId,
    String? reporterId,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      distance: distance ?? this.distance,
      bearing: bearing ?? this.bearing,
      category: category ?? this.category,
      alertLevel: alertLevel ?? this.alertLevel,
      status: status ?? this.status,
      witnessCount: witnessCount ?? this.witnessCount,
      viewCount: viewCount ?? this.viewCount,
      verificationScore: verificationScore ?? this.verificationScore,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      submittedAt: submittedAt ?? this.submittedAt,
      processedAt: processedAt ?? this.processedAt,
      matrixRoomId: matrixRoomId ?? this.matrixRoomId,
      reporterId: reporterId ?? this.reporterId,
    );
  }

  factory Alert.fromApiJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final mediaFiles = json['media_files'] as List<dynamic>?;
    
    return Alert(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: location?['latitude']?.toDouble() ?? 0.0,
      longitude: location?['longitude']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      distance: json['distance_km']?.toDouble(),
      bearing: json['bearing_deg']?.toDouble(),
      category: json['category'] as String? ?? 'unknown',
      alertLevel: json['alert_level'] as String? ?? 'low',
      status: json['status'] as String? ?? 'pending',
      witnessCount: json['witness_count'] as int? ?? 1,
      viewCount: json['view_count'] as int? ?? 0,
      verificationScore: json['verification_score']?.toDouble() ?? 0.0,
      mediaFiles: mediaFiles?.cast<Map<String, dynamic>>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPublic: json['is_public'] as bool? ?? true,
      submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at'] as String) : null,
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at'] as String) : null,
      matrixRoomId: json['matrix_room_id'] as String?,
      reporterId: json['reporter_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'created_at': createdAt.toIso8601String(),
      if (distance != null) 'distance_km': distance,
      if (bearing != null) 'bearing_deg': bearing,
      'category': category,
      'alert_level': alertLevel,
      'status': status,
      'witness_count': witnessCount,
      'view_count': viewCount,
      'verification_score': verificationScore,
      'media_files': mediaFiles,
      'tags': tags,
      'is_public': isPublic,
      if (submittedAt != null) 'submitted_at': submittedAt!.toIso8601String(),
      if (processedAt != null) 'processed_at': processedAt!.toIso8601String(),
      if (matrixRoomId != null) 'matrix_room_id': matrixRoomId,
      if (reporterId != null) 'reporter_id': reporterId,
    };
  }
}

// Alerts List Provider
@riverpod
class AlertsList extends _$AlertsList {
  @override
  Future<List<Alert>> build() async {
    // Fetch alerts from API
    return await _fetchAlertsFromApi();
  }

  Future<List<Alert>> _fetchAlertsFromApi({
    int limit = 20,
    int offset = 0,
    String? category,
    String? minAlertLevel,
    double? maxDistanceKm,
    double? latitude,
    double? longitude,
    int? recentHours,
    bool verifiedOnly = false,
  }) async {
    try {
      final apiClient = ApiClient.instance;
      
      final response = await apiClient.listAlerts(
        limit: limit,
        offset: offset,
        category: category,
        minAlertLevel: minAlertLevel,
        maxDistanceKm: maxDistanceKm,
        latitude: latitude,
        longitude: longitude,
        recentHours: recentHours,
        verifiedOnly: verifiedOnly,
      );

      if (response['success'] == true) {
        final alertsData = response['data'] as Map<String, dynamic>;
        final alertsList = alertsData['alerts'] as List<dynamic>;
        
        return alertsList
            .cast<Map<String, dynamic>>()
            .map((alertJson) => Alert.fromApiJson(alertJson))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch alerts');
      }
    } catch (e) {
      // On API error, return empty list with error state
      print('Error fetching alerts: $e');
      // In production, you might want to set an error state instead
      return [];
    }
  }

  Future<void> refresh({
    String? category,
    String? minAlertLevel,
    double? maxDistanceKm,
    double? latitude,
    double? longitude,
    int? recentHours,
    bool verifiedOnly = false,
  }) async {
    state = const AsyncLoading();
    
    final alerts = await _fetchAlertsFromApi(
      category: category,
      minAlertLevel: minAlertLevel,
      maxDistanceKm: maxDistanceKm,
      latitude: latitude,
      longitude: longitude,
      recentHours: recentHours,
      verifiedOnly: verifiedOnly,
    );
    
    state = AsyncData(alerts);
  }

  Future<void> loadMore({
    String? category,
    String? minAlertLevel,
    double? maxDistanceKm,
    double? latitude,
    double? longitude,
    int? recentHours,
    bool verifiedOnly = false,
  }) async {
    final currentAlerts = state.value ?? [];
    
    final newAlerts = await _fetchAlertsFromApi(
      offset: currentAlerts.length,
      category: category,
      minAlertLevel: minAlertLevel,
      maxDistanceKm: maxDistanceKm,
      latitude: latitude,
      longitude: longitude,
      recentHours: recentHours,
      verifiedOnly: verifiedOnly,
    );
    
    state = AsyncData([...currentAlerts, ...newAlerts]);
  }

  void addAlert(Alert alert) {
    final currentAlerts = state.value ?? [];
    state = AsyncData([alert, ...currentAlerts]);
  }

  void removeAlert(String alertId) {
    final currentAlerts = state.value ?? [];
    state = AsyncData(currentAlerts.where((alert) => alert.id != alertId).toList());
  }

  void updateAlert(Alert updatedAlert) {
    final currentAlerts = state.value ?? [];
    state = AsyncData(currentAlerts.map((alert) {
      return alert.id == updatedAlert.id ? updatedAlert : alert;
    }).toList());
  }
}

// Single Alert Provider
@riverpod
Future<Alert?> alertById(AlertByIdRef ref, String alertId) async {
  try {
    // First try to get from cached alerts
    final alertsAsync = ref.watch(alertsListProvider);
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
    final response = await apiClient.getAlertDetails(alertId);
    
    if (response['success'] == true) {
      final alertData = response['data'] as Map<String, dynamic>;
      return Alert.fromApiJson(alertData);
    }
    
    return null;
  } catch (e) {
    print('Error fetching alert $alertId: $e');
    return null;
  }
}

// Filter State Provider
@riverpod
class AlertsFilterState extends _$AlertsFilterState {
  @override
  AlertsFilter build() {
    return const AlertsFilter();
  }

  void updateFilter(AlertsFilter filter) {
    state = filter;
  }

  void resetFilter() {
    state = const AlertsFilter();
  }

  void toggleCategory(String category) {
    final categories = Set<String>.from(state.categories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    state = state.copyWith(categories: categories);
  }

  void setMaxDistance(double? distance) {
    state = state.copyWith(maxDistanceKm: distance);
  }

  void setMaxAge(int? hours) {
    state = state.copyWith(maxAgeHours: hours);
  }

  void setVerifiedOnly(bool? verified) {
    state = state.copyWith(verifiedOnly: verified);
  }

  void setSorting(AlertSortBy sortBy, {bool? ascending}) {
    state = state.copyWith(
      sortBy: sortBy,
      ascending: ascending ?? state.ascending,
    );
  }
}

// Loading State Provider
@riverpod
class AlertsLoadingState extends _$AlertsLoadingState {
  @override
  bool build() {
    // Watch the alerts list provider and return loading state based on it
    final alertsAsync = ref.watch(alertsListProvider);
    return alertsAsync.isLoading;
  }

  void setLoading(bool loading) {
    // This is now managed by the AlertsList provider itself
    // Keep for compatibility but state comes from AlertsList
  }

  Future<void> refresh() async {
    // Trigger refresh on the alerts list provider
    await ref.read(alertsListProvider.notifier).refresh();
  }
}

// Filtered and Sorted Alerts Provider
@riverpod
Future<List<Alert>> filteredAlerts(FilteredAlertsRef ref) async {
  final alertsAsync = ref.watch(alertsListProvider);
  final filter = ref.watch(alertsFilterStateProvider);
  
  if (!alertsAsync.hasValue) {
    return [];
  }
  
  final alerts = alertsAsync.value!;
  
  // Apply filters
  var filteredAlerts = alerts.where((alert) {
    // Category filter
    if (filter.categories.isNotEmpty && !filter.categories.contains(alert.category)) {
      return false;
    }
    
    // Distance filter
    if (filter.maxDistanceKm != null && 
        alert.distance != null && 
        alert.distance! > filter.maxDistanceKm!) {
      return false;
    }
    
    // Age filter
    if (filter.maxAgeHours != null) {
      final ageHours = DateTime.now().difference(alert.createdAt).inHours;
      if (ageHours > filter.maxAgeHours!) {
        return false;
      }
    }
    
    // Verified filter
    if (filter.verifiedOnly == true && !alert.isVerified) {
      return false;
    }
    
    return true;
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
        final distanceA = a.distance ?? double.infinity;
        final distanceB = b.distance ?? double.infinity;
        comparison = distanceA.compareTo(distanceB);
        break;
      case AlertSortBy.category:
        comparison = a.category.compareTo(b.category);
        break;
      case AlertSortBy.verified:
        // Verified first, then by creation time
        if (a.isVerified != b.isVerified) {
          comparison = b.isVerified ? 1 : -1;
        } else {
          comparison = b.createdAt.compareTo(a.createdAt);
        }
        break;
    }
    
    // For newest/oldest, ascending means oldest first, descending means newest first
    // The comparison is already set up correctly, don't negate it
    return comparison;
  });

  return filteredAlerts;
}

// Nearby Alerts Provider for compass/map
@riverpod
Future<List<Alert>> nearbyAlerts(
  NearbyAlertsRef ref, {
  required double latitude,
  required double longitude,
  double radiusKm = 50.0,
  int? recentHours,
  String? minAlertLevel,
}) async {
  try {
    final apiClient = ApiClient.instance;
    
    final response = await apiClient.getNearbyAlerts(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      recentHours: recentHours,
      minAlertLevel: minAlertLevel,
    );

    if (response['success'] == true) {
      final alertsData = response['data'] as Map<String, dynamic>;
      final alertsList = alertsData['alerts'] as List<dynamic>;
      
      return alertsList
          .cast<Map<String, dynamic>>()
          .map((alertJson) => Alert.fromApiJson(alertJson))
          .toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch nearby alerts');
    }
  } catch (e) {
    print('Error fetching nearby alerts: $e');
    return [];
  }
}