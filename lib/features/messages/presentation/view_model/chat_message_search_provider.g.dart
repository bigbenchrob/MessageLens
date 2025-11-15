// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatMessageSearchResultsHash() =>
    r'b682506afeb985f90cf672f775bd00136024bec1';

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

/// See also [chatMessageSearchResults].
@ProviderFor(chatMessageSearchResults)
const chatMessageSearchResultsProvider = ChatMessageSearchResultsFamily();

/// See also [chatMessageSearchResults].
class ChatMessageSearchResultsFamily
    extends Family<AsyncValue<List<ChatMessageListItem>>> {
  /// See also [chatMessageSearchResults].
  const ChatMessageSearchResultsFamily();

  /// See also [chatMessageSearchResults].
  ChatMessageSearchResultsProvider call({
    required int chatId,
    required String query,
  }) {
    return ChatMessageSearchResultsProvider(chatId: chatId, query: query);
  }

  @override
  ChatMessageSearchResultsProvider getProviderOverride(
    covariant ChatMessageSearchResultsProvider provider,
  ) {
    return call(chatId: provider.chatId, query: provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMessageSearchResultsProvider';
}

/// See also [chatMessageSearchResults].
class ChatMessageSearchResultsProvider
    extends AutoDisposeFutureProvider<List<ChatMessageListItem>> {
  /// See also [chatMessageSearchResults].
  ChatMessageSearchResultsProvider({required int chatId, required String query})
    : this._internal(
        (ref) => chatMessageSearchResults(
          ref as ChatMessageSearchResultsRef,
          chatId: chatId,
          query: query,
        ),
        from: chatMessageSearchResultsProvider,
        name: r'chatMessageSearchResultsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatMessageSearchResultsHash,
        dependencies: ChatMessageSearchResultsFamily._dependencies,
        allTransitiveDependencies:
            ChatMessageSearchResultsFamily._allTransitiveDependencies,
        chatId: chatId,
        query: query,
      );

  ChatMessageSearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
    required this.query,
  }) : super.internal();

  final int chatId;
  final String query;

  @override
  Override overrideWith(
    FutureOr<List<ChatMessageListItem>> Function(
      ChatMessageSearchResultsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatMessageSearchResultsProvider._internal(
        (ref) => create(ref as ChatMessageSearchResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ChatMessageListItem>> createElement() {
    return _ChatMessageSearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessageSearchResultsProvider &&
        other.chatId == chatId &&
        other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatMessageSearchResultsRef
    on AutoDisposeFutureProviderRef<List<ChatMessageListItem>> {
  /// The parameter `chatId` of this provider.
  int get chatId;

  /// The parameter `query` of this provider.
  String get query;
}

class _ChatMessageSearchResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<ChatMessageListItem>>
    with ChatMessageSearchResultsRef {
  _ChatMessageSearchResultsProviderElement(super.provider);

  @override
  int get chatId => (origin as ChatMessageSearchResultsProvider).chatId;
  @override
  String get query => (origin as ChatMessageSearchResultsProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
