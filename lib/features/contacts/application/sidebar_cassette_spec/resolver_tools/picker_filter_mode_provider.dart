import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'picker_filter_mode_provider.g.dart';

/// Controls which contacts the picker displays.
enum PickerFilterMode {
  /// Show all contacts (A–Z).
  all,

  /// Show only user-designated favourites.
  favouritesOnly,
}

@Riverpod(keepAlive: true)
class PickerFilter extends _$PickerFilter {
  @override
  PickerFilterMode build() => PickerFilterMode.all;

  void setMode(PickerFilterMode mode) {
    state = mode;
  }
}
