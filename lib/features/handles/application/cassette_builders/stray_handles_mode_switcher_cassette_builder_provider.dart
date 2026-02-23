import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../presentation/cassettes/stray_handles_mode_switcher_cassette.dart';

part 'stray_handles_mode_switcher_cassette_builder_provider.g.dart';

/// Builds the cassette view model for the stray handles mode filter.
@riverpod
SidebarCassetteCardViewModel strayHandlesModeSwitcherCassetteBuilder(
  Ref ref, {
  required StrayHandleFilter filter,
}) {
  return SidebarCassetteCardViewModel(
    title: '', // Empty - the "Show:" label is inline in the widget
    shouldExpand: false,
    child: StrayHandlesModeSwitcherCassette(filter: filter),
  );
}
