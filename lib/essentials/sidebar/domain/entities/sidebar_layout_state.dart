import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../navigation/domain/entities/features/sidebar_root_spec.dart';
import 'sidebar_element_spec.dart';

part 'sidebar_layout_state.freezed.dart';

@freezed
abstract class SidebarLayoutState with _$SidebarLayoutState {
  const factory SidebarLayoutState({
    required SidebarRootSpec root,
    required List<SidebarElementSpec> elements,
  }) = _SidebarLayoutState;
}
