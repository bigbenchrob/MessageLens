// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactProfileHash() => r'73033d7e4227e968567e12b3629d38b72930bb59';

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

/// See also [contactProfile].
@ProviderFor(contactProfile)
const contactProfileProvider = ContactProfileFamily();

/// See also [contactProfile].
class ContactProfileFamily extends Family<AsyncValue<ContactProfileSummary?>> {
  /// See also [contactProfile].
  const ContactProfileFamily();

  /// See also [contactProfile].
  ContactProfileProvider call({required int contactId}) {
    return ContactProfileProvider(contactId: contactId);
  }

  @override
  ContactProfileProvider getProviderOverride(
    covariant ContactProfileProvider provider,
  ) {
    return call(contactId: provider.contactId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactProfileProvider';
}

/// See also [contactProfile].
class ContactProfileProvider
    extends AutoDisposeFutureProvider<ContactProfileSummary?> {
  /// See also [contactProfile].
  ContactProfileProvider({required int contactId})
    : this._internal(
        (ref) => contactProfile(ref as ContactProfileRef, contactId: contactId),
        from: contactProfileProvider,
        name: r'contactProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactProfileHash,
        dependencies: ContactProfileFamily._dependencies,
        allTransitiveDependencies:
            ContactProfileFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  ContactProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final int contactId;

  @override
  Override overrideWith(
    FutureOr<ContactProfileSummary?> Function(ContactProfileRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactProfileProvider._internal(
        (ref) => create(ref as ContactProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ContactProfileSummary?> createElement() {
    return _ContactProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactProfileProvider && other.contactId == contactId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactProfileRef
    on AutoDisposeFutureProviderRef<ContactProfileSummary?> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _ContactProfileProviderElement
    extends AutoDisposeFutureProviderElement<ContactProfileSummary?>
    with ContactProfileRef {
  _ContactProfileProviderElement(super.provider);

  @override
  int get contactId => (origin as ContactProfileProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
