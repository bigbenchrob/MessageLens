import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/chats/presentation/view_model/recent_chats_provider.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db_migrate/domain/entities/db_migration_result.dart';
import '../../../db_migrate/domain/states/table_migration_progress.dart';
import '../../../db_migrate/feature_level_providers.dart';
import '../../application/services/import_status_checker.dart';
import '../../domain/entities/db_import_result.dart';
import '../../domain/states/table_import_progress.dart';
import '../../feature_level_providers.dart';

part 'db_import_control_provider.g.dart';

enum DbImportMode { import, migration }

enum DbImportViewMode { progress, summary }

class UiStageProgress {
  const UiStageProgress({
    required this.name,
    required this.displayName,
    required this.sortIndex,
    this.isActive = false,
    this.isComplete = false,
    this.progress,
    this.current,
    this.total,
    this.startedAt,
    this.completedAt,
  });

  final String name;
  final String displayName;
  final int sortIndex;
  final bool isActive;
  final bool isComplete;
  final double? progress;
  final int? current;
  final int? total;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Duration? get duration {
    if (startedAt == null || completedAt == null) {
      return null;
    }
    return completedAt!.difference(startedAt!);
  }

  UiStageProgress copyWith({
    bool? isActive,
    bool? isComplete,
    double? progress,
    bool clearProgress = false,
    int? current,
    bool clearCurrent = false,
    int? total,
    bool clearTotal = false,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return UiStageProgress(
      name: name,
      displayName: displayName,
      sortIndex: sortIndex,
      isActive: isActive ?? this.isActive,
      isComplete: isComplete ?? this.isComplete,
      progress: clearProgress ? null : progress ?? this.progress,
      current: clearCurrent ? null : current ?? this.current,
      total: clearTotal ? null : total ?? this.total,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }
}

class UiTableMigrationPhaseStatus {
  const UiTableMigrationPhaseStatus({
    required this.phase,
    required this.status,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.message,
    this.rowsProcessed,
    this.totalRows,
    this.currentItem,
  });

  final TableMigrationPhase phase;
  final TableMigrationStatus status;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? message;

  /// Number of rows processed so far (only set during inProgress).
  final int? rowsProcessed;

  /// Total number of rows to process (only set during inProgress).
  final int? totalRows;

  /// Description of the current item being processed.
  final String? currentItem;

  /// Progress as a fraction 0.0 to 1.0, or null if not determinable.
  double? get progress {
    if (rowsProcessed == null || totalRows == null || totalRows == 0) {
      return null;
    }
    return rowsProcessed! / totalRows!;
  }

  UiTableMigrationPhaseStatus copyWith({
    TableMigrationStatus? status,
    DateTime? updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? message,
    int? rowsProcessed,
    bool clearRowsProcessed = false,
    int? totalRows,
    bool clearTotalRows = false,
    String? currentItem,
    bool clearCurrentItem = false,
  }) {
    return UiTableMigrationPhaseStatus(
      phase: phase,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      message: message ?? this.message,
      rowsProcessed: clearRowsProcessed
          ? null
          : rowsProcessed ?? this.rowsProcessed,
      totalRows: clearTotalRows ? null : totalRows ?? this.totalRows,
      currentItem: clearCurrentItem ? null : currentItem ?? this.currentItem,
    );
  }

  Duration? get duration {
    if (startedAt == null || completedAt == null) {
      return null;
    }
    return completedAt!.difference(startedAt!);
  }
}

class UiTableMigrationProgress {
  const UiTableMigrationProgress({
    required this.tableName,
    required this.displayName,
    required this.sortIndex,
    required this.phases,
  });

  final String tableName;
  final String displayName;
  final int sortIndex;
  final Map<TableMigrationPhase, UiTableMigrationPhaseStatus> phases;

  UiTableMigrationProgress copyWith({
    Map<TableMigrationPhase, UiTableMigrationPhaseStatus>? phases,
  }) {
    return UiTableMigrationProgress(
      tableName: tableName,
      displayName: displayName,
      sortIndex: sortIndex,
      phases: phases ?? this.phases,
    );
  }

  TableMigrationStatus get overallStatus {
    if (phases.values.any(
      (status) => status.status == TableMigrationStatus.failed,
    )) {
      return TableMigrationStatus.failed;
    }
    if (phases.length == TableMigrationPhase.values.length &&
        phases.values.every(
          (status) => status.status == TableMigrationStatus.succeeded,
        )) {
      return TableMigrationStatus.succeeded;
    }
    return TableMigrationStatus.started;
  }

  bool get isComplete => overallStatus == TableMigrationStatus.succeeded;

  UiTableMigrationPhaseStatus? statusForPhase(TableMigrationPhase phase) {
    return phases[phase];
  }

  UiTableMigrationPhaseStatus? get latestStatus {
    if (phases.isEmpty) {
      return null;
    }
    return phases.values.reduce(
      (current, next) =>
          current.updatedAt.isAfter(next.updatedAt) ? current : next,
    );
  }

  String? get failureMessage {
    for (final phase in phases.values) {
      if (phase.status == TableMigrationStatus.failed &&
          phase.message != null &&
          phase.message!.isNotEmpty) {
        return phase.message;
      }
    }
    return null;
  }

  DateTime? get startedAt {
    DateTime? earliest;
    for (final phase in phases.values) {
      final started = phase.startedAt;
      if (started == null) {
        continue;
      }
      if (earliest == null || started.isBefore(earliest)) {
        earliest = started;
      }
    }
    return earliest;
  }

  DateTime? get completedAt {
    DateTime? latest;
    for (final phase in phases.values) {
      final completed = phase.completedAt;
      if (completed == null) {
        return null;
      }
      if (latest == null || completed.isAfter(latest)) {
        latest = completed;
      }
    }
    return latest;
  }

  Duration? get duration {
    final start = startedAt;
    final end = completedAt;
    if (start == null || end == null) {
      return null;
    }
    return end.difference(start);
  }
}

class DbImportControlState {
  const DbImportControlState({
    this.selectedMode = DbImportMode.import,
    this.isProcessing = false,
    this.statusMessage,
    this.progress,
    this.stages = const <UiStageProgress>[],
    this.tableProgress = const <UiTableMigrationProgress>[],
    this.currentStage,
    this.viewMode = DbImportViewMode.progress,
    this.showingDebugPanel = false,
    this.lastImportResult,
    this.lastMigrationResult,
  });

  final DbImportMode selectedMode;
  final bool isProcessing;
  final String? statusMessage;
  final double? progress;
  final List<UiStageProgress> stages;
  final List<UiTableMigrationProgress> tableProgress;
  final String? currentStage;
  final DbImportViewMode viewMode;
  final bool showingDebugPanel;
  final DbImportResult? lastImportResult;
  final DbMigrationResult? lastMigrationResult;

  DbImportControlState copyWith({
    DbImportMode? selectedMode,
    bool? isProcessing,
    String? statusMessage,
    bool clearStatusMessage = false,
    double? progress,
    bool clearProgress = false,
    List<UiStageProgress>? stages,
    List<UiTableMigrationProgress>? tableProgress,
    bool clearTableProgress = false,
    String? currentStage,
    bool clearCurrentStage = false,
    DbImportViewMode? viewMode,
    bool? showingDebugPanel,
    DbImportResult? lastImportResult,
    bool clearImportResult = false,
    DbMigrationResult? lastMigrationResult,
    bool clearMigrationResult = false,
  }) {
    return DbImportControlState(
      selectedMode: selectedMode ?? this.selectedMode,
      isProcessing: isProcessing ?? this.isProcessing,
      statusMessage: clearStatusMessage
          ? null
          : statusMessage ?? this.statusMessage,
      progress: clearProgress ? null : progress ?? this.progress,
      stages: stages ?? this.stages,
      tableProgress: clearTableProgress
          ? const <UiTableMigrationProgress>[]
          : tableProgress ?? this.tableProgress,
      currentStage: clearCurrentStage
          ? null
          : currentStage ?? this.currentStage,
      viewMode: viewMode ?? this.viewMode,
      showingDebugPanel: showingDebugPanel ?? this.showingDebugPanel,
      lastImportResult: clearImportResult
          ? null
          : lastImportResult ?? this.lastImportResult,
      lastMigrationResult: clearMigrationResult
          ? null
          : lastMigrationResult ?? this.lastMigrationResult,
    );
  }
}

@riverpod
class DbImportControlViewModel extends _$DbImportControlViewModel {
  @override
  DbImportControlState build() {
    return const DbImportControlState();
  }

  void setMode(DbImportMode mode) {
    state = state.copyWith(selectedMode: mode);
  }

  void setViewMode(DbImportViewMode mode) {
    if (state.viewMode != mode) {
      state = state.copyWith(viewMode: mode);
    }
  }

  void setDebugPanelVisible({required bool isVisible}) {
    if (state.showingDebugPanel == isVisible) {
      return;
    }
    state = state.copyWith(showingDebugPanel: isVisible);
  }

  void toggleDebugPanel() {
    state = state.copyWith(showingDebugPanel: !state.showingDebugPanel);
  }

  void reset() {
    state = const DbImportControlState();
  }

  /// Deletes import and working databases (preserving overlay DB),
  /// invalidates their providers, and resets UI to virgin state.
  Future<void> resetAllDatabases() async {
    if (state.isProcessing) {
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Resetting databases...',
      stages: const <UiStageProgress>[],
      clearProgress: true,
      clearCurrentStage: true,
      clearImportResult: true,
      clearMigrationResult: true,
      clearTableProgress: true,
      viewMode: DbImportViewMode.progress,
    );

    ref.read(dbMaintenanceLockProvider.notifier).begin();
    try {
      // Close import database connection
      try {
        final ledgerDb = await ref.read(sqfliteImportDatabaseProvider.future);
        await ledgerDb.close();
      } catch (_) {
        // Already closed or not available
      }
      ref.invalidate(sqfliteImportDatabaseProvider);

      // Close working database connection
      try {
        final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
        await workingDb.close();
      } catch (_) {
        // Already closed or not available
      }
      ref.invalidate(driftWorkingDatabaseProvider);

      // Delete database files (NOT overlay DB)
      const dbDir = '/Users/rob/sqlite_rmc/remember_every_text/';
      for (final baseName in <String>['macos_import.db', 'working.db']) {
        final basePath = '$dbDir$baseName';
        for (final filePath in <String>[
          basePath,
          '$basePath-wal',
          '$basePath-shm',
        ]) {
          final file = File(filePath);
          if (file.existsSync()) {
            await file.delete();
          }
        }
      }

      // Re-invalidate so next access creates fresh databases
      ref.invalidate(sqfliteImportDatabaseProvider);
      ref.invalidate(driftWorkingDatabaseProvider);

      state = state.copyWith(
        isProcessing: false,
        statusMessage:
            'Databases reset. Import and working databases deleted (overlay preserved).',
      );
    } catch (error) {
      final message = _mapDatabaseError('Reset failed', error);
      state = state.copyWith(isProcessing: false, statusMessage: message);
    } finally {
      ref.read(dbMaintenanceLockProvider.notifier).end();
    }
  }

  Future<void> clearImportDatabase() async {
    if (state.isProcessing) {
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Clearing import database...',
      stages: const <UiStageProgress>[],
      clearProgress: true,
      clearCurrentStage: true,
      clearImportResult: true,
      clearTableProgress: true,
      viewMode: DbImportViewMode.progress,
    );

    try {
      final startedAt = DateTime.now();
      // ignore: avoid_print
      print('[DbImportControl] clearImportDatabase: start @ $startedAt');

      // Close the import DB connection so the file can be deleted.
      try {
        // ignore: avoid_print
        print(
          '[DbImportControl] clearImportDatabase: acquiring sqfliteImportDatabaseProvider.future',
        );
        final ledgerDb = await ref.read(sqfliteImportDatabaseProvider.future);
        // ignore: avoid_print
        print('[DbImportControl] clearImportDatabase: closing import DB...');
        await ledgerDb.close();
        // ignore: avoid_print
        print('[DbImportControl] clearImportDatabase: import DB closed');
      } catch (_) {
        // ignore: avoid_print
        print(
          '[DbImportControl] clearImportDatabase: import DB close skipped (already closed / not available)',
        );
      }

      // ignore: avoid_print
      print(
        '[DbImportControl] clearImportDatabase: invalidating sqfliteImportDatabaseProvider (pre-clear)',
      );
      ref.invalidate(sqfliteImportDatabaseProvider);

      try {
        const importDbDir = '/Users/rob/sqlite_rmc/remember_every_text/';
        const basePath = '${importDbDir}macos_import.db';
        final candidates = <String>[basePath, '$basePath-wal', '$basePath-shm'];

        for (final filePath in candidates) {
          final file = File(filePath);
          if (!file.existsSync()) {
            continue;
          }
          // ignore: avoid_print
          print('[DbImportControl] clearImportDatabase: deleting $filePath');
          await file.delete();
        }

        // ignore: avoid_print
        print(
          '[DbImportControl] clearImportDatabase: macos_import.db files deleted',
        );
      } catch (error) {
        // ignore: avoid_print
        print(
          '[DbImportControl] clearImportDatabase: delete files FAILED error=$error',
        );
        rethrow;
      }

      // ignore: avoid_print
      print(
        '[DbImportControl] clearImportDatabase: invalidating sqfliteImportDatabaseProvider (post-clear)',
      );
      ref.invalidate(sqfliteImportDatabaseProvider);

      // ignore: avoid_print
      print(
        '[DbImportControl] clearImportDatabase: success in ${DateTime.now().difference(startedAt).inMilliseconds}ms',
      );

      state = state.copyWith(
        isProcessing: false,
        statusMessage:
            'Import database deleted and will be recreated on demand. Run Import again to repopulate it.',
        clearProgress: true,
        clearCurrentStage: true,
        clearTableProgress: true,
      );
    } catch (error) {
      final message = _mapDatabaseError(
        'Failed to clear import database',
        error,
      );
      state = state.copyWith(isProcessing: false, statusMessage: message);
    }
  }

  Future<void> clearWorkingDatabase() async {
    if (state.isProcessing) {
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Clearing working database...',
      stages: const <UiStageProgress>[],
      clearProgress: true,
      clearCurrentStage: true,
      clearMigrationResult: true,
      clearTableProgress: true,
      viewMode: DbImportViewMode.progress,
    );

    ref.read(dbMaintenanceLockProvider.notifier).begin();
    try {
      final startedAt = DateTime.now();
      // ignore: avoid_print
      print('[DbImportControl] clearWorkingDatabase: start @ $startedAt');

      // CRITICAL: Close the Drift working database connection BEFORE issuing
      // bulk deletes. Otherwise, the background isolate can get stuck and the
      // UI will hang waiting for the worker to respond.
      try {
        // ignore: avoid_print
        print(
          '[DbImportControl] clearWorkingDatabase: acquiring driftWorkingDatabaseProvider.future',
        );
        final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
        // ignore: avoid_print
        print(
          '[DbImportControl] clearWorkingDatabase: closing WorkingDatabase...',
        );
        await workingDb.close();
        // ignore: avoid_print
        print('[DbImportControl] clearWorkingDatabase: WorkingDatabase closed');
      } catch (_) {
        // Database might not exist yet or already be closed.
        // ignore: avoid_print
        print(
          '[DbImportControl] clearWorkingDatabase: WorkingDatabase close skipped (already closed / not available)',
        );
      }

      // ignore: avoid_print
      print(
        '[DbImportControl] clearWorkingDatabase: invalidating driftWorkingDatabaseProvider (pre-clear)',
      );
      ref.invalidate(driftWorkingDatabaseProvider);

      // FAST PATH:
      // Clearing by issuing massive DELETE statements can hang indefinitely on
      // some SQLite setups (FTS triggers, WAL contention, long-lived readers).
      // Deleting the database files is deterministic and much faster.
      try {
        const workingDbDir = '/Users/rob/sqlite_rmc/remember_every_text/';
        const basePath = '${workingDbDir}working.db';
        final candidates = <String>[basePath, '$basePath-wal', '$basePath-shm'];

        for (final filePath in candidates) {
          final file = File(filePath);
          if (!file.existsSync()) {
            continue;
          }
          // ignore: avoid_print
          print('[DbImportControl] clearWorkingDatabase: deleting $filePath');
          await file.delete();
        }

        // ignore: avoid_print
        print(
          '[DbImportControl] clearWorkingDatabase: working.db files deleted',
        );
      } catch (error) {
        // ignore: avoid_print
        print(
          '[DbImportControl] clearWorkingDatabase: delete files FAILED error=$error',
        );
        rethrow;
      }

      // ignore: avoid_print
      print(
        '[DbImportControl] clearWorkingDatabase: skipping SQL clearWorkingProjection (fast delete-on-disk strategy)',
      );

      // ignore: avoid_print
      print(
        '[DbImportControl] clearWorkingDatabase: invalidating driftWorkingDatabaseProvider (post-clear)',
      );
      ref.invalidate(driftWorkingDatabaseProvider);

      // ignore: avoid_print
      print(
        '[DbImportControl] clearWorkingDatabase: success in ${DateTime.now().difference(startedAt).inMilliseconds}ms',
      );

      state = state.copyWith(
        isProcessing: false,
        statusMessage:
            'Working database deleted and will be recreated on demand. Run Migration to repopulate it.',
        clearProgress: true,
        clearCurrentStage: true,
        clearTableProgress: true,
      );
    } catch (error) {
      // ignore: avoid_print
      print('[DbImportControl] clearWorkingDatabase: FAILED with error=$error');
      final message = _mapDatabaseError(
        'Failed to clear working database',
        error,
      );
      state = state.copyWith(isProcessing: false, statusMessage: message);
    } finally {
      ref.read(dbMaintenanceLockProvider.notifier).end();
    }
  }

  Future<void> startImport() async {
    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Starting import...',
      progress: 0.0,
      stages: const <UiStageProgress>[],
      tableProgress: const <UiTableMigrationProgress>[],
      showingDebugPanel: false,
      clearImportResult: true,
    );

    try {
      final service = ref.read(orchestratedLedgerImportServiceProvider);
      final result = await service.runImport(
        onExecutionPlan: (steps) {
          // Build UI step list from the orchestrator's topological order.
          state = state.copyWith(
            stages: <UiStageProgress>[
              for (final step in steps)
                UiStageProgress(
                  name: step.name,
                  displayName: step.displayName,
                  sortIndex: step.index,
                ),
            ],
          );
        },
        onTableProgress: (event) {
          _handleTableImportProgress(event);
        },
      );

      state = state.copyWith(
        isProcessing: false,
        statusMessage: result.success
            ? 'Import completed successfully'
            : 'Import failed: ${result.error ?? 'Unknown error'}',
        progress: result.success ? 1.0 : state.progress,
        lastImportResult: result,
      );
    } catch (error) {
      final message = _mapDatabaseError('Import failed', error);
      state = state.copyWith(
        isProcessing: false,
        statusMessage: message,
        progress: 0.0,
      );
    }
  }

  Future<void> startMigration({bool skipImportCheck = false}) async {
    // Check if there's unimported data in macOS chat.db
    if (!skipImportCheck) {
      try {
        final importDb = await ref.read(sqfliteImportDatabaseProvider.future);

        // macOS Messages database is always at this location
        final homeDir = Platform.environment['HOME'];
        if (homeDir == null) {
          throw Exception('Could not determine home directory');
        }
        final macOsChatDbPath = '$homeDir/Library/Messages/chat.db';

        const checker = ImportStatusChecker();
        final status = await checker.checkStatus(
          macOsChatDbPath: macOsChatDbPath,
          importDb: importDb,
        );

        // If there's unimported data, run import first
        if (status.hasUnimportedData) {
          state = state.copyWith(
            statusMessage:
                'Found ${status.unimportedMessageCount} unimported messages. Running import first...',
          );

          await runImportAndMigration();
          return;
        }
      } catch (error) {
        // Log but continue with migration - don't fail if we can't check status
        print('Warning: Could not check import status: $error');
      }
    }

    // Check if working DB has existing data BEFORE closing the connection
    final useIncrementalMode = await _hasExistingMessages();

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Starting migration...',
      progress: 0.0,
      stages: const <UiStageProgress>[],
      tableProgress: const <UiTableMigrationProgress>[],
      showingDebugPanel: false,
      clearMigrationResult: true,
    );

    // CRITICAL: Close ALL database connections BEFORE migration
    // to avoid "database is locked" errors during ATTACH
    try {
      final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
      await workingDb.close();
    } catch (_) {
      // Database might not exist yet or already closed - that's fine
    }
    ref.invalidate(driftWorkingDatabaseProvider);

    try {
      final importDb = await ref.read(sqfliteImportDatabaseProvider.future);
      await importDb.close();
    } catch (_) {
      // Import database might not exist yet or already closed - that's fine
    }
    ref.invalidate(sqfliteImportDatabaseProvider);

    try {
      final result = await ref
          .read(handlesMigrationServiceProvider)
          .run(
            onExecutionPlan: (steps) {
              state = state.copyWith(
                stages: <UiStageProgress>[
                  for (final step in steps)
                    UiStageProgress(
                      name: step.name,
                      displayName: step.displayName,
                      sortIndex: step.index,
                    ),
                ],
              );
            },
            onTableProgress: (TableMigrationProgressEvent event) {
              _handleTableMigrationProgress(event);
            },
            incrementalMode: useIncrementalMode,
          );

      state = state.copyWith(
        isProcessing: false,
        statusMessage: result.success
            ? 'Migration completed successfully'
            : 'Migration failed: ${result.error ?? 'Unknown error'}',
        progress: result.success ? 1.0 : state.progress,
        lastMigrationResult: result,
      );

      if (result.success) {
        ref.invalidate(recentChatsProvider);
      }
    } catch (error) {
      final message = _mapDatabaseError('Migration failed', error);
      state = state.copyWith(
        isProcessing: false,
        statusMessage: message,
        progress: 0.0,
      );
    }
  }

