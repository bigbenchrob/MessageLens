// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sidebarUtilitiesCassetteCoordinatorHash() =>
    r'2565c62fe95edf851fe478c107a949abda786874';

/// SidebarUtilities CassetteCoordinator
///
/// This coordinator is part of the SidebarUtilities feature and is responsible
/// for *routing only*:
///
/// - Accept a SidebarUtilityCassetteSpec (sidebar protocol entity)
/// - Pattern-match on the spec variant
/// - Delegate to appropriate builders for widget construction
/// - Return a SidebarCassetteCardViewModel (NOT a wrapped widget)
///
/// ## Contract
///
/// - MUST NOT call ref.watch()
/// - MAY use ref.read()
/// - MUST return fully resolved view model with chrome decisions
///
/// ## Spec Variants
///
/// - topChatMenu: The primary navigation dropdown for messages mode
/// - settingsMenu: The navigation dropdown for settings mode
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
