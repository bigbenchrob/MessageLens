// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handlesInfoCassetteCoordinatorHash() =>
    r'29eafcb7cdd5a1f6ffc312245e513c8c24d5a2e5';

/// Handles InfoCassetteCoordinator
///
/// This coordinator is part of the Handles feature and is responsible for *routing only*:
///
/// - Accept a HandlesInfoCassetteSpec (sidebar protocol entity)
/// - Pattern-match on the spec variant
/// - Delegate meaning/data/formatting to application-layer case handlers/resolvers
/// - Return a SidebarCassetteCardViewModel (NOT a wrapped widget)
///
/// Why return a view model instead of a widget?
///
/// - The app-level CassetteWidgetCoordinator centralizes UI chrome decisions.
/// - This keeps card layout/padding/header policies consistent across features.
/// - Features remain agnostic to how cards are visually framed.
/// - Future changes to card chrome happen in one place, not N features.
///
/// IMPORTANT:
/// This coordinator should remain small. If you see data fetching or complex formatting
/// happening here, it belongs in spec_cases (e.g., HandlesInfoContentResolver).
///
/// Copied from [HandlesInfoCassetteCoordinator].
@ProviderFor(HandlesInfoCassetteCoordinator)
final handlesInfoCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<HandlesInfoCassetteCoordinator, void>.internal(
      HandlesInfoCassetteCoordinator.new,
      name: r'handlesInfoCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handlesInfoCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HandlesInfoCassetteCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
