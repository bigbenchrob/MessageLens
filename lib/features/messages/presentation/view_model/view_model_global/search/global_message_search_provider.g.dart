// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_message_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$globalMessageSearchResultsHash() =>
    r'2e12e072f8f62eb7238ebc882384ff1aa7627554';

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

/// See also [globalMessageSearchResults].
@ProviderFor(globalMessageSearchResults)
const globalMessageSearchResultsProvider = GlobalMessageSearchResultsFamily();

/// See also [globalMessageSearchResults].
class GlobalMessageSearchResultsFamily
    extends Family<AsyncValue<List<MessageListItem>>> {
  /// See also [globalMessageSearchResults].
  const GlobalMessageSearchResultsFamily();

  /// See also [globalMessageSearchResults].
  GlobalMessageSearchResultsProvider call({
    required String query,
    required SearchMode mode,
  }) {
    return GlobalMessageSearchResultsProvider(query: query, mode: mode);
  }

  @override
  GlobalMessageSearchResultsProvider getProviderOverride(
    covariant GlobalMessageSearchResultsProvider provider,
  ) {
    return call(query: provider.query, mode: provider.mode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'globalMessageSearchResultsProvider';
}

/// See also [globalMessageSearchResults].
class GlobalMessageSearchResultsProvider
    extends AutoDisposeFutureProvider<List<MessageListItem>> {
  /// See also [globalMessageSearchResults].
  GlobalMessageSearchResultsProvider({
    required String query,
    required SearchMode mode,
  }) : this._internal(
         (ref) => globalMessageSearchResults(
           ref as GlobalMessageSearchResultsRef,
           query: query,
           mode: mode,
         ),
         from: globalMessageSearchResultsProvider,
         name: r'globalMessageSearchResultsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$globalMessageSearchResultsHash,
         dependencies: GlobalMessageSearchResultsFamily._dependencies,
         allTransitiveDependencies:
             GlobalMessageSearchResultsFamily._allTransitiveDependencies,
         query: query,
         mode: mode,
       );

  GlobalMessageSearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.mode,
  }) : super.internal();

  final String query;
  final SearchMode mode;

  @override
  Override overrideWith(
    FutureOr<List<MessageListItem>> Function(
      GlobalMessageSearchResultsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GlobalMessageSearchResultsProvider._internal(
        (ref) => create(ref as GlobalMessageSearchResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MessageListItem>> createElement() {
    return _GlobalMessageSearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalMessageSearchResultsProvider &&
        other.query == query &&
        other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GlobalMessageSearchResultsRef
    on AutoDisposeFutureProviderRef<List<MessageListItem>> {
  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `mode` of this provider.
  SearchMode get mode;
}

class _GlobalMessageSearchResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<MessageListItem>>
    with GlobalMessageSearchResultsRef {
  _GlobalMessageSearchResultsProviderElement(super.provider);

  @override
  String get query => (origin as GlobalMessageSearchResultsProvider).query;
  @override
  SearchMode get mode => (origin as GlobalMessageSearchResultsProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
