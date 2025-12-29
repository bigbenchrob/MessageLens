import '../domain/entities/window_state_entity.dart';
import '../domain/ports/window_manager_port.dart';
import '../domain/ports/window_storage_port.dart';

/// Service to manage window state persistence and restoration
class WindowStateService {
  final WindowStoragePort _storage;
  final WindowManagerPort _windowManager;
  WindowStateEntity? _cachedState;

  static const double _shrinkRatioThreshold = 0.75;
  static const double _autoShrinkWidthThreshold = 520.0;
  static const double _autoShrinkHeightThreshold = 420.0;
  static const double _minWidth = 900.0;
  static const double _minHeight = 720.0;
  static const double _fallbackMinWidth = 900.0;
  static const double _fallbackMinHeight = 720.0;

  WindowStateService({
    required WindowStoragePort storage,
    required WindowManagerPort windowManager,
  }) : _storage = storage,
       _windowManager = windowManager;

  /// Load the saved window state or return default state
  Future<WindowStateEntity> loadWindowState() async {
    try {
      final state = await _storage.loadWindowState();
      _cachedState = state ?? WindowStateEntity.defaultState();
      return _cachedState!;
    } catch (e) {
      _cachedState = WindowStateEntity.defaultState();
      return _cachedState!;
    }
  }

  /// Save the current window state
  Future<void> saveWindowState(WindowStateEntity state) async {
    try {
      await _storage.saveWindowState(state);
      _cachedState = state;
    } catch (e) {
      // Silently fail - window state is not critical
    }
  }

  /// Apply window state to the actual window
  Future<void> applyWindowState(WindowStateEntity state) async {
    try {
      await _windowManager.setWindowMinSize(
        width: _minWidth,
        height: _minHeight,
      );

      await _windowManager.setWindowFrame(
        x: state.x,
        y: state.y,
        width: state.width,
        height: state.height,
      );

      if (state.isMinimized) {
        await _windowManager.minimize();
      }
    } catch (e) {
      // Silently fail - window positioning is not critical
    }
  }

  /// Get current window state from the window manager
  Future<WindowStateEntity> getCurrentWindowState({
    double? sidebarWidth,
  }) async {
    try {
      final frame = await _windowManager.getWindowFrame();
      final isMinimized = await _windowManager.isMinimized();

      return WindowStateEntity(
        width: frame['width'] ?? 1200.0,
        height: frame['height'] ?? 800.0,
        x: frame['x'] ?? 100.0,
        y: frame['y'] ?? 100.0,
        isMinimized: isMinimized,
        sidebarWidth: sidebarWidth ?? 320.0,
      );
    } catch (e) {
      return WindowStateEntity.defaultState();
    }
  }

  /// Save current window state - convenience method for main.dart
  Future<void> saveCurrentWindowState() async {
    try {
      // Load existing state to preserve sidebar widths
      final existingState = await loadWindowState();

      // Get current window dimensions
      final frame = await _windowManager.getWindowFrame();
      final isMinimized = await _windowManager.isMinimized();

      // Create new state preserving sidebar widths from existing state
      final currentState = WindowStateEntity(
        width: frame['width'] ?? existingState.width,
        height: frame['height'] ?? existingState.height,
        x: frame['x'] ?? existingState.x,
        y: frame['y'] ?? existingState.y,
        isMinimized: isMinimized,
        sidebarWidth:
            existingState.sidebarWidth, // Preserve existing sidebar width
      );

      final previousState = _cachedState;
      final widthShrankUnexpectedly =
          previousState != null &&
          previousState.width > _autoShrinkWidthThreshold &&
          currentState.width <= _autoShrinkWidthThreshold &&
          currentState.width < previousState.width * _shrinkRatioThreshold;
      final heightShrankUnexpectedly =
          previousState != null &&
          previousState.height > _autoShrinkHeightThreshold &&
          currentState.height <= _autoShrinkHeightThreshold &&
          currentState.height < previousState.height * _shrinkRatioThreshold;

      if (widthShrankUnexpectedly || heightShrankUnexpectedly) {
        return;
      }

      await saveWindowState(currentState);
    } catch (e) {
      // If anything fails, fall back to the old method
      final currentState = await getCurrentWindowState();
      await saveWindowState(currentState);
    }
  }

