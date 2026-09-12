import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show
        admittedArchiveAccessAuthorityProvider,
        archiveOwnedResourceRegistryProvider;
import '../domain/log_entry.dart';
import '../infrastructure/log_file_writer.dart';
import '../infrastructure/macos_unified_log_bridge.dart';

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
  LogFileWriter? _writer;
  Future<void>? _writerReady;
  final MacosUnifiedLogBridge _unifiedLogBridge = MacosUnifiedLogBridge();

  @override
  List<LogEntry> build() {
    final authority = ref.watch(admittedArchiveAccessAuthorityProvider);
    if (authority != null) {
      final writer = LogFileWriter(
        logDirectory: Directory(authority.resolvePath('application_logs')),
      );
      _writer = writer;
      _writerReady = writer.init();
      final resources = ref.read(archiveOwnedResourceRegistryProvider);
      resources.register(
        identity: writer,
        label: 'application log writer',
        close: writer.close,
      );
      ref.onDispose(() async {
        resources.unregister(writer);
        await writer.close();
      });
    }
    return [];
  }

  /// The underlying file writer, exposed for the export service.
  LogFileWriter get writer {
    final writer = _writer;
    if (writer == null) {
      throw StateError(
        'Persistent log access was requested before archive admission.',
      );
    }
    return writer;
  }

  Future<void> get ready {
    return _writerReady ?? Future<void>.value();
  }

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
    _writer?.append(entry);

    if (entry.level != LogLevel.debug) {
      unawaited(_unifiedLogBridge.log(entry));
    }
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
