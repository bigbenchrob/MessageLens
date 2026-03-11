import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/log_entry.dart';
import '../infrastructure/log_file_writer.dart';

part 'app_logger.g.dart';

/// Maximum number of entries kept in the in-memory buffer for UI display.
const _kMaxInMemoryEntries = 500;

/// Unified application logger.
///
/// Accepts structured log entries at four levels (`debug`, `info`, `warn`,
/// `error`) and writes them both to an in-memory buffer (exposed as provider
/// state) and to a persistent JSONL log file via [LogFileWriter].
///
/// The `debug` level is gated behind [kDebugMode] so release builds only
/// contain `info`, `warn`, and `error` entries.
@Riverpod(keepAlive: true)
class AppLogger extends _$AppLogger {
  final LogFileWriter _writer = LogFileWriter();

  @override
  List<LogEntry> build() {
    _writer.init();
    ref.onDispose(_writer.close);
    return [];
  }

  /// The underlying file writer, exposed for the export service.
  LogFileWriter get writer => _writer;

  void log(
    LogLevel level,
    String message, {
    String? source,
    Map<String, dynamic>? context,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now().toUtc(),
      level: level,
      source: source,
      message: message,
      context: context ?? const {},
    );

    // Append to in-memory buffer with cap.
    final buffer = [...state, entry];
    if (buffer.length > _kMaxInMemoryEntries) {
      state = buffer.sublist(buffer.length - _kMaxInMemoryEntries);
    } else {
      state = buffer;
    }

    // Async file write (fire-and-forget).
    _writer.append(entry);
  }

  void debug(String message, {String? source, Map<String, dynamic>? context}) {
    // Gate debug-level entries behind compile-time constant.
    if (!kDebugMode) {
      return;
    }
    log(LogLevel.debug, message, source: source, context: context);
  }

  void info(String message, {String? source, Map<String, dynamic>? context}) =>
      log(LogLevel.info, message, source: source, context: context);

  void warn(String message, {String? source, Map<String, dynamic>? context}) =>
      log(LogLevel.warn, message, source: source, context: context);

  void error(String message, {String? source, Map<String, dynamic>? context}) =>
      log(LogLevel.error, message, source: source, context: context);
}
