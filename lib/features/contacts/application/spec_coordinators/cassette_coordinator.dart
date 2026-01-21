import 'package:riverpod_annotation/riverpod_annotation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Essentials imports (shared sidebar protocol + view model)
// ─────────────────────────────────────────────────────────────────────────────

import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Legacy bridge imports (temporary - will be removed after full migration)
// ─────────────────────────────────────────────────────────────────────────────

import '../../presentation/cassettes/contact_hero_summary_cassette.dart';
import '../use_cases/contact_chooser_view_builder_provider.dart';

part 'cassette_coordinator.g.dart';

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
/// - [ ] recentContacts → RecentContactsResolver + ChooserWidgetBuilder
/// - [ ] contactHeroSummary → HeroSummaryResolver + HeroSummaryWidgetBuilder
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/30-NEW-FEATURE-ADDITION/
///      contacts-cassette-cross-surface-migration/PROPOSAL.md
@riverpod
class ContactsCassetteCoordinator extends _$ContactsCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator; invoked imperatively by other coordinators.
  }

  /// Build a sidebar cassette view model for a Contacts cassette request.
  ///
  /// This is async because:
  /// - Content resolvers may depend on repositories (counts, derived values)
  /// - Keeping the API async avoids refactoring call sites later
  Future<SidebarCassetteCardViewModel> buildViewModel(
    ContactsCassetteSpec spec,
  ) async {
    return spec.map(
      recentContacts: (recent) => SidebarCassetteCardViewModel(
        title: '',
        subtitle: null,
        child: ref.watch(contactChooserViewBuilderProvider(recent)),
      ),
      contactChooser: (chooser) => SidebarCassetteCardViewModel(
        title: '',
        subtitle: null,
        child: ref.watch(contactChooserViewBuilderProvider(chooser)),
      ),
      contactHeroSummary: (hero) => SidebarCassetteCardViewModel(
        title: '',
        subtitle: null,
        shouldExpand: false,
        child: ContactHeroSummaryCassette(spec: hero),
      ),
    );
  }
}
