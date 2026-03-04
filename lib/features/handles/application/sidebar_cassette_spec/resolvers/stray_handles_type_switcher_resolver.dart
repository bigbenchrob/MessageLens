import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../widget_builders/stray_handles_type_switcher_cassette.dart';

part 'stray_handles_type_switcher_resolver.g.dart';

/// Resolver for the stray handles type switcher cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class StrayHandlesTypeSwitcherResolver
    extends _$StrayHandlesTypeSwitcherResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve selected filter and cassette index into a sidebar cassette view model.
  Future<SidebarCassetteCardViewModel> resolve({
    required StrayHandleFilter selectedFilter,
    required int cassetteIndex,
  }) async {
    return SidebarCassetteCardViewModel(
      title: '', // Intentionally empty - control is self-explanatory
      shouldExpand: false,
      isNaked: true, // Tight spacing control for filter controls
      child: StrayHandlesTypeSwitcherCassette(
        selectedFilter: selectedFilter,
        cassetteIndex: cassetteIndex,
      ),
    );
  }
}
