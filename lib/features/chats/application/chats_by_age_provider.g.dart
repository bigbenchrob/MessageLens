// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_by_age_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatsByAgeHash() => r'324893a6e698320e13504bd550e3e315c1cc0013';

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

/// Returns chats ordered by first message date (oldest first).
///
/// Copied from [chatsByAge].
@ProviderFor(chatsByAge)
const chatsByAgeProvider = ChatsByAgeFamily();

/// Returns chats ordered by first message date (oldest first).
///
/// Copied from [chatsByAge].
class ChatsByAgeFamily extends Family<AsyncValue<List<RecentChatSummary>>> {
  /// Returns chats ordered by first message date (oldest first).
  ///
  /// Copied from [chatsByAge].
  const ChatsByAgeFamily();

  /// Returns chats ordered by first message date (oldest first).
  ///
  /// Copied from [chatsByAge].
  ChatsByAgeProvider call({int? limit}) {
    return ChatsByAgeProvider(limit: limit);
  }

  @override
  ChatsByAgeProvider getProviderOverride(
    covariant ChatsByAgeProvider provider,
  ) {
    return call(limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatsByAgeProvider';
}

/// Returns chats ordered by first message date (oldest first).
///
/// Copied from [chatsByAge].
class ChatsByAgeProvider
    extends AutoDisposeFutureProvider<List<RecentChatSummary>> {
  /// Returns chats ordered by first message date (oldest first).
  ///
  /// Copied from [chatsByAge].
  ChatsByAgeProvider({int? limit})
    : this._internal(
        (ref) => chatsByAge(ref as ChatsByAgeRef, limit: limit),
        from: chatsByAgeProvider,
        name: r'chatsByAgeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatsByAgeHash,
        dependencies: ChatsByAgeFamily._dependencies,
        allTransitiveDependencies: ChatsByAgeFamily._allTransitiveDependencies,
        limit: limit,
      );

  ChatsByAgeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int? limit;

  @override
  Override overrideWith(
    FutureOr<List<RecentChatSummary>> Function(ChatsByAgeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatsByAgeProvider._internal(
        (ref) => create(ref as ChatsByAgeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecentChatSummary>> createElement() {
    return _ChatsByAgeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatsByAgeProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatsByAgeRef on AutoDisposeFutureProviderRef<List<RecentChatSummary>> {
  /// The parameter `limit` of this provider.
  int? get limit;
}

class _ChatsByAgeProviderElement
    extends AutoDisposeFutureProviderElement<List<RecentChatSummary>>
    with ChatsByAgeRef {
  _ChatsByAgeProviderElement(super.provider);

  @override
  int? get limit => (origin as ChatsByAgeProvider).limit;
}

String _$chatsByAgeRecentHash() => r'350f1eed4092b41f7f49f5757dd2389d65d4dc51';

/// Returns chats ordered by first message date (newest first).
///
/// Copied from [chatsByAgeRecent].
@ProviderFor(chatsByAgeRecent)
const chatsByAgeRecentProvider = ChatsByAgeRecentFamily();

/// Returns chats ordered by first message date (newest first).
///
/// Copied from [chatsByAgeRecent].
class ChatsByAgeRecentFamily
    extends Family<AsyncValue<List<RecentChatSummary>>> {
  /// Returns chats ordered by first message date (newest first).
  ///
  /// Copied from [chatsByAgeRecent].
  const ChatsByAgeRecentFamily();

  /// Returns chats ordered by first message date (newest first).
  ///
  /// Copied from [chatsByAgeRecent].
  ChatsByAgeRecentProvider call({int? limit}) {
    return ChatsByAgeRecentProvider(limit: limit);
  }

  @override
  ChatsByAgeRecentProvider getProviderOverride(
    covariant ChatsByAgeRecentProvider provider,
  ) {
    return call(limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatsByAgeRecentProvider';
}

/// Returns chats ordered by first message date (newest first).
///
/// Copied from [chatsByAgeRecent].
class ChatsByAgeRecentProvider
    extends AutoDisposeFutureProvider<List<RecentChatSummary>> {
  /// Returns chats ordered by first message date (newest first).
  ///
  /// Copied from [chatsByAgeRecent].
  ChatsByAgeRecentProvider({int? limit})
    : this._internal(
        (ref) => chatsByAgeRecent(ref as ChatsByAgeRecentRef, limit: limit),
        from: chatsByAgeRecentProvider,
        name: r'chatsByAgeRecentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatsByAgeRecentHash,
        dependencies: ChatsByAgeRecentFamily._dependencies,
        allTransitiveDependencies:
            ChatsByAgeRecentFamily._allTransitiveDependencies,
        limit: limit,
      );

  ChatsByAgeRecentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int? limit;

  @override
  Override overrideWith(
    FutureOr<List<RecentChatSummary>> Function(ChatsByAgeRecentRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatsByAgeRecentProvider._internal(
        (ref) => create(ref as ChatsByAgeRecentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecentChatSummary>> createElement() {
    return _ChatsByAgeRecentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatsByAgeRecentProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatsByAgeRecentRef
    on AutoDisposeFutureProviderRef<List<RecentChatSummary>> {
  /// The parameter `limit` of this provider.
  int? get limit;
}

class _ChatsByAgeRecentProviderElement
    extends AutoDisposeFutureProviderElement<List<RecentChatSummary>>
    with ChatsByAgeRecentRef {
  _ChatsByAgeRecentProviderElement(super.provider);

  @override
  int? get limit => (origin as ChatsByAgeRecentProvider).limit;
}

String _$unmatchedChatsHash() => r'7f28fe1e6b39bcfdb60012abe48cbcb51570efe0';

/// Returns chats where the handle has no participant match (unmatched phone numbers/emails).
///
/// Copied from [unmatchedChats].
@ProviderFor(unmatchedChats)
const unmatchedChatsProvider = UnmatchedChatsFamily();

/// Returns chats where the handle has no participant match (unmatched phone numbers/emails).
///
/// Copied from [unmatchedChats].
class UnmatchedChatsFamily extends Family<AsyncValue<List<RecentChatSummary>>> {
  /// Returns chats where the handle has no participant match (unmatched phone numbers/emails).
  ///
  /// Copied from [unmatchedChats].
  const UnmatchedChatsFamily();

  /// Returns chats where the handle has no participant match (unmatched phone numbers/emails).
  ///
  /// Copied from [unmatchedChats].
  UnmatchedChatsProvider call({int? limit}) {
    return UnmatchedChatsProvider(limit: limit);
  }

  @override
  UnmatchedChatsProvider getProviderOverride(
    covariant UnmatchedChatsProvider provider,
  ) {
    return call(limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'unmatchedChatsProvider';
}

/// Returns chats where the handle has no participant match (unmatched phone numbers/emails).
///
/// Copied from [unmatchedChats].
class UnmatchedChatsProvider
    extends AutoDisposeFutureProvider<List<RecentChatSummary>> {
  /// Returns chats where the handle has no participant match (unmatched phone numbers/emails).
  ///
  /// Copied from [unmatchedChats].
  UnmatchedChatsProvider({int? limit})
    : this._internal(
        (ref) => unmatchedChats(ref as UnmatchedChatsRef, limit: limit),
        from: unmatchedChatsProvider,
        name: r'unmatchedChatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unmatchedChatsHash,
        dependencies: UnmatchedChatsFamily._dependencies,
        allTransitiveDependencies:
            UnmatchedChatsFamily._allTransitiveDependencies,
        limit: limit,
      );

  UnmatchedChatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int? limit;

  @override
  Override overrideWith(
    FutureOr<List<RecentChatSummary>> Function(UnmatchedChatsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnmatchedChatsProvider._internal(
        (ref) => create(ref as UnmatchedChatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecentChatSummary>> createElement() {
    return _UnmatchedChatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnmatchedChatsProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UnmatchedChatsRef
    on AutoDisposeFutureProviderRef<List<RecentChatSummary>> {
  /// The parameter `limit` of this provider.
  int? get limit;
}

class _UnmatchedChatsProviderElement
    extends AutoDisposeFutureProviderElement<List<RecentChatSummary>>
    with UnmatchedChatsRef {
  _UnmatchedChatsProviderElement(super.provider);

  @override
  int? get limit => (origin as UnmatchedChatsProvider).limit;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
