import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

part 'sidebar_utility_cassette_spec.freezed.dart';
part 'sidebar_utility_cassette_spec.g.dart';

@freezed
abstract class SidebarUtilityCassetteSpec with _$SidebarUtilityCassetteSpec {
  const factory SidebarUtilityCassetteSpec.topChatMenu({
    @Default(TopChatMenuChoice.contacts) TopChatMenuChoice selectedChoice,
  }) = _SidebarUtilityCassetteSpecTopChatMenu;

  // other variants...

  factory SidebarUtilityCassetteSpec.fromJson(Map<String, dynamic> json) =>
      _$SidebarUtilityCassetteSpecFromJson(json);
}
