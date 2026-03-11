import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/contacts_info_cassette_spec.dart';
import '../widget_builders/contact_selection_control_widget.dart';

part 'info_content_resolver.g.dart';

/// Resolved content for a contacts info card.
class ContactsInfoContent {
  final String? title;
  final String body;

  /// Optional escape-hatch action widget rendered at the bottom of the card.
  final Widget? action;

  const ContactsInfoContent({this.title, required this.body, this.action});
}

/// Resolves info card content for [ContactsInfoKey] values.
///
/// This resolver maps semantic keys to the actual text content displayed
/// in info cards. This keeps the text owned by the feature while allowing
/// the essentials layer to request it via keys.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (the info key)
/// - Returns resolved content (not view models or widgets)
/// - Owns the meaning of each key
@riverpod
class ContactsInfoContentResolver extends _$ContactsInfoContentResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the content for a given info key.
  ///
  /// [cassetteIndex] is needed so that embedded action widgets
  /// (e.g., the selection control) can replace-and-cascade at the
  /// correct position in the rack.
  Future<ContactsInfoContent> resolve(
    ContactsInfoKey key, {
    required int cassetteIndex,
    int? chosenContactId,
  }) async {
    switch (key) {
      case ContactsInfoKey.favouritesVsRecents:
        return const ContactsInfoContent(
          body:
              'These are contacts from your Address Book as well as those '
              "you've created to identify messages from unfamiliar phone "
              'numbers and email addresses.',
        );
      case ContactsInfoKey.chosenContact:
        return ContactsInfoContent(
          body:
              'Showing messages and activity for the selected contact. '
              'Click the name to edit how it appears in the app.',
          action: ContactSelectionControlWidget(
            contactId: chosenContactId!,
            cassetteIndex: cassetteIndex,
          ),
        );
    }
  }
}
