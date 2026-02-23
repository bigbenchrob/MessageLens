// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handlesSettingsCoordinatorHash() =>
    r'50a62f1bdc1ebc214b6a2bcea039de1a193bcff9';

/// Handles Settings Cassette Coordinator
///
/// Routes [HandlesSettingsSpec] variants to their respective resolvers.
/// This coordinator is the entry point for handles-related settings cassettes.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [HandlesSettingsSpec]
/// - Pattern-matches on the spec
/// - Calls exactly ONE resolver
/// - Returns the resolver's `Future<SidebarCassetteCardViewModel>`
///
/// Copied from [HandlesSettingsCoordinator].
@ProviderFor(HandlesSettingsCoordinator)
final handlesSettingsCoordinatorProvider =
    AutoDisposeNotifierProvider<HandlesSettingsCoordinator, void>.internal(
      HandlesSettingsCoordinator.new,
      name: r'handlesSettingsCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handlesSettingsCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HandlesSettingsCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
