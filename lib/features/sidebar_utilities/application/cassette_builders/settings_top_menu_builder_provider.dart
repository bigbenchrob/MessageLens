import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/feature_level_providers.dart';
import '../../presentation/cassettes/settings_top_menu.dart';

part 'settings_top_menu_builder_provider.g.dart';

/// Builder that converts a [SidebarUtilityCassetteSpec.settingsMenu] into the
/// drop-down style settings top menu widget.
@riverpod
class SettingsTopMenuBuilder extends _$SettingsTopMenuBuilder {
  @override
  Widget build(SidebarUtilityCassetteSpec sidebarUtilityCassetteSpec) {
    return SettingsTopMenu(spec: sidebarUtilityCassetteSpec);
  }
}
