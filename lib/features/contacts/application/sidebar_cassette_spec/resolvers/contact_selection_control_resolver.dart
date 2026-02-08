import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../widget_builders/contact_selection_control_widget.dart';

part 'contact_selection_control_resolver.g.dart';

/// Resolves the "back to picker" selection control.
///
/// The selection control is **navigation, not content and not identity**.
/// It uses [CassetteCardType.sidebarNavigation] — a full-bleed card type
/// purpose-built for "back to previous state" navigation affordances.
/// No card chrome, no shadow, no contact name.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Does NOT construct widgets itself (delegates to widget builder)
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
      cardType: CassetteCardType.sidebarNavigation,
      shouldExpand: false,
      child: ContactSelectionControlWidget(
        contactId: contactId,
        cassetteIndex: cassetteIndex,
      ),
    );
  }
}
