// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enriched_alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$enrichedAlertByIdHash() => r'89ae214209969aa52bdfa8e17ae237547d73684e';

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

/// Single enriched alert provider
///
/// Copied from [enrichedAlertById].
@ProviderFor(enrichedAlertById)
const enrichedAlertByIdProvider = EnrichedAlertByIdFamily();

/// Single enriched alert provider
///
/// Copied from [enrichedAlertById].
class EnrichedAlertByIdFamily extends Family<AsyncValue<EnrichedAlert?>> {
  /// Single enriched alert provider
  ///
  /// Copied from [enrichedAlertById].
  const EnrichedAlertByIdFamily();

  /// Single enriched alert provider
  ///
  /// Copied from [enrichedAlertById].
  EnrichedAlertByIdProvider call(String alertId) {
    return EnrichedAlertByIdProvider(alertId);
  }

  @override
  EnrichedAlertByIdProvider getProviderOverride(
    covariant EnrichedAlertByIdProvider provider,
  ) {
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
  String? get name => r'enrichedAlertByIdProvider';
}

/// Single enriched alert provider
///
/// Copied from [enrichedAlertById].
class EnrichedAlertByIdProvider
    extends AutoDisposeFutureProvider<EnrichedAlert?> {
  /// Single enriched alert provider
  ///
  /// Copied from [enrichedAlertById].
  EnrichedAlertByIdProvider(String alertId)
    : this._internal(
        (ref) => enrichedAlertById(ref as EnrichedAlertByIdRef, alertId),
        from: enrichedAlertByIdProvider,
        name: r'enrichedAlertByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$enrichedAlertByIdHash,
        dependencies: EnrichedAlertByIdFamily._dependencies,
        allTransitiveDependencies:
            EnrichedAlertByIdFamily._allTransitiveDependencies,
        alertId: alertId,
      );

  EnrichedAlertByIdProvider._internal(
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
    FutureOr<EnrichedAlert?> Function(EnrichedAlertByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EnrichedAlertByIdProvider._internal(
        (ref) => create(ref as EnrichedAlertByIdRef),
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
  AutoDisposeFutureProviderElement<EnrichedAlert?> createElement() {
    return _EnrichedAlertByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EnrichedAlertByIdProvider && other.alertId == alertId;
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
mixin EnrichedAlertByIdRef on AutoDisposeFutureProviderRef<EnrichedAlert?> {
  /// The parameter `alertId` of this provider.
  String get alertId;
}

class _EnrichedAlertByIdProviderElement
    extends AutoDisposeFutureProviderElement<EnrichedAlert?>
    with EnrichedAlertByIdRef {
  _EnrichedAlertByIdProviderElement(super.provider);

  @override
  String get alertId => (origin as EnrichedAlertByIdProvider).alertId;
}

String _$filteredEnrichedAlertsHash() =>
    r'6a65aac50ba60f3feb6c7d4abf36bfa8625f242c';

/// Filtered enriched alerts provider with quarantine handling
///
/// Copied from [filteredEnrichedAlerts].
@ProviderFor(filteredEnrichedAlerts)
const filteredEnrichedAlertsProvider = FilteredEnrichedAlertsFamily();

/// Filtered enriched alerts provider with quarantine handling
///
/// Copied from [filteredEnrichedAlerts].
class FilteredEnrichedAlertsFamily
    extends Family<AsyncValue<List<EnrichedAlert>>> {
  /// Filtered enriched alerts provider with quarantine handling
  ///
  /// Copied from [filteredEnrichedAlerts].
  const FilteredEnrichedAlertsFamily();

  /// Filtered enriched alerts provider with quarantine handling
  ///
  /// Copied from [filteredEnrichedAlerts].
  FilteredEnrichedAlertsProvider call({
    bool includeQuarantined = false,
    bool isPublicContext = true,
    String? currentUserId,
    bool isModerator = false,
  }) {
    return FilteredEnrichedAlertsProvider(
      includeQuarantined: includeQuarantined,
      isPublicContext: isPublicContext,
      currentUserId: currentUserId,
      isModerator: isModerator,
    );
  }

  @override
  FilteredEnrichedAlertsProvider getProviderOverride(
    covariant FilteredEnrichedAlertsProvider provider,
  ) {
    return call(
      includeQuarantined: provider.includeQuarantined,
      isPublicContext: provider.isPublicContext,
      currentUserId: provider.currentUserId,
      isModerator: provider.isModerator,
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
  String? get name => r'filteredEnrichedAlertsProvider';
}

/// Filtered enriched alerts provider with quarantine handling
///
/// Copied from [filteredEnrichedAlerts].
class FilteredEnrichedAlertsProvider
    extends AutoDisposeFutureProvider<List<EnrichedAlert>> {
  /// Filtered enriched alerts provider with quarantine handling
  ///
  /// Copied from [filteredEnrichedAlerts].
  FilteredEnrichedAlertsProvider({
    bool includeQuarantined = false,
    bool isPublicContext = true,
    String? currentUserId,
    bool isModerator = false,
  }) : this._internal(
         (ref) => filteredEnrichedAlerts(
           ref as FilteredEnrichedAlertsRef,
           includeQuarantined: includeQuarantined,
           isPublicContext: isPublicContext,
           currentUserId: currentUserId,
           isModerator: isModerator,
         ),
         from: filteredEnrichedAlertsProvider,
         name: r'filteredEnrichedAlertsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$filteredEnrichedAlertsHash,
         dependencies: FilteredEnrichedAlertsFamily._dependencies,
         allTransitiveDependencies:
             FilteredEnrichedAlertsFamily._allTransitiveDependencies,
         includeQuarantined: includeQuarantined,
         isPublicContext: isPublicContext,
         currentUserId: currentUserId,
         isModerator: isModerator,
       );

  FilteredEnrichedAlertsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.includeQuarantined,
    required this.isPublicContext,
    required this.currentUserId,
    required this.isModerator,
  }) : super.internal();

  final bool includeQuarantined;
  final bool isPublicContext;
  final String? currentUserId;
  final bool isModerator;

  @override
  Override overrideWith(
    FutureOr<List<EnrichedAlert>> Function(FilteredEnrichedAlertsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredEnrichedAlertsProvider._internal(
        (ref) => create(ref as FilteredEnrichedAlertsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        includeQuarantined: includeQuarantined,
        isPublicContext: isPublicContext,
        currentUserId: currentUserId,
        isModerator: isModerator,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<EnrichedAlert>> createElement() {
    return _FilteredEnrichedAlertsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredEnrichedAlertsProvider &&
        other.includeQuarantined == includeQuarantined &&
        other.isPublicContext == isPublicContext &&
        other.currentUserId == currentUserId &&
        other.isModerator == isModerator;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, includeQuarantined.hashCode);
    hash = _SystemHash.combine(hash, isPublicContext.hashCode);
    hash = _SystemHash.combine(hash, currentUserId.hashCode);
    hash = _SystemHash.combine(hash, isModerator.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredEnrichedAlertsRef
    on AutoDisposeFutureProviderRef<List<EnrichedAlert>> {
  /// The parameter `includeQuarantined` of this provider.
  bool get includeQuarantined;

  /// The parameter `isPublicContext` of this provider.
  bool get isPublicContext;

  /// The parameter `currentUserId` of this provider.
  String? get currentUserId;

  /// The parameter `isModerator` of this provider.
  bool get isModerator;
}

class _FilteredEnrichedAlertsProviderElement
    extends AutoDisposeFutureProviderElement<List<EnrichedAlert>>
    with FilteredEnrichedAlertsRef {
  _FilteredEnrichedAlertsProviderElement(super.provider);

  @override
  bool get includeQuarantined =>
      (origin as FilteredEnrichedAlertsProvider).includeQuarantined;
  @override
  bool get isPublicContext =>
      (origin as FilteredEnrichedAlertsProvider).isPublicContext;
  @override
  String? get currentUserId =>
      (origin as FilteredEnrichedAlertsProvider).currentUserId;
  @override
  bool get isModerator =>
      (origin as FilteredEnrichedAlertsProvider).isModerator;
}

String _$quarantineSummaryHash() => r'fa432e1bba05d678399b3ac3a302ab5c6a158907';

/// Quarantine summary provider for moderation dashboard
///
/// Copied from [quarantineSummary].
@ProviderFor(quarantineSummary)
final quarantineSummaryProvider =
    AutoDisposeFutureProvider<QuarantineSummary>.internal(
      quarantineSummary,
      name: r'quarantineSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$quarantineSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuarantineSummaryRef = AutoDisposeFutureProviderRef<QuarantineSummary>;
String _$enrichedAlertsListHash() =>
    r'424f91ebc2502747d002f5c20ce7b0a09835a889';

/// Provider for enriched alerts with quarantine handling
///
/// Copied from [EnrichedAlertsList].
@ProviderFor(EnrichedAlertsList)
final enrichedAlertsListProvider =
    AutoDisposeAsyncNotifierProvider<
      EnrichedAlertsList,
      List<EnrichedAlert>
    >.internal(
      EnrichedAlertsList.new,
      name: r'enrichedAlertsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$enrichedAlertsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EnrichedAlertsList = AutoDisposeAsyncNotifier<List<EnrichedAlert>>;
String _$userContextHash() => r'67ad607e040deaeefeafac92df497bacea1db090';

/// User context provider for quarantine filtering
///
/// Copied from [UserContext].
@ProviderFor(UserContext)
final userContextProvider =
    AutoDisposeNotifierProvider<UserContext, UserContextData>.internal(
      UserContext.new,
      name: r'userContextProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userContextHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserContext = AutoDisposeNotifier<UserContextData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
