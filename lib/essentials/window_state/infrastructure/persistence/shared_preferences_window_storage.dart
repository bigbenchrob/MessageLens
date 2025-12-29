import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/window_state_entity.dart';
import '../../domain/ports/window_storage_port.dart';

/// SharedPreferences implementation of window state storage
class SharedPreferencesWindowStorage implements WindowStoragePort {
  static const double _minWidth = 900.0;
  static const double _minHeight = 720.0;
  static const double _maxWidth = 5000.0;
  static const double _maxHeight = 3000.0;
  static const String _keyWidth = 'window_width';
  static const String _keyHeight = 'window_height';
  static const String _keyX = 'window_x';
  static const String _keyY = 'window_y';
  static const String _keyIsMinimized = 'window_is_minimized';
  static const String _keySidebarWidth = 'sidebar_width';

  @override
  Future<WindowStateEntity?> loadWindowState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final width = prefs.getDouble(_keyWidth);
      final height = prefs.getDouble(_keyHeight);
      final x = prefs.getDouble(_keyX);
      final y = prefs.getDouble(_keyY);
      final isMinimized = prefs.getBool(_keyIsMinimized);
      final sidebarWidth = prefs.getDouble(_keySidebarWidth);

      // Only return state if we have valid window dimensions
      if (width != null && height != null && x != null && y != null) {
        final clampedWidth = width.clamp(_minWidth, _maxWidth);
        final clampedHeight = height.clamp(_minHeight, _maxHeight);

        final state = WindowStateEntity(
          width: clampedWidth,
          height: clampedHeight,
          x: x,
          y: y,
          isMinimized: isMinimized ?? false,
          sidebarWidth: sidebarWidth ?? 320.0,
        );

        if (clampedWidth != width || clampedHeight != height) {
          print(
            '🚨 Window dimensions out of range: ${width}x$height. Clamped to ${clampedWidth}x$clampedHeight.',
          );
        }

        return state;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveWindowState(WindowStateEntity state) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setDouble(_keyWidth, state.width);
      await prefs.setDouble(_keyHeight, state.height);
      await prefs.setDouble(_keyX, state.x);
      await prefs.setDouble(_keyY, state.y);
      await prefs.setBool(_keyIsMinimized, state.isMinimized);
      await prefs.setDouble(_keySidebarWidth, state.sidebarWidth);
    } catch (e) {
      // Fail silently - not critical
    }
  }

  @override
  Future<void> clearWindowState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_keyWidth),
        prefs.remove(_keyHeight),
        prefs.remove(_keyX),
        prefs.remove(_keyY),
        prefs.remove(_keyIsMinimized),
        prefs.remove(_keySidebarWidth),
      ]);
    } catch (e) {
      // Silently fail
    }
  }
}
