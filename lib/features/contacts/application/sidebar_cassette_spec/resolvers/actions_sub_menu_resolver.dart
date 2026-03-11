import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../widget_builders/actions_sub_menu_widget.dart';

part 'actions_sub_menu_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.actionsMenu().
///
/// Returns a naked cassette with the actions submenu dropdown.
@riverpod
class ActionsSubMenuResolver extends _$ActionsSubMenuResolver {
  @override
  void build() {}

  SidebarCassetteCardViewModel resolve({
    required ActionsMenuChoice? currentChoice,
    required int cassetteIndex,
  }) {
    return SidebarCassetteCardViewModel(
      title: '',
      isNaked: true,
      child: ActionsSubMenuWidget(
        currentChoice: currentChoice,
        cassetteIndex: cassetteIndex,
        sidebarMode: SidebarMode.settings,
      ),
    );
  }
}
