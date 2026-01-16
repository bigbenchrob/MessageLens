// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatsRepositoryProviderHash() =>
    r'65b2e6dab31687667986321b68399ab6113803d5';

/// Provider for the ChatsRepository implementation.
///
/// Wire dependencies via `ref.watch(...)` when infrastructure is ready.
///
/// Copied from [ChatsRepositoryProvider].
@ProviderFor(ChatsRepositoryProvider)
final chatsRepositoryProviderProvider =
    AutoDisposeNotifierProvider<
      ChatsRepositoryProvider,
      SqliteChatsRepository
    >.internal(
      ChatsRepositoryProvider.new,
      name: r'chatsRepositoryProviderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatsRepositoryProviderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatsRepositoryProvider = AutoDisposeNotifier<SqliteChatsRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
