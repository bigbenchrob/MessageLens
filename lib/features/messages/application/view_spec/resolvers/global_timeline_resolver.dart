import 'package:flutter/widgets.dart';

import '../widget_builders/global_timeline_builder.dart';

/// Resolves the [MessagesSpec.globalTimeline] variant to a center panel widget.
class GlobalTimelineResolver {
  Widget resolve({DateTime? scrollToDate}) {
    return buildGlobalTimelineView(scrollToDate: scrollToDate);
  }
}
