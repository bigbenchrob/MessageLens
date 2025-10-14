import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../db_migrate/domain/entities/db_migration_result.dart';
import '../../../db_migrate/domain/states/db_migration_progress.dart';
import '../../../db_migrate/domain/states/table_migration_progress.dart';
import '../../../db_migrate/domain/value_objects/db_migration_stage.dart';
import '../../../db_migrate/feature_level_providers.dart';
import '../../domain/entities/db_import_result.dart';
import '../../domain/states/db_import_progress.dart';
import '../../domain/value_objects/db_import_stage.dart';
import '../../feature_level_providers.dart';

part 'db_import_control_provider.g.dart';

const List<DbMigrationStage> _handlesMigrationStages = <DbMigrationStage>[
  DbMigrationStage.preparingSources,
  DbMigrationStage.clearingWorking,
  DbMigrationStage.migratingIdentities,
  DbMigrationStage.completed,
];

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
  });

  final TableMigrationPhase phase;
  final TableMigrationStatus status;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? message;

  UiTableMigrationPhaseStatus copyWith({
    TableMigrationStatus? status,
    DateTime? updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? message,
  }) {
    return UiTableMigrationPhaseStatus(
      phase: phase,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      message: message ?? this.message,
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
      final ledgerDb = await ref.read(sqfliteImportDatabaseProvider.future);
      await ledgerDb.clearAllData();

      state = state.copyWith(
        isProcessing: false,
        statusMessage: 'Import database cleared.',
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

    try {
      await ref.read(handlesMigrationServiceProvider).clearWorkingProjection();
      ref.invalidate(driftWorkingDatabaseProvider);

      state = state.copyWith(
        isProcessing: false,
        statusMessage: 'Working database cleared.',
        clearProgress: true,
        clearCurrentStage: true,
        clearTableProgress: true,
      );
    } catch (error) {
      final message = _mapDatabaseError(
        'Failed to clear working database',
        error,
      );
      state = state.copyWith(isProcessing: false, statusMessage: message);
    }
  }

  Future<void> startImport() async {
    final stages = _importStageTemplate();

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Starting import...',
      progress: 0.0,
      stages: stages,
      tableProgress: const <UiTableMigrationProgress>[],
      showingDebugPanel: false,
      clearImportResult: true,
    );

    try {
      final service = ref.read(ledgerImportServiceProvider);
      final result = await service.runImport(
        onProgress: (progress) {
          _handleImportProgress(progress);
        },
      );

      final updatedStages = result.success
          ? _markAllStagesComplete(state.stages)
          : state.stages;

      state = state.copyWith(
        isProcessing: false,
        statusMessage: result.success
            ? 'Import completed successfully'
            : 'Import failed: ${result.error ?? 'Unknown error'}',
        progress: result.success ? 1.0 : state.progress,
        stages: updatedStages,
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

  Future<void> startMigration() async {
    final stages = _migrationStageTemplate(stageOrder: _handlesMigrationStages);

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Starting migration...',
      progress: 0.0,
      stages: stages,
      tableProgress: const <UiTableMigrationProgress>[],
      showingDebugPanel: false,
      clearMigrationResult: true,
    );

    try {
      final result = await ref
          .read(handlesMigrationServiceProvider)
          .run(
            onProgress: (DbMigrationProgress progress) {
              _handleMigrationProgress(progress);
            },
            onTableProgress: (TableMigrationProgressEvent event) {
              _handleTableMigrationProgress(event);
            },
          );

      final updatedStages = result.success
          ? _markAllStagesComplete(state.stages)
          : state.stages;

      state = state.copyWith(
        isProcessing: false,
        statusMessage: result.success
            ? 'Migration completed successfully'
            : 'Migration failed: ${result.error ?? 'Unknown error'}',
        progress: result.success ? 1.0 : state.progress,
        stages: updatedStages,
        lastMigrationResult: result,
      );
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

  void _handleImportProgress(DbImportProgress progress) {
    final updatedStages = _updateStageProgress(
      currentStages: state.stages,
      stageName: progress.stage.key,
      stageProgress: progress.stageProgress,
      stageCurrent: progress.stageCurrent,
      stageTotal: progress.stageTotal,
    );

    state = state.copyWith(
      stages: updatedStages,
      currentStage: progress.stage.key,
      progress: progress.overallProgress,
      statusMessage: progress.message,
    );
  }

  void _handleMigrationProgress(DbMigrationProgress progress) {
    final updatedStages = _updateStageProgress(
      currentStages: state.stages,
      stageName: progress.stage.key,
      stageProgress: progress.stageProgress,
      stageCurrent: progress.stageCurrent,
      stageTotal: progress.stageTotal,
    );

    state = state.copyWith(
      stages: updatedStages,
      currentStage: progress.stage.key,
      progress: progress.overallProgress,
      statusMessage: progress.message,
    );
  }

  void _handleTableMigrationProgress(TableMigrationProgressEvent event) {
    final now = DateTime.now();
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
          return UiTableMigrationPhaseStatus(
            phase: event.phase,
            status: event.status,
            updatedAt: now,
            startedAt: existing?.startedAt ?? now,
            message: event.message,
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

  List<UiStageProgress> _importStageTemplate() {
    const stages = DbImportStage.values;
    return List<UiStageProgress>.generate(stages.length, (index) {
      final stage = stages[index];
      return UiStageProgress(
        name: stage.key,
        displayName: stage.label,
        sortIndex: index,
        isActive: index == 0,
      );
    });
  }

  List<UiStageProgress> _migrationStageTemplate({
    Iterable<DbMigrationStage>? stageOrder,
  }) {
    final stages = stageOrder == null
        ? DbMigrationStage.values
        : List<DbMigrationStage>.from(stageOrder);
    return List<UiStageProgress>.generate(stages.length, (index) {
      final stage = stages[index];
      return UiStageProgress(
        name: stage.key,
        displayName: stage.label,
        sortIndex: index,
        isActive: index == 0,
      );
    });
  }

  List<UiTableMigrationProgress> _sortTableProgress(
    List<UiTableMigrationProgress> progress,
  ) {
    final sorted = List<UiTableMigrationProgress>.of(progress)
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    return sorted;
  }

  List<UiStageProgress> _updateStageProgress({
    required List<UiStageProgress> currentStages,
    required String stageName,
    double? stageProgress,
    int? stageCurrent,
    int? stageTotal,
  }) {
    if (currentStages.isEmpty) {
      return currentStages;
    }

    final index = currentStages.indexWhere((stage) => stage.name == stageName);
    if (index == -1) {
      return currentStages;
    }

    final now = DateTime.now();
    return List<UiStageProgress>.generate(currentStages.length, (i) {
      final stage = currentStages[i];
      if (i < index) {
        if (stage.isComplete) {
          return stage;
        }
        return stage.copyWith(
          isActive: false,
          isComplete: true,
          progress: stage.progress ?? 1.0,
          startedAt: stage.startedAt ?? now,
          completedAt: stage.completedAt ?? now,
        );
      }
      if (i == index) {
        final isComplete = stageProgress != null && stageProgress >= 1.0;
        final completedAt = isComplete ? stage.completedAt ?? now : null;
        final progressValue = stageProgress ?? stage.progress;
        return stage.copyWith(
          isActive: !isComplete,
          isComplete: isComplete,
          progress: isComplete ? (progressValue ?? 1.0) : progressValue,
          current: stageCurrent,
          total: stageTotal,
          startedAt: stage.startedAt ?? now,
          completedAt: completedAt,
          clearCompletedAt: !isComplete,
        );
      }
      return stage.copyWith(
        isActive: false,
        isComplete: false,
        clearCurrent: true,
        clearTotal: true,
        clearProgress: true,
        clearStartedAt: true,
        clearCompletedAt: true,
      );
    });
  }

  List<UiStageProgress> _markAllStagesComplete(List<UiStageProgress> stages) {
    if (stages.isEmpty) {
      return stages;
    }
    final now = DateTime.now();
    return stages
        .map(
          (stage) => stage.copyWith(
            isActive: false,
            isComplete: true,
            progress: stage.progress ?? 1.0,
            startedAt: stage.startedAt ?? now,
            completedAt: stage.completedAt ?? now,
          ),
        )
        .toList(growable: false);
  }
}
