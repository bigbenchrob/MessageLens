// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_list_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsListRepositoryHash() =>
    r'b70472a91bef9a6664d34d604c3d59ec7c559891';

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

/// See also [contactsListRepository].
@ProviderFor(contactsListRepository)
const contactsListRepositoryProvider = ContactsListRepositoryFamily();

/// See also [contactsListRepository].
class ContactsListRepositoryFamily
    extends Family<AsyncValue<List<ContactSummary>>> {
  /// See also [contactsListRepository].
  const ContactsListRepositoryFamily();

  /// See also [contactsListRepository].
  ContactsListRepositoryProvider call({required ContactsListSpec spec}) {
    return ContactsListRepositoryProvider(spec: spec);
  }

  @override
  ContactsListRepositoryProvider getProviderOverride(
    covariant ContactsListRepositoryProvider provider,
  ) {
    return call(spec: provider.spec);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactsListRepositoryProvider';
}

/// See also [contactsListRepository].
class ContactsListRepositoryProvider
    extends AutoDisposeFutureProvider<List<ContactSummary>> {
  /// See also [contactsListRepository].
  ContactsListRepositoryProvider({required ContactsListSpec spec})
    : this._internal(
        (ref) => contactsListRepository(
          ref as ContactsListRepositoryRef,
          spec: spec,
        ),
        from: contactsListRepositoryProvider,
        name: r'contactsListRepositoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactsListRepositoryHash,
        dependencies: ContactsListRepositoryFamily._dependencies,
        allTransitiveDependencies:
            ContactsListRepositoryFamily._allTransitiveDependencies,
        spec: spec,
      );

  ContactsListRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.spec,
  }) : super.internal();

  final ContactsListSpec spec;

  @override
  Override overrideWith(
    FutureOr<List<ContactSummary>> Function(ContactsListRepositoryRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactsListRepositoryProvider._internal(
        (ref) => create(ref as ContactsListRepositoryRef),
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
  AutoDisposeFutureProviderElement<List<ContactSummary>> createElement() {
    return _ContactsListRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactsListRepositoryProvider && other.spec == spec;
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
mixin ContactsListRepositoryRef
    on AutoDisposeFutureProviderRef<List<ContactSummary>> {
  /// The parameter `spec` of this provider.
  ContactsListSpec get spec;
}

class _ContactsListRepositoryProviderElement
    extends AutoDisposeFutureProviderElement<List<ContactSummary>>
    with ContactsListRepositoryRef {
  _ContactsListRepositoryProviderElement(super.provider);

  @override
  ContactsListSpec get spec => (origin as ContactsListRepositoryProvider).spec;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
