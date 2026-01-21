import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

part 'handles_info_card_cassette_builder_provider.g.dart';

/// Builds the cassette view model for handles info cards.
///
/// Info cards display explanatory text without controls or data.
/// They always have a child cassette that follows.
///
/// This builder returns a [SidebarCassetteCardViewModel] with
/// [CassetteCardType.info], which tells [CassetteWidgetCoordinator]
/// to render a [SidebarInfoCard] instead of [SidebarCassetteCard].
@riverpod
SidebarCassetteCardViewModel handlesInfoCardCassetteBuilder(
  Ref ref, {
  String? title,
  required String message,
  String? footnote,
}) {
  return SidebarCassetteCardViewModel(
    title: title ?? '',
    footerText: footnote,
    cardType: CassetteCardType.info,
    infoBodyText: message,
    shouldExpand: false,
    // child is required but ignored for info cards
    child: const SizedBox.shrink(),
  );
}
