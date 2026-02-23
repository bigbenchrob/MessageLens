// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stray_handles_type_switcher_cassette_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strayHandlesTypeSwitcherCassetteBuilderHash() =>
    r'6c6ec32efdf3779942cb016990aa36643b836238';

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

/// Builds the cassette view model for the stray handles type switcher.
///
/// Copied from [strayHandlesTypeSwitcherCassetteBuilder].
@ProviderFor(strayHandlesTypeSwitcherCassetteBuilder)
const strayHandlesTypeSwitcherCassetteBuilderProvider =
    StrayHandlesTypeSwitcherCassetteBuilderFamily();

/// Builds the cassette view model for the stray handles type switcher.
///
/// Copied from [strayHandlesTypeSwitcherCassetteBuilder].
class StrayHandlesTypeSwitcherCassetteBuilderFamily
    extends Family<SidebarCassetteCardViewModel> {
  /// Builds the cassette view model for the stray handles type switcher.
  ///
  /// Copied from [strayHandlesTypeSwitcherCassetteBuilder].
  const StrayHandlesTypeSwitcherCassetteBuilderFamily();

  /// Builds the cassette view model for the stray handles type switcher.
  ///
  /// Copied from [strayHandlesTypeSwitcherCassetteBuilder].
  StrayHandlesTypeSwitcherCassetteBuilderProvider call({
    required StrayHandleFilter selectedFilter,
    required int cassetteIndex,
  }) {
    return StrayHandlesTypeSwitcherCassetteBuilderProvider(
      selectedFilter: selectedFilter,
      cassetteIndex: cassetteIndex,
    );
  }

  @override
  StrayHandlesTypeSwitcherCassetteBuilderProvider getProviderOverride(
    covariant StrayHandlesTypeSwitcherCassetteBuilderProvider provider,
  ) {
    return call(
      selectedFilter: provider.selectedFilter,
      cassetteIndex: provider.cassetteIndex,
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
  String? get name => r'strayHandlesTypeSwitcherCassetteBuilderProvider';
}

/// Builds the cassette view model for the stray handles type switcher.
///
/// Copied from [strayHandlesTypeSwitcherCassetteBuilder].
class StrayHandlesTypeSwitcherCassetteBuilderProvider
    extends AutoDisposeProvider<SidebarCassetteCardViewModel> {
  /// Builds the cassette view model for the stray handles type switcher.
  ///
  /// Copied from [strayHandlesTypeSwitcherCassetteBuilder].
  StrayHandlesTypeSwitcherCassetteBuilderProvider({
    required StrayHandleFilter selectedFilter,
    required int cassetteIndex,
  }) : this._internal(
         (ref) => strayHandlesTypeSwitcherCassetteBuilder(
           ref as StrayHandlesTypeSwitcherCassetteBuilderRef,
           selectedFilter: selectedFilter,
           cassetteIndex: cassetteIndex,
         ),
         from: strayHandlesTypeSwitcherCassetteBuilderProvider,
         name: r'strayHandlesTypeSwitcherCassetteBuilderProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$strayHandlesTypeSwitcherCassetteBuilderHash,
         dependencies:
             StrayHandlesTypeSwitcherCassetteBuilderFamily._dependencies,
         allTransitiveDependencies:
             StrayHandlesTypeSwitcherCassetteBuilderFamily
                 ._allTransitiveDependencies,
         selectedFilter: selectedFilter,
         cassetteIndex: cassetteIndex,
       );

  StrayHandlesTypeSwitcherCassetteBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.selectedFilter,
    required this.cassetteIndex,
  }) : super.internal();

  final StrayHandleFilter selectedFilter;
  final int cassetteIndex;

  @override
  Override overrideWith(
    SidebarCassetteCardViewModel Function(
      StrayHandlesTypeSwitcherCassetteBuilderRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StrayHandlesTypeSwitcherCassetteBuilderProvider._internal(
        (ref) => create(ref as StrayHandlesTypeSwitcherCassetteBuilderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        selectedFilter: selectedFilter,
        cassetteIndex: cassetteIndex,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<SidebarCassetteCardViewModel> createElement() {
    return _StrayHandlesTypeSwitcherCassetteBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StrayHandlesTypeSwitcherCassetteBuilderProvider &&
        other.selectedFilter == selectedFilter &&
        other.cassetteIndex == cassetteIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, selectedFilter.hashCode);
    hash = _SystemHash.combine(hash, cassetteIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StrayHandlesTypeSwitcherCassetteBuilderRef
    on AutoDisposeProviderRef<SidebarCassetteCardViewModel> {
  /// The parameter `selectedFilter` of this provider.
  StrayHandleFilter get selectedFilter;

  /// The parameter `cassetteIndex` of this provider.
  int get cassetteIndex;
}

class _StrayHandlesTypeSwitcherCassetteBuilderProviderElement
    extends AutoDisposeProviderElement<SidebarCassetteCardViewModel>
    with StrayHandlesTypeSwitcherCassetteBuilderRef {
  _StrayHandlesTypeSwitcherCassetteBuilderProviderElement(super.provider);

  @override
  StrayHandleFilter get selectedFilter =>
      (origin as StrayHandlesTypeSwitcherCassetteBuilderProvider)
          .selectedFilter;
  @override
  int get cassetteIndex =>
      (origin as StrayHandlesTypeSwitcherCassetteBuilderProvider).cassetteIndex;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
