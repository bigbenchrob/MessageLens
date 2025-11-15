// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_message_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactMessageSearchResultsHash() =>
    r'5fc0f45e74af308d2e105448aacfc8c5df48b7b7';

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

/// See also [contactMessageSearchResults].
@ProviderFor(contactMessageSearchResults)
const contactMessageSearchResultsProvider = ContactMessageSearchResultsFamily();

/// See also [contactMessageSearchResults].
class ContactMessageSearchResultsFamily
    extends Family<AsyncValue<List<ChatMessageListItem>>> {
  /// See also [contactMessageSearchResults].
  const ContactMessageSearchResultsFamily();

  /// See also [contactMessageSearchResults].
  ContactMessageSearchResultsProvider call({
    required int contactId,
    required String query,
  }) {
    return ContactMessageSearchResultsProvider(
      contactId: contactId,
      query: query,
    );
  }

  @override
  ContactMessageSearchResultsProvider getProviderOverride(
    covariant ContactMessageSearchResultsProvider provider,
  ) {
    return call(contactId: provider.contactId, query: provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactMessageSearchResultsProvider';
}

/// See also [contactMessageSearchResults].
class ContactMessageSearchResultsProvider
    extends AutoDisposeFutureProvider<List<ChatMessageListItem>> {
  /// See also [contactMessageSearchResults].
  ContactMessageSearchResultsProvider({
    required int contactId,
    required String query,
  }) : this._internal(
         (ref) => contactMessageSearchResults(
           ref as ContactMessageSearchResultsRef,
           contactId: contactId,
           query: query,
         ),
         from: contactMessageSearchResultsProvider,
         name: r'contactMessageSearchResultsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$contactMessageSearchResultsHash,
         dependencies: ContactMessageSearchResultsFamily._dependencies,
         allTransitiveDependencies:
             ContactMessageSearchResultsFamily._allTransitiveDependencies,
         contactId: contactId,
         query: query,
       );

  ContactMessageSearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.query,
  }) : super.internal();

  final int contactId;
  final String query;

  @override
  Override overrideWith(
    FutureOr<List<ChatMessageListItem>> Function(
      ContactMessageSearchResultsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactMessageSearchResultsProvider._internal(
        (ref) => create(ref as ContactMessageSearchResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ChatMessageListItem>> createElement() {
    return _ContactMessageSearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactMessageSearchResultsProvider &&
        other.contactId == contactId &&
        other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactMessageSearchResultsRef
    on AutoDisposeFutureProviderRef<List<ChatMessageListItem>> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `query` of this provider.
  String get query;
}

class _ContactMessageSearchResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<ChatMessageListItem>>
    with ContactMessageSearchResultsRef {
  _ContactMessageSearchResultsProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as ContactMessageSearchResultsProvider).contactId;
  @override
  String get query => (origin as ContactMessageSearchResultsProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
