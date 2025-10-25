// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_messages_pager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatMessagesPagerHash() => r'457f6064691927cf9833f233db24fc3cb8249326';

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

abstract class _$ChatMessagesPager
    extends BuildlessAutoDisposeAsyncNotifier<MessagesPagerState> {
  late final int chatId;

  FutureOr<MessagesPagerState> build({required int chatId});
}

/// See also [ChatMessagesPager].
@ProviderFor(ChatMessagesPager)
const chatMessagesPagerProvider = ChatMessagesPagerFamily();

/// See also [ChatMessagesPager].
class ChatMessagesPagerFamily extends Family<AsyncValue<MessagesPagerState>> {
  /// See also [ChatMessagesPager].
  const ChatMessagesPagerFamily();

  /// See also [ChatMessagesPager].
  ChatMessagesPagerProvider call({required int chatId}) {
    return ChatMessagesPagerProvider(chatId: chatId);
  }

  @override
  ChatMessagesPagerProvider getProviderOverride(
    covariant ChatMessagesPagerProvider provider,
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
  String? get name => r'chatMessagesPagerProvider';
}

/// See also [ChatMessagesPager].
class ChatMessagesPagerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ChatMessagesPager,
          MessagesPagerState
        > {
  /// See also [ChatMessagesPager].
  ChatMessagesPagerProvider({required int chatId})
    : this._internal(
        () => ChatMessagesPager()..chatId = chatId,
        from: chatMessagesPagerProvider,
        name: r'chatMessagesPagerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatMessagesPagerHash,
        dependencies: ChatMessagesPagerFamily._dependencies,
        allTransitiveDependencies:
            ChatMessagesPagerFamily._allTransitiveDependencies,
        chatId: chatId,
      );

  ChatMessagesPagerProvider._internal(
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
  FutureOr<MessagesPagerState> runNotifierBuild(
    covariant ChatMessagesPager notifier,
  ) {
    return notifier.build(chatId: chatId);
  }

  @override
  Override overrideWith(ChatMessagesPager Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessagesPagerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ChatMessagesPager, MessagesPagerState>
  createElement() {
    return _ChatMessagesPagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesPagerProvider && other.chatId == chatId;
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
mixin ChatMessagesPagerRef
    on AutoDisposeAsyncNotifierProviderRef<MessagesPagerState> {
  /// The parameter `chatId` of this provider.
  int get chatId;
}

class _ChatMessagesPagerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ChatMessagesPager,
          MessagesPagerState
        >
    with ChatMessagesPagerRef {
  _ChatMessagesPagerProviderElement(super.provider);

  @override
  int get chatId => (origin as ChatMessagesPagerProvider).chatId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
