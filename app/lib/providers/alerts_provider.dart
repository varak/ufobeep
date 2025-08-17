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
    this.locationName,
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
    this.enrichment,
    this.photoAnalysis,
    this.totalConfirmations = 0,
    this.canConfirmWitness = true,
  });

  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String? locationName;
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
  final Map<String, dynamic>? enrichment;
  final List<Map<String, dynamic>>? photoAnalysis;
  final int totalConfirmations;
  final bool canConfirmWitness;

  // Computed properties
  bool get isVerified => status == 'verified';
  bool get hasMedia => mediaFiles.isNotEmpty;
  String get mediaUrl => hasMedia ? (primaryMediaFile?['url'] ?? mediaFiles.first['url'] ?? '') : '';
  
  // Get primary media file (or first if no primary)
  Map<String, dynamic>? get primaryMediaFile {
    if (mediaFiles.isEmpty) return null;
    
    // Look for primary media
    try {
      final primaryMedia = mediaFiles.firstWhere(
        (media) => media['is_primary'] == true,
      );
      return primaryMedia;
    } catch (e) {
      // No primary found, return first media file
      return mediaFiles.first;
    }
  }
  
  // Get thumbnail URL for primary media
  String get primaryThumbnailUrl {
    final primary = primaryMediaFile;
    if (primary == null) return '';
    return primary['thumbnail_url'] ?? primary['url'] ?? '';
  }

  Alert copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    String? locationName,
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
    Map<String, dynamic>? enrichment,
    List<Map<String, dynamic>>? photoAnalysis,
    int? totalConfirmations,
    bool? canConfirmWitness,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      locationName: locationName ?? this.locationName,
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
      enrichment: enrichment ?? this.enrichment,
      photoAnalysis: photoAnalysis ?? this.photoAnalysis,
      totalConfirmations: totalConfirmations ?? this.totalConfirmations,
      canConfirmWitness: canConfirmWitness ?? this.canConfirmWitness,
    );
  }

  factory Alert.fromApiJson(Map<String, dynamic> json) {
    try {
      // Handle both old format (with 'location' object) and new format (with 'jittered_location' or 'sensor_data')
      Map<String, dynamic>? location = json['location'] as Map<String, dynamic>?;
      Map<String, dynamic>? jitteredLocation = json['jittered_location'] as Map<String, dynamic>?;
      Map<String, dynamic>? sensorData = json['sensor_data'] as Map<String, dynamic>?;
      
      // Try to get coordinates from various possible locations in the response
      double lat = 0.0;
      double lng = 0.0;
      
      if (jitteredLocation != null) {
        lat = (jitteredLocation['latitude']?.toDouble() ?? jitteredLocation['lat']?.toDouble()) ?? 0.0;
        lng = (jitteredLocation['longitude']?.toDouble() ?? jitteredLocation['lng']?.toDouble()) ?? 0.0;
      } else if (location != null) {
        lat = (location['latitude']?.toDouble() ?? location['lat']?.toDouble()) ?? 0.0;
        lng = (location['longitude']?.toDouble() ?? location['lng']?.toDouble()) ?? 0.0;
      } else if (sensorData != null && sensorData['location'] != null) {
        final sensorLoc = sensorData['location'] as Map<String, dynamic>;
        lat = (sensorLoc['latitude']?.toDouble() ?? sensorLoc['lat']?.toDouble()) ?? 0.0;
        lng = (sensorLoc['longitude']?.toDouble() ?? sensorLoc['lng']?.toDouble()) ?? 0.0;
      } else if (sensorData != null) {
        lat = (sensorData['latitude']?.toDouble() ?? sensorData['lat']?.toDouble()) ?? 0.0;
        lng = (sensorData['longitude']?.toDouble() ?? sensorData['lng']?.toDouble()) ?? 0.0;
      }
      
      // Safely parse media files
      List<Map<String, dynamic>> parsedMediaFiles = [];
      try {
        final mediaFiles = json['media_files'] as List<dynamic>?;
        if (mediaFiles != null) {
          for (final media in mediaFiles) {
            if (media is Map<String, dynamic>) {
              parsedMediaFiles.add(media);
            }
          }
        }
      } catch (e) {
        print('Error parsing media_files for alert ${json['id']}: $e');
      }
      
      // Safely parse photo analysis
      List<Map<String, dynamic>>? parsedPhotoAnalysis;
      try {
        final photoAnalysis = json['photo_analysis'];
        if (photoAnalysis is List) {
          parsedPhotoAnalysis = [];
          for (final analysis in photoAnalysis) {
            if (analysis is Map<String, dynamic>) {
              parsedPhotoAnalysis.add(analysis);
            }
          }
        }
      } catch (e) {
        print('Error parsing photo_analysis for alert ${json['id']}: $e');
      }
      
      // Safely parse tags
      List<String> parsedTags = [];
      try {
        final tags = json['tags'];
        if (tags is List) {
          for (final tag in tags) {
            if (tag is String) {
              parsedTags.add(tag);
            }
          }
        }
      } catch (e) {
        print('Error parsing tags for alert ${json['id']}: $e');
      }
      
      return Alert(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        latitude: lat,
        longitude: lng,
        createdAt: DateTime.parse(json['created_at'] as String? ?? json['submitted_at'] as String? ?? DateTime.now().toIso8601String()),
        locationName: location?['name'] as String?,
        distance: json['distance_km']?.toDouble(),
        bearing: json['bearing_deg']?.toDouble(),
        category: json['category'] as String? ?? 'ufo',
        alertLevel: json['alert_level'] as String? ?? 'low',
        status: json['status'] as String? ?? 'pending',
        witnessCount: json['witness_count'] as int? ?? 1,
        viewCount: json['view_count'] as int? ?? 0,
        verificationScore: json['verification_score']?.toDouble() ?? 0.0,
        mediaFiles: parsedMediaFiles,
        tags: parsedTags,
        isPublic: json['is_public'] as bool? ?? true,
        submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at'] as String) : null,
        processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at'] as String) : null,
        matrixRoomId: json['matrix_room_id'] as String?,
        reporterId: json['reporter_id'] as String?,
        enrichment: json['enrichment'] as Map<String, dynamic>?,
        photoAnalysis: parsedPhotoAnalysis,
        totalConfirmations: json['total_confirmations'] as int? ?? 0,
        canConfirmWitness: json['can_confirm_witness'] as bool? ?? true,
      );
    } catch (e) {
      print('Error parsing alert JSON for ${json['id']}: $e');
      print('Raw JSON: $json');
      rethrow;
    }
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
      if (enrichment != null) 'enrichment': enrichment,
      if (photoAnalysis != null) 'photo_analysis': photoAnalysis,
      'total_confirmations': totalConfirmations,
      'can_confirm_witness': canConfirmWitness,
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
    // Always fetch fresh data from API to get latest analysis status
    // This ensures photo analysis status updates are reflected immediately
    final apiClient = ApiClient.instance;
    
    // Add timeout to prevent hanging
    final response = await apiClient.getAlertDetails(alertId).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('Timeout fetching alert $alertId');
        throw Exception('Request timeout');
      },
    );
    
    if (response['success'] == true) {
      final alertData = response['data'] as Map<String, dynamic>;
      return Alert.fromApiJson(alertData);
    }
    
    // Fallback to cached data if API call fails
    final alertsAsync = ref.watch(alertsListProvider);
    if (alertsAsync.hasValue) {
      final alerts = alertsAsync.value!;
      for (final alert in alerts) {
        if (alert.id == alertId) {
          return alert;
        }
      }
    }
    
    return null;
  } catch (e) {
    print('Error fetching alert $alertId: $e');
    
    // If it's a 404 error or timeout, don't retry endlessly
    if (e.toString().contains('404') || e.toString().contains('timeout')) {
      print('Alert $alertId not found or timed out, checking cache only');
      
      // Check cache one time for 404/timeout cases
      final alertsAsync = ref.watch(alertsListProvider);
      if (alertsAsync.hasValue) {
        final alerts = alertsAsync.value!;
        for (final alert in alerts) {
          if (alert.id == alertId) {
            return alert;
          }
        }
      }
      
      // Return null immediately for 404 - don't keep retrying
      return null;
    }
    
    // For other errors, fallback to cached data
    final alertsAsync = ref.watch(alertsListProvider);
    if (alertsAsync.hasValue) {
      final alerts = alertsAsync.value!;
      for (final alert in alerts) {
        if (alert.id == alertId) {
          return alert;
        }
      }
    }
    
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