// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$panelCoordinatorHash() => r'6af6644f3c140dc6ab6e64b9f7f21d452ce46355';

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

abstract class _$PanelCoordinator extends BuildlessAutoDisposeNotifier<void> {
  late final SidebarMode mode;

  void build(SidebarMode mode);
}

/// Coordinator that maps panel ViewSpecs to rendered widgets
///
/// Copied from [PanelCoordinator].
@ProviderFor(PanelCoordinator)
const panelCoordinatorProvider = PanelCoordinatorFamily();

/// Coordinator that maps panel ViewSpecs to rendered widgets
///
/// Copied from [PanelCoordinator].
class PanelCoordinatorFamily extends Family<void> {
  /// Coordinator that maps panel ViewSpecs to rendered widgets
  ///
  /// Copied from [PanelCoordinator].
  const PanelCoordinatorFamily();

  /// Coordinator that maps panel ViewSpecs to rendered widgets
  ///
  /// Copied from [PanelCoordinator].
  PanelCoordinatorProvider call(SidebarMode mode) {
    return PanelCoordinatorProvider(mode);
  }

  @override
  PanelCoordinatorProvider getProviderOverride(
    covariant PanelCoordinatorProvider provider,
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
  String? get name => r'panelCoordinatorProvider';
}

/// Coordinator that maps panel ViewSpecs to rendered widgets
///
/// Copied from [PanelCoordinator].
class PanelCoordinatorProvider
    extends AutoDisposeNotifierProviderImpl<PanelCoordinator, void> {
  /// Coordinator that maps panel ViewSpecs to rendered widgets
  ///
  /// Copied from [PanelCoordinator].
  PanelCoordinatorProvider(SidebarMode mode)
    : this._internal(
        () => PanelCoordinator()..mode = mode,
        from: panelCoordinatorProvider,
        name: r'panelCoordinatorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$panelCoordinatorHash,
        dependencies: PanelCoordinatorFamily._dependencies,
        allTransitiveDependencies:
            PanelCoordinatorFamily._allTransitiveDependencies,
        mode: mode,
      );

  PanelCoordinatorProvider._internal(
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
  void runNotifierBuild(covariant PanelCoordinator notifier) {
    return notifier.build(mode);
  }

  @override
  Override overrideWith(PanelCoordinator Function() create) {
    return ProviderOverride(
      origin: this,
      override: PanelCoordinatorProvider._internal(
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
  AutoDisposeNotifierProviderElement<PanelCoordinator, void> createElement() {
    return _PanelCoordinatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PanelCoordinatorProvider && other.mode == mode;
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
mixin PanelCoordinatorRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _PanelCoordinatorProviderElement
    extends AutoDisposeNotifierProviderElement<PanelCoordinator, void>
    with PanelCoordinatorRef {
  _PanelCoordinatorProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as PanelCoordinatorProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
