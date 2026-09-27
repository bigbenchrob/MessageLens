// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_mutation_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$archiveDatabaseReopenBlockedHash() =>
    r'55ba4b7d26c836206d64c3d432dbe1ce2354f986';

/// See also [archiveDatabaseReopenBlocked].
@ProviderFor(archiveDatabaseReopenBlocked)
final archiveDatabaseReopenBlockedProvider = AutoDisposeProvider<bool>.internal(
  archiveDatabaseReopenBlocked,
  name: r'archiveDatabaseReopenBlockedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archiveDatabaseReopenBlockedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArchiveDatabaseReopenBlockedRef = AutoDisposeProviderRef<bool>;
String _$archiveMutationCoordinatorHash() =>
    r'7268e7403e4de3441455f3f83eb4e68edc3ec9ab';

/// Single process-local admission authority for every archive mutation.
///
/// Feature owners retain their business logic. They request a named operation
/// here before mutating an admitted archive. Nested stages inherit the same
/// owner through the async Zone and may re-enter without creating another
/// authority source.
///
/// Copied from [ArchiveMutationCoordinator].
@ProviderFor(ArchiveMutationCoordinator)
final archiveMutationCoordinatorProvider =
    NotifierProvider<
      ArchiveMutationCoordinator,
      ArchiveMutationCoordinatorState
    >.internal(
      ArchiveMutationCoordinator.new,
      name: r'archiveMutationCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$archiveMutationCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArchiveMutationCoordinator =
    Notifier<ArchiveMutationCoordinatorState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
