import 'package:freezed_annotation/freezed_annotation.dart';

part 'sidebar_utility_cassette_spec.freezed.dart';

@freezed
abstract class SidebarUtilityCassetteSpec with _$SidebarUtilityCassetteSpec {
  const factory SidebarUtilityCassetteSpec.topChatMenu({
    @Default(1) int chosenMenuIndex,
  }) = _SidebarUtilityCassetteSpec;
}
