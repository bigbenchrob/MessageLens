import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../resolvers/settings_top_menu_resolver.dart';
import '../resolvers/top_chat_menu_resolver.dart';

part 'cassette_coordinator.g.dart';

/// Sidebar Utilities Cassette Coordinator
///
/// This coordinator routes [SidebarUtilityCassetteSpec] to the appropriate
/// resolver. It follows the cross-surface spec system contract:
///
/// - Receives a spec + cassetteIndex
/// - Pattern-matches on the spec variant
/// - Extracts payload parameters
/// - Calls exactly ONE resolver
/// - Returns the resolver's Future<SidebarCassetteCardViewModel>
///
/// The coordinator MUST NOT:
/// - Perform IO
/// - Construct widgets
/// - Build view models itself
/// - Pass specs to resolvers
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
@riverpod
class SidebarUtilitiesCassetteCoordinator
    extends _$SidebarUtilitiesCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator; invoked imperatively.
  }

  /// Route a [SidebarUtilityCassetteSpec] to the appropriate resolver.
  ///
  /// The [cassetteIndex] is passed through to resolvers so that widget
  /// builders can update the cassette rack without holding specs in state.
  Future<SidebarCassetteCardViewModel> buildViewModel(
    SidebarUtilityCassetteSpec spec, {
    required int cassetteIndex,
  }) async {
    return spec.map(
      topChatMenu: (menu) => ref
          .read(topChatMenuResolverProvider.notifier)
          .resolve(
            currentChoice: menu.selectedChoice,
            cassetteIndex: cassetteIndex,
            sidebarMode: SidebarMode.messages,
          ),
      settingsMenu: (menu) => ref
          .read(settingsTopMenuResolverProvider.notifier)
          .resolve(
            currentChoice: menu.selectedChoice,
            cassetteIndex: cassetteIndex,
            sidebarMode: SidebarMode.settings,
          ),
    );
  }
}
