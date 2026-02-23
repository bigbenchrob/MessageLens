import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/stray_handles_mode_switcher_cassette.dart';

part 'stray_handles_mode_switcher_resolver.g.dart';

/// Resolver for the stray handles mode switcher cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class StrayHandlesModeSwitcherResolver
    extends _$StrayHandlesModeSwitcherResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve filter into a sidebar cassette view model.
  Future<SidebarCassetteCardViewModel> resolve({
    required StrayHandleFilter filter,
  }) async {
    return SidebarCassetteCardViewModel(
      title: '', // Empty - the "Show:" label is inline in the widget
      shouldExpand: false,
      isNaked: true, // Tight spacing control for filter controls
      child: StrayHandlesModeSwitcherCassette(filter: filter),
    );
  }
}
