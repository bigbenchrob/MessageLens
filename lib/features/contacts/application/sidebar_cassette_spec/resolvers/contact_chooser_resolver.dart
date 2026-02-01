import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../widget_builders/contact_chooser_widget.dart';

part 'contact_chooser_resolver.g.dart';

/// Resolves a contact chooser cassette.
///
/// This resolver determines the correct content for the contact chooser/recent
/// contacts cassette and returns a fully-realized [SidebarCassetteCardViewModel].
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Does NOT construct widgets itself (delegates to widget builder)
///
/// ## Parameters
///
/// - [chosenContactId] - Currently selected contact, if any
/// - [cassetteIndex] - Position in the cassette rack (for updates)
/// - [showRecentContacts] - Whether to prioritize recent contacts display
@riverpod
class ContactChooserResolver extends _$ContactChooserResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the contact chooser cassette.
  Future<SidebarCassetteCardViewModel> resolve({
    required int? chosenContactId,
    required int cassetteIndex,
    required bool showRecentContacts,
  }) async {
    // The widget builder handles all the reactive logic (watching contacts,
    // determining flat vs grouped display, handling selection). We just
    // provide it with the immutable parameters it needs.
    return SidebarCassetteCardViewModel(
      title: '',
      subtitle: null,
      shouldExpand: true,
      child: ContactChooserWidget(
        chosenContactId: chosenContactId,
        cassetteIndex: cassetteIndex,
        showRecentContacts: showRecentContacts,
      ),
    );
  }
}
