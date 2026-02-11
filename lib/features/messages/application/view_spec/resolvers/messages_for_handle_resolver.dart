import 'package:flutter/widgets.dart';

import '../widget_builders/messages_for_handle_builder.dart';

/// Resolves the [MessagesSpec.forHandle] variant to a center panel widget.
class MessagesForHandleResolver {
  Widget resolve({required int handleId}) {
    return buildMessagesForHandleView(handleId: handleId);
  }
}
