// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_widget_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cassetteWidgetCoordinatorHash() =>
    r'743842af84a5671fd5005e3430706f1c4872ce83';

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

abstract class _$CassetteWidgetCoordinator
    extends BuildlessAutoDisposeNotifier<List<Widget>> {
  late final SidebarMode mode;

  List<Widget> build(SidebarMode mode);
}

/// Coordinates the construction of sidebar utility cassettes.
///
/// This provider reads the current [CassetteRack] from
/// [cassetteRackStateProvider] and transforms each [CassetteSpec] into
/// the corresponding [Widget] via the appropriate builder.  At this stage
/// only the top chat menu cassette is supported; additional cassette types
/// should be handled here as they are implemented.
/// Coordinates the construction of sidebar utility cassettes as a class-based
/// Riverpod notifier.
///
/// This notifier listens to the [cassetteRackStateProvider] and rebuilds
/// whenever the rack changes.  It converts each [CassetteSpec] in the rack
/// into a concrete [Widget] by delegating to the appropriate builder.
/// The top chat or settings menu are present by default.  Additional cassette
/// variants (e.g. unmatched handles, all messages) are added depending on user
/// actions and application state.
///
/// Copied from [CassetteWidgetCoordinator].
@ProviderFor(CassetteWidgetCoordinator)
const cassetteWidgetCoordinatorProvider = CassetteWidgetCoordinatorFamily();

/// Coordinates the construction of sidebar utility cassettes.
///
/// This provider reads the current [CassetteRack] from
/// [cassetteRackStateProvider] and transforms each [CassetteSpec] into
/// the corresponding [Widget] via the appropriate builder.  At this stage
/// only the top chat menu cassette is supported; additional cassette types
/// should be handled here as they are implemented.
/// Coordinates the construction of sidebar utility cassettes as a class-based
/// Riverpod notifier.
///
/// This notifier listens to the [cassetteRackStateProvider] and rebuilds
/// whenever the rack changes.  It converts each [CassetteSpec] in the rack
/// into a concrete [Widget] by delegating to the appropriate builder.
/// The top chat or settings menu are present by default.  Additional cassette
/// variants (e.g. unmatched handles, all messages) are added depending on user
/// actions and application state.
///
/// Copied from [CassetteWidgetCoordinator].
class CassetteWidgetCoordinatorFamily extends Family<List<Widget>> {
  /// Coordinates the construction of sidebar utility cassettes.
  ///
  /// This provider reads the current [CassetteRack] from
  /// [cassetteRackStateProvider] and transforms each [CassetteSpec] into
  /// the corresponding [Widget] via the appropriate builder.  At this stage
  /// only the top chat menu cassette is supported; additional cassette types
  /// should be handled here as they are implemented.
  /// Coordinates the construction of sidebar utility cassettes as a class-based
  /// Riverpod notifier.
  ///
  /// This notifier listens to the [cassetteRackStateProvider] and rebuilds
  /// whenever the rack changes.  It converts each [CassetteSpec] in the rack
  /// into a concrete [Widget] by delegating to the appropriate builder.
  /// The top chat or settings menu are present by default.  Additional cassette
  /// variants (e.g. unmatched handles, all messages) are added depending on user
  /// actions and application state.
  ///
  /// Copied from [CassetteWidgetCoordinator].
  const CassetteWidgetCoordinatorFamily();

  /// Coordinates the construction of sidebar utility cassettes.
  ///
  /// This provider reads the current [CassetteRack] from
  /// [cassetteRackStateProvider] and transforms each [CassetteSpec] into
  /// the corresponding [Widget] via the appropriate builder.  At this stage
  /// only the top chat menu cassette is supported; additional cassette types
  /// should be handled here as they are implemented.
  /// Coordinates the construction of sidebar utility cassettes as a class-based
  /// Riverpod notifier.
  ///
  /// This notifier listens to the [cassetteRackStateProvider] and rebuilds
  /// whenever the rack changes.  It converts each [CassetteSpec] in the rack
  /// into a concrete [Widget] by delegating to the appropriate builder.
  /// The top chat or settings menu are present by default.  Additional cassette
  /// variants (e.g. unmatched handles, all messages) are added depending on user
  /// actions and application state.
  ///
  /// Copied from [CassetteWidgetCoordinator].
  CassetteWidgetCoordinatorProvider call(SidebarMode mode) {
    return CassetteWidgetCoordinatorProvider(mode);
  }

