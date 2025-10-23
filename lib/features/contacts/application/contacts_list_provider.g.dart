// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsListHash() => r'5e6dd63a6178e0463a65ce9895fbd1682b49e526';

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

/// See also [contactsList].
@ProviderFor(contactsList)
const contactsListProvider = ContactsListFamily();

/// See also [contactsList].
class ContactsListFamily extends Family<AsyncValue<List<ContactSummary>>> {
  /// See also [contactsList].
  const ContactsListFamily();

  /// See also [contactsList].
  ContactsListProvider call({required ContactsListSpec spec}) {
    return ContactsListProvider(spec: spec);
  }

  @override
  ContactsListProvider getProviderOverride(
    covariant ContactsListProvider provider,
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
  String? get name => r'contactsListProvider';
}

/// See also [contactsList].
class ContactsListProvider
    extends AutoDisposeFutureProvider<List<ContactSummary>> {
  /// See also [contactsList].
  ContactsListProvider({required ContactsListSpec spec})
    : this._internal(
        (ref) => contactsList(ref as ContactsListRef, spec: spec),
        from: contactsListProvider,
        name: r'contactsListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactsListHash,
        dependencies: ContactsListFamily._dependencies,
        allTransitiveDependencies:
            ContactsListFamily._allTransitiveDependencies,
        spec: spec,
      );

  ContactsListProvider._internal(
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
    FutureOr<List<ContactSummary>> Function(ContactsListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactsListProvider._internal(
        (ref) => create(ref as ContactsListRef),
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
    return _ContactsListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactsListProvider && other.spec == spec;
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
mixin ContactsListRef on AutoDisposeFutureProviderRef<List<ContactSummary>> {
  /// The parameter `spec` of this provider.
  ContactsListSpec get spec;
}

class _ContactsListProviderElement
    extends AutoDisposeFutureProviderElement<List<ContactSummary>>
    with ContactsListRef {
  _ContactsListProviderElement(super.provider);

  @override
  ContactsListSpec get spec => (origin as ContactsListProvider).spec;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
