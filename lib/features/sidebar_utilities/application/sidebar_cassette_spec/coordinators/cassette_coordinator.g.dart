// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sidebarUtilitiesCassetteCoordinatorHash() =>
    r'4f4586aaa3161f5dd3bd54492de77d7e6a4b303e';

/// Sidebar Utilities Cassette Coordinator
///
/// This coordinator routes [SidebarUtilityCassetteSpec] to the appropriate
/// resolver. It follows the cross-surface spec system contract:
///
/// - Receives a spec + cassetteIndex
/// - Pattern-matches on the spec variant
/// - Extracts payload parameters
/// - Calls exactly ONE resolver
/// - Returns the resolver's `Future<SidebarCassettePayload>`
///
/// The coordinator MUST NOT:
/// - Perform IO
/// - Construct widgets
/// - Build view models itself
/// - Pass specs to resolvers
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
///
/// Copied from [SidebarUtilitiesCassetteCoordinator].
@ProviderFor(SidebarUtilitiesCassetteCoordinator)
final sidebarUtilitiesCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<
      SidebarUtilitiesCassetteCoordinator,
      void
    >.internal(
      SidebarUtilitiesCassetteCoordinator.new,
      name: r'sidebarUtilitiesCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sidebarUtilitiesCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SidebarUtilitiesCassetteCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
