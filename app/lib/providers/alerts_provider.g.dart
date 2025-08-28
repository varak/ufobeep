// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertByIdHash() => r'5bfee04d98e30050c69655d2e0fa9571b52d02ec';

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
class AlertByIdFamily extends Family<AsyncValue<Alert?>> {
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
class AlertByIdProvider extends AutoDisposeFutureProvider<Alert?> {
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
  Override overrideWith(
    FutureOr<Alert?> Function(AlertByIdRef provider) create,
  ) {
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
  AutoDisposeFutureProviderElement<Alert?> createElement() {
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
mixin AlertByIdRef on AutoDisposeFutureProviderRef<Alert?> {
  /// The parameter `alertId` of this provider.
  String get alertId;
}

class _AlertByIdProviderElement extends AutoDisposeFutureProviderElement<Alert?>
    with AlertByIdRef {
  _AlertByIdProviderElement(super.provider);

  @override
  String get alertId => (origin as AlertByIdProvider).alertId;
}

String _$filteredAlertsHash() => r'958024ff2c22d58f5afd07a821e7ba30e736ab38';

/// See also [filteredAlerts].
@ProviderFor(filteredAlerts)
final filteredAlertsProvider = AutoDisposeFutureProvider<List<Alert>>.internal(
  filteredAlerts,
  name: r'filteredAlertsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredAlertsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredAlertsRef = AutoDisposeFutureProviderRef<List<Alert>>;
String _$nearbyAlertsHash() => r'a5ed4119c8f6dd47fb581b5eb6ef31ffea8a50cc';

/// See also [nearbyAlerts].
@ProviderFor(nearbyAlerts)
const nearbyAlertsProvider = NearbyAlertsFamily();

/// See also [nearbyAlerts].
class NearbyAlertsFamily extends Family<AsyncValue<List<Alert>>> {
  /// See also [nearbyAlerts].
  const NearbyAlertsFamily();

  /// See also [nearbyAlerts].
  NearbyAlertsProvider call({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    int? recentHours,
    String? minAlertLevel,
  }) {
    return NearbyAlertsProvider(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      recentHours: recentHours,
      minAlertLevel: minAlertLevel,
    );
  }

  @override
  NearbyAlertsProvider getProviderOverride(
    covariant NearbyAlertsProvider provider,
  ) {
    return call(
      latitude: provider.latitude,
      longitude: provider.longitude,
      radiusKm: provider.radiusKm,
      recentHours: provider.recentHours,
      minAlertLevel: provider.minAlertLevel,
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
  String? get name => r'nearbyAlertsProvider';
}

/// See also [nearbyAlerts].
class NearbyAlertsProvider extends AutoDisposeFutureProvider<List<Alert>> {
  /// See also [nearbyAlerts].
  NearbyAlertsProvider({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    int? recentHours,
    String? minAlertLevel,
  }) : this._internal(
         (ref) => nearbyAlerts(
           ref as NearbyAlertsRef,
           latitude: latitude,
           longitude: longitude,
           radiusKm: radiusKm,
           recentHours: recentHours,
           minAlertLevel: minAlertLevel,
         ),
         from: nearbyAlertsProvider,
         name: r'nearbyAlertsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$nearbyAlertsHash,
         dependencies: NearbyAlertsFamily._dependencies,
         allTransitiveDependencies:
             NearbyAlertsFamily._allTransitiveDependencies,
         latitude: latitude,
         longitude: longitude,
         radiusKm: radiusKm,
         recentHours: recentHours,
         minAlertLevel: minAlertLevel,
       );

  NearbyAlertsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.recentHours,
    required this.minAlertLevel,
  }) : super.internal();

  final double latitude;
  final double longitude;
  final double radiusKm;
  final int? recentHours;
  final String? minAlertLevel;

  @override
  Override overrideWith(
    FutureOr<List<Alert>> Function(NearbyAlertsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NearbyAlertsProvider._internal(
        (ref) => create(ref as NearbyAlertsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        recentHours: recentHours,
        minAlertLevel: minAlertLevel,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Alert>> createElement() {
    return _NearbyAlertsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyAlertsProvider &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radiusKm == radiusKm &&
        other.recentHours == recentHours &&
        other.minAlertLevel == minAlertLevel;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, latitude.hashCode);
    hash = _SystemHash.combine(hash, longitude.hashCode);
    hash = _SystemHash.combine(hash, radiusKm.hashCode);
    hash = _SystemHash.combine(hash, recentHours.hashCode);
    hash = _SystemHash.combine(hash, minAlertLevel.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NearbyAlertsRef on AutoDisposeFutureProviderRef<List<Alert>> {
  /// The parameter `latitude` of this provider.
  double get latitude;

  /// The parameter `longitude` of this provider.
  double get longitude;

  /// The parameter `radiusKm` of this provider.
  double get radiusKm;

  /// The parameter `recentHours` of this provider.
  int? get recentHours;

  /// The parameter `minAlertLevel` of this provider.
  String? get minAlertLevel;
}

class _NearbyAlertsProviderElement
    extends AutoDisposeFutureProviderElement<List<Alert>>
    with NearbyAlertsRef {
  _NearbyAlertsProviderElement(super.provider);

  @override
  double get latitude => (origin as NearbyAlertsProvider).latitude;
  @override
  double get longitude => (origin as NearbyAlertsProvider).longitude;
  @override
  double get radiusKm => (origin as NearbyAlertsProvider).radiusKm;
  @override
  int? get recentHours => (origin as NearbyAlertsProvider).recentHours;
  @override
  String? get minAlertLevel => (origin as NearbyAlertsProvider).minAlertLevel;
}

String _$alertsListHash() => r'07e10a0b38113262c119732aefaa9ecf0e3f7ef5';

/// See also [AlertsList].
@ProviderFor(AlertsList)
final alertsListProvider =
    AutoDisposeAsyncNotifierProvider<AlertsList, List<Alert>>.internal(
      AlertsList.new,
      name: r'alertsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alertsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AlertsList = AutoDisposeAsyncNotifier<List<Alert>>;
String _$alertsFilterStateHash() => r'5e990ab3d1c3ffd6b11c441b8a151b3462beec28';

/// See also [AlertsFilterState].
@ProviderFor(AlertsFilterState)
final alertsFilterStateProvider =
    AutoDisposeNotifierProvider<AlertsFilterState, AlertsFilter>.internal(
      AlertsFilterState.new,
      name: r'alertsFilterStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alertsFilterStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AlertsFilterState = AutoDisposeNotifier<AlertsFilter>;
String _$alertsLoadingStateHash() =>
    r'3a8e8035d79c4c54ab5e317f4a5f35bca8ffd05a';

/// See also [AlertsLoadingState].
@ProviderFor(AlertsLoadingState)
final alertsLoadingStateProvider =
    AutoDisposeNotifierProvider<AlertsLoadingState, bool>.internal(
      AlertsLoadingState.new,
      name: r'alertsLoadingStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alertsLoadingStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AlertsLoadingState = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
