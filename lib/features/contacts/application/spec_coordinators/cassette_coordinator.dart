import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../domain/spec_classes/contacts_cassette_spec.dart';
import '../sidebar_cassette_spec/resolvers/contact_chooser_resolver.dart';
import '../sidebar_cassette_spec/resolvers/contact_hero_summary_resolver.dart';

part 'cassette_coordinator.g.dart';

/// Contacts CassetteCoordinator
///
/// This coordinator is part of the Contacts feature and is responsible for
/// *routing only*:
///
/// - Accept a ContactsCassetteSpec (sidebar protocol entity)
/// - Pattern-match on the spec variant
/// - Extract payload parameters
/// - Call exactly ONE resolver
/// - Return the resolver's Future<SidebarCassetteCardViewModel>
///
/// Why return a view model instead of a widget?
///
/// - The app-level CassetteWidgetCoordinator centralizes UI chrome decisions.
/// - This keeps card layout/padding/header policies consistent across features.
/// - Features remain agnostic to how cards are visually framed.
/// - Future changes to card chrome happen in one place, not N features.
///
/// The coordinator:
/// - MUST NOT perform IO
/// - MUST NOT construct widgets
/// - MUST NOT build view models itself
/// - MUST NOT pass specs beyond this layer
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
@riverpod
class ContactsCassetteCoordinator extends _$ContactsCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator; invoked imperatively by other coordinators.
  }

  /// Route a [ContactsCassetteSpec] to the appropriate resolver.
  ///
  /// The [cassetteIndex] is passed through to resolvers so that widget
  /// builders can update the cassette rack without holding specs in state.
  Future<SidebarCassetteCardViewModel> buildViewModel(
    ContactsCassetteSpec spec, {
    required int cassetteIndex,
  }) async {
    return spec.map(
      contactChooser: (chooser) => ref
          .read(contactChooserResolverProvider.notifier)
          .resolve(
            chosenContactId: chooser.chosenContactId,
            cassetteIndex: cassetteIndex,
          ),
      contactHeroSummary: (hero) => ref
          .read(contactHeroSummaryResolverProvider.notifier)
          .resolve(
            contactId: hero.chosenContactId,
            cassetteIndex: cassetteIndex,
          ),
    );
  }
}
