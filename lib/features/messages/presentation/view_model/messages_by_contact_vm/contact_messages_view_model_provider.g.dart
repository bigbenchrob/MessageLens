// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_messages_view_model_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactMessagesViewModelHash() =>
    r'1270e3f579c8d5c0d947a130b5c08d34c05b2458';

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

abstract class _$ContactMessagesViewModel
    extends BuildlessAutoDisposeNotifier<ContactMessagesViewModelState> {
  late final int contactId;

  ContactMessagesViewModelState build({required int contactId});
}

/// See also [ContactMessagesViewModel].
@ProviderFor(ContactMessagesViewModel)
const contactMessagesViewModelProvider = ContactMessagesViewModelFamily();

/// See also [ContactMessagesViewModel].
class ContactMessagesViewModelFamily
    extends Family<ContactMessagesViewModelState> {
  /// See also [ContactMessagesViewModel].
  const ContactMessagesViewModelFamily();

  /// See also [ContactMessagesViewModel].
  ContactMessagesViewModelProvider call({required int contactId}) {
    return ContactMessagesViewModelProvider(contactId: contactId);
  }

  @override
  ContactMessagesViewModelProvider getProviderOverride(
    covariant ContactMessagesViewModelProvider provider,
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
  String? get name => r'contactMessagesViewModelProvider';
}

/// See also [ContactMessagesViewModel].
class ContactMessagesViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          ContactMessagesViewModel,
          ContactMessagesViewModelState
        > {
  /// See also [ContactMessagesViewModel].
  ContactMessagesViewModelProvider({required int contactId})
    : this._internal(
        () => ContactMessagesViewModel()..contactId = contactId,
        from: contactMessagesViewModelProvider,
        name: r'contactMessagesViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactMessagesViewModelHash,
        dependencies: ContactMessagesViewModelFamily._dependencies,
        allTransitiveDependencies:
            ContactMessagesViewModelFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  ContactMessagesViewModelProvider._internal(
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
  ContactMessagesViewModelState runNotifierBuild(
    covariant ContactMessagesViewModel notifier,
  ) {
    return notifier.build(contactId: contactId);
  }

  @override
  Override overrideWith(ContactMessagesViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContactMessagesViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<
    ContactMessagesViewModel,
    ContactMessagesViewModelState
  >
  createElement() {
    return _ContactMessagesViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactMessagesViewModelProvider &&
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
mixin ContactMessagesViewModelRef
    on AutoDisposeNotifierProviderRef<ContactMessagesViewModelState> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _ContactMessagesViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ContactMessagesViewModel,
          ContactMessagesViewModelState
        >
    with ContactMessagesViewModelRef {
  _ContactMessagesViewModelProviderElement(super.provider);

  @override
  int get contactId => (origin as ContactMessagesViewModelProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