  @override
  CassetteWidgetCoordinatorProvider getProviderOverride(
    covariant CassetteWidgetCoordinatorProvider provider,
  ) {
    return call(provider.mode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cassetteWidgetCoordinatorProvider';
}

/// Coordinates the construction of sidebar utility cassettes.
///
/// This provider reads the current [CassetteRack] from
/// [cassetteRackStateProvider] and transforms each [CassetteSpec] into
/// the corresponding [Widget] via the appropriate builder.  At this stage
/// only the top chat menu cassette is supported; additional cassette types
/// should be handled here as they are implemented.
/// Coordinates the construction of sidebar utility cassettes as a class-based
/// Riverpod notifier.
///
/// This notifier listens to the [cassetteRackStateProvider] and rebuilds
/// whenever the rack changes.  It converts each [CassetteSpec] in the rack
/// into a concrete [Widget] by delegating to the appropriate builder.
/// The top chat or settings menu are present by default.  Additional cassette
/// variants (e.g. unmatched handles, all messages) are added depending on user
/// actions and application state.
///
/// Copied from [CassetteWidgetCoordinator].
class CassetteWidgetCoordinatorProvider
    extends
        AutoDisposeNotifierProviderImpl<
          CassetteWidgetCoordinator,
          List<Widget>
        > {
  /// Coordinates the construction of sidebar utility cassettes.
  ///
  /// This provider reads the current [CassetteRack] from
  /// [cassetteRackStateProvider] and transforms each [CassetteSpec] into
  /// the corresponding [Widget] via the appropriate builder.  At this stage
  /// only the top chat menu cassette is supported; additional cassette types
  /// should be handled here as they are implemented.
  /// Coordinates the construction of sidebar utility cassettes as a class-based
  /// Riverpod notifier.
  ///
  /// This notifier listens to the [cassetteRackStateProvider] and rebuilds
  /// whenever the rack changes.  It converts each [CassetteSpec] in the rack
  /// into a concrete [Widget] by delegating to the appropriate builder.
  /// The top chat or settings menu are present by default.  Additional cassette
  /// variants (e.g. unmatched handles, all messages) are added depending on user
  /// actions and application state.
  ///
  /// Copied from [CassetteWidgetCoordinator].
  CassetteWidgetCoordinatorProvider(SidebarMode mode)
    : this._internal(
        () => CassetteWidgetCoordinator()..mode = mode,
        from: cassetteWidgetCoordinatorProvider,
        name: r'cassetteWidgetCoordinatorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cassetteWidgetCoordinatorHash,
        dependencies: CassetteWidgetCoordinatorFamily._dependencies,
        allTransitiveDependencies:
            CassetteWidgetCoordinatorFamily._allTransitiveDependencies,
        mode: mode,
      );

  CassetteWidgetCoordinatorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mode,
  }) : super.internal();

  final SidebarMode mode;

  @override
  List<Widget> runNotifierBuild(covariant CassetteWidgetCoordinator notifier) {
    return notifier.build(mode);
  }

  @override
  Override overrideWith(CassetteWidgetCoordinator Function() create) {
    return ProviderOverride(
      origin: this,
      override: CassetteWidgetCoordinatorProvider._internal(
        () => create()..mode = mode,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CassetteWidgetCoordinator, List<Widget>>
  createElement() {
    return _CassetteWidgetCoordinatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CassetteWidgetCoordinatorProvider && other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CassetteWidgetCoordinatorRef
    on AutoDisposeNotifierProviderRef<List<Widget>> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _CassetteWidgetCoordinatorProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          CassetteWidgetCoordinator,
          List<Widget>
        >
    with CassetteWidgetCoordinatorRef {
  _CassetteWidgetCoordinatorProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as CassetteWidgetCoordinatorProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
