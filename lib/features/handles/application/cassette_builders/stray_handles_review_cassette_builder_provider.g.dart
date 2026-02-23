// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stray_handles_review_cassette_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strayHandlesReviewCassetteBuilderHash() =>
    r'2ec23ee2de4041f955215288e2895874eb6514b0';

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

/// Builds the cassette view model for the unified stray handles review list.
///
/// Copied from [strayHandlesReviewCassetteBuilder].
@ProviderFor(strayHandlesReviewCassetteBuilder)
const strayHandlesReviewCassetteBuilderProvider =
    StrayHandlesReviewCassetteBuilderFamily();

/// Builds the cassette view model for the unified stray handles review list.
///
/// Copied from [strayHandlesReviewCassetteBuilder].
class StrayHandlesReviewCassetteBuilderFamily
    extends Family<SidebarCassetteCardViewModel> {
  /// Builds the cassette view model for the unified stray handles review list.
  ///
  /// Copied from [strayHandlesReviewCassetteBuilder].
  const StrayHandlesReviewCassetteBuilderFamily();

  /// Builds the cassette view model for the unified stray handles review list.
  ///
  /// Copied from [strayHandlesReviewCassetteBuilder].
  StrayHandlesReviewCassetteBuilderProvider call({
    required StrayHandleFilter filter,
    required StrayHandleMode mode,
  }) {
    return StrayHandlesReviewCassetteBuilderProvider(
      filter: filter,
      mode: mode,
    );
  }

  @override
  StrayHandlesReviewCassetteBuilderProvider getProviderOverride(
    covariant StrayHandlesReviewCassetteBuilderProvider provider,
  ) {
    return call(filter: provider.filter, mode: provider.mode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'strayHandlesReviewCassetteBuilderProvider';
}

/// Builds the cassette view model for the unified stray handles review list.
///
/// Copied from [strayHandlesReviewCassetteBuilder].
class StrayHandlesReviewCassetteBuilderProvider
    extends AutoDisposeProvider<SidebarCassetteCardViewModel> {
  /// Builds the cassette view model for the unified stray handles review list.
  ///
  /// Copied from [strayHandlesReviewCassetteBuilder].
  StrayHandlesReviewCassetteBuilderProvider({
    required StrayHandleFilter filter,
    required StrayHandleMode mode,
  }) : this._internal(
         (ref) => strayHandlesReviewCassetteBuilder(
           ref as StrayHandlesReviewCassetteBuilderRef,
           filter: filter,
           mode: mode,
         ),
         from: strayHandlesReviewCassetteBuilderProvider,
         name: r'strayHandlesReviewCassetteBuilderProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$strayHandlesReviewCassetteBuilderHash,
         dependencies: StrayHandlesReviewCassetteBuilderFamily._dependencies,
         allTransitiveDependencies:
             StrayHandlesReviewCassetteBuilderFamily._allTransitiveDependencies,
         filter: filter,
         mode: mode,
       );

  StrayHandlesReviewCassetteBuilderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
    required this.mode,
  }) : super.internal();

  final StrayHandleFilter filter;
  final StrayHandleMode mode;

  @override
  Override overrideWith(
    SidebarCassetteCardViewModel Function(
      StrayHandlesReviewCassetteBuilderRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StrayHandlesReviewCassetteBuilderProvider._internal(
        (ref) => create(ref as StrayHandlesReviewCassetteBuilderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<SidebarCassetteCardViewModel> createElement() {
    return _StrayHandlesReviewCassetteBuilderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StrayHandlesReviewCassetteBuilderProvider &&
        other.filter == filter &&
        other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StrayHandlesReviewCassetteBuilderRef
    on AutoDisposeProviderRef<SidebarCassetteCardViewModel> {
  /// The parameter `filter` of this provider.
  StrayHandleFilter get filter;

  /// The parameter `mode` of this provider.
  StrayHandleMode get mode;
}

class _StrayHandlesReviewCassetteBuilderProviderElement
    extends AutoDisposeProviderElement<SidebarCassetteCardViewModel>
    with StrayHandlesReviewCassetteBuilderRef {
  _StrayHandlesReviewCassetteBuilderProviderElement(super.provider);

  @override
  StrayHandleFilter get filter =>
      (origin as StrayHandlesReviewCassetteBuilderProvider).filter;
  @override
  StrayHandleMode get mode =>
      (origin as StrayHandlesReviewCassetteBuilderProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