  /// Restore window state and apply it - convenience method for main.dart
  Future<void> restoreWindowState() async {
    final state = await loadWindowState();
    await applyWindowState(state);
  }

  /// Reconcile window size after display transitions to avoid unintended shrinking
  Future<void> reconcileAfterScreenChange() async {
    try {
      final savedState = _cachedState ?? await loadWindowState();

      // Give macOS a moment to finish its automatic adjustments before reading frame data.
      await Future<void>.delayed(const Duration(milliseconds: 120));

      final frame = await _windowManager.getWindowFrame();
      final currentWidth = frame['width'] ?? savedState.width;
      final currentHeight = frame['height'] ?? savedState.height;

      final widthShrank =
          savedState.width > _autoShrinkWidthThreshold &&
          currentWidth < savedState.width * _shrinkRatioThreshold;
      final heightShrank =
          savedState.height > _autoShrinkHeightThreshold &&
          currentHeight < savedState.height * _shrinkRatioThreshold;

      if (!widthShrank && !heightShrank) {
        return;
      }

      final x = frame['x'] ?? savedState.x;
      final y = frame['y'] ?? savedState.y;

      final minWidth = savedState.width > _fallbackMinWidth
          ? savedState.width
          : _minWidth;
      final minHeight = savedState.height > _fallbackMinHeight
          ? savedState.height
          : _minHeight;

      await _windowManager.setWindowMinSize(width: minWidth, height: minHeight);

      await Future<void>.delayed(const Duration(milliseconds: 32));

      await _windowManager.setWindowFrame(
        x: x,
        y: y,
        width: savedState.width,
        height: savedState.height,
      );

      await Future<void>.delayed(const Duration(milliseconds: 180));

      final reconciledFrame = await _windowManager.getWindowFrame();

      await _windowManager.setWindowMinSize(
        width: _minWidth,
        height: _minHeight,
      );

      final actualWidth = reconciledFrame['width'] ?? savedState.width;
      final actualHeight = reconciledFrame['height'] ?? savedState.height;
      final actualX = reconciledFrame['x'] ?? x;
      final actualY = reconciledFrame['y'] ?? y;

      final widthStillShrunk =
          savedState.width > _autoShrinkWidthThreshold &&
          actualWidth < savedState.width * _shrinkRatioThreshold;
      final heightStillShrunk =
          savedState.height > _autoShrinkHeightThreshold &&
          actualHeight < savedState.height * _shrinkRatioThreshold;

      final updatedState = savedState.copyWith(
        width: widthStillShrunk ? actualWidth : savedState.width,
        height: heightStillShrunk ? actualHeight : savedState.height,
        x: actualX,
        y: actualY,
      );

      await saveWindowState(updatedState);
    } catch (e) {
      // Silently ignore reconciliation failures.
    }
  }

  /// Ensure the runtime window cannot shrink below the configured minimum.
  /// If the current frame is already below the threshold, bump it up.
  Future<void> enforceMinSize() async {
    try {
      await _windowManager.setWindowMinSize(
        width: _minWidth,
        height: _minHeight,
      );

      final frame = await _windowManager.getWindowFrame();
      final width = frame['width'] ?? _minWidth;
      final height = frame['height'] ?? _minHeight;
      final x = frame['x'] ?? 0.0;
      final y = frame['y'] ?? 0.0;

      final targetWidth = width < _minWidth ? _minWidth : width;
      final targetHeight = height < _minHeight ? _minHeight : height;

      if (targetWidth != width || targetHeight != height) {
        await _windowManager.setWindowFrame(
          x: x,
          y: y,
          width: targetWidth,
          height: targetHeight,
        );
      }
    } catch (_) {
      // Silently ignore; sizing not critical.
    }
  }
}
