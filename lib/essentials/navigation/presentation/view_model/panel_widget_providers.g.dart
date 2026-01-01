// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_widget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$centerPanelWidgetHash() => r'c7c17f1a5aa31d76ec4c64ee0b875cd1265dc180';

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

/// Widget provider for center panel
///
/// Copied from [centerPanelWidget].
@ProviderFor(centerPanelWidget)
const centerPanelWidgetProvider = CenterPanelWidgetFamily();

/// Widget provider for center panel
///
/// Copied from [centerPanelWidget].
class CenterPanelWidgetFamily extends Family<Widget> {
  /// Widget provider for center panel
  ///
  /// Copied from [centerPanelWidget].
  const CenterPanelWidgetFamily();

  /// Widget provider for center panel
  ///
  /// Copied from [centerPanelWidget].
  CenterPanelWidgetProvider call(SidebarMode mode) {
    return CenterPanelWidgetProvider(mode);
  }

  @override
  CenterPanelWidgetProvider getProviderOverride(
    covariant CenterPanelWidgetProvider provider,
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
  String? get name => r'centerPanelWidgetProvider';
}

/// Widget provider for center panel
///
/// Copied from [centerPanelWidget].
class CenterPanelWidgetProvider extends AutoDisposeProvider<Widget> {
  /// Widget provider for center panel
  ///
  /// Copied from [centerPanelWidget].
  CenterPanelWidgetProvider(SidebarMode mode)
    : this._internal(
        (ref) => centerPanelWidget(ref as CenterPanelWidgetRef, mode),
        from: centerPanelWidgetProvider,
        name: r'centerPanelWidgetProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$centerPanelWidgetHash,
        dependencies: CenterPanelWidgetFamily._dependencies,
        allTransitiveDependencies:
            CenterPanelWidgetFamily._allTransitiveDependencies,
        mode: mode,
      );

  CenterPanelWidgetProvider._internal(
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
  Override overrideWith(Widget Function(CenterPanelWidgetRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: CenterPanelWidgetProvider._internal(
        (ref) => create(ref as CenterPanelWidgetRef),
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
  AutoDisposeProviderElement<Widget> createElement() {
    return _CenterPanelWidgetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CenterPanelWidgetProvider && other.mode == mode;
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
mixin CenterPanelWidgetRef on AutoDisposeProviderRef<Widget> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _CenterPanelWidgetProviderElement
    extends AutoDisposeProviderElement<Widget>
    with CenterPanelWidgetRef {
  _CenterPanelWidgetProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as CenterPanelWidgetProvider).mode;
}

String _$leftPanelWidgetHash() => r'b863d2e2231a43d730b192216a00099d8482e808';

/// Widget provider for left panel (sidebar).
///
/// This provider builds the left panel by reading the current list of
/// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
/// is wrapped in a [Column] so that the cassettes are laid out vertically.
///
/// Copied from [leftPanelWidget].
@ProviderFor(leftPanelWidget)
const leftPanelWidgetProvider = LeftPanelWidgetFamily();

/// Widget provider for left panel (sidebar).
///
/// This provider builds the left panel by reading the current list of
/// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
/// is wrapped in a [Column] so that the cassettes are laid out vertically.
///
/// Copied from [leftPanelWidget].
class LeftPanelWidgetFamily extends Family<Widget> {
  /// Widget provider for left panel (sidebar).
  ///
  /// This provider builds the left panel by reading the current list of
  /// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
  /// is wrapped in a [Column] so that the cassettes are laid out vertically.
  ///
  /// Copied from [leftPanelWidget].
  const LeftPanelWidgetFamily();

  /// Widget provider for left panel (sidebar).
  ///
  /// This provider builds the left panel by reading the current list of
  /// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
  /// is wrapped in a [Column] so that the cassettes are laid out vertically.
  ///
  /// Copied from [leftPanelWidget].
  LeftPanelWidgetProvider call(SidebarMode mode) {
    return LeftPanelWidgetProvider(mode);
  }

  @override
  LeftPanelWidgetProvider getProviderOverride(
    covariant LeftPanelWidgetProvider provider,
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
  String? get name => r'leftPanelWidgetProvider';
}

/// Widget provider for left panel (sidebar).
///
/// This provider builds the left panel by reading the current list of
/// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
/// is wrapped in a [Column] so that the cassettes are laid out vertically.
///
/// Copied from [leftPanelWidget].
class LeftPanelWidgetProvider extends AutoDisposeProvider<Widget> {
  /// Widget provider for left panel (sidebar).
  ///
  /// This provider builds the left panel by reading the current list of
  /// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
  /// is wrapped in a [Column] so that the cassettes are laid out vertically.
  ///
  /// Copied from [leftPanelWidget].
  LeftPanelWidgetProvider(SidebarMode mode)
    : this._internal(
        (ref) => leftPanelWidget(ref as LeftPanelWidgetRef, mode),
        from: leftPanelWidgetProvider,
        name: r'leftPanelWidgetProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$leftPanelWidgetHash,
        dependencies: LeftPanelWidgetFamily._dependencies,
        allTransitiveDependencies:
            LeftPanelWidgetFamily._allTransitiveDependencies,
        mode: mode,
      );

  LeftPanelWidgetProvider._internal(
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
  Override overrideWith(Widget Function(LeftPanelWidgetRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: LeftPanelWidgetProvider._internal(
        (ref) => create(ref as LeftPanelWidgetRef),
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
  AutoDisposeProviderElement<Widget> createElement() {
    return _LeftPanelWidgetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeftPanelWidgetProvider && other.mode == mode;
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
mixin LeftPanelWidgetRef on AutoDisposeProviderRef<Widget> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _LeftPanelWidgetProviderElement extends AutoDisposeProviderElement<Widget>
    with LeftPanelWidgetRef {
  _LeftPanelWidgetProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as LeftPanelWidgetProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
