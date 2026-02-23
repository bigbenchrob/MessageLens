// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handlesCassetteCoordinatorHash() =>
    r'c9f78abbf8ed5bf2e8454aa6423ad53d49071a94';

/// Handles Cassette Coordinator
///
/// Routes [HandlesCassetteSpec] variants to their respective resolvers.
/// This coordinator is the entry point for all handles-related sidebar cassettes.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [HandlesCassetteSpec]
/// - Pattern-matches on the spec
/// - Extracts payload parameters
/// - Calls exactly ONE resolver
/// - Returns the resolver's `Future<SidebarCassetteCardViewModel>`
///
/// The coordinator MUST NOT:
/// - Perform IO
/// - Construct widgets
/// - Build view models itself
/// - Pass specs to resolvers
///
/// Copied from [HandlesCassetteCoordinator].
@ProviderFor(HandlesCassetteCoordinator)
final handlesCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<HandlesCassetteCoordinator, void>.internal(
      HandlesCassetteCoordinator.new,
      name: r'handlesCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handlesCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HandlesCassetteCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
