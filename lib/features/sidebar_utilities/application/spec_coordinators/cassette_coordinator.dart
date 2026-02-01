import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/domain/entities/features/sidebar_utility_cassette_spec.dart';
import '../render_models/sidebar_utilities_cassette_content.dart';
import '../render_models/sidebar_utilities_cassette_render_model.dart';

part 'cassette_coordinator.g.dart';

/// SidebarUtilities CassetteCoordinator
///
/// This coordinator is part of the SidebarUtilities feature and is responsible
/// for *routing only*:
///
/// - Accept a SidebarUtilityCassetteSpec (sidebar protocol entity)
/// - Pattern-match on the spec variant
/// - Delegate to appropriate builders for widget construction
/// - Return a SidebarCassetteCardViewModel (NOT a wrapped widget)
///
/// ## Contract
///
/// - MUST NOT call ref.watch()
/// - MAY use ref.read()
/// - MUST return fully resolved view model with chrome decisions
///
/// ## Spec Variants
///
/// - topChatMenu: The primary navigation dropdown for messages mode
/// - settingsMenu: The navigation dropdown for settings mode
@riverpod
class SidebarUtilitiesCassetteCoordinator
    extends _$SidebarUtilitiesCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator; invoked imperatively by CassetteWidgetCoordinator.
  }

  /// Build a sidebar cassette view model for a SidebarUtility cassette request.
  ///
  /// Returns async to maintain consistent API with other feature coordinators,
  /// even though current implementation is synchronous.
  Future<SidebarUtilitiesCassetteRenderModel> buildViewModel(
    SidebarUtilityCassetteSpec spec,
  ) async {
    return spec.map(
      topChatMenu: (_) => SidebarUtilitiesCassetteRenderModel(
        title: '',
        isNaked: true,
        content: SidebarUtilitiesCassetteContent.topChatMenu(spec: spec),
      ),
      settingsMenu: (_) => SidebarUtilitiesCassetteRenderModel(
        title: '',
        isNaked: true,
        content: SidebarUtilitiesCassetteContent.settingsMenu(spec: spec),
      ),
    );
  }
}
