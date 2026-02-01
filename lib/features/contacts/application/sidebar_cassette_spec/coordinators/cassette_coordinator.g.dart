// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsCassetteCoordinatorHash() =>
    r'31d62d5462116c0def3a61e96289d165fcdcedb9';

/// Contacts Cassette Coordinator
///
/// Routes [ContactsCassetteSpec] variants to their respective resolvers.
/// This coordinator is the entry point for all contacts-related sidebar cassettes.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [ContactsCassetteSpec]
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
/// Copied from [ContactsCassetteCoordinator].
@ProviderFor(ContactsCassetteCoordinator)
final contactsCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<ContactsCassetteCoordinator, void>.internal(
      ContactsCassetteCoordinator.new,
      name: r'contactsCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsCassetteCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
