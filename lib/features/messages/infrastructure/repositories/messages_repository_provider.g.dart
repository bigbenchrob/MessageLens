// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesRepositoryHash() =>
    r'6028586c7d9c52d76726b6e050b68279ca5e4db1';

/// Provides the [SqliteMessagesRepository] instance.
///
/// Wire real dependencies with ref.watch(...) as you implement infra.
///
/// Copied from [MessagesRepository].
@ProviderFor(MessagesRepository)
final messagesRepositoryProvider =
    AutoDisposeNotifierProvider<
      MessagesRepository,
      SqliteMessagesRepository
    >.internal(
      MessagesRepository.new,
      name: r'messagesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$messagesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MessagesRepository = AutoDisposeNotifier<SqliteMessagesRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
