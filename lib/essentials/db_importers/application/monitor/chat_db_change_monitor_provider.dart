import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db_migrate/feature_level_providers.dart';
import '../../feature_level_providers.dart';

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

      // Immediate check on startup to catch messages that arrived while app was closed.
      // This ensures users don't see stale data for 15 seconds.
      await _checkForNewMessagesOnStartup(chatDbPath);

      _startPolling(chatDbPath);
    } catch (error, stackTrace) {
      _handleError('Failed to initialize chat.db monitor: $error', stackTrace);
    }
  }

  /// Check for new messages immediately on startup.
  ///
  /// This catches the case where the app was closed for an extended period
  /// and new messages arrived. Without this, users would see stale data until
  /// the first polling interval (15 seconds).
  Future<void> _checkForNewMessagesOnStartup(String chatDbPath) async {
    try {
      final currentMaxRowId = _readMaxRowId(chatDbPath);
      final previousMaxRowId = state.lastMaxRowId;

      if (previousMaxRowId != null && currentMaxRowId > previousMaxRowId) {
        print(
          'Startup check: new messages detected (MAX ROWID: $previousMaxRowId → $currentMaxRowId)',
        );
        _scheduleProbe();
      } else {
        print('Startup check: no new messages (MAX ROWID: $currentMaxRowId)');
      }
    } catch (error) {
      // Non-fatal - polling will catch up
      print('Startup check failed: $error');
    }
  }

  Future<void> _primeMaxRowId(String chatDbPath) async {
    try {
      // CRITICAL: Prime from import.db, not chat.db!
      // This ensures we detect messages that arrived before app launch
      // but after the last import batch completed.
      final importDb = await ref.read(sqfliteImportDatabaseProvider.future);
      final importedMaxRowId = await importDb.getMaxImportedMessageRowId();

      // Use imported max if available, otherwise fall back to chat.db
      final maxRowId = importedMaxRowId ?? _readMaxRowId(chatDbPath);
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

        // Trigger incremental import and migration
        print('Triggering incremental import and migration...');

        final importService = ref.read(orchestratedLedgerImportServiceProvider);
        final importResult = await importService.runImport();

        if (importResult.success) {
          print('Incremental import successful. Triggering migration...');
          final migrationService = ref.read(handlesMigrationServiceProvider);
          final migrationResult = await migrationService.run(
            incrementalMode: true,
          );

          if (migrationResult.success) {
            print('Incremental migration successful.');
            // Signal to UI providers that new message data is available
            // This causes message list providers to rebuild with updated counts
            ref.read(messageDataVersionProvider.notifier).bump();
            // Note: Do NOT invalidate driftWorkingDatabaseProvider here!
            // It closes the isolate connection and causes "connection was closed"
            // errors for in-flight queries. Drift's reactive streams automatically
            // detect data changes via its internal watch mechanisms.
          } else {
            _handleError(
              'Incremental migration failed: ${migrationResult.error}',
              null,
            );
          }
        } else {
          _handleError(
            'Incremental import failed: ${importResult.error}',
            null,
          );
        }
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
