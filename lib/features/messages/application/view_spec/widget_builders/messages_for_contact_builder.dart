import 'package:flutter/widgets.dart';

import '../../../domain/value_objects/message_timeline_scope.dart';
import '../../../presentation/view/messages_timeline_view.dart';

/// Widget builder for the contact messages view.
///
/// Constructs a unified [MessagesTimelineView] for the given contact,
/// optionally scrolled to a specific date.
Widget buildMessagesForContactView({
  required int contactId,
  DateTime? scrollToDate,
  int? filterHandleId,
}) {
  return MessagesTimelineView(
    scope: MessageTimelineScope.contact(
      contactId: contactId,
      filterHandleId: filterHandleId,
    ),
    scrollToDate: scrollToDate,
  );
}
