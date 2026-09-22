import 'package:flutter/widgets.dart';

import '../../../../environment_summary/feature_level_providers.dart'
    show EnvironmentSummaryPanel;

final class EnvironmentSummaryPanelResolver {
  Widget resolve() {
    return const EnvironmentSummaryPanel();
  }
}
