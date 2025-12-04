import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/feature_level_providers.dart';
import '../../presentation/cassettes/top_chat_menu.dart';

part 'top_chat_menu_builder_provider.g.dart';

// This class encapsulates the logic for converting a
/// [SidebarWidgetCassetteSpec.topChatMenu] into the corresponding
/// [TopChatMenu] widget.
/// Additional sidebar widget cassettes should have their own builders
///  placed in this folder.
@riverpod
class TopChatMenuBuilder extends _$TopChatMenuBuilder {
  @override
  Widget build(SidebarUtilityCassetteSpec sidebarUtilityCassetteSpec) {
    return TopChatMenu(spec: sidebarUtilityCassetteSpec);
  }
}
