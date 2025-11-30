import 'package:freezed_annotation/freezed_annotation.dart';

import 'features/contacts_cassette_spec.dart';
import 'features/sidebar_widget_cassette_spec.dart';

part 'cassette_spec.freezed.dart';

@freezed
abstract class CassetteSpec with _$CassetteSpec {
  const factory CassetteSpec.sidebarWidget(SidebarWidgetCassetteSpec spec) =
      _CassetteSidebarWidget;
  const factory CassetteSpec.contacts(ContactsCassetteSpec spec) =
      _CasetteContacts;
}
