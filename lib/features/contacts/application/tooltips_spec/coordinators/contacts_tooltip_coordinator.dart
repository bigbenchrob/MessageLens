import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/contacts_tooltip_spec.dart';

part 'contacts_tooltip_coordinator.g.dart';

/// Contacts Tooltip Coordinator
///
/// Routes [ContactsTooltipSpec] variants to their resolvers and returns
/// the resolved tooltip text.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [ContactsTooltipSpec]
/// - Pattern-matches on the spec
/// - Calls the appropriate resolver
/// - Returns resolved text string
///
/// The coordinator MUST NOT:
/// - Perform IO
/// - Construct widgets
/// - Build view models itself
@riverpod
class ContactsTooltipCoordinator extends _$ContactsTooltipCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Resolve a contacts tooltip spec to display text.
  Future<String> resolve(ContactsTooltipSpec spec) async {
    return spec.when(
      editDisplayName: () => 'Edit display name',
      // Future handlers:
      // favoriteContact: () => 'Mark as favorite',
      // viewAllChats: () => 'View all conversations',
    );
  }
}