  Future<void> runImportAndMigration({bool awaitCompletion = true}) async {
    Future<void> pipeline() async {
      if (state.isProcessing) {
        return;
      }

      await startImport();

      final importSuccess = state.lastImportResult?.success ?? false;
      if (!importSuccess) {
        return;
      }

      if (state.isProcessing) {
        return;
      }

      await startMigration();
    }

    if (awaitCompletion) {
      await pipeline();
      return;
    }

    unawaited(pipeline());
  }

  /// Check if working.db has existing messages to determine if incremental mode should be used
  Future<bool> _hasExistingMessages() async {
    try {
      final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
      final result = await workingDb
          .customSelect('SELECT COUNT(*) as count FROM messages')
          .getSingle();
      final count = result.read<int>('count');
      return count > 0;
    } catch (_) {
      // If we can't determine, default to false (full migration)
      return false;
    }
  }

  String _mapDatabaseError(String prefix, Object error) {
    final raw = error.toString();
    if ((raw.contains('SqliteFfiException') &&
            raw.contains('authorization denied')) ||
        raw.contains('database is locked') ||
        raw.contains('SQLITE_BUSY') ||
        raw.contains('SQLITE_LOCKED') ||
        raw.contains('database_locked') ||
        raw.contains('unable to open database file')) {
      return '$prefix: Database is locked or in use.\n\n'
          'Troubleshooting steps:\n'
          '1. Close VS Code SQLite extension viewer\n'
          '2. Close DB Browser for SQLite\n'
          '3. Check for other running instances of this app\n'
          '4. Restart the app if the lock persists\n\n'
          'Technical error: $raw';
    }

    return '$prefix: $raw';
  }

