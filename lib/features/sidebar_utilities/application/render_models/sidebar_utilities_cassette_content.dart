import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../essentials/sidebar/domain/entities/features/sidebar_utility_cassette_spec.dart';

part 'sidebar_utilities_cassette_content.freezed.dart';

@freezed
sealed class SidebarUtilitiesCassetteContent
    with _$SidebarUtilitiesCassetteContent {
  const SidebarUtilitiesCassetteContent._();

  const factory SidebarUtilitiesCassetteContent.topChatMenu({
    required SidebarUtilityCassetteSpec spec,
  }) = _TopChatMenuContent;

  const factory SidebarUtilitiesCassetteContent.settingsMenu({
    required SidebarUtilityCassetteSpec spec,
  }) = _SettingsMenuContent;
}
