// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesCassetteCoordinatorHash() =>
    r'b51077693e9c52ae66ef7de5668fbb71ed42daf2';

/// Messages Cassette Coordinator
///
/// Routes [MessagesCassetteSpec] variants to their respective resolvers.
/// This coordinator is the entry point for all messages-related sidebar
/// cassettes.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [MessagesCassetteSpec]
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
/// Copied from [MessagesCassetteCoordinator].
@ProviderFor(MessagesCassetteCoordinator)
final messagesCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<MessagesCassetteCoordinator, void>.internal(
      MessagesCassetteCoordinator.new,
      name: r'messagesCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$messagesCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MessagesCassetteCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
