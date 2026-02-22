import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../widget_builders/contact_hero_summary_widget.dart';

part 'contact_hero_summary_resolver.g.dart';

/// Resolves a contact hero summary cassette.
///
/// This resolver produces a fully-realized [SidebarCassetteCardViewModel]
/// for displaying detailed contact information.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Does NOT construct widgets itself (delegates to widget builder)
@riverpod
class ContactHeroSummaryResolver extends _$ContactHeroSummaryResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the contact hero summary cassette.
  Future<SidebarCassetteCardViewModel> resolve({
    required int contactId,
    required int cassetteIndex,
  }) async {
    return SidebarCassetteCardViewModel(
      title: '',
      subtitle: null,
      isNaked: true, // Align edges with top menu dropdown
      shouldExpand: false, // Hero summary wraps content, doesn't expand
      child: ContactHeroSummaryWidget(
        contactId: contactId,
        cassetteIndex: cassetteIndex,
      ),
    );
  }
}
