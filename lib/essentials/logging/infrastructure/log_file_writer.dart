import 'dart:io';

import '../domain/log_entry.dart';

/// Appends [LogEntry] objects as JSONL lines to a rotating log file.
///
/// Location: `~/Library/Logs/MessageLens/app.log`
/// Rotation: current + 1 previous file, ~2 MB cap per file.
class LogFileWriter {
  static const _maxBytes = 2 * 1024 * 1024; // 2 MB
  static const _logDirName = 'MessageLens';
  static const _logFileName = 'app.log';
  static const _prevLogFileName = 'app.log.1';

  late final Directory _logDir;
  late final File _logFile;
  late final File _prevLogFile;
  IOSink? _sink;
  int _currentSize = 0;
  bool _initialized = false;

  /// The directory where log files are stored.
  Directory get logDir => _logDir;

  /// The current active log file.
  File get logFile => _logFile;

  /// The previous (rotated) log file.
  File get prevLogFile => _prevLogFile;

  /// Initialize the writer: create directory, rotate if needed, open the sink.
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    final home = Platform.environment['HOME'];
    if (home == null) {
      return; // Can't determine home dir — logging will be in-memory only.
    }

    _logDir = Directory('$home/Library/Logs/$_logDirName');
    _logFile = File('${_logDir.path}/$_logFileName');
    _prevLogFile = File('${_logDir.path}/$_prevLogFileName');

    try {
      if (!_logDir.existsSync()) {
        _logDir.createSync(recursive: true);
      }

      // Rotate on startup if the current log exceeds the cap.
      if (_logFile.existsSync() && _logFile.lengthSync() >= _maxBytes) {
        _rotate();
      }

      _currentSize = _logFile.existsSync() ? _logFile.lengthSync() : 0;
      _sink = _logFile.openWrite(mode: FileMode.append);
      _initialized = true;
    } catch (_) {
      // If anything fails, logging degrades to in-memory only.
    }
  }

  /// Append a log entry as one JSONL line.
  void append(LogEntry entry) {
    final sink = _sink;
    if (!_initialized || sink == null) {
      return;
    }

    try {
      final line = '${entry.toJsonLine()}\n';
      final lineBytes = line.length; // Approximation; sufficient for cap.
      sink.write(line);
      _currentSize += lineBytes;

      if (_currentSize >= _maxBytes) {
        _rotateAsync();
      }
    } catch (_) {
      // Never let logging failures propagate.
    }
  }

  /// Flush buffered writes to disk (call before export).
  Future<void> flush() async {
    try {
      await _sink?.flush();
    } catch (_) {
      // Ignore flush failures.
    }
  }

  /// Close the sink. Called on dispose.
  Future<void> close() async {
    try {
      await _sink?.flush();
      await _sink?.close();
    } catch (_) {
      // Ignore close failures.
    }
    _sink = null;
    _initialized = false;
  }

  void _rotate() {
    try {
      if (_prevLogFile.existsSync()) {
        _prevLogFile.deleteSync();
      }
      if (_logFile.existsSync()) {
        _logFile.renameSync(_prevLogFile.path);
      }
    } catch (_) {
      // Best-effort rotation.
    }
  }

  Future<void> _rotateAsync() async {
    try {
      await _sink?.flush();
      await _sink?.close();
      _rotate();
      _currentSize = 0;
      _sink = _logFile.openWrite(mode: FileMode.append);
    } catch (_) {
      // If rotation fails, continue writing to the current file.
    }
  }
}
