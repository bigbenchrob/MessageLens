import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../widget_builders/contact_selection_control_widget.dart';

part 'contact_selection_control_resolver.g.dart';

/// Resolves a contact selection control cassette.
///
/// This resolver produces a compact "Change contact" control view model
/// that displays the selected contact and provides re-entry to the picker.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Does NOT construct widgets itself (delegates to widget builder)
///
/// ## Visual Role
///
/// The selection control is visually subordinate to the Hero Card and serves
/// as a "collapsed" representation of the picker. It provides:
/// - Selected contact name display
/// - "Change" affordance to return to picker
/// - Compact height (~44px)
@riverpod
class ContactSelectionControlResolver
    extends _$ContactSelectionControlResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the contact selection control cassette.
  Future<SidebarCassetteCardViewModel> resolve({
    required int contactId,
    required int cassetteIndex,
  }) async {
    return SidebarCassetteCardViewModel(
      title: '',
      subtitle: null,
      isControl: true, // Compact control styling
      shouldExpand: false,
      child: ContactSelectionControlWidget(
        contactId: contactId,
        cassetteIndex: cassetteIndex,
      ),
    );
  }
}
