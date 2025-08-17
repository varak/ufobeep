// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertByIdHash() => r'5c6a2a5b8c9d1e2f3a4b5c6d7e8f9a0b1c2d3e4f';

/// See also [alertById].
@ProviderFor(alertById)
const alertByIdProvider = AlertByIdFamily();

/// See also [alertById].
class AlertByIdFamily extends Family<AsyncValue<Alert?>> {
  /// See also [alertById].
  const AlertByIdFamily();

  /// See also [alertById].
  AlertByIdProvider call(
    String alertId,
  ) {
    return AlertByIdProvider(
      alertId,
    );
  }

  @override
  AlertByIdProvider getProviderOverride(
    covariant AlertByIdProvider provider,
  ) {
    return call(
      provider.alertId,
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
  String? get name => r'alertByIdProvider';
}

/// See also [alertById].
class AlertByIdProvider extends AutoDisposeFutureProvider<Alert?> {
  /// See also [alertById].
  AlertByIdProvider(
    String alertId,
  ) : this._internal(
          (ref) => alertById(
            ref as AlertByIdRef,
            alertId,
          ),
          from: alertByIdProvider,
          name: r'alertByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$alertByIdHash,
          dependencies: AlertByIdFamily._dependencies,
          allTransitiveDependencies:
              AlertByIdFamily._allTransitiveDependencies,
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

mixin AlertByIdRef on AutoDisposeFutureProviderRef<Alert?> {
  /// The parameter `alertId` of this provider.
  String get alertId;
}

class _AlertByIdProviderElement
    extends AutoDisposeFutureProviderElement<Alert?> with AlertByIdRef {
  _AlertByIdProviderElement(super.provider);

  @override
  String get alertId => (origin as AlertByIdProvider).alertId;
}

String _$filteredAlertsHash() => r'3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f';

/// See also [filteredAlerts].
@ProviderFor(filteredAlerts)
final filteredAlertsProvider =
    AutoDisposeFutureProvider<List<Alert>>.internal(
  filteredAlerts,
  name: r'filteredAlertsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredAlertsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredAlertsRef = AutoDisposeFutureProviderRef<List<Alert>>;
String _$nearbyAlertsHash() => r'1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a';

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
    double radiusKm = 10.0,
  }) {
    return NearbyAlertsProvider(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
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
    double radiusKm = 10.0,
  }) : this._internal(
          (ref) => nearbyAlerts(
            ref as NearbyAlertsRef,
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
          ),
          from: nearbyAlertsProvider,
          name: r'nearbyAlertsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$nearbyAlertsHash,
          dependencies: NearbyAlertsFamily._dependencies,
          allTransitiveDependencies:
              NearbyAlertsFamily._allTransitiveDependencies,
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
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
  }) : super.internal();

  final double latitude;
  final double longitude;
  final double radiusKm;

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
        other.radiusKm == radiusKm;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, latitude.hashCode);
    hash = _SystemHash.combine(hash, longitude.hashCode);
    hash = _SystemHash.combine(hash, radiusKm.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NearbyAlertsRef on AutoDisposeFutureProviderRef<List<Alert>> {
  /// The parameter `latitude` of this provider.
  double get latitude;

  /// The parameter `longitude` of this provider.
  double get longitude;

  /// The parameter `radiusKm` of this provider.
  double get radiusKm;
}

class _NearbyAlertsProviderElement
    extends AutoDisposeFutureProviderElement<List<Alert>> with NearbyAlertsRef {
  _NearbyAlertsProviderElement(super.provider);

  @override
  double get latitude => (origin as NearbyAlertsProvider).latitude;
  @override
  double get longitude => (origin as NearbyAlertsProvider).longitude;
  @override
  double get radiusKm => (origin as NearbyAlertsProvider).radiusKm;
}

String _$alertsListHash() => r'9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a';

/// See also [AlertsList].
@ProviderFor(AlertsList)
final alertsListProvider =
    AutoDisposeAsyncNotifierProvider<AlertsList, List<Alert>>.internal(
  AlertsList.new,
  name: r'alertsListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$alertsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertsList = AutoDisposeAsyncNotifier<List<Alert>>;

String _$alertsFilterStateHash() => r'2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e';

/// See also [AlertsFilterState].
@ProviderFor(AlertsFilterState)
final alertsFilterStateProvider = AutoDisposeNotifierProvider<AlertsFilterState,
    AlertsFilter>.internal(
  AlertsFilterState.new,
  name: r'alertsFilterStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertsFilterStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertsFilterState = AutoDisposeNotifier<AlertsFilter>;

String _$alertsLoadingStateHash() => r'4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c';

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

abstract class _SystemHash {
  static int combine(int hash, int value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}