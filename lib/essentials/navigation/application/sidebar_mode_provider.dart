import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/sidebar_mode.dart';

part 'sidebar_mode_provider.g.dart';

/// Controls the active sidebar mode (Messages vs Settings).
@riverpod
class ActiveSidebarMode extends _$ActiveSidebarMode {
  @override
  SidebarMode build() {
    return SidebarMode.messages;
  }

  void setMode(SidebarMode mode) {
    state = mode;
  }
}
