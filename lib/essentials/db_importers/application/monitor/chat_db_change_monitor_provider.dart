import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:watcher/watcher.dart';

import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db_migrate/domain/entities/db_migration_result.dart';
import '../../../db_migrate/feature_level_providers.dart';
import '../../domain/entities/db_import_result.dart';
import '../../feature_level_providers.dart';

part 'chat_db_change_monitor_provider.g.dart';

class ChatDbChangeMonitorState {
  const ChatDbChangeMonitorState({
    this.lastDataVersion,
    this.isImporting = false,
    this.isMigrating = false,
    this.lastImportResult,
    this.lastMigrationResult,
    this.lastError,
  });

  final int? lastDataVersion;
  final bool isImporting;
  final bool isMigrating;
  final DbImportResult? lastImportResult;
  final DbMigrationResult? lastMigrationResult;
  final String? lastError;

  ChatDbChangeMonitorState copyWith({
    int? lastDataVersion,
    bool? isImporting,
    bool? isMigrating,
    DbImportResult? lastImportResult,
    DbMigrationResult? lastMigrationResult,
    bool clearImportResult = false,
    bool clearMigrationResult = false,
    String? lastError,
    bool clearError = false,
  }) {
    return ChatDbChangeMonitorState(
      lastDataVersion: lastDataVersion ?? this.lastDataVersion,
      isImporting: isImporting ?? this.isImporting,
      isMigrating: isMigrating ?? this.isMigrating,
      lastImportResult: clearImportResult
          ? null
          : lastImportResult ?? this.lastImportResult,
      lastMigrationResult: clearMigrationResult
          ? null
          : lastMigrationResult ?? this.lastMigrationResult,
      lastError: clearError ? null : lastError ?? this.lastError,
    );
  }
}

@Riverpod(keepAlive: true)
class ChatDbChangeMonitor extends _$ChatDbChangeMonitor {
  DirectoryWatcher? _directoryWatcher;
  StreamSubscription<WatchEvent>? _watcherSubscription;
  Timer? _debounceTimer;
  bool _importInFlight = false;
  bool _migrationInFlight = false;
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
      _watcherSubscription?.cancel();
      _directoryWatcher = null;
    });

    return const ChatDbChangeMonitorState();
  }

  Future<void> _initialize() async {
    try {
      final pathsHelper = await ref.read(pathsHelperProvider.future);
      final chatDbPath = pathsHelper.chatDBPath;
      _chatDbPath = chatDbPath;

      await _primeDataVersion(chatDbPath);
      await _startWatching(chatDbPath);
    } catch (error, stackTrace) {
      _handleError('Failed to initialize chat.db monitor: $error', stackTrace);
    }
  }

  Future<void> _primeDataVersion(String chatDbPath) async {
    try {
      final dataVersion = _readDataVersion(chatDbPath);
      state = state.copyWith(
        lastDataVersion: dataVersion,
        clearError: true,
        clearImportResult: true,
      );
    } catch (error, stackTrace) {
      _handleError('Unable to prime data version: $error', stackTrace);
    }
  }

  Future<void> _startWatching(String chatDbPath) async {
    final directoryPath = p.dirname(chatDbPath);

    final directoryExists = Directory(directoryPath).existsSync();
    if (!directoryExists) {
      _handleError('Messages directory not found: $directoryPath', null);
      return;
    }

    _directoryWatcher = DirectoryWatcher(directoryPath);
    _watcherSubscription = _directoryWatcher!.events.listen(
      (event) {
        final fileName = p.basename(event.path);
        if (fileName == 'chat.db' || fileName == 'chat.db-wal') {
          _scheduleProbe();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _handleError('Watcher error: $error', stackTrace);
      },
    );
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

    if (_migrationInFlight) {
      await _waitForMigrationToComplete();
      if (!_pendingProbe) {
        return;
      }
    }

    _importInFlight = true;
    var migrationNeeded = false;
    state = state.copyWith(
      isImporting: true,
      clearError: true,
      clearImportResult: true,
    );

    try {
      while (_pendingProbe) {
        _pendingProbe = false;

        final currentVersion = _readDataVersion(chatDbPath);
        final previousVersion = state.lastDataVersion;
        if (previousVersion != null && currentVersion == previousVersion) {
          continue;
        }

        state = state.copyWith(lastDataVersion: currentVersion);

        final result = await ref
            .read(orchestratedLedgerImportServiceProvider)
            .runImport();

        state = state.copyWith(lastImportResult: result, clearError: true);

        if (!result.success) {
          final message =
              result.error ?? 'Automatic import failed for an unknown reason';
          _handleError('Automatic import failed: $message', null);
          continue;
        }

        migrationNeeded = true;
      }

      if (migrationNeeded) {
        await _runMigration();
      }
    } catch (error, stackTrace) {
      _handleError('Automatic import failed: $error', stackTrace);
    } finally {
      _importInFlight = false;
      state = state.copyWith(isImporting: false);

      if (_pendingProbe) {
        unawaited(_processPendingChanges());
      }
    }
  }

  int _readDataVersion(String chatDbPath) {
    try {
      final db = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
      try {
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');
        final result = db.select('PRAGMA data_version;');
        if (result.isEmpty || result.first.values.isEmpty) {
          throw const FormatException('PRAGMA data_version returned no rows');
        }
        final value = result.first.values.first;
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

  Future<void> _runMigration() async {
    if (_migrationInFlight) {
      return;
    }

    _migrationInFlight = true;
    state = state.copyWith(
      isMigrating: true,
      clearError: true,
      clearMigrationResult: true,
    );

    try {
      final result = await ref.read(handlesMigrationServiceProvider).run();

      state = state.copyWith(lastMigrationResult: result, clearError: true);

      if (!result.success) {
        final message =
            result.error ?? 'Automatic migration failed for an unknown reason';
        _handleError('Automatic migration failed: $message', null);
        return;
      }

      ref.invalidate(driftWorkingDatabaseProvider);
    } catch (error, stackTrace) {
      _handleError('Automatic migration failed: $error', stackTrace);
    } finally {
      _migrationInFlight = false;
      state = state.copyWith(isMigrating: false);
    }
  }

  Future<void> _waitForMigrationToComplete() async {
    while (_migrationInFlight) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }
}
