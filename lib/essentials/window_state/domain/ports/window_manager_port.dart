abstract class WindowManagerPort {
  Future<void> setWindowFrame({
    required double x,
    required double y,
    required double width,
    required double height,
  });

  Future<Map<String, double>> getWindowFrame();

  Future<void> maximize();
  Future<void> minimize();
  Future<void> restore();

  Future<bool> isMaximized();
  Future<bool> isMinimized();

  Future<void> setWindowMinSize({
    required double width,
    required double height,
  });
}
