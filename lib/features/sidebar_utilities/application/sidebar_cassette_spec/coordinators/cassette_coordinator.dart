import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/sidebar_utilities_constants.dart';
import '../../../domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../resolvers/settings_root_resolver.dart';
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
/// - Returns the resolver's `Future<SidebarCassettePayload>`
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
    // Stateless coordinator; called by the sidebar cassette render router.
  }

  /// Route a [SidebarUtilityCassetteSpec] to the appropriate resolver.
  ///
  /// The [cassetteIndex] is passed through to resolvers so that widget
  /// builders can update the cassette rack without holding specs in state.
  Future<SidebarCassettePayload> buildViewModel(
    SidebarUtilityCassetteSpec spec, {
    required int cassetteIndex,
    SettingsMenuActionId? persistentSettingsContextActionId,
    bool hasActiveTransientSettingsProjection = false,
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
          .read(settingsRootResolverProvider.notifier)
          .resolve(
            cassetteIndex: cassetteIndex,
            persistentContextActionId: persistentSettingsContextActionId,
            hasActiveTransientProjection: hasActiveTransientSettingsProjection,
          ),
    );
  }
}
