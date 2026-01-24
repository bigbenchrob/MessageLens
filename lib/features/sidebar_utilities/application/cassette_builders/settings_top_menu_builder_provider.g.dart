// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_top_menu_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsTopMenuBuilderHash() =>
    r'e616337b2e6013f39b3f0ffe0f761e40e7d63864';

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

abstract class _$SettingsTopMenuBuilder
    extends BuildlessAutoDisposeNotifier<Widget> {
  late final SidebarUtilityCassetteSpec spec;

  Widget build(SidebarUtilityCassetteSpec spec);
}

/// Builder that converts a [SidebarUtilityCassetteSpec.settingsMenu] into the
/// drop-down style settings top menu widget.
///
/// Copied from [SettingsTopMenuBuilder].
@ProviderFor(SettingsTopMenuBuilder)
const settingsTopMenuBuilderProvider = SettingsTopMenuBuilderFamily();

/// Builder that converts a [SidebarUtilityCassetteSpec.settingsMenu] into the
/// drop-down style settings top menu widget.
///
/// Copied from [SettingsTopMenuBuilder].
class SettingsTopMenuBuilderFamily extends Family<Widget> {
  /// Builder that converts a [SidebarUtilityCassetteSpec.settingsMenu] into the
  /// drop-down style settings top menu widget.
  ///
  /// Copied from [SettingsTopMenuBuilder].
  const SettingsTopMenuBuilderFamily();

  /// Builder that converts a [SidebarUtilityCassetteSpec.settingsMenu] into the
  /// drop-down style settings top menu widget.
  ///
  /// Copied from [SettingsTopMenuBuilder].
  SettingsTopMenuBuilderProvider call(SidebarUtilityCassetteSpec spec) {
    return SettingsTopMenuBuilderProvider(spec);
  }

  @override
  SettingsTopMenuBuilderProvider getProviderOverride(
    covariant SettingsTopMenuBuilderProvider provider,
  ) {
    return call(provider.spec);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'settingsTopMenuBuilderProvider';
}

/// Builder that converts a [SidebarUtilityCassetteSpec.settingsMenu] into the
/// drop-down style settings top menu widget.
///
/// Copied from [SettingsTopMenuBuilder].
class SettingsTopMenuBuilderProvider
    extends AutoDisposeNotifierProviderImpl<SettingsTopMenuBuilder, Widget> {
  /// Builder that converts a [SidebarUtilityCassetteSpec.settingsMenu] into the
  /// drop-down style settings top menu widget.
  ///
  /// Copied from [SettingsTopMenuBuilder].
  SettingsTopMenuBuilderProvider(SidebarUtilityCassetteSpec spec)
    : this._internal(
        () => SettingsTopMenuBuilder()..spec = spec,
        from: settingsTopMenuBuilderProvider,
        name: r'settingsTopMenuBuilderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$settingsTopMenuBuilderHash,
        dependencies: SettingsTopMenuBuilderFamily._dependencies,
        allTransitiveDependencies:
            SettingsTopMenuBuilderFamily._allTransitiveDependencies,
        spec: spec,
      );

  SettingsTopMenuBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.spec,
  }) : super.internal();

  final SidebarUtilityCassetteSpec spec;

  @override
  Widget runNotifierBuild(covariant SettingsTopMenuBuilder notifier) {
    return notifier.build(spec);
  }

  @override
  Override overrideWith(SettingsTopMenuBuilder Function() create) {
    return ProviderOverride(
      origin: this,
      override: SettingsTopMenuBuilderProvider._internal(
        () => create()..spec = spec,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        spec: spec,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SettingsTopMenuBuilder, Widget>
  createElement() {
    return _SettingsTopMenuBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsTopMenuBuilderProvider && other.spec == spec;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, spec.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SettingsTopMenuBuilderRef on AutoDisposeNotifierProviderRef<Widget> {
  /// The parameter `spec` of this provider.
  SidebarUtilityCassetteSpec get spec;
}

class _SettingsTopMenuBuilderProviderElement
    extends AutoDisposeNotifierProviderElement<SettingsTopMenuBuilder, Widget>
    with SettingsTopMenuBuilderRef {
  _SettingsTopMenuBuilderProviderElement(super.provider);

  @override
  SidebarUtilityCassetteSpec get spec =>
      (origin as SettingsTopMenuBuilderProvider).spec;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
