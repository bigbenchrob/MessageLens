# Agent Brief: macOS Window Management with `macos_ui` + `macos_window_utils`

## 0) Install & wire-up
- Add packages:
  ```yaml
  dependencies:
    macos_ui: ^latest
    macos_window_utils: ^latest
  ```
  macos_ui is macOS-first and integrates directly with `macos_window_utils`.

- Initialize the plugin in `macos/Runner/MainFlutterWindow.swift` (older projects may need this wiring). Replace the default `FlutterViewController` with `MacOSWindowUtilsViewController` and call `MainFlutterWindowManipulator.start(mainFlutterWindow: self)`.

## 1) Core references (bookmark these)
- **WindowManipulator API** — all window controls: titlebar, fullscreen, buttons, alpha, frame, etc.
- **TitlebarSafeArea widget** — safely layout under titlebar.
- **MacosToolbarPassthrough** — passes native toolbar gestures to Flutter.
- **macos_ui package docs** — layout, Modern Window Look, ToolBar, etc.
- **Cross-platform parity:** `window_manager` for Win/Linux.

## 2) One-time init (Dart)
```dart
import 'package:macos_window_utils/window_manipulator.dart';

Future<void> prepareWindow() async {
  await WindowManipulator.initialize(enableWindowDelegate: true);
  await WindowManipulator.setWindowMinSize(const Size(900, 600));
  await WindowManipulator.centerWindow();
}
```

## 3) Modern titlebar (transparent, draggable, content beneath)
```dart
await WindowManipulator.enableFullSizeContentView();
await WindowManipulator.makeTitlebarTransparent();
await WindowManipulator.hideTitle();

return TitlebarSafeArea(
  child: YourScaffold(),
);
```

## 4) Toolbar styles & native passthrough
```dart
await WindowManipulator.setToolbarStyle(toolbarStyle: NSWindowToolbarStyle.unified);

return MacosToolbarPassthrough(
  child: YourFlutterToolbar(),
);
```

## 5) Window buttons (traffic lights) & positions
```dart
final closeRect = await WindowManipulator.getStandardWindowButtonPosition(
  buttonType: NSWindowButtonType.closeButton,
);

await WindowManipulator.overrideStandardWindowButtonPosition(
  buttonType: NSWindowButtonType.closeButton,
  offset: const Offset(4, 0),
);

await WindowManipulator.hideMiniaturizeButton();
await WindowManipulator.enableZoomButton();
```

## 6) Size, position, levels, z-order
```dart
await WindowManipulator.setWindowFrame(const Rect.fromLTWH(200, 120, 1280, 900));
await WindowManipulator.setWindowMaxSize(const Size(1920, 1200));
await WindowManipulator.setLevel(NSWindowLevel.floating);
await WindowManipulator.orderFrontRegardless();
```

## 7) Fullscreen, zoom, miniaturize
```dart
if (!await WindowManipulator.isWindowFullscreened()) {
  await WindowManipulator.enterFullscreen();
}
await WindowManipulator.miniaturizeWindow();
await WindowManipulator.unzoomWindow();
```

## 8) Transparency, vibrancy, and background
```dart
await WindowManipulator.setWindowAlphaValue(0.96);
await WindowManipulator.setMaterial(NSVisualEffectViewMaterial.underWindowBackground);
await WindowManipulator.setNSVisualEffectViewState(NSVisualEffectViewState.active);
await WindowManipulator.setWindowBackgroundColorToClear();
await WindowManipulator.setWindowBackgroundColorToDefaultColor();
```

## 9) Input routing tricks
```dart
await WindowManipulator.ignoreMouseEvents();
await WindowManipulator.acknowledgeMouseEvents();
```

## 10) Document affordances (• in titlebar, proxies)
```dart
await WindowManipulator.setRepresentedFilename('/path/to/file.txt');
await WindowManipulator.setDocumentEdited();
await WindowManipulator.setDocumentUnedited();
await WindowManipulator.setSubtitle('Read-only');
```

## 11) Window delegate events (resize/move)
```dart
final handle = WindowManipulator.addNSWindowDelegate(NSWindowDelegate(
  windowDidResize: (_) { /* update layout */ },
  windowDidMove:   (_) { /* persist position */ },
));
```

## 12) Cross-platform parity (optional)
Pair `macos_window_utils` (macOS chrome) with `window_manager` for consistent APIs on Windows/Linux.

## 13) Quick checklist
- Initialize manipulator & delegate.
- Apply modern chrome.
- Add `TitlebarSafeArea`.
- Wrap toolbars in `MacosToolbarPassthrough`.
- Adjust size, position, transparency, and event handling as needed.
