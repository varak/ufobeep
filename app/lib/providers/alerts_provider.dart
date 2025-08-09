import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    // Mock data for now
    return [
      Alert(
        id: '1',
        title: 'Strange Lights',
        description: 'Unusual formation of bright lights moving in coordinated pattern',
        latitude: 37.7749,
        longitude: -122.4194,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        mediaUrl: 'https://example.com/image1.jpg',
        distance: 2.3,
        bearing: 45.0,
        category: 'ufo',
        isVerified: true,
      ),
      Alert(
        id: '2',
        title: 'Missing Cat',
        description: 'Orange tabby cat, last seen near the park',
        latitude: 37.7849,
        longitude: -122.4094,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        mediaUrl: 'https://example.com/image2.jpg',
        distance: 1.1,
        bearing: 120.0,
        category: 'missing_pet',
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

// Filtered Alerts Provider
@riverpod
List<Alert> filteredAlerts(FilteredAlertsRef ref, {
  String? category,
  double? maxDistance,
  bool? verified,
}) {
  final alerts = ref.watch(alertsListProvider);
  
  return alerts.where((alert) {
    if (category != null && alert.category != category) return false;
    if (maxDistance != null && alert.distance != null && alert.distance! > maxDistance) return false;
    if (verified != null && alert.isVerified != verified) return false;
    return true;
  }).toList();
}