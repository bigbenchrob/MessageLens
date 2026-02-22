// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stray_handles_mode_switcher_cassette_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strayHandlesModeSwitcherCassetteBuilderHash() =>
    r'ab68467834a4a42f05e89ff0af85926149bed0a0';

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

/// Builds the cassette view model for the stray handles mode switcher.
///
/// Copied from [strayHandlesModeSwitcherCassetteBuilder].
@ProviderFor(strayHandlesModeSwitcherCassetteBuilder)
const strayHandlesModeSwitcherCassetteBuilderProvider =
    StrayHandlesModeSwitcherCassetteBuilderFamily();

/// Builds the cassette view model for the stray handles mode switcher.
///
/// Copied from [strayHandlesModeSwitcherCassetteBuilder].
class StrayHandlesModeSwitcherCassetteBuilderFamily
    extends Family<SidebarCassetteCardViewModel> {
  /// Builds the cassette view model for the stray handles mode switcher.
  ///
  /// Copied from [strayHandlesModeSwitcherCassetteBuilder].
  const StrayHandlesModeSwitcherCassetteBuilderFamily();

  /// Builds the cassette view model for the stray handles mode switcher.
  ///
  /// Copied from [strayHandlesModeSwitcherCassetteBuilder].
  StrayHandlesModeSwitcherCassetteBuilderProvider call({
    required StrayHandleFilter filter,
  }) {
    return StrayHandlesModeSwitcherCassetteBuilderProvider(filter: filter);
  }

  @override
  StrayHandlesModeSwitcherCassetteBuilderProvider getProviderOverride(
    covariant StrayHandlesModeSwitcherCassetteBuilderProvider provider,
  ) {
    return call(filter: provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'strayHandlesModeSwitcherCassetteBuilderProvider';
}

/// Builds the cassette view model for the stray handles mode switcher.
///
/// Copied from [strayHandlesModeSwitcherCassetteBuilder].
class StrayHandlesModeSwitcherCassetteBuilderProvider
    extends AutoDisposeProvider<SidebarCassetteCardViewModel> {
  /// Builds the cassette view model for the stray handles mode switcher.
  ///
  /// Copied from [strayHandlesModeSwitcherCassetteBuilder].
  StrayHandlesModeSwitcherCassetteBuilderProvider({
    required StrayHandleFilter filter,
  }) : this._internal(
         (ref) => strayHandlesModeSwitcherCassetteBuilder(
           ref as StrayHandlesModeSwitcherCassetteBuilderRef,
           filter: filter,
         ),
         from: strayHandlesModeSwitcherCassetteBuilderProvider,
         name: r'strayHandlesModeSwitcherCassetteBuilderProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$strayHandlesModeSwitcherCassetteBuilderHash,
         dependencies:
             StrayHandlesModeSwitcherCassetteBuilderFamily._dependencies,
         allTransitiveDependencies:
             StrayHandlesModeSwitcherCassetteBuilderFamily
                 ._allTransitiveDependencies,
         filter: filter,
       );

  StrayHandlesModeSwitcherCassetteBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final StrayHandleFilter filter;

  @override
  Override overrideWith(
    SidebarCassetteCardViewModel Function(
      StrayHandlesModeSwitcherCassetteBuilderRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StrayHandlesModeSwitcherCassetteBuilderProvider._internal(
        (ref) => create(ref as StrayHandlesModeSwitcherCassetteBuilderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<SidebarCassetteCardViewModel> createElement() {
    return _StrayHandlesModeSwitcherCassetteBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StrayHandlesModeSwitcherCassetteBuilderProvider &&
        other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StrayHandlesModeSwitcherCassetteBuilderRef
    on AutoDisposeProviderRef<SidebarCassetteCardViewModel> {
  /// The parameter `filter` of this provider.
  StrayHandleFilter get filter;
}

class _StrayHandlesModeSwitcherCassetteBuilderProviderElement
    extends AutoDisposeProviderElement<SidebarCassetteCardViewModel>
    with StrayHandlesModeSwitcherCassetteBuilderRef {
  _StrayHandlesModeSwitcherCassetteBuilderProviderElement(super.provider);

  @override
  StrayHandleFilter get filter =>
      (origin as StrayHandlesModeSwitcherCassetteBuilderProvider).filter;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
