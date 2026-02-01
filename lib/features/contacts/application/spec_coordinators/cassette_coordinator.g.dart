// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsCassetteCoordinatorHash() =>
    r'c681a4b71375d3464c07a33d66dea1edceda1631';

/// Contacts CassetteCoordinator
///
/// This coordinator is part of the Contacts feature and is responsible for
/// *routing only*:
///
/// - Accept a ContactsCassetteSpec (sidebar protocol entity)
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
/// ## Migration Status
///
/// This coordinator is being migrated to the cross-surface spec architecture.
/// Currently it bridges to legacy builders; these will be replaced phase by phase:
///
/// - [ ] contactChooser → ChooserContentResolver + ChooserWidgetBuilder
/// - [x] contactHeroSummary → HeroSummaryResolver + HeroSummaryWidgetBuilder
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/30-NEW-FEATURE-ADDITION/
///      contacts-cassette-cross-surface-migration/PROPOSAL.md
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
