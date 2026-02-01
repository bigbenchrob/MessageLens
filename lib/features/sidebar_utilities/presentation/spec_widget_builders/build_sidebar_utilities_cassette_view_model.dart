import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../application/render_models/sidebar_utilities_cassette_content.dart';
import '../../application/render_models/sidebar_utilities_cassette_render_model.dart';
import '../cassettes/top_chat_menu.dart';

SidebarCassetteCardViewModel buildSidebarUtilitiesCassetteViewModel(
  WidgetRef ref,
  SidebarUtilitiesCassetteRenderModel model,
) {
  final child = model.content.when(
    topChatMenu: (spec) => TopChatMenu(spec: spec),
    settingsMenu: (spec) => const SizedBox.shrink(), // TODO
  );

  return SidebarCassetteCardViewModel(
    title: model.title,
    isNaked: model.isNaked,
    child: child,
  );
}
