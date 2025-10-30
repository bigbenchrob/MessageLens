// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_for_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesForChatHash() => r'1f20806691a7cc8488068ca2b46b6feb5138d065';

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

/// See also [messagesForChat].
@ProviderFor(messagesForChat)
const messagesForChatProvider = MessagesForChatFamily();

/// See also [messagesForChat].
class MessagesForChatFamily
    extends Family<AsyncValue<List<ChatMessageListItem>>> {
  /// See also [messagesForChat].
  const MessagesForChatFamily();

  /// See also [messagesForChat].
  MessagesForChatProvider call({required int chatId}) {
    return MessagesForChatProvider(chatId: chatId);
  }

  @override
  MessagesForChatProvider getProviderOverride(
    covariant MessagesForChatProvider provider,
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
  String? get name => r'messagesForChatProvider';
}

/// See also [messagesForChat].
class MessagesForChatProvider
    extends AutoDisposeStreamProvider<List<ChatMessageListItem>> {
  /// See also [messagesForChat].
  MessagesForChatProvider({required int chatId})
    : this._internal(
        (ref) => messagesForChat(ref as MessagesForChatRef, chatId: chatId),
        from: messagesForChatProvider,
        name: r'messagesForChatProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesForChatHash,
        dependencies: MessagesForChatFamily._dependencies,
        allTransitiveDependencies:
            MessagesForChatFamily._allTransitiveDependencies,
        chatId: chatId,
      );

  MessagesForChatProvider._internal(
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
  Override overrideWith(
    Stream<List<ChatMessageListItem>> Function(MessagesForChatRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesForChatProvider._internal(
        (ref) => create(ref as MessagesForChatRef),
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
  AutoDisposeStreamProviderElement<List<ChatMessageListItem>> createElement() {
    return _MessagesForChatProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesForChatProvider && other.chatId == chatId;
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
mixin MessagesForChatRef
    on AutoDisposeStreamProviderRef<List<ChatMessageListItem>> {
  /// The parameter `chatId` of this provider.
  int get chatId;
}

class _MessagesForChatProviderElement
    extends AutoDisposeStreamProviderElement<List<ChatMessageListItem>>
    with MessagesForChatRef {
  _MessagesForChatProviderElement(super.provider);

  @override
  int get chatId => (origin as MessagesForChatProvider).chatId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
