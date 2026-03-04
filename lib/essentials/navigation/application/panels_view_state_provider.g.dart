// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panels_view_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$panelsViewStateHash() => r'b36fa770d495991d6052b838455a6f83240a7774';

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

abstract class _$PanelsViewState
    extends BuildlessAutoDisposeNotifier<Map<WindowPanel, PanelStack>> {
  late final SidebarMode mode;

  Map<WindowPanel, PanelStack> build(SidebarMode mode);
}

/// See also [PanelsViewState].
@ProviderFor(PanelsViewState)
const panelsViewStateProvider = PanelsViewStateFamily();

/// See also [PanelsViewState].
class PanelsViewStateFamily extends Family<Map<WindowPanel, PanelStack>> {
  /// See also [PanelsViewState].
  const PanelsViewStateFamily();

  /// See also [PanelsViewState].
  PanelsViewStateProvider call(SidebarMode mode) {
    return PanelsViewStateProvider(mode);
  }

  @override
  PanelsViewStateProvider getProviderOverride(
    covariant PanelsViewStateProvider provider,
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
  String? get name => r'panelsViewStateProvider';
}

/// See also [PanelsViewState].
class PanelsViewStateProvider
    extends
        AutoDisposeNotifierProviderImpl<
          PanelsViewState,
          Map<WindowPanel, PanelStack>
        > {
  /// See also [PanelsViewState].
  PanelsViewStateProvider(SidebarMode mode)
    : this._internal(
        () => PanelsViewState()..mode = mode,
        from: panelsViewStateProvider,
        name: r'panelsViewStateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$panelsViewStateHash,
        dependencies: PanelsViewStateFamily._dependencies,
        allTransitiveDependencies:
            PanelsViewStateFamily._allTransitiveDependencies,
        mode: mode,
      );

  PanelsViewStateProvider._internal(
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
  Map<WindowPanel, PanelStack> runNotifierBuild(
    covariant PanelsViewState notifier,
  ) {
    return notifier.build(mode);
  }

  @override
  Override overrideWith(PanelsViewState Function() create) {
    return ProviderOverride(
      origin: this,
      override: PanelsViewStateProvider._internal(
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
  AutoDisposeNotifierProviderElement<
    PanelsViewState,
    Map<WindowPanel, PanelStack>
  >
  createElement() {
    return _PanelsViewStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PanelsViewStateProvider && other.mode == mode;
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
mixin PanelsViewStateRef
    on AutoDisposeNotifierProviderRef<Map<WindowPanel, PanelStack>> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _PanelsViewStateProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          PanelsViewState,
          Map<WindowPanel, PanelStack>
        >
    with PanelsViewStateRef {
  _PanelsViewStateProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as PanelsViewStateProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
