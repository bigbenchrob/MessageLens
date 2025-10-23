// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageRepositoryHash() => r'21d4db4c1fbc7f5f904716b41c3759ba8d7e3d07';

/// See also [MessageRepository].
@ProviderFor(MessageRepository)
final messageRepositoryProvider =
    AutoDisposeNotifierProvider<
      MessageRepository,
      SqliteMessagesRepository
    >.internal(
      MessageRepository.new,
      name: r'messageRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$messageRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MessageRepository = AutoDisposeNotifier<SqliteMessagesRepository>;
String _$messagesCoordinatorHash() =>
    r'61c6012ea2e3d80772ca9a6f2ad4989e0da0a545';

/// Coordinator that maps [MessagesSpec] to rendered widgets for the center panel.
///
/// Copied from [MessagesCoordinator].
@ProviderFor(MessagesCoordinator)
final messagesCoordinatorProvider =
    AutoDisposeNotifierProvider<MessagesCoordinator, void>.internal(
      MessagesCoordinator.new,
      name: r'messagesCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$messagesCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MessagesCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
