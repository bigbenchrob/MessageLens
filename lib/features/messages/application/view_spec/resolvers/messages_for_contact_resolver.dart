import 'package:flutter/widgets.dart';

import '../widget_builders/messages_for_contact_builder.dart';

/// Resolves the [MessagesSpec.forContact] variant to a center panel widget.
class MessagesForContactResolver {
  Widget resolve({required int contactId, DateTime? scrollToDate}) {
    return buildMessagesForContactView(
      contactId: contactId,
      scrollToDate: scrollToDate,
    );
  }
}
