---
tier: project
scope: build
owner: agent-per-project
last_reviewed: 2025-07-27
source_of_truth: doc
links:
  - ../../lib/main.dart
  - ../../macos/Runner.xcodeproj/project.pbxproj
  - ../../lib/frb_generated.dart
tests: []
---

# Rust FFI Dylib Bundling for macOS Release Builds

## TL;DR

`flutter_rust_bridge` (FRB) resolves the Rust `.dylib` using `Directory.current` (the process CWD). During development the CWD is the project root, so the relative path works. **When launched via Finder / Dock / `open` command, macOS LaunchServices sets CWD to `/`, and the dylib is never found.** The `RustLib.init()` call hangs forever — no timeout, no exception — producing a permanent black window.

**Solution**: Two-part fix:
1. **Dart side** (`lib/main.dart`): resolve the dylib from the app bundle's `Frameworks/` directory before falling back to the default FRB loader.
2. **Xcode side** (`project.pbxproj`): a custom build phase copies the pre-built dylib into a proper versioned macOS framework structure inside the built `.app`.

---

## The Problem in Detail

### Symptom

After `flutter build macos --release`, the app:
- ✅ Launches instantly from terminal: `./build/macos/Build/Products/Release/remember_every_text.app/Contents/MacOS/remember_every_text`
- ❌ Shows a permanent **black window** when launched via: `open build/macos/Build/Products/Release/remember_every_text.app`, Finder double-click, or Dock

No crash, no error, no log output. The window opens but the Flutter engine never renders.

### Root Cause

FRB v2.11.1 generates this config in `lib/frb_generated.dart`:

```dart
static const kDefaultExternalLibraryLoaderConfig =
    ExternalLibraryLoaderConfig(
      stem: 'attributed_string_decoder',
      ioDirectory: 'rust/rust/attributed-string-decoder/target/release/',
      webPrefix: 'pkg/',
    );
```

When `RustLib.init()` is called without an explicit `externalLibrary` argument, FRB resolves the dylib path using:

```dart
Directory.current.uri.resolve(ioDirectory)
```

| Launch Method | `Directory.current` | Resolved Path | Result |
|---|---|---|---|
| Terminal from project dir | `/Users/rob/Dev/.../remember_every_text` | `.../rust/rust/.../target/release/libattributed_string_decoder.dylib` | ✅ Found |
| LaunchServices / Finder / `open` | `/` | `/rust/rust/.../target/release/libattributed_string_decoder.dylib` | ❌ Missing |

When the file doesn't exist, `RustLib.init()` **hangs indefinitely** — it never throws and never times out. Because `main()` awaits this call, Flutter initialization freezes before the first frame.

### Why a Black Window (Not a Crash)

`WidgetsFlutterBinding.ensureInitialized()` and the Flutter engine start normally. The NSWindow is created and shown by macOS. But `runApp()` is never reached because `await RustLib.init()` blocks forever. The engine has no widget tree to render → the GPU surface stays empty → black window.

---

## The Solution

### Part 1: Bundle-Aware Dart Initialization (`lib/main.dart`)

Instead of relying on FRB's CWD-dependent default loader, we resolve the dylib from a known location inside the app bundle:

```dart
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show ExternalLibrary;

// In main():
try {
  final bundlePath = Platform.resolvedExecutable; // .../MacOS/remember_every_text
  final frameworksDir = Directory(
    '${File(bundlePath).parent.parent.path}/Frameworks',
  );
  final bundledDylib = File(
    '${frameworksDir.path}/attributed_string_decoder.framework/attributed_string_decoder',
  );
  if (bundledDylib.existsSync()) {
    // Release mode: load from bundled framework
    await RustLib.init(
      externalLibrary: ExternalLibrary.open(bundledDylib.path),
    );
  } else {
    // Development mode: fall back to FRB's default (CWD-based) resolution
    await RustLib.init();
  }
} catch (e) {
  debugPrint('RustLib.init failed: $e — URL preview parsing will be unavailable');
}
```

**Key details:**
- `Platform.resolvedExecutable` resolves symlinks and returns the absolute path to the binary inside the `.app` bundle.
- The `Frameworks/` directory is at `Contents/Frameworks/` — two levels up from the binary at `Contents/MacOS/remember_every_text`.
- The `existsSync()` check lets development builds (where no framework is bundled) fall through to the default FRB loader, which works because the CWD is the project root.
- The `try/catch` ensures the app launches even if Rust integration fails entirely.

### Part 2: Xcode Build Phase (`project.pbxproj`)

A custom shell script build phase named **"Bundle Rust FFI Library"** runs after "[CP] Embed Pods Frameworks". It copies the pre-built dylib from the Rust crate's target directory into a proper **versioned macOS framework** inside the built `.app`.

**Why a versioned framework?** Xcode validates framework structures and rejects:
- Flat frameworks (missing `Info.plist`)
- Frameworks with `Info.plist` in the wrong location (must be at `Versions/A/Resources/Info.plist`)

The build phase creates this structure:

```
attributed_string_decoder.framework/
├── Versions/
│   ├── A/
│   │   ├── attributed_string_decoder          ← the actual dylib (renamed, no lib prefix)
│   │   └── Resources/
│   │       └── Info.plist
│   └── Current → A                             ← symlink
├── attributed_string_decoder → Versions/Current/attributed_string_decoder  ← symlink
└── Resources → Versions/Current/Resources      ← symlink
```

