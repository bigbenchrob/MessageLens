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
  static const double _fallbackMinWidth = 320.0;
  static const double _fallbackMinHeight = 240.0;

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

  /// Save sidebar widths while preserving other window state
  Future<void> saveSidebarWidths({
    double? sidebarWidth,
    double? endSidebarWidth,
  }) async {
    try {
      print(
        '🔧 [saveSidebarWidths] Called with: sidebarWidth=$sidebarWidth, endSidebarWidth=$endSidebarWidth',
      );

      // First load the existing state to preserve current sidebar widths
      final existingState = await loadWindowState();
      print(
        '🔧 [saveSidebarWidths] Existing state: sidebar=${existingState.sidebarWidth}, endSidebar=${existingState.endSidebarWidth}',
      );

      // Get current window dimensions
      final frame = await _windowManager.getWindowFrame();
      final isMinimized = await _windowManager.isMinimized();

      // Calculate the final values
      final finalSidebarWidth = sidebarWidth ?? existingState.sidebarWidth;
      final finalEndSidebarWidth =
          endSidebarWidth ?? existingState.endSidebarWidth;
      print(
        '🔧 [saveSidebarWidths] Final values to save: sidebar=$finalSidebarWidth, endSidebar=$finalEndSidebarWidth',
      );

      // Create new state preserving existing sidebar widths unless specified
      final newState = WindowStateEntity(
        width: frame['width'] ?? existingState.width,
        height: frame['height'] ?? existingState.height,
        x: frame['x'] ?? existingState.x,
        y: frame['y'] ?? existingState.y,
        isMinimized: isMinimized,
        sidebarWidth: finalSidebarWidth,
        endSidebarWidth: finalEndSidebarWidth,
      );

      await saveWindowState(newState);
    } catch (e) {
      // Silently fail - sidebar state is not critical
    }
  }

  /// Apply window state to the actual window
  Future<void> applyWindowState(WindowStateEntity state) async {
    try {
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
    double? endSidebarWidth,
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
        endSidebarWidth: endSidebarWidth ?? 280.0,
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
        endSidebarWidth: existingState
            .endSidebarWidth, // Preserve existing end sidebar width
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
          : _fallbackMinWidth;
      final minHeight = savedState.height > _fallbackMinHeight
          ? savedState.height
          : _fallbackMinHeight;

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
        width: _fallbackMinWidth,
        height: _fallbackMinHeight,
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
}
