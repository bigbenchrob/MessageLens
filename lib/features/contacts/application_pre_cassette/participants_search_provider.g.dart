// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participants_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$participantsSearchHash() =>
    r'9a1947670de729e44ef89cd14cc8d2ffbdeb9513';

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

/// See also [participantsSearch].
@ProviderFor(participantsSearch)
const participantsSearchProvider = ParticipantsSearchFamily();

/// See also [participantsSearch].
class ParticipantsSearchFamily
    extends Family<AsyncValue<List<ParticipantSearchResult>>> {
  /// See also [participantsSearch].
  const ParticipantsSearchFamily();

  /// See also [participantsSearch].
  ParticipantsSearchProvider call({required String query}) {
    return ParticipantsSearchProvider(query: query);
  }

  @override
  ParticipantsSearchProvider getProviderOverride(
    covariant ParticipantsSearchProvider provider,
  ) {
    return call(query: provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'participantsSearchProvider';
}

/// See also [participantsSearch].
class ParticipantsSearchProvider
    extends AutoDisposeFutureProvider<List<ParticipantSearchResult>> {
  /// See also [participantsSearch].
  ParticipantsSearchProvider({required String query})
    : this._internal(
        (ref) => participantsSearch(ref as ParticipantsSearchRef, query: query),
        from: participantsSearchProvider,
        name: r'participantsSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$participantsSearchHash,
        dependencies: ParticipantsSearchFamily._dependencies,
        allTransitiveDependencies:
            ParticipantsSearchFamily._allTransitiveDependencies,
        query: query,
      );

  ParticipantsSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<ParticipantSearchResult>> Function(
      ParticipantsSearchRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ParticipantsSearchProvider._internal(
        (ref) => create(ref as ParticipantsSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ParticipantSearchResult>>
  createElement() {
    return _ParticipantsSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ParticipantsSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ParticipantsSearchRef
    on AutoDisposeFutureProviderRef<List<ParticipantSearchResult>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _ParticipantsSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<ParticipantSearchResult>>
    with ParticipantsSearchRef {
  _ParticipantsSearchProviderElement(super.provider);

  @override
  String get query => (origin as ParticipantsSearchProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
