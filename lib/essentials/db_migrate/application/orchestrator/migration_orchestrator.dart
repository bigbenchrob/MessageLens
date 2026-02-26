import '../../domain/base_table_migrator.dart';
import '../../domain/i_migrators.dart/table_migrator.dart';
import '../../domain/states/table_migration_progress.dart';
import '../../domain/value_objects/db_migration_stage.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

class MigrationOrchestrator {
  final List<TableMigrator> _migrators;
  MigrationOrchestrator(this._migrators);

  List<TableMigrator> _sorted() {
    // Kahn’s algorithm over (name -> dependsOn)
    final byName = {for (final m in _migrators) m.name: m};
    final indeg = <String, int>{};
    final graph = <String, List<String>>{};
    for (final m in _migrators) {
      indeg.putIfAbsent(m.name, () => 0);
      for (final dep in m.dependsOn) {
        graph.putIfAbsent(dep, () => []).add(m.name);
        indeg[m.name] = (indeg[m.name] ?? 0) + 1;
      }
    }
    final q = <String>[...indeg.keys.where((k) => indeg[k] == 0)];
    final order = <TableMigrator>[];
    while (q.isNotEmpty) {
      final n = q.removeLast();
      order.add(byName[n]!);
      for (final nxt in graph[n] ?? const <String>[]) {
        indeg[nxt] = (indeg[nxt] ?? 0) - 1;
        if (indeg[nxt] == 0) {
          q.add(nxt);
        }
      }
    }
    if (order.length != _migrators.length) {
      throw StateError('Cycle in migrator dependencies.');
    }
    return order;
  }

  Future<void> run(
    MigrationContext ctx, {
    TableMigrationProgressCallback? onTableProgress,
  }) async {
    final ordered = _sorted();

    ctx.log('Preparing working DB…');
    await _prepareWorking(ctx, ordered);

    ctx.log('Execution order: ${ordered.map((m) => m.name).join(" → ")}');

    for (final migrator in ordered) {
      final stamp = DateTime.now().toIso8601String();
      ctx.log('=== [$stamp] ${migrator.name} :: validatePrereqs ===');
      await _runPhase(
        ctx: ctx,
        migrator: migrator,
        phase: TableMigrationPhase.validatePrereqs,
        action: () => migrator.validatePrereqs(ctx),
        onTableProgress: onTableProgress,
      );

      if (!ctx.dryRun) {
        ctx.log('=== ${migrator.name} :: copy ===');
        await _runPhase(
          ctx: ctx,
          migrator: migrator,
          phase: TableMigrationPhase.copy,
          action: () => migrator.copy(ctx),
          onTableProgress: onTableProgress,
        );
      } else {
        ctx.log('=== ${migrator.name} :: copy (skipped, dryRun) ===');
      }

      ctx.log('=== ${migrator.name} :: postValidate ===');
      await _runPhase(
        ctx: ctx,
        migrator: migrator,
        phase: TableMigrationPhase.postValidate,
        action: () => migrator.postValidate(ctx),
        onTableProgress: onTableProgress,
      );
    }

    ctx.log('Migration complete.');
  }

  Future<void> _prepareWorking(
    MigrationContext ctx,
    List<TableMigrator> ordered,
  ) async {
    if (ctx.dryRun) {
      ctx.log('Dry-run: skipping truncate.');
      return;
    }

    await ctx.workingDb.customStatement('PRAGMA foreign_keys = ON');

    if (ctx.incrementalMode) {
      ctx.log('Incremental mode: skipping table truncation.');
      return;
    }

    final tables = <String>{};
    for (final migrator in ordered) {
      if (migrator is BaseTableMigrator) {
        tables.addAll(migrator.targetTables);
      } else {
        tables.add(migrator.name);
      }
    }

    final truncateOrder = tables.toList().reversed;
    for (final table in truncateOrder) {
      ctx.log('Clearing working table `$table`…');
      await ctx.workingDb.customStatement('DELETE FROM $table');
    }
  }

  Future<void> _runPhase({
    required MigrationContext ctx,
    required TableMigrator migrator,
    required TableMigrationPhase phase,
    required Future<void> Function() action,
    TableMigrationProgressCallback? onTableProgress,
  }) async {
    final displayName = _displayNameFor(migrator);
    final stage = _stageForPhase(phase);
    final phaseLabel = '${migrator.name}::$phase';

    onTableProgress?.call(
      TableMigrationProgressEvent(
        tableName: migrator.name,
        displayName: displayName,
        phase: phase,
        status: TableMigrationStatus.started,
        stage: stage,
      ),
    );

    try {
      await ctx.ensureImportReady('$phaseLabel (preflight)');
      await action();
      await ctx.ensureImportClean('$phaseLabel (postflight)');
      onTableProgress?.call(
        TableMigrationProgressEvent(
          tableName: migrator.name,
          displayName: displayName,
          phase: phase,
          status: TableMigrationStatus.succeeded,
          stage: stage,
        ),
      );
    } catch (error) {
      ctx.log('[${migrator.name}] phase $phase failed: $error');
      try {
        await ctx.ensureImportClean('$phaseLabel (cleanup)');
      } catch (cleanupError) {
        ctx.log(
          '[${migrator.name}] phase $phase cleanup failed: $cleanupError',
        );
      }
      onTableProgress?.call(
        TableMigrationProgressEvent(
          tableName: migrator.name,
          displayName: displayName,
          phase: phase,
          status: TableMigrationStatus.failed,
          message: error.toString(),
          stage: stage,
        ),
      );
      rethrow;
    }
  }
}

DbMigrationStage _stageForPhase(TableMigrationPhase phase) {
  switch (phase) {
    case TableMigrationPhase.validatePrereqs:
      return DbMigrationStage.migratingIdentities;
    case TableMigrationPhase.copy:
      return DbMigrationStage.migratingIdentities;
    case TableMigrationPhase.postValidate:
      return DbMigrationStage.migratingIdentities;
  }
}

String _displayNameFor(TableMigrator migrator) {
  if (migrator is BaseTableMigrator) {
    return migrator.displayName;
  }
  return _humanizeName(migrator.name);
}

String _humanizeName(String raw) {
  if (raw.isEmpty) {
    return raw;
  }
  return raw
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
