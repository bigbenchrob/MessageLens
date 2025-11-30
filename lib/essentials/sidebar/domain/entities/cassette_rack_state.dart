// A value object representing the current stack of cassettes in the sidebar.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'cassette_spec.dart';
import 'features/sidebar_widget_cassette_spec.dart';

part 'cassette_rack_state.freezed.dart';

///
/// It uses the `freezed` package to generate the immutable data class
/// implementation along with copyWith, equality, and debugging utilities.  A
/// convenience factory [CassetteRack.initial] is provided to generate the
/// tracer‑bullet default containing a single top chat menu cassette.
@freezed
abstract class CassetteRack with _$CassetteRack {
  /// Creates a new [CassetteRack] with the given list of [cassettes].  The
  /// default value is an empty list.  The list is immutable, as the
  /// generated copyWith will always create new lists when updating.
  const factory CassetteRack({
    @Default(<CassetteSpec>[]) List<CassetteSpec> cassettes,
  }) = _CassetteRack;

  /// Private constructor used by the `freezed` mixin.  Required to be able
  /// to add custom methods to the class.
  const CassetteRack._();

  /// Returns a fresh [CassetteRack] containing a single top chat menu
  /// cassette.  This is the initial tracer‑bullet state used by
  /// [CassetteRackState.build].
  factory CassetteRack.initialTopChatMenu() {
    return CassetteRack(
      cassettes: List<CassetteSpec>.unmodifiable([
        const CassetteSpec.sidebarWidget(
          SidebarWidgetCassetteSpec.topChatMenu(),
        ),
      ]),
    );
  }
}
