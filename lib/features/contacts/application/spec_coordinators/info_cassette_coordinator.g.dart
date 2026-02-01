// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$infoCassetteCoordinatorHash() =>
    r'67a855b09721e2d3cd609ccc45d2e6468839a1fe';

/// Contacts InfoCassetteCoordinator
///
/// This coordinator is part of the Contacts feature and is responsible for *routing only*:
///
/// - Accept a ContactsInfoCassetteSpec (sidebar protocol entity)
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
/// happening here, it belongs in spec_cases (e.g., InfoContentResolver).
///
/// Copied from [InfoCassetteCoordinator].
@ProviderFor(InfoCassetteCoordinator)
final infoCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<InfoCassetteCoordinator, void>.internal(
      InfoCassetteCoordinator.new,
      name: r'infoCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$infoCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InfoCassetteCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
