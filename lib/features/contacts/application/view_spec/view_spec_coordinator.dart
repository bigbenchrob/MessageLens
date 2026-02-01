import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_spec.dart';

part 'view_spec_coordinator.g.dart';

/// Coordinator that maps [ContactsSpec] to rendered widgets for the center panel.
///
/// This coordinator handles the ViewSpec system for contacts (panels),
/// separate from the CassetteSpec system (sidebar).
@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a widget for the given [ContactsSpec].
  Widget buildForSpec(ContactsSpec spec) {
    return spec.when(
      list: () => _buildPlaceholder('Contacts list view coming soon'),
      detail: (contactId) =>
          _buildPlaceholder('Contact detail for $contactId coming soon'),
      search: (query) =>
          _buildPlaceholder('Contact search for "$query" coming soon'),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
