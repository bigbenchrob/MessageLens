// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_messages_ordinal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatMessagesOrdinalHash() =>
    r'a0139fd93b5797f7a3699fea8769a39c533ec4b9';

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

abstract class _$ChatMessagesOrdinal
    extends BuildlessAutoDisposeAsyncNotifier<MessagesOrdinalState> {
  late final int chatId;

  FutureOr<MessagesOrdinalState> build({required int chatId});
}

/// See also [ChatMessagesOrdinal].
@ProviderFor(ChatMessagesOrdinal)
const chatMessagesOrdinalProvider = ChatMessagesOrdinalFamily();

/// See also [ChatMessagesOrdinal].
class ChatMessagesOrdinalFamily
    extends Family<AsyncValue<MessagesOrdinalState>> {
  /// See also [ChatMessagesOrdinal].
  const ChatMessagesOrdinalFamily();

  /// See also [ChatMessagesOrdinal].
  ChatMessagesOrdinalProvider call({required int chatId}) {
    return ChatMessagesOrdinalProvider(chatId: chatId);
  }

  @override
  ChatMessagesOrdinalProvider getProviderOverride(
    covariant ChatMessagesOrdinalProvider provider,
  ) {
    return call(chatId: provider.chatId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMessagesOrdinalProvider';
}

/// See also [ChatMessagesOrdinal].
class ChatMessagesOrdinalProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ChatMessagesOrdinal,
          MessagesOrdinalState
        > {
  /// See also [ChatMessagesOrdinal].
  ChatMessagesOrdinalProvider({required int chatId})
    : this._internal(
        () => ChatMessagesOrdinal()..chatId = chatId,
        from: chatMessagesOrdinalProvider,
        name: r'chatMessagesOrdinalProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatMessagesOrdinalHash,
        dependencies: ChatMessagesOrdinalFamily._dependencies,
        allTransitiveDependencies:
            ChatMessagesOrdinalFamily._allTransitiveDependencies,
        chatId: chatId,
      );

  ChatMessagesOrdinalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final int chatId;

  @override
  FutureOr<MessagesOrdinalState> runNotifierBuild(
    covariant ChatMessagesOrdinal notifier,
  ) {
    return notifier.build(chatId: chatId);
  }

  @override
  Override overrideWith(ChatMessagesOrdinal Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessagesOrdinalProvider._internal(
        () => create()..chatId = chatId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ChatMessagesOrdinal,
    MessagesOrdinalState
  >
  createElement() {
    return _ChatMessagesOrdinalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesOrdinalProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatMessagesOrdinalRef
    on AutoDisposeAsyncNotifierProviderRef<MessagesOrdinalState> {
  /// The parameter `chatId` of this provider.
  int get chatId;
}

class _ChatMessagesOrdinalProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ChatMessagesOrdinal,
          MessagesOrdinalState
        >
    with ChatMessagesOrdinalRef {
  _ChatMessagesOrdinalProviderElement(super.provider);

  @override
  int get chatId => (origin as ChatMessagesOrdinalProvider).chatId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
