import 'dart:io';

/// Checks whether the app has Full Disk Access by attempting to read
/// the macOS Messages database at `~/Library/Messages/chat.db`.
///
/// This is a pure filesystem probe — no SQLite, no provider dependencies.
/// It can be called synchronously from a Riverpod `build()` method.
class FdaChecker {
  const FdaChecker();

  // ── Debug: set to true to simulate FDA-not-granted during dev. ──
  // When true, canReadMessagesDatabase() always returns false.
  // Flip back to false for production builds.
  static bool debugSimulateFdaMissing = false;

  /// The absolute path to the macOS Messages database.
  static String get chatDbPath {
    final home = Platform.environment['HOME'] ?? '/Users/unknown';
    return '$home/Library/Messages/chat.db';
  }

  /// Returns `true` if the app can open `chat.db` for reading.
  ///
  /// A `false` result most likely means Full Disk Access has not been
  /// granted in System Settings → Privacy & Security.
  bool canReadMessagesDatabase() {
    if (debugSimulateFdaMissing) {
      return false;
    }

    try {
      final file = File(chatDbPath);
      if (!file.existsSync()) {
        return false;
      }
      final raf = file.openSync(mode: FileMode.read);
      raf.closeSync();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Open System Settings to the Full Disk Access pane.
  ///
  /// Uses the `x-apple.systempreferences:` URL scheme which works on
  /// both pre-Ventura (System Preferences) and Ventura+ (System Settings).
  static Future<void> openFdaSettings() async {
    await Process.run('open', [
      'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles',
    ]);
  }
}
