import 'package:flutter/widgets.dart';

import '../../../presentation/view/messages_for_contact_view.dart';

/// Widget builder for the contact messages view.
///
/// Constructs a [MessagesForContactView] for the given contact, optionally
/// scrolled to a specific date.
Widget buildMessagesForContactView({
  required int contactId,
  DateTime? scrollToDate,
}) {
  return MessagesForContactView(
    contactId: contactId,
    scrollToDate: scrollToDate,
  );
}
