// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_header_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatHeaderInfoHash() => r'01a1e9b46c7a1932094a48c4ecfacf29673e7c7f';

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

/// See also [chatHeaderInfo].
@ProviderFor(chatHeaderInfo)
const chatHeaderInfoProvider = ChatHeaderInfoFamily();

/// See also [chatHeaderInfo].
class ChatHeaderInfoFamily extends Family<AsyncValue<ChatHeaderInfo>> {
  /// See also [chatHeaderInfo].
  const ChatHeaderInfoFamily();

  /// See also [chatHeaderInfo].
  ChatHeaderInfoProvider call({required int chatId}) {
    return ChatHeaderInfoProvider(chatId: chatId);
  }

  @override
  ChatHeaderInfoProvider getProviderOverride(
    covariant ChatHeaderInfoProvider provider,
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
  String? get name => r'chatHeaderInfoProvider';
}

/// See also [chatHeaderInfo].
class ChatHeaderInfoProvider extends AutoDisposeFutureProvider<ChatHeaderInfo> {
  /// See also [chatHeaderInfo].
  ChatHeaderInfoProvider({required int chatId})
    : this._internal(
        (ref) => chatHeaderInfo(ref as ChatHeaderInfoRef, chatId: chatId),
        from: chatHeaderInfoProvider,
        name: r'chatHeaderInfoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatHeaderInfoHash,
        dependencies: ChatHeaderInfoFamily._dependencies,
        allTransitiveDependencies:
            ChatHeaderInfoFamily._allTransitiveDependencies,
        chatId: chatId,
      );

  ChatHeaderInfoProvider._internal(
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
    FutureOr<ChatHeaderInfo> Function(ChatHeaderInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatHeaderInfoProvider._internal(
        (ref) => create(ref as ChatHeaderInfoRef),
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
  AutoDisposeFutureProviderElement<ChatHeaderInfo> createElement() {
    return _ChatHeaderInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatHeaderInfoProvider && other.chatId == chatId;
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
mixin ChatHeaderInfoRef on AutoDisposeFutureProviderRef<ChatHeaderInfo> {
  /// The parameter `chatId` of this provider.
  int get chatId;
}

class _ChatHeaderInfoProviderElement
    extends AutoDisposeFutureProviderElement<ChatHeaderInfo>
    with ChatHeaderInfoRef {
  _ChatHeaderInfoProviderElement(super.provider);

  @override
  int get chatId => (origin as ChatHeaderInfoProvider).chatId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
