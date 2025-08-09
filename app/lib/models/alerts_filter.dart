import 'package:json_annotation/json_annotation.dart';

part 'alerts_filter.g.dart';

@JsonSerializable()
class AlertsFilter {
  final Set<String> categories;
  final double? maxDistanceKm;
  final int? maxAgeHours;
  final bool? verifiedOnly;
  final AlertSortBy sortBy;
  final bool ascending;

  const AlertsFilter({
    this.categories = const {},
    this.maxDistanceKm,
    this.maxAgeHours,
    this.verifiedOnly,
    this.sortBy = AlertSortBy.newest,
    this.ascending = false,
  });

  factory AlertsFilter.fromJson(Map<String, dynamic> json) =>
      _$AlertsFilterFromJson(json);

  Map<String, dynamic> toJson() => _$AlertsFilterToJson(this);

  AlertsFilter copyWith({
    Set<String>? categories,
    double? maxDistanceKm,
    int? maxAgeHours,
    bool? verifiedOnly,
    AlertSortBy? sortBy,
    bool? ascending,
  }) {
    return AlertsFilter(
      categories: categories ?? this.categories,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      maxAgeHours: maxAgeHours ?? this.maxAgeHours,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  // Clear specific filter
  AlertsFilter clearDistance() => copyWith(maxDistanceKm: null);
  AlertsFilter clearAge() => copyWith(maxAgeHours: null);
  AlertsFilter clearVerified() => copyWith(verifiedOnly: null);
  AlertsFilter clearCategories() => copyWith(categories: const {});

  // Reset all filters
  AlertsFilter reset() => const AlertsFilter();

  // Check if any filters are active
  bool get hasActiveFilters {
    return categories.isNotEmpty ||
           maxDistanceKm != null ||
           maxAgeHours != null ||
           verifiedOnly != null;
  }

  // Get filter summary for UI
  String get filterSummary {
    final parts = <String>[];
    
    if (categories.isNotEmpty) {
      parts.add('${categories.length} category${categories.length > 1 ? 'ies' : ''}');
    }
    
    if (maxDistanceKm != null) {
      parts.add('≤${maxDistanceKm!.toInt()}km');
    }
    
    if (maxAgeHours != null) {
      if (maxAgeHours! < 24) {
        parts.add('≤${maxAgeHours}h');
      } else {
        parts.add('≤${(maxAgeHours! / 24).toInt()}d');
      }
    }
    
    if (verifiedOnly == true) {
      parts.add('verified only');
    }
    
    return parts.isEmpty ? 'All alerts' : parts.join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertsFilter &&
          runtimeType == other.runtimeType &&
          categories.length == other.categories.length &&
          categories.every((cat) => other.categories.contains(cat)) &&
          maxDistanceKm == other.maxDistanceKm &&
          maxAgeHours == other.maxAgeHours &&
          verifiedOnly == other.verifiedOnly &&
          sortBy == other.sortBy &&
          ascending == other.ascending;

  @override
  int get hashCode => Object.hash(
        categories,
        maxDistanceKm,
        maxAgeHours,
        verifiedOnly,
        sortBy,
        ascending,
      );

  @override
  String toString() {
    return 'AlertsFilter{'
        'categories: $categories, '
        'maxDistanceKm: $maxDistanceKm, '
        'maxAgeHours: $maxAgeHours, '
        'verifiedOnly: $verifiedOnly, '
        'sortBy: $sortBy, '
        'ascending: $ascending'
        '}';
  }
}

enum AlertSortBy {
  newest,
  oldest,
  distance,
  category,
  verified,
}

// Extension for better display names
extension AlertSortByExtension on AlertSortBy {
  String get displayName {
    switch (this) {
      case AlertSortBy.newest:
        return 'Newest First';
      case AlertSortBy.oldest:
        return 'Oldest First';
      case AlertSortBy.distance:
        return 'Distance';
      case AlertSortBy.category:
        return 'Category';
      case AlertSortBy.verified:
        return 'Verified First';
    }
  }

  String get shortName {
    switch (this) {
      case AlertSortBy.newest:
        return 'Newest';
      case AlertSortBy.oldest:
        return 'Oldest';
      case AlertSortBy.distance:
        return 'Distance';
      case AlertSortBy.category:
        return 'Category';
      case AlertSortBy.verified:
        return 'Verified';
    }
  }
}

// Alert categories with metadata
class AlertCategory {
  final String key;
  final String displayName;
  final String icon;
  final String color;
  final String description;

  const AlertCategory({
    required this.key,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.description,
  });

  static const List<AlertCategory> all = [
    AlertCategory(
      key: 'ufo',
      displayName: 'UFO Sightings',
      icon: '👽',
      color: 'primary',
      description: 'Unidentified flying objects and anomalous phenomena',
    ),
    AlertCategory(
      key: 'missing_pet',
      displayName: 'Missing Pets',
      icon: '🐾',
      color: 'warning',
      description: 'Lost cats, dogs, and other pets',
    ),
    AlertCategory(
      key: 'missing_person',
      displayName: 'Missing Persons',
      icon: '🔍',
      color: 'error',
      description: 'Missing people alerts',
    ),
    AlertCategory(
      key: 'suspicious',
      displayName: 'Suspicious Activity',
      icon: '⚠️',
      color: 'warning',
      description: 'Unusual or suspicious activity',
    ),
    AlertCategory(
      key: 'other',
      displayName: 'Other',
      icon: '❓',
      color: 'secondary',
      description: 'Other types of alerts',
    ),
  ];

  static AlertCategory? getByKey(String key) {
    try {
      return all.firstWhere((cat) => cat.key == key);
    } catch (e) {
      return null;
    }
  }
}

// Predefined filter presets
class FilterPresets {
  static const AlertsFilter all = AlertsFilter();
  
  static const AlertsFilter nearby = AlertsFilter(
    maxDistanceKm: 5.0,
    sortBy: AlertSortBy.distance,
  );
  
  static const AlertsFilter recent = AlertsFilter(
    maxAgeHours: 24,
    sortBy: AlertSortBy.newest,
  );
  
  static const AlertsFilter verified = AlertsFilter(
    verifiedOnly: true,
    sortBy: AlertSortBy.verified,
  );
  
  static const AlertsFilter ufoOnly = AlertsFilter(
    categories: {'ufo'},
    sortBy: AlertSortBy.newest,
  );

  static const List<AlertsFilter> presets = [
    all,
    nearby,
    recent,
    verified,
    ufoOnly,
  ];

  static List<String> get presetNames => [
    'All Alerts',
    'Nearby (5km)',
    'Recent (24h)',
    'Verified Only',
    'UFOs Only',
  ];
}