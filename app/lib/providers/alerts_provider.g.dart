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

String _$filteredAlertsHash() => r'4c257aa9e3b5ba00657ef82fbcb96c5cf2ca228c';

/// See also [filteredAlerts].
@ProviderFor(filteredAlerts)
final filteredAlertsProvider = AutoDisposeProvider<List<Alert>>.internal(
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
typedef FilteredAlertsRef = AutoDisposeProviderRef<List<Alert>>;
String _$alertsListHash() => r'3b2ff94061e946e381fea10247763c03087723a5';

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
    r'de352779e2e2a2420e0855a5d225ddb9e8e1cfef';

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
