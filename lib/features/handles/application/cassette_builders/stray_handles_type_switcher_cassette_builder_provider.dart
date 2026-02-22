import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../presentation/cassettes/stray_handles_type_switcher_cassette.dart';

part 'stray_handles_type_switcher_cassette_builder_provider.g.dart';

/// Builds the cassette view model for the stray handles type switcher.
@riverpod
SidebarCassetteCardViewModel strayHandlesTypeSwitcherCassetteBuilder(
  Ref ref, {
  required StrayHandleFilter selectedFilter,
  required int cassetteIndex,
}) {
  return SidebarCassetteCardViewModel(
    title: 'Handle Type',
    shouldExpand: false,
    child: StrayHandlesTypeSwitcherCassette(
      selectedFilter: selectedFilter,
      cassetteIndex: cassetteIndex,
    ),
  );
}
