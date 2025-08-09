import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/alerts_filter.dart';

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
    required this.mediaUrl,
    this.distance,
    this.bearing,
    this.category = 'unknown',
    this.isVerified = false,
  });

  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String mediaUrl;
  final double? distance;
  final double? bearing;
  final String category;
  final bool isVerified;

  Alert copyWith({
    String? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    String? mediaUrl,
    double? distance,
    double? bearing,
    String? category,
    bool? isVerified,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      distance: distance ?? this.distance,
      bearing: bearing ?? this.bearing,
      category: category ?? this.category,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

// Alerts List Provider
@riverpod
class AlertsList extends _$AlertsList {
  @override
  List<Alert> build() {
    // Enhanced mock data for testing filters and UI
    return [
      Alert(
        id: '1',
        title: 'Triangle Formation',
        description: 'Three bright lights in perfect triangular formation, moving silently across the sky at high speed',
        latitude: 37.7749,
        longitude: -122.4194,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        mediaUrl: 'https://example.com/ufo1.jpg',
        distance: 2.3,
        bearing: 45.0,
        category: 'ufo',
        isVerified: true,
      ),
      Alert(
        id: '2',
        title: 'Missing Orange Tabby',
        description: 'Fluffy orange tabby cat "Whiskers", wearing blue collar, last seen near Dolores Park',
        latitude: 37.7849,
        longitude: -122.4094,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        mediaUrl: 'https://example.com/cat1.jpg',
        distance: 1.1,
        bearing: 120.0,
        category: 'missing_pet',
        isVerified: false,
      ),
      Alert(
        id: '3',
        title: 'Disc-Shaped Craft',
        description: 'Large metallic disc hovering above the Golden Gate Bridge for approximately 10 minutes',
        latitude: 37.8199,
        longitude: -122.4783,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        mediaUrl: 'https://example.com/ufo2.jpg',
        distance: 8.7,
        bearing: 315.0,
        category: 'ufo',
        isVerified: true,
      ),
      Alert(
        id: '4',
        title: 'Missing Person - Sarah Chen',
        description: 'Last seen wearing red jacket near Castro District, 5\'4", black hair, contact police immediately',
        latitude: 37.7609,
        longitude: -122.4350,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        mediaUrl: 'https://example.com/missing1.jpg',
        distance: 3.2,
        bearing: 180.0,
        category: 'missing_person',
        isVerified: true,
      ),
      Alert(
        id: '5',
        title: 'Pulsating Orb',
        description: 'Bright white orb pulsating with different colors, stationary for 20+ minutes then disappeared instantly',
        latitude: 37.7849,
        longitude: -122.4094,
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        mediaUrl: 'https://example.com/ufo3.jpg',
        distance: 1.8,
        bearing: 90.0,
        category: 'ufo',
        isVerified: false,
      ),
      Alert(
        id: '6',
        title: 'Missing Small Dog',
        description: 'Yorkshire Terrier "Buddy", very friendly, escaped from yard on 24th Street',
        latitude: 37.7749,
        longitude: -122.4194,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        mediaUrl: 'https://example.com/dog1.jpg',
        distance: 2.3,
        bearing: 270.0,
        category: 'missing_pet',
        isVerified: false,
      ),
      Alert(
        id: '7',
        title: 'Unusual Aircraft',
        description: 'Silent triangular craft with no visible propulsion, moving at impossible speeds and angles',
        latitude: 37.8044,
        longitude: -122.2712,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        mediaUrl: 'https://example.com/ufo4.jpg',
        distance: 15.2,
        bearing: 60.0,
        category: 'ufo',
        isVerified: false,
      ),
      Alert(
        id: '8',
        title: 'Suspicious Activity',
        description: 'Unmarked vans circling neighborhood repeatedly, occupants taking photos of houses',
        latitude: 37.7749,
        longitude: -122.4194,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        mediaUrl: 'https://example.com/suspicious1.jpg',
        distance: 0.8,
        bearing: 225.0,
        category: 'suspicious',
        isVerified: false,
      ),
    ];
  }

  void addAlert(Alert alert) {
    state = [alert, ...state];
  }

  void removeAlert(String alertId) {
    state = state.where((alert) => alert.id != alertId).toList();
  }

  void updateAlert(Alert updatedAlert) {
    state = state.map((alert) {
      return alert.id == updatedAlert.id ? updatedAlert : alert;
    }).toList();
  }
}

// Single Alert Provider
@riverpod
Alert? alertById(AlertByIdRef ref, String alertId) {
  final alerts = ref.watch(alertsListProvider);
  try {
    return alerts.firstWhere((alert) => alert.id == alertId);
  } catch (e) {
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
    return false;
  }

  void setLoading(bool loading) {
    state = loading;
  }

  Future<void> refresh() async {
    state = true;
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Refresh alerts data
    ref.invalidate(alertsListProvider);
    
    state = false;
  }
}

// Filtered and Sorted Alerts Provider
@riverpod
List<Alert> filteredAlerts(FilteredAlertsRef ref) {
  final alerts = ref.watch(alertsListProvider);
  final filter = ref.watch(alertsFilterStateProvider);
  
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
    
    return filter.ascending ? comparison : -comparison;
  });

  return filteredAlerts;
}