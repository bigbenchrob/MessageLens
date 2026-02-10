import 'package:flutter/widgets.dart';

import '../widget_builders/handle_lens_builder.dart';

/// Resolves the [MessagesSpec.handleLens] variant to a center panel widget.
class HandleLensResolver {
  Widget resolve({required int handleId}) {
    return buildHandleLensView(handleId: handleId);
  }
}
