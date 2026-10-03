import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../window_state/feature_level_providers.dart'
    show windowStateServiceProvider;

part 'app_czar_operating_session_visual_initializer_provider.g.dart';

abstract interface class AppCzarOperatingSessionVisualInitializer {
  Future<void> initializeVisualWindowState();
}

final class _WindowStateOperatingSessionVisualInitializer
    implements AppCzarOperatingSessionVisualInitializer {
  const _WindowStateOperatingSessionVisualInitializer({
    required Future<void> Function() restoreWindowState,
    required Future<void> Function() enforceMinSize,
  }) : _restoreWindowState = restoreWindowState,
       _enforceMinSize = enforceMinSize;

  final Future<void> Function() _restoreWindowState;
  final Future<void> Function() _enforceMinSize;

  @override
  Future<void> initializeVisualWindowState() async {
    await _restoreWindowState();
    await _enforceMinSize();
  }
}

@Riverpod(keepAlive: true)
AppCzarOperatingSessionVisualInitializer
appCzarOperatingSessionVisualInitializer(Ref ref) {
  final windowStateService = ref.watch(windowStateServiceProvider);
  return _WindowStateOperatingSessionVisualInitializer(
    restoreWindowState: windowStateService.restoreWindowState,
    enforceMinSize: windowStateService.enforceMinSize,
  );
}
