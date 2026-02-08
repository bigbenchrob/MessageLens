// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_rack_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cassetteRackStateHash() => r'10652c1904006798307e6151e7091c75ea2005e5';

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

abstract class _$CassetteRackState
    extends BuildlessAutoDisposeNotifier<CassetteRack> {
  late final SidebarMode mode;

  CassetteRack build(SidebarMode mode);
}

/// A Riverpod notifier managing the current [CassetteRack].
///
/// This class follows the class‑based provider syntax described in the
/// Riverpod documentation.  It exposes methods to mutate the rack in
/// response to user interactions (pushing new cassettes, updating existing
/// ones, truncating the stack, etc.).  Because the notifier’s state is
/// immutable, each mutation produces a new [CassetteRack] instance.
///
/// Copied from [CassetteRackState].
@ProviderFor(CassetteRackState)
const cassetteRackStateProvider = CassetteRackStateFamily();

/// A Riverpod notifier managing the current [CassetteRack].
///
/// This class follows the class‑based provider syntax described in the
/// Riverpod documentation.  It exposes methods to mutate the rack in
/// response to user interactions (pushing new cassettes, updating existing
/// ones, truncating the stack, etc.).  Because the notifier’s state is
/// immutable, each mutation produces a new [CassetteRack] instance.
///
/// Copied from [CassetteRackState].
class CassetteRackStateFamily extends Family<CassetteRack> {
  /// A Riverpod notifier managing the current [CassetteRack].
  ///
  /// This class follows the class‑based provider syntax described in the
  /// Riverpod documentation.  It exposes methods to mutate the rack in
  /// response to user interactions (pushing new cassettes, updating existing
  /// ones, truncating the stack, etc.).  Because the notifier’s state is
  /// immutable, each mutation produces a new [CassetteRack] instance.
  ///
  /// Copied from [CassetteRackState].
  const CassetteRackStateFamily();

  /// A Riverpod notifier managing the current [CassetteRack].
  ///
  /// This class follows the class‑based provider syntax described in the
  /// Riverpod documentation.  It exposes methods to mutate the rack in
  /// response to user interactions (pushing new cassettes, updating existing
  /// ones, truncating the stack, etc.).  Because the notifier’s state is
  /// immutable, each mutation produces a new [CassetteRack] instance.
  ///
  /// Copied from [CassetteRackState].
  CassetteRackStateProvider call(SidebarMode mode) {
    return CassetteRackStateProvider(mode);
  }

  @override
  CassetteRackStateProvider getProviderOverride(
    covariant CassetteRackStateProvider provider,
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
  String? get name => r'cassetteRackStateProvider';
}

/// A Riverpod notifier managing the current [CassetteRack].
///
/// This class follows the class‑based provider syntax described in the
/// Riverpod documentation.  It exposes methods to mutate the rack in
/// response to user interactions (pushing new cassettes, updating existing
/// ones, truncating the stack, etc.).  Because the notifier’s state is
/// immutable, each mutation produces a new [CassetteRack] instance.
///
/// Copied from [CassetteRackState].
class CassetteRackStateProvider
    extends AutoDisposeNotifierProviderImpl<CassetteRackState, CassetteRack> {
  /// A Riverpod notifier managing the current [CassetteRack].
  ///
  /// This class follows the class‑based provider syntax described in the
  /// Riverpod documentation.  It exposes methods to mutate the rack in
  /// response to user interactions (pushing new cassettes, updating existing
  /// ones, truncating the stack, etc.).  Because the notifier’s state is
  /// immutable, each mutation produces a new [CassetteRack] instance.
  ///
  /// Copied from [CassetteRackState].
  CassetteRackStateProvider(SidebarMode mode)
    : this._internal(
        () => CassetteRackState()..mode = mode,
        from: cassetteRackStateProvider,
        name: r'cassetteRackStateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cassetteRackStateHash,
        dependencies: CassetteRackStateFamily._dependencies,
        allTransitiveDependencies:
            CassetteRackStateFamily._allTransitiveDependencies,
        mode: mode,
      );

  CassetteRackStateProvider._internal(
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
  CassetteRack runNotifierBuild(covariant CassetteRackState notifier) {
    return notifier.build(mode);
  }

  @override
  Override overrideWith(CassetteRackState Function() create) {
    return ProviderOverride(
      origin: this,
      override: CassetteRackStateProvider._internal(
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
  AutoDisposeNotifierProviderElement<CassetteRackState, CassetteRack>
  createElement() {
    return _CassetteRackStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CassetteRackStateProvider && other.mode == mode;
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
mixin CassetteRackStateRef on AutoDisposeNotifierProviderRef<CassetteRack> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _CassetteRackStateProviderElement
    extends AutoDisposeNotifierProviderElement<CassetteRackState, CassetteRack>
    with CassetteRackStateRef {
  _CassetteRackStateProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as CassetteRackStateProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
