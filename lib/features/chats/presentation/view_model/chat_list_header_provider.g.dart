// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_header_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatListHeaderHash() => r'5b33ecf475c57cf18f33054e2bb1a8a1aeb2d224';

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

/// See also [chatListHeader].
@ProviderFor(chatListHeader)
const chatListHeaderProvider = ChatListHeaderFamily();

/// See also [chatListHeader].
class ChatListHeaderFamily extends Family<String> {
  /// See also [chatListHeader].
  const ChatListHeaderFamily();

  /// See also [chatListHeader].
  ChatListHeaderProvider call({
    required ChatsSpec spec,
    int? limit,
    int? selectedChatId,
  }) {
    return ChatListHeaderProvider(
      spec: spec,
      limit: limit,
      selectedChatId: selectedChatId,
    );
  }

  @override
  ChatListHeaderProvider getProviderOverride(
    covariant ChatListHeaderProvider provider,
  ) {
    return call(
      spec: provider.spec,
      limit: provider.limit,
      selectedChatId: provider.selectedChatId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatListHeaderProvider';
}

/// See also [chatListHeader].
class ChatListHeaderProvider extends AutoDisposeProvider<String> {
  /// See also [chatListHeader].
  ChatListHeaderProvider({
    required ChatsSpec spec,
    int? limit,
    int? selectedChatId,
  }) : this._internal(
         (ref) => chatListHeader(
           ref as ChatListHeaderRef,
           spec: spec,
           limit: limit,
           selectedChatId: selectedChatId,
         ),
         from: chatListHeaderProvider,
         name: r'chatListHeaderProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$chatListHeaderHash,
         dependencies: ChatListHeaderFamily._dependencies,
         allTransitiveDependencies:
             ChatListHeaderFamily._allTransitiveDependencies,
         spec: spec,
         limit: limit,
         selectedChatId: selectedChatId,
       );

  ChatListHeaderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.spec,
    required this.limit,
    required this.selectedChatId,
  }) : super.internal();

  final ChatsSpec spec;
  final int? limit;
  final int? selectedChatId;

  @override
  Override overrideWith(String Function(ChatListHeaderRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: ChatListHeaderProvider._internal(
        (ref) => create(ref as ChatListHeaderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        spec: spec,
        limit: limit,
        selectedChatId: selectedChatId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _ChatListHeaderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatListHeaderProvider &&
        other.spec == spec &&
        other.limit == limit &&
        other.selectedChatId == selectedChatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, spec.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, selectedChatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatListHeaderRef on AutoDisposeProviderRef<String> {
  /// The parameter `spec` of this provider.
  ChatsSpec get spec;

  /// The parameter `limit` of this provider.
  int? get limit;

  /// The parameter `selectedChatId` of this provider.
  int? get selectedChatId;
}

class _ChatListHeaderProviderElement extends AutoDisposeProviderElement<String>
    with ChatListHeaderRef {
  _ChatListHeaderProviderElement(super.provider);

  @override
  ChatsSpec get spec => (origin as ChatListHeaderProvider).spec;
  @override
  int? get limit => (origin as ChatListHeaderProvider).limit;
  @override
  int? get selectedChatId => (origin as ChatListHeaderProvider).selectedChatId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
