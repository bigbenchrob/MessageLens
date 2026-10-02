// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_widget_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resolvedSidebarCassetteHash() =>
    r'4a29341060bc15f5d583b9a412aec75644288c7b';

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

/// See also [resolvedSidebarCassette].
@ProviderFor(resolvedSidebarCassette)
const resolvedSidebarCassetteProvider = ResolvedSidebarCassetteFamily();

/// See also [resolvedSidebarCassette].
class ResolvedSidebarCassetteFamily
    extends Family<AsyncValue<ResolvedSidebarCassette>> {
  /// See also [resolvedSidebarCassette].
  const ResolvedSidebarCassetteFamily();

  /// See also [resolvedSidebarCassette].
  ResolvedSidebarCassetteProvider call(
    SidebarMode mode,
    CassetteSpec spec,
    int cassetteIndex,
  ) {
    return ResolvedSidebarCassetteProvider(mode, spec, cassetteIndex);
  }

  @override
  ResolvedSidebarCassetteProvider getProviderOverride(
    covariant ResolvedSidebarCassetteProvider provider,
  ) {
    return call(provider.mode, provider.spec, provider.cassetteIndex);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'resolvedSidebarCassetteProvider';
}

/// See also [resolvedSidebarCassette].
class ResolvedSidebarCassetteProvider
    extends AutoDisposeFutureProvider<ResolvedSidebarCassette> {
  /// See also [resolvedSidebarCassette].
  ResolvedSidebarCassetteProvider(
    SidebarMode mode,
    CassetteSpec spec,
    int cassetteIndex,
  ) : this._internal(
        (ref) => resolvedSidebarCassette(
          ref as ResolvedSidebarCassetteRef,
          mode,
          spec,
          cassetteIndex,
        ),
        from: resolvedSidebarCassetteProvider,
        name: r'resolvedSidebarCassetteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$resolvedSidebarCassetteHash,
        dependencies: ResolvedSidebarCassetteFamily._dependencies,
        allTransitiveDependencies:
            ResolvedSidebarCassetteFamily._allTransitiveDependencies,
        mode: mode,
        spec: spec,
        cassetteIndex: cassetteIndex,
      );

  ResolvedSidebarCassetteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mode,
    required this.spec,
    required this.cassetteIndex,
  }) : super.internal();

  final SidebarMode mode;
  final CassetteSpec spec;
  final int cassetteIndex;

  @override
  Override overrideWith(
    FutureOr<ResolvedSidebarCassette> Function(
      ResolvedSidebarCassetteRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ResolvedSidebarCassetteProvider._internal(
        (ref) => create(ref as ResolvedSidebarCassetteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mode: mode,
        spec: spec,
        cassetteIndex: cassetteIndex,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ResolvedSidebarCassette> createElement() {
    return _ResolvedSidebarCassetteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResolvedSidebarCassetteProvider &&
        other.mode == mode &&
        other.spec == spec &&
        other.cassetteIndex == cassetteIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);
    hash = _SystemHash.combine(hash, spec.hashCode);
    hash = _SystemHash.combine(hash, cassetteIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResolvedSidebarCassetteRef
    on AutoDisposeFutureProviderRef<ResolvedSidebarCassette> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;

  /// The parameter `spec` of this provider.
  CassetteSpec get spec;

  /// The parameter `cassetteIndex` of this provider.
  int get cassetteIndex;
}

class _ResolvedSidebarCassetteProviderElement
    extends AutoDisposeFutureProviderElement<ResolvedSidebarCassette>
    with ResolvedSidebarCassetteRef {
  _ResolvedSidebarCassetteProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as ResolvedSidebarCassetteProvider).mode;
  @override
  CassetteSpec get spec => (origin as ResolvedSidebarCassetteProvider).spec;
  @override
  int get cassetteIndex =>
      (origin as ResolvedSidebarCassetteProvider).cassetteIndex;
}

String _$sidebarCassetteResolutionStateHash() =>
    r'aa838aa4f97e4394a346966fb8a8d4251fdcff8a';

/// See also [sidebarCassetteResolutionState].
@ProviderFor(sidebarCassetteResolutionState)
const sidebarCassetteResolutionStateProvider =
    SidebarCassetteResolutionStateFamily();

/// See also [sidebarCassetteResolutionState].
class SidebarCassetteResolutionStateFamily
    extends Family<SidebarCassetteResolutionState> {
  /// See also [sidebarCassetteResolutionState].
  const SidebarCassetteResolutionStateFamily();

  /// See also [sidebarCassetteResolutionState].
  SidebarCassetteResolutionStateProvider call(SidebarMode mode) {
    return SidebarCassetteResolutionStateProvider(mode);
  }

  @override
  SidebarCassetteResolutionStateProvider getProviderOverride(
    covariant SidebarCassetteResolutionStateProvider provider,
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
  String? get name => r'sidebarCassetteResolutionStateProvider';
}

/// See also [sidebarCassetteResolutionState].
class SidebarCassetteResolutionStateProvider
    extends AutoDisposeProvider<SidebarCassetteResolutionState> {
  /// See also [sidebarCassetteResolutionState].
  SidebarCassetteResolutionStateProvider(SidebarMode mode)
    : this._internal(
        (ref) => sidebarCassetteResolutionState(
          ref as SidebarCassetteResolutionStateRef,
          mode,
        ),
        from: sidebarCassetteResolutionStateProvider,
        name: r'sidebarCassetteResolutionStateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sidebarCassetteResolutionStateHash,
        dependencies: SidebarCassetteResolutionStateFamily._dependencies,
        allTransitiveDependencies:
            SidebarCassetteResolutionStateFamily._allTransitiveDependencies,
        mode: mode,
      );

  SidebarCassetteResolutionStateProvider._internal(
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
  Override overrideWith(
    SidebarCassetteResolutionState Function(
      SidebarCassetteResolutionStateRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SidebarCassetteResolutionStateProvider._internal(
        (ref) => create(ref as SidebarCassetteResolutionStateRef),
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
  AutoDisposeProviderElement<SidebarCassetteResolutionState> createElement() {
    return _SidebarCassetteResolutionStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SidebarCassetteResolutionStateProvider &&
        other.mode == mode;
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
mixin SidebarCassetteResolutionStateRef
    on AutoDisposeProviderRef<SidebarCassetteResolutionState> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _SidebarCassetteResolutionStateProviderElement
    extends AutoDisposeProviderElement<SidebarCassetteResolutionState>
    with SidebarCassetteResolutionStateRef {
  _SidebarCassetteResolutionStateProviderElement(super.provider);

  @override
  SidebarMode get mode =>
      (origin as SidebarCassetteResolutionStateProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
