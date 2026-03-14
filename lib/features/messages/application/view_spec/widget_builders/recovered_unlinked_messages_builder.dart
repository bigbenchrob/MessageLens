import 'package:flutter/widgets.dart';

import '../../../presentation/view/recovered_unlinked_messages_placeholder_view.dart';

/// Widget builder for the recovered-unlinked-messages center panel view.
Widget buildRecoveredUnlinkedMessagesView({
  int? contactId,
  bool onlyNoHandleFromMe = false,
}) {
  return RecoveredUnlinkedMessagesPlaceholderView(
    contactId: contactId,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
}
