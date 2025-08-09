// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertByIdHash() => r'eba7c709e9fdf2702cc5f6ddd95e1c8549588357';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [alertById].
@ProviderFor(alertById)
const alertByIdProvider = AlertByIdFamily();

/// See also [alertById].
class AlertByIdFamily extends Family<Alert?> {
  /// See also [alertById].
  const AlertByIdFamily();

  /// See also [alertById].
  AlertByIdProvider call(String alertId) {
    return AlertByIdProvider(alertId);
  }

  @override
  AlertByIdProvider getProviderOverride(covariant AlertByIdProvider provider) {
    return call(provider.alertId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'alertByIdProvider';
}

/// See also [alertById].
class AlertByIdProvider extends AutoDisposeProvider<Alert?> {
  /// See also [alertById].
  AlertByIdProvider(String alertId)
    : this._internal(
        (ref) => alertById(ref as AlertByIdRef, alertId),
        from: alertByIdProvider,
        name: r'alertByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$alertByIdHash,
        dependencies: AlertByIdFamily._dependencies,
        allTransitiveDependencies: AlertByIdFamily._allTransitiveDependencies,
        alertId: alertId,
      );

  AlertByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.alertId,
  }) : super.internal();

  final String alertId;

  @override
  Override overrideWith(Alert? Function(AlertByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: AlertByIdProvider._internal(
        (ref) => create(ref as AlertByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        alertId: alertId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Alert?> createElement() {
    return _AlertByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AlertByIdProvider && other.alertId == alertId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, alertId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AlertByIdRef on AutoDisposeProviderRef<Alert?> {
  /// The parameter `alertId` of this provider.
  String get alertId;
}

class _AlertByIdProviderElement extends AutoDisposeProviderElement<Alert?>
    with AlertByIdRef {
  _AlertByIdProviderElement(super.provider);

  @override
  String get alertId => (origin as AlertByIdProvider).alertId;
}

String _$filteredAlertsHash() => r'cfbe62ddfbd0de500da52f588b57badd8b1677c7';

/// See also [filteredAlerts].
@ProviderFor(filteredAlerts)
const filteredAlertsProvider = FilteredAlertsFamily();

/// See also [filteredAlerts].
class FilteredAlertsFamily extends Family<List<Alert>> {
  /// See also [filteredAlerts].
  const FilteredAlertsFamily();

  /// See also [filteredAlerts].
  FilteredAlertsProvider call({
    String? category,
    double? maxDistance,
    bool? verified,
  }) {
    return FilteredAlertsProvider(
      category: category,
      maxDistance: maxDistance,
      verified: verified,
    );
  }

  @override
  FilteredAlertsProvider getProviderOverride(
    covariant FilteredAlertsProvider provider,
  ) {
    return call(
      category: provider.category,
      maxDistance: provider.maxDistance,
      verified: provider.verified,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredAlertsProvider';
}

/// See also [filteredAlerts].
class FilteredAlertsProvider extends AutoDisposeProvider<List<Alert>> {
  /// See also [filteredAlerts].
  FilteredAlertsProvider({
    String? category,
    double? maxDistance,
    bool? verified,
  }) : this._internal(
         (ref) => filteredAlerts(
           ref as FilteredAlertsRef,
           category: category,
           maxDistance: maxDistance,
           verified: verified,
         ),
         from: filteredAlertsProvider,
         name: r'filteredAlertsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$filteredAlertsHash,
         dependencies: FilteredAlertsFamily._dependencies,
         allTransitiveDependencies:
             FilteredAlertsFamily._allTransitiveDependencies,
         category: category,
         maxDistance: maxDistance,
         verified: verified,
       );

  FilteredAlertsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
    required this.maxDistance,
    required this.verified,
  }) : super.internal();

  final String? category;
  final double? maxDistance;
  final bool? verified;

  @override
  Override overrideWith(
    List<Alert> Function(FilteredAlertsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredAlertsProvider._internal(
        (ref) => create(ref as FilteredAlertsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
        maxDistance: maxDistance,
        verified: verified,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Alert>> createElement() {
    return _FilteredAlertsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredAlertsProvider &&
        other.category == category &&
        other.maxDistance == maxDistance &&
        other.verified == verified;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);
    hash = _SystemHash.combine(hash, maxDistance.hashCode);
    hash = _SystemHash.combine(hash, verified.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredAlertsRef on AutoDisposeProviderRef<List<Alert>> {
  /// The parameter `category` of this provider.
  String? get category;

  /// The parameter `maxDistance` of this provider.
  double? get maxDistance;

  /// The parameter `verified` of this provider.
  bool? get verified;
}

class _FilteredAlertsProviderElement
    extends AutoDisposeProviderElement<List<Alert>>
    with FilteredAlertsRef {
  _FilteredAlertsProviderElement(super.provider);

  @override
  String? get category => (origin as FilteredAlertsProvider).category;
  @override
  double? get maxDistance => (origin as FilteredAlertsProvider).maxDistance;
  @override
  bool? get verified => (origin as FilteredAlertsProvider).verified;
}

String _$alertsListHash() => r'a3db99b4ff2f15f82c9740362bd47bd93ffd3a15';

/// See also [AlertsList].
@ProviderFor(AlertsList)
final alertsListProvider =
    AutoDisposeNotifierProvider<AlertsList, List<Alert>>.internal(
      AlertsList.new,
      name: r'alertsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alertsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AlertsList = AutoDisposeNotifier<List<Alert>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
