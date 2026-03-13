// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handles_for_contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handlesForContactHash() => r'74ad9a970ac32926a0534ed68d403cf3b32163d0';

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

/// Returns all handles linked to a contact, merging working DB and overlay.
///
/// For working-DB participants, handles come from `handle_to_participant`.
/// For virtual participants (id >= 1,000,000,000), handles come from
/// `handle_to_participant_overrides` in the overlay DB.
/// Overlay links for real participants are also included.
///
/// Copied from [handlesForContact].
@ProviderFor(handlesForContact)
const handlesForContactProvider = HandlesForContactFamily();

/// Returns all handles linked to a contact, merging working DB and overlay.
///
/// For working-DB participants, handles come from `handle_to_participant`.
/// For virtual participants (id >= 1,000,000,000), handles come from
/// `handle_to_participant_overrides` in the overlay DB.
/// Overlay links for real participants are also included.
///
/// Copied from [handlesForContact].
class HandlesForContactFamily extends Family<AsyncValue<List<LinkedHandle>>> {
  /// Returns all handles linked to a contact, merging working DB and overlay.
  ///
  /// For working-DB participants, handles come from `handle_to_participant`.
  /// For virtual participants (id >= 1,000,000,000), handles come from
  /// `handle_to_participant_overrides` in the overlay DB.
  /// Overlay links for real participants are also included.
  ///
  /// Copied from [handlesForContact].
  const HandlesForContactFamily();

  /// Returns all handles linked to a contact, merging working DB and overlay.
  ///
  /// For working-DB participants, handles come from `handle_to_participant`.
  /// For virtual participants (id >= 1,000,000,000), handles come from
  /// `handle_to_participant_overrides` in the overlay DB.
  /// Overlay links for real participants are also included.
  ///
  /// Copied from [handlesForContact].
  HandlesForContactProvider call({required int contactId}) {
    return HandlesForContactProvider(contactId: contactId);
  }

  @override
  HandlesForContactProvider getProviderOverride(
    covariant HandlesForContactProvider provider,
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
  String? get name => r'handlesForContactProvider';
}

/// Returns all handles linked to a contact, merging working DB and overlay.
///
/// For working-DB participants, handles come from `handle_to_participant`.
/// For virtual participants (id >= 1,000,000,000), handles come from
/// `handle_to_participant_overrides` in the overlay DB.
/// Overlay links for real participants are also included.
///
/// Copied from [handlesForContact].
class HandlesForContactProvider
    extends AutoDisposeFutureProvider<List<LinkedHandle>> {
  /// Returns all handles linked to a contact, merging working DB and overlay.
  ///
  /// For working-DB participants, handles come from `handle_to_participant`.
  /// For virtual participants (id >= 1,000,000,000), handles come from
  /// `handle_to_participant_overrides` in the overlay DB.
  /// Overlay links for real participants are also included.
  ///
  /// Copied from [handlesForContact].
  HandlesForContactProvider({required int contactId})
    : this._internal(
        (ref) => handlesForContact(
          ref as HandlesForContactRef,
          contactId: contactId,
        ),
        from: handlesForContactProvider,
        name: r'handlesForContactProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$handlesForContactHash,
        dependencies: HandlesForContactFamily._dependencies,
        allTransitiveDependencies:
            HandlesForContactFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  HandlesForContactProvider._internal(
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
    FutureOr<List<LinkedHandle>> Function(HandlesForContactRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HandlesForContactProvider._internal(
        (ref) => create(ref as HandlesForContactRef),
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
  AutoDisposeFutureProviderElement<List<LinkedHandle>> createElement() {
    return _HandlesForContactProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandlesForContactProvider && other.contactId == contactId;
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
mixin HandlesForContactRef on AutoDisposeFutureProviderRef<List<LinkedHandle>> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _HandlesForContactProviderElement
    extends AutoDisposeFutureProviderElement<List<LinkedHandle>>
    with HandlesForContactRef {
  _HandlesForContactProviderElement(super.provider);

  @override
  int get contactId => (origin as HandlesForContactProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
