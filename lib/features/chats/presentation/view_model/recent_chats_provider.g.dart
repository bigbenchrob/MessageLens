// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_chats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentChatsHash() => r'dabd33042b924eb94303c5a0ff3dc9243fd6122a';

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

/// See also [recentChats].
@ProviderFor(recentChats)
const recentChatsProvider = RecentChatsFamily();

/// See also [recentChats].
class RecentChatsFamily extends Family<AsyncValue<List<RecentChatSummary>>> {
  /// See also [recentChats].
  const RecentChatsFamily();

  /// See also [recentChats].
  RecentChatsProvider call({int limit = 5}) {
    return RecentChatsProvider(limit: limit);
  }

  @override
  RecentChatsProvider getProviderOverride(
    covariant RecentChatsProvider provider,
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
  String? get name => r'recentChatsProvider';
}

/// See also [recentChats].
class RecentChatsProvider
    extends AutoDisposeFutureProvider<List<RecentChatSummary>> {
  /// See also [recentChats].
  RecentChatsProvider({int limit = 5})
    : this._internal(
        (ref) => recentChats(ref as RecentChatsRef, limit: limit),
        from: recentChatsProvider,
        name: r'recentChatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recentChatsHash,
        dependencies: RecentChatsFamily._dependencies,
        allTransitiveDependencies: RecentChatsFamily._allTransitiveDependencies,
        limit: limit,
      );

  RecentChatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<RecentChatSummary>> Function(RecentChatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentChatsProvider._internal(
        (ref) => create(ref as RecentChatsRef),
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
    return _RecentChatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentChatsProvider && other.limit == limit;
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
mixin RecentChatsRef on AutoDisposeFutureProviderRef<List<RecentChatSummary>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _RecentChatsProviderElement
    extends AutoDisposeFutureProviderElement<List<RecentChatSummary>>
    with RecentChatsRef {
  _RecentChatsProviderElement(super.provider);

  @override
  int get limit => (origin as RecentChatsProvider).limit;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
