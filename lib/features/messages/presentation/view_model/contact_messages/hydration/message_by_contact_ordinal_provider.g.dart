// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_by_contact_ordinal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageByContactOrdinalHash() =>
    r'21d59f7967b57d879b7731cbc7778876ac0aeda2';

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

/// Loads a message by its ordinal position within a contact's message history.
/// This shows messages across all chats/handles with the contact.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency.
///
/// Copied from [messageByContactOrdinal].
@ProviderFor(messageByContactOrdinal)
const messageByContactOrdinalProvider = MessageByContactOrdinalFamily();

/// Loads a message by its ordinal position within a contact's message history.
/// This shows messages across all chats/handles with the contact.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency.
///
/// Copied from [messageByContactOrdinal].
class MessageByContactOrdinalFamily
    extends Family<AsyncValue<ChatMessageListItem?>> {
  /// Loads a message by its ordinal position within a contact's message history.
  /// This shows messages across all chats/handles with the contact.
  /// Returns null if ordinal is out of range.
  /// Uses auto-dispose for memory efficiency.
  ///
  /// Copied from [messageByContactOrdinal].
  const MessageByContactOrdinalFamily();

  /// Loads a message by its ordinal position within a contact's message history.
  /// This shows messages across all chats/handles with the contact.
  /// Returns null if ordinal is out of range.
  /// Uses auto-dispose for memory efficiency.
  ///
  /// Copied from [messageByContactOrdinal].
  MessageByContactOrdinalProvider call({
    required int contactId,
    required int ordinal,
  }) {
    return MessageByContactOrdinalProvider(
      contactId: contactId,
      ordinal: ordinal,
    );
  }

  @override
  MessageByContactOrdinalProvider getProviderOverride(
    covariant MessageByContactOrdinalProvider provider,
  ) {
    return call(contactId: provider.contactId, ordinal: provider.ordinal);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageByContactOrdinalProvider';
}

/// Loads a message by its ordinal position within a contact's message history.
/// This shows messages across all chats/handles with the contact.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency.
///
/// Copied from [messageByContactOrdinal].
class MessageByContactOrdinalProvider
    extends AutoDisposeFutureProvider<ChatMessageListItem?> {
  /// Loads a message by its ordinal position within a contact's message history.
  /// This shows messages across all chats/handles with the contact.
  /// Returns null if ordinal is out of range.
  /// Uses auto-dispose for memory efficiency.
  ///
  /// Copied from [messageByContactOrdinal].
  MessageByContactOrdinalProvider({
    required int contactId,
    required int ordinal,
  }) : this._internal(
         (ref) => messageByContactOrdinal(
           ref as MessageByContactOrdinalRef,
           contactId: contactId,
           ordinal: ordinal,
         ),
         from: messageByContactOrdinalProvider,
         name: r'messageByContactOrdinalProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageByContactOrdinalHash,
         dependencies: MessageByContactOrdinalFamily._dependencies,
         allTransitiveDependencies:
             MessageByContactOrdinalFamily._allTransitiveDependencies,
         contactId: contactId,
         ordinal: ordinal,
       );

  MessageByContactOrdinalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.ordinal,
  }) : super.internal();

  final int contactId;
  final int ordinal;

  @override
  Override overrideWith(
    FutureOr<ChatMessageListItem?> Function(MessageByContactOrdinalRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageByContactOrdinalProvider._internal(
        (ref) => create(ref as MessageByContactOrdinalRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        ordinal: ordinal,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChatMessageListItem?> createElement() {
    return _MessageByContactOrdinalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageByContactOrdinalProvider &&
        other.contactId == contactId &&
        other.ordinal == ordinal;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, ordinal.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageByContactOrdinalRef
    on AutoDisposeFutureProviderRef<ChatMessageListItem?> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `ordinal` of this provider.
  int get ordinal;
}

class _MessageByContactOrdinalProviderElement
    extends AutoDisposeFutureProviderElement<ChatMessageListItem?>
    with MessageByContactOrdinalRef {
  _MessageByContactOrdinalProviderElement(super.provider);

  @override
  int get contactId => (origin as MessageByContactOrdinalProvider).contactId;
  @override
  int get ordinal => (origin as MessageByContactOrdinalProvider).ordinal;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
