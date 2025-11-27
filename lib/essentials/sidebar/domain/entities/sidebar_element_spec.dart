import 'package:freezed_annotation/freezed_annotation.dart';

import '../sidebar_constants.dart';

part 'sidebar_element_spec.freezed.dart';

@freezed
abstract class SidebarElementSpec with _$SidebarElementSpec {
  const factory SidebarElementSpec({
    required String id,
    required SidebarElementKind kind,
    Object? payload,
  }) = _SidebarElementSpec;

  const SidebarElementSpec._();
}