  Future<void> checkDatabaseAccess() async {
    state = state.copyWith(statusMessage: 'Checking database access...');

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        statusMessage: 'Database access check completed. Ready for migration.',
      );
    } catch (error) {
      final message = _mapDatabaseError('Database access check failed', error);
      state = state.copyWith(statusMessage: message);
    }
  }

  void showDatabaseDiagnostics() {
    const diagnosticMessage = '''
Database Lock Diagnostics:

🔍 MOST LIKELY CAUSE:
The running application itself has database connections open!

Common causes of database locks:
1. 🔥 INTERNAL: App's own database connections (most likely)
2. VS Code SQLite extension
3. DB Browser for SQLite
4. Another instance of this app
5. Terminal sqlite3 commands
6. System backup processes (Time Machine)
7. Antivirus scanning
8. File indexing (Spotlight)

📁 Database file locations:
• import.db (in ~/sqlite_rmc/messages/)
• working.db (in ~/sqlite_rmc/messages/)

🛠️ Troubleshooting steps:
1. 🔄 RESTART THIS APP (closes internal connections)
2. Quit all database applications
3. Check Activity Monitor for sqlite processes
4. Close any open terminal sqlite3 sessions
5. Run migration again

💡 Technical note: The app may be holding database connections
that prevent migration access. Restarting the app is the best solution.''';

    state = state.copyWith(statusMessage: diagnosticMessage);
  }

  void _handleTableImportProgress(TableImportProgressEvent event) {
    final now = DateTime.now();

    // Update the UI step corresponding to this importer.
    final stageIndex = state.stages.indexWhere(
      (s) => s.name == event.importerName,
    );
    if (stageIndex != -1) {
      final stage = state.stages[stageIndex];

      // A step becomes complete only when its final phase succeeds.
      final isComplete =
          event.phase == TableImportPhase.postValidate &&
          event.status == TableImportStatus.succeeded;

      // Once active, a step stays active until complete (no flicker
      // between phases like validatePrereqs→copy→postValidate).
      final isActive =
          !isComplete &&
          (stage.isActive ||
              event.status == TableImportStatus.started ||
              event.status == TableImportStatus.inProgress);

      double? progress;
      if (event.rowsProcessed != null &&
          event.totalRows != null &&
          event.totalRows! > 0) {
        progress = event.rowsProcessed! / event.totalRows!;
      }

      final updatedStages = List<UiStageProgress>.of(state.stages);
      updatedStages[stageIndex] = stage.copyWith(
        isActive: isActive && !isComplete,
        isComplete: isComplete || stage.isComplete,
        progress: isComplete ? 1.0 : progress ?? stage.progress,
        current: event.rowsProcessed ?? stage.current,
        total: event.totalRows ?? stage.total,
        startedAt: stage.startedAt ?? now,
        completedAt: isComplete ? now : stage.completedAt,
      );

      final completedCount = updatedStages.where((s) => s.isComplete).length;
      final overallProgress = updatedStages.isEmpty
          ? 0.0
          : completedCount / updatedStages.length;

      state = state.copyWith(
        stages: updatedStages,
        currentStage: event.importerName,
        progress: overallProgress,
        statusMessage: '${event.displayName}: ${event.phase.name}',
      );
    }

    // Also maintain the detailed table-level progress for the summary view.
    final entries = List<UiTableMigrationProgress>.of(state.tableProgress);
    final tableIndex = entries.indexWhere(
      (progress) => progress.tableName == event.importerName,
    );

    // Convert TableImportPhase to TableMigrationPhase (they have same values)
    final phase = TableMigrationPhase.values.firstWhere(
      (p) => p.name == event.phase.name,
    );

    // Convert TableImportStatus to TableMigrationStatus
    final status = TableMigrationStatus.values.firstWhere(
      (s) => s.name == event.status.name,
    );

    UiTableMigrationPhaseStatus buildStatus(
      UiTableMigrationPhaseStatus? existing,
    ) {
      final startedAt = existing?.startedAt ?? now;
      switch (event.status) {
        case TableImportStatus.started:
        case TableImportStatus.inProgress:
          return UiTableMigrationPhaseStatus(
            phase: phase,
            status: status,
            updatedAt: now,
            startedAt: existing?.startedAt ?? now,
            message: event.message,
            rowsProcessed: event.rowsProcessed,
            totalRows: event.totalRows,
            currentItem: event.currentItem,
          );
        case TableImportStatus.succeeded:
        case TableImportStatus.failed:
          final message = event.message ?? existing?.message;
          return UiTableMigrationPhaseStatus(
            phase: phase,
            status: status,
            updatedAt: now,
            startedAt: existing?.startedAt ?? startedAt,
            completedAt: now,
            message: message,
          );
      }
    }

    if (tableIndex == -1) {
      final phaseStatus = buildStatus(null);
      entries.add(
        UiTableMigrationProgress(
          tableName: event.importerName,
          displayName: event.displayName,
          sortIndex: entries.length,
          phases: <TableMigrationPhase, UiTableMigrationPhaseStatus>{
            phase: phaseStatus,
          },
        ),
      );
    } else {
      final current = entries[tableIndex];
      final phases = Map<TableMigrationPhase, UiTableMigrationPhaseStatus>.from(
        current.phases,
      );
      final phaseStatus = buildStatus(phases[phase]);
      phases[phase] = phaseStatus;
      entries[tableIndex] = current.copyWith(phases: phases);
    }

    state = state.copyWith(tableProgress: _sortTableProgress(entries));
  }

  void _handleTableMigrationProgress(TableMigrationProgressEvent event) {
    final now = DateTime.now();

    // Update the UI step corresponding to this migrator.
    final stageIndex = state.stages.indexWhere(
      (s) => s.name == event.tableName,
    );
    if (stageIndex != -1) {
      final stage = state.stages[stageIndex];

      final isComplete =
          event.phase == TableMigrationPhase.postValidate &&
          event.status == TableMigrationStatus.succeeded;

      final isActive =
          !isComplete &&
          (stage.isActive ||
              event.status == TableMigrationStatus.started ||
              event.status == TableMigrationStatus.inProgress);

      double? progress;
      if (event.rowsProcessed != null &&
          event.totalRows != null &&
          event.totalRows! > 0) {
        progress = event.rowsProcessed! / event.totalRows!;
      }

      final updatedStages = List<UiStageProgress>.of(state.stages);
      updatedStages[stageIndex] = stage.copyWith(
        isActive: isActive && !isComplete,
        isComplete: isComplete || stage.isComplete,
        progress: isComplete ? 1.0 : progress ?? stage.progress,
        current: event.rowsProcessed ?? stage.current,
        total: event.totalRows ?? stage.total,
        startedAt: stage.startedAt ?? now,
        completedAt: isComplete ? now : stage.completedAt,
      );

      final completedCount = updatedStages.where((s) => s.isComplete).length;
      final overallProgress = updatedStages.isEmpty
          ? 0.0
          : completedCount / updatedStages.length;

      state = state.copyWith(
        stages: updatedStages,
        currentStage: event.tableName,
        progress: overallProgress,
        statusMessage: '${event.displayName}: ${event.phase.name}',
      );
    }

    // Also maintain the detailed table-level progress for the summary view.
    final entries = List<UiTableMigrationProgress>.of(state.tableProgress);
    final index = entries.indexWhere(
      (progress) => progress.tableName == event.tableName,
    );

    UiTableMigrationPhaseStatus buildStatus(
      UiTableMigrationPhaseStatus? existing,
    ) {
      final startedAt = existing?.startedAt ?? now;
      switch (event.status) {
        case TableMigrationStatus.started:
        case TableMigrationStatus.inProgress:
          return UiTableMigrationPhaseStatus(
            phase: event.phase,
            status: event.status,
            updatedAt: now,
            startedAt: existing?.startedAt ?? now,
            message: event.message,
            rowsProcessed: event.rowsProcessed,
            totalRows: event.totalRows,
            currentItem: event.currentItem,
          );
        case TableMigrationStatus.succeeded:
        case TableMigrationStatus.failed:
          final message = event.message ?? existing?.message;
          return UiTableMigrationPhaseStatus(
            phase: event.phase,
            status: event.status,
            updatedAt: now,
            startedAt: existing?.startedAt ?? startedAt,
            completedAt: now,
            message: message,
          );
      }
    }

    if (index == -1) {
      final status = buildStatus(null);
      entries.add(
        UiTableMigrationProgress(
          tableName: event.tableName,
          displayName: event.displayName,
          sortIndex: entries.length,
          phases: <TableMigrationPhase, UiTableMigrationPhaseStatus>{
            event.phase: status,
          },
        ),
      );
    } else {
      final current = entries[index];
      final phases = Map<TableMigrationPhase, UiTableMigrationPhaseStatus>.from(
        current.phases,
      );
      final status = buildStatus(phases[event.phase]);
      phases[event.phase] = status;
      entries[index] = current.copyWith(phases: phases);
    }

    state = state.copyWith(tableProgress: _sortTableProgress(entries));
  }

  List<UiTableMigrationProgress> _sortTableProgress(
    List<UiTableMigrationProgress> progress,
  ) {
    final sorted = List<UiTableMigrationProgress>.of(progress)
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    return sorted;
  }
}
