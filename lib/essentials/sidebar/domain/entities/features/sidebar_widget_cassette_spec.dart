import 'package:freezed_annotation/freezed_annotation.dart';

part 'sidebar_widget_cassette_spec.freezed.dart';

@freezed
abstract class SidebarWidgetCassetteSpec with _$SidebarWidgetCassetteSpec {
  const factory SidebarWidgetCassetteSpec.topChatMenu({
    @Default(1) int chosenMenuIndex,
  }) = _SidebarWidgetCassetteSpec;
}
