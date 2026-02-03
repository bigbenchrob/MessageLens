import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../constants/domain/contact_constants.dart';
import '../../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import '../resolver_tools/picker_mode_decision.dart';
import '../widget_builders/contact_flat_list_widget.dart';
import '../widget_builders/contact_grouped_picker_widget.dart';

part 'contact_chooser_resolver.g.dart';

/// Resolves a contact chooser cassette.
///
/// This resolver determines the correct content for the contact chooser
/// cassette by:
/// 1. Fetching contact count from the repository
/// 2. Using [determinePickerMode] to decide flat vs grouped display
/// 3. Returning a view model with the appropriate widget builder
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Owns all decision-making for this cassette
///
/// Resolvers MUST NOT:
/// - Accept a spec object
/// - Read a spec from shared state
/// - Return widgets, builders, or partial results
@riverpod
class ContactChooserResolver extends _$ContactChooserResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the contact chooser cassette.
  ///
  /// Fetches contact count to determine display mode (flat vs grouped),
  /// then returns a view model with the appropriate widget.
  Future<SidebarCassetteCardViewModel> resolve({
    required int? chosenContactId,
    required int cassetteIndex,
  }) async {
    // Fetch contacts to determine count
    final contacts = await ref.read(
      contactsListRepositoryProvider(
        spec: const ContactsListSpec.alphabetical(),
      ).future,
    );

    // Use resolver tool to make the decision
    final pickerMode = determinePickerMode(contacts.length);

    // Return view model with appropriate widget based on decision
    return switch (pickerMode) {
      ContactPickerMode.flat => SidebarCassetteCardViewModel(
        title: '',
        subtitle: null,
        shouldExpand: true,
        child: ContactFlatListWidget(
          chosenContactId: chosenContactId,
          cassetteIndex: cassetteIndex,
        ),
      ),
      ContactPickerMode.grouped => SidebarCassetteCardViewModel(
        title: '',
        subtitle: null,
        shouldExpand: true,
        child: ContactGroupedPickerWidget(
          chosenContactId: chosenContactId,
          cassetteIndex: cassetteIndex,
        ),
      ),
    };
  }
}
