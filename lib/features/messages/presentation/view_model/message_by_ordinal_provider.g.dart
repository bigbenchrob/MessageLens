// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_by_ordinal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageByOrdinalHash() => r'e96c8a17176d4e4274aa2b2c13125c9118ee5500';

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

/// Loads a message by its ordinal position within a chat.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency with large chats.
///
/// Copied from [messageByOrdinal].
@ProviderFor(messageByOrdinal)
const messageByOrdinalProvider = MessageByOrdinalFamily();

/// Loads a message by its ordinal position within a chat.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency with large chats.
///
/// Copied from [messageByOrdinal].
class MessageByOrdinalFamily extends Family<AsyncValue<ChatMessageListItem?>> {
  /// Loads a message by its ordinal position within a chat.
  /// Returns null if ordinal is out of range.
  /// Uses auto-dispose for memory efficiency with large chats.
  ///
  /// Copied from [messageByOrdinal].
  const MessageByOrdinalFamily();

  /// Loads a message by its ordinal position within a chat.
  /// Returns null if ordinal is out of range.
  /// Uses auto-dispose for memory efficiency with large chats.
  ///
  /// Copied from [messageByOrdinal].
  MessageByOrdinalProvider call({required int chatId, required int ordinal}) {
    return MessageByOrdinalProvider(chatId: chatId, ordinal: ordinal);
  }

  @override
  MessageByOrdinalProvider getProviderOverride(
    covariant MessageByOrdinalProvider provider,
  ) {
    return call(chatId: provider.chatId, ordinal: provider.ordinal);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageByOrdinalProvider';
}

/// Loads a message by its ordinal position within a chat.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency with large chats.
///
/// Copied from [messageByOrdinal].
class MessageByOrdinalProvider
    extends AutoDisposeFutureProvider<ChatMessageListItem?> {
  /// Loads a message by its ordinal position within a chat.
  /// Returns null if ordinal is out of range.
  /// Uses auto-dispose for memory efficiency with large chats.
  ///
  /// Copied from [messageByOrdinal].
  MessageByOrdinalProvider({required int chatId, required int ordinal})
    : this._internal(
        (ref) => messageByOrdinal(
          ref as MessageByOrdinalRef,
          chatId: chatId,
          ordinal: ordinal,
        ),
        from: messageByOrdinalProvider,
        name: r'messageByOrdinalProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageByOrdinalHash,
        dependencies: MessageByOrdinalFamily._dependencies,
        allTransitiveDependencies:
            MessageByOrdinalFamily._allTransitiveDependencies,
        chatId: chatId,
        ordinal: ordinal,
      );

  MessageByOrdinalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
    required this.ordinal,
  }) : super.internal();

  final int chatId;
  final int ordinal;

  @override
  Override overrideWith(
    FutureOr<ChatMessageListItem?> Function(MessageByOrdinalRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageByOrdinalProvider._internal(
        (ref) => create(ref as MessageByOrdinalRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
        ordinal: ordinal,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChatMessageListItem?> createElement() {
    return _MessageByOrdinalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageByOrdinalProvider &&
        other.chatId == chatId &&
        other.ordinal == ordinal;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);
    hash = _SystemHash.combine(hash, ordinal.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageByOrdinalRef
    on AutoDisposeFutureProviderRef<ChatMessageListItem?> {
  /// The parameter `chatId` of this provider.
  int get chatId;

  /// The parameter `ordinal` of this provider.
  int get ordinal;
}

class _MessageByOrdinalProviderElement
    extends AutoDisposeFutureProviderElement<ChatMessageListItem?>
    with MessageByOrdinalRef {
  _MessageByOrdinalProviderElement(super.provider);

  @override
  int get chatId => (origin as MessageByOrdinalProvider).chatId;
  @override
  int get ordinal => (origin as MessageByOrdinalProvider).ordinal;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
