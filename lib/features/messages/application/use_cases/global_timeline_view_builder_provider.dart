import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/view/global_timeline_placeholder_view.dart';

part 'global_timeline_view_builder_provider.g.dart';

@riverpod
Widget globalTimelineViewBuilder(Ref ref) {
  return const GlobalTimelinePlaceholderView();
}
