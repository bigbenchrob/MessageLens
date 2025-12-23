// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_messages_ordinal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactMessagesOrdinalHash() =>
    r'538f2fb3c577f414b7cf06807bff91a0dc6bd3a6';

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

abstract class _$ContactMessagesOrdinal
    extends BuildlessAutoDisposeAsyncNotifier<ContactMessagesOrdinalState> {
  late final int contactId;

  FutureOr<ContactMessagesOrdinalState> build({required int contactId});
}

/// See also [ContactMessagesOrdinal].
@ProviderFor(ContactMessagesOrdinal)
const contactMessagesOrdinalProvider = ContactMessagesOrdinalFamily();

/// See also [ContactMessagesOrdinal].
class ContactMessagesOrdinalFamily
    extends Family<AsyncValue<ContactMessagesOrdinalState>> {
  /// See also [ContactMessagesOrdinal].
  const ContactMessagesOrdinalFamily();

  /// See also [ContactMessagesOrdinal].
  ContactMessagesOrdinalProvider call({required int contactId}) {
    return ContactMessagesOrdinalProvider(contactId: contactId);
  }

  @override
  ContactMessagesOrdinalProvider getProviderOverride(
    covariant ContactMessagesOrdinalProvider provider,
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
  String? get name => r'contactMessagesOrdinalProvider';
}

/// See also [ContactMessagesOrdinal].
class ContactMessagesOrdinalProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ContactMessagesOrdinal,
          ContactMessagesOrdinalState
        > {
  /// See also [ContactMessagesOrdinal].
  ContactMessagesOrdinalProvider({required int contactId})
    : this._internal(
        () => ContactMessagesOrdinal()..contactId = contactId,
        from: contactMessagesOrdinalProvider,
        name: r'contactMessagesOrdinalProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactMessagesOrdinalHash,
        dependencies: ContactMessagesOrdinalFamily._dependencies,
        allTransitiveDependencies:
            ContactMessagesOrdinalFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  ContactMessagesOrdinalProvider._internal(
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
  FutureOr<ContactMessagesOrdinalState> runNotifierBuild(
    covariant ContactMessagesOrdinal notifier,
  ) {
    return notifier.build(contactId: contactId);
  }

  @override
  Override overrideWith(ContactMessagesOrdinal Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContactMessagesOrdinalProvider._internal(
        () => create()..contactId = contactId,
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
  AutoDisposeAsyncNotifierProviderElement<
    ContactMessagesOrdinal,
    ContactMessagesOrdinalState
  >
  createElement() {
    return _ContactMessagesOrdinalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactMessagesOrdinalProvider &&
        other.contactId == contactId;
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
mixin ContactMessagesOrdinalRef
    on AutoDisposeAsyncNotifierProviderRef<ContactMessagesOrdinalState> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _ContactMessagesOrdinalProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ContactMessagesOrdinal,
          ContactMessagesOrdinalState
        >
    with ContactMessagesOrdinalRef {
  _ContactMessagesOrdinalProviderElement(super.provider);

  @override
  int get contactId => (origin as ContactMessagesOrdinalProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