**Build phase shell script** (from `project.pbxproj`):

```bash
DYLIB="${SRCROOT}/../rust/rust/attributed-string-decoder/target/release/libattributed_string_decoder.dylib"
FW_DIR="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/attributed_string_decoder.framework"
if [ -f "$DYLIB" ]; then
  mkdir -p "$FW_DIR/Versions/A/Resources"
  cp "$DYLIB" "$FW_DIR/Versions/A/attributed_string_decoder"
  ln -sf A "$FW_DIR/Versions/Current"
  ln -sf Versions/Current/attributed_string_decoder "$FW_DIR/attributed_string_decoder"
  ln -sf Versions/Current/Resources "$FW_DIR/Resources"
  cat > "$FW_DIR/Versions/A/Resources/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>com.remember-this-text.attributed-string-decoder</string>
  <key>CFBundleName</key>
  <string>attributed_string_decoder</string>
  <key>CFBundleExecutable</key>
  <string>attributed_string_decoder</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
</dict>
</plist>
PLIST
  echo "Bundled Rust FFI library into $FW_DIR"
else
  echo "warning: Rust dylib not found at $DYLIB — URL preview parsing will be unavailable in release builds"
fi
```

**Input/output paths** are declared so Xcode can skip the phase when the dylib hasn't changed:
- **Input**: `${SRCROOT}/../rust/rust/attributed-string-decoder/target/release/libattributed_string_decoder.dylib`
- **Output**: `${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/attributed_string_decoder.framework/attributed_string_decoder`

---

## Files Modified

| File | Change |
|------|--------|
| `lib/main.dart` | Bundle-aware `RustLib.init()` with `ExternalLibrary.open()` and fallback. Added `flutter_rust_bridge` import. |
| `macos/Runner.xcodeproj/project.pbxproj` | Added "Bundle Rust FFI Library" shell script build phase after "[CP] Embed Pods Frameworks". |
| `lib/frb_generated.dart` | **NOT modified** — this is auto-generated by FRB and contains the problematic `ioDirectory` config. We work around it in `main.dart`. |

---

## Prerequisites

The Rust crate must be pre-built before running `flutter build macos`:

```bash
cd rust/rust/attributed-string-decoder
cargo build --release
```

The build phase expects the dylib at `rust/rust/attributed-string-decoder/target/release/libattributed_string_decoder.dylib`. If it's missing, the phase prints a warning and the app launches without Rust support (URL preview parsing unavailable).

---

## Diagnostic History

This section documents the debugging journey that led to the root cause discovery, preserved to avoid repeating dead ends.

### Red Herrings Explored

| Approach | Why It Failed |
|---|---|
| `NSWindow.alphaValue = 0` then reveal | Setting alpha to exactly 0 removes the window from the compositor entirely — it becomes permanently invisible |
| `NSWindow.alphaValue = 0.01` + Timer reveal | Window appeared, but this was a symptom treatment, not a fix — the real issue was RustLib hanging |
| Method channel from AppDelegate to reveal window | Flutter never rendered a frame, so the channel handler never ran |
| Code signing / notarization investigation | Both signed and unsigned builds exhibited the same behavior — not a code signing issue |
| `xattr` / App Translocation | No quarantine attributes present on local builds |
| Impeller vs Skia rendering toggle | Neither renderer made a difference — the hang was pre-render |
| `macos_window_utils` configuration | Window was being created and shown correctly — the issue was in Dart initialization after window creation |

### Diagnostic Approach That Worked

1. **Binary vs `open` comparison**: Running the raw binary from terminal worked; `open` didn't. This proved the issue was environment-dependent, not code-logical.
2. **Timing instrumentation**: Added `Stopwatch`-based timing between each `await` call in `main()`, writing to `/tmp/ret_open_launch.log` (file-based, since stdout isn't visible for LaunchServices launches).
3. **The telltale log**: When launched via `open`, the log stopped at `"sqflite FFI: 0ms"` — the line just before `await RustLib.init()`. The call never completed.
4. **CWD hypothesis**: Checked `Directory.current` — confirmed it was `/` when launched via `open`, vs the project root from terminal.
5. **FRB source analysis**: Traced `ExternalLibraryLoaderConfig.ioDirectory` through FRB's resolution code to `Directory.current.uri.resolve()`, confirming the CWD dependency.

---

## Impact & Scope

- **Affected**: Any macOS release build launched via Finder, Dock, `open` command, or LaunchServices
- **Not affected**: Development builds (`flutter run -d macos`), terminal-launched release builds
- **FRB version**: v2.11.1 (may be fixed in future versions — check `ExternalLibraryLoaderConfig` behavior)
- **Risk**: If the Rust crate is not pre-built, the dylib won't be bundled and Rust-dependent features (URL preview parsing, `attributedBody` decode) will be unavailable — but the app will launch normally

---

## INVIOLATE RULES

1. **NEVER modify `lib/frb_generated.dart`** — it is auto-generated by `flutter_rust_bridge`. Always work around it.
2. **NEVER rely on `Directory.current` for bundle resource resolution** — use `Platform.resolvedExecutable` for bundle-relative paths.
3. **ALWAYS use versioned framework structure** when adding dylibs to the macOS bundle — Xcode enforces `Versions/A/Resources/Info.plist`.
4. **ALWAYS keep the fallback `RustLib.init()`** so development builds continue to work without bundled frameworks.
5. **ALWAYS pre-build the Rust crate** (`cargo build --release`) before release builds.
