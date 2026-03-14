import 'package:flutter/widgets.dart';

import '../widget_builders/recovered_unlinked_messages_builder.dart';

/// Resolves the [MessagesSpec.recoveredUnlinkedMessages] variant.
class RecoveredUnlinkedMessagesResolver {
  Widget resolve({int? contactId, bool onlyNoHandleFromMe = false}) {
    return buildRecoveredUnlinkedMessagesView(
      contactId: contactId,
      onlyNoHandleFromMe: onlyNoHandleFromMe,
    );
  }
}
