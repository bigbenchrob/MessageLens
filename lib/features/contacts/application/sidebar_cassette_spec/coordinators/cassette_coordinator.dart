import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/contacts_cassette_spec.dart';
import '../resolvers/contact_chooser_resolver.dart';
import '../resolvers/contact_hero_summary_resolver.dart';

part 'cassette_coordinator.g.dart';

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
@riverpod
class ContactsCassetteCoordinator extends _$ContactsCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a sidebar cassette view model for the given contacts cassette spec.
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
            showRecentContacts: true,
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
