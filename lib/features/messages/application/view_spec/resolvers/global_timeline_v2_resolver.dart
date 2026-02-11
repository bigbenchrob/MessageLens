import 'package:flutter/widgets.dart';

import '../widget_builders/global_timeline_v2_builder.dart';

/// Resolves the [MessagesSpec.globalTimelineV2] variant to a center panel widget.
class GlobalTimelineV2Resolver {
  Widget resolve({DateTime? scrollToDate}) {
    return buildGlobalTimelineV2View(scrollToDate: scrollToDate);
  }
}
