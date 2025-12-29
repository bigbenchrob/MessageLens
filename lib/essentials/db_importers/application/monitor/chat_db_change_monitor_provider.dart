import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../providers.dart';

part 'chat_db_change_monitor_provider.g.dart';

class ChatDbChangeMonitorState {
  const ChatDbChangeMonitorState({
    this.lastMaxRowId,
    this.lastChangeDetected,
    this.lastError,
  });

  final int? lastMaxRowId;
  final DateTime? lastChangeDetected;
  final String? lastError;

  ChatDbChangeMonitorState copyWith({
    int? lastMaxRowId,
    DateTime? lastChangeDetected,
    String? lastError,
    bool clearError = false,
  }) {
    return ChatDbChangeMonitorState(
      lastMaxRowId: lastMaxRowId ?? this.lastMaxRowId,
      lastChangeDetected: lastChangeDetected ?? this.lastChangeDetected,
      lastError: clearError ? null : lastError ?? this.lastError,
    );
  }
}

@Riverpod(keepAlive: true)
class ChatDbChangeMonitor extends _$ChatDbChangeMonitor {
  Timer? _debounceTimer;
  Timer? _pollingTimer;
  bool _importInFlight = false;
  bool _pendingProbe = false;
  String? _chatDbPath;

  @override
  ChatDbChangeMonitorState build() {
    if (!Platform.isMacOS) {
      return const ChatDbChangeMonitorState();
    }

    unawaited(_initialize());

    ref.onDispose(() {
      _debounceTimer?.cancel();
      _pollingTimer?.cancel();
    });

    return const ChatDbChangeMonitorState();
  }

  Future<void> _initialize() async {
    try {
      final pathsHelper = await ref.read(pathsHelperProvider.future);
      final chatDbPath = pathsHelper.chatDBPath;
      _chatDbPath = chatDbPath;

      await _primeMaxRowId(chatDbPath);
      _startPolling(chatDbPath);
    } catch (error, stackTrace) {
      _handleError('Failed to initialize chat.db monitor: $error', stackTrace);
    }
  }

  Future<void> _primeMaxRowId(String chatDbPath) async {
    try {
      final maxRowId = _readMaxRowId(chatDbPath);
      state = state.copyWith(lastMaxRowId: maxRowId, clearError: true);
    } catch (error, stackTrace) {
      _handleError('Unable to prime MAX(ROWID): $error', stackTrace);
    }
  }

  void _startPolling(String chatDbPath) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      try {
        final currentMaxRowId = _readMaxRowId(chatDbPath);
        final previousMaxRowId = state.lastMaxRowId;

        if (previousMaxRowId != null && currentMaxRowId > previousMaxRowId) {
          _scheduleProbe();
        }
      } catch (error) {
        // Silently continue on polling errors
      }
    });
  }

  void _scheduleProbe() {
    _pendingProbe = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      unawaited(_processPendingChanges());
    });
  }

  Future<void> _processPendingChanges() async {
    if (!_pendingProbe || _importInFlight) {
      return;
    }

    final chatDbPath = _chatDbPath;
    if (chatDbPath == null) {
      _pendingProbe = false;
      return;
    }

    _importInFlight = true;

    try {
      while (_pendingProbe) {
        _pendingProbe = false;

        final currentMaxRowId = _readMaxRowId(chatDbPath);
        final previousMaxRowId = state.lastMaxRowId;

        if (previousMaxRowId != null && currentMaxRowId <= previousMaxRowId) {
          continue;
        }

        final now = DateTime.now();
        final newMessageCount = previousMaxRowId != null
            ? currentMaxRowId - previousMaxRowId
            : 0;

        state = state.copyWith(
          lastMaxRowId: currentMaxRowId,
          lastChangeDetected: now,
        );

        print(
          'New message(s) detected in Messages database: $newMessageCount message(s), MAX(ROWID): $previousMaxRowId → $currentMaxRowId',
        );

        // Schedule import/migration for later to avoid disrupting active UI
        // TODO: Show notification to user or run during app idle time
        print(
          'Incremental import/migration deferred - trigger manually or implement idle-time scheduling',
        );
      }
    } catch (error, stackTrace) {
      _handleError('Change detection failed: $error', stackTrace);
    } finally {
      _importInFlight = false;

      if (_pendingProbe) {
        unawaited(_processPendingChanges());
      }
    }
  }

  int _readMaxRowId(String chatDbPath) {
    try {
      final db = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
      try {
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');
        final result = db.select(
          'SELECT MAX(ROWID) as max_rowid FROM message;',
        );
        if (result.isEmpty || result.first.values.isEmpty) {
          throw const FormatException('MAX(ROWID) query returned no rows');
        }
        final value = result.first.values.first;
        if (value == null) {
          return 0; // Empty table
        }
        if (value is int) {
          return value;
        }
        if (value is num) {
          return value.toInt();
        }
        return int.parse('$value');
      } finally {
        db.dispose();
      }
    } on SqliteException catch (error) {
      throw Exception('SQLite error (${error.extendedResultCode}): $error');
    }
  }

  void _handleError(String message, StackTrace? stackTrace) {
    state = state.copyWith(lastError: message);
    if (stackTrace != null) {
      stderr.writeln('$message\n$stackTrace');
    } else {
      stderr.writeln(message);
    }
  }
}
