// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_layout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sidebarLayoutHash() => r'4a0e34fd6cc74910e677e6f2a74850994afc790b';

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

abstract class _$SidebarLayout
    extends BuildlessAutoDisposeNotifier<SidebarLayoutState> {
  late final SidebarRootSpec root;

  SidebarLayoutState build(SidebarRootSpec root);
}

/// See also [SidebarLayout].
@ProviderFor(SidebarLayout)
const sidebarLayoutProvider = SidebarLayoutFamily();

/// See also [SidebarLayout].
class SidebarLayoutFamily extends Family<SidebarLayoutState> {
  /// See also [SidebarLayout].
  const SidebarLayoutFamily();

  /// See also [SidebarLayout].
  SidebarLayoutProvider call(SidebarRootSpec root) {
    return SidebarLayoutProvider(root);
  }

  @override
  SidebarLayoutProvider getProviderOverride(
    covariant SidebarLayoutProvider provider,
  ) {
    return call(provider.root);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sidebarLayoutProvider';
}

/// See also [SidebarLayout].
class SidebarLayoutProvider
    extends AutoDisposeNotifierProviderImpl<SidebarLayout, SidebarLayoutState> {
  /// See also [SidebarLayout].
  SidebarLayoutProvider(SidebarRootSpec root)
    : this._internal(
        () => SidebarLayout()..root = root,
        from: sidebarLayoutProvider,
        name: r'sidebarLayoutProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sidebarLayoutHash,
        dependencies: SidebarLayoutFamily._dependencies,
        allTransitiveDependencies:
            SidebarLayoutFamily._allTransitiveDependencies,
        root: root,
      );

  SidebarLayoutProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.root,
  }) : super.internal();

  final SidebarRootSpec root;

  @override
  SidebarLayoutState runNotifierBuild(covariant SidebarLayout notifier) {
    return notifier.build(root);
  }

  @override
  Override overrideWith(SidebarLayout Function() create) {
    return ProviderOverride(
      origin: this,
      override: SidebarLayoutProvider._internal(
        () => create()..root = root,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        root: root,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SidebarLayout, SidebarLayoutState>
  createElement() {
    return _SidebarLayoutProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SidebarLayoutProvider && other.root == root;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, root.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SidebarLayoutRef on AutoDisposeNotifierProviderRef<SidebarLayoutState> {
  /// The parameter `root` of this provider.
  SidebarRootSpec get root;
}

class _SidebarLayoutProviderElement
    extends
        AutoDisposeNotifierProviderElement<SidebarLayout, SidebarLayoutState>
    with SidebarLayoutRef {
  _SidebarLayoutProviderElement(super.provider);

  @override
  SidebarRootSpec get root => (origin as SidebarLayoutProvider).root;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
