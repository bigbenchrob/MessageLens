import '../../domain/base_table_importer.dart';
import '../../domain/i_importers.dart/table_importer.dart';
import '../../domain/states/table_import_progress.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

/// Executes table-level importers in dependency order, dispatching phase-level
/// updates so callers can surface granular progress information.
class ImportOrchestrator {
  ImportOrchestrator(List<TableImporter> importers)
    : _importers = List<TableImporter>.unmodifiable(importers);

  final List<TableImporter> _importers;

  Future<void> run(
    IImportContext ctx, {
    TableImportProgressCallback? onTableProgress,
  }) async {
    final ordered = _sorted();

    ctx.info('Preparing import ledger...');
    ctx.info('Execution order: ${ordered.map((m) => m.name).join(' -> ')}');

    for (final importer in ordered) {
      final phaseStamp = DateTime.now().toIso8601String();
      ctx.info('=== [$phaseStamp] ${importer.name} :: validatePrereqs ===');
      await _runPhase(
        ctx: ctx,
        importer: importer,
        phase: TableImportPhase.validatePrereqs,
        action: () => importer.validatePrereqs(ctx),
        onTableProgress: onTableProgress,
      );

      if (!ctx.dryRun) {
        ctx.info('=== ${importer.name} :: copy ===');
        await _runPhase(
          ctx: ctx,
          importer: importer,
          phase: TableImportPhase.copy,
          action: () => importer.copy(ctx),
          onTableProgress: onTableProgress,
        );
      } else {
        ctx.info('=== ${importer.name} :: copy (skipped, dryRun) ===');
      }

      ctx.info('=== ${importer.name} :: postValidate ===');
      await _runPhase(
        ctx: ctx,
        importer: importer,
        phase: TableImportPhase.postValidate,
        action: () => importer.postValidate(ctx),
        onTableProgress: onTableProgress,
      );
    }

    ctx.info('Import orchestration complete.');
  }

  List<TableImporter> _sorted() {
    final byName = <String, TableImporter>{
      for (final importer in _importers) importer.name: importer,
    };

    final indegree = <String, int>{};
    final graph = <String, List<String>>{};

    for (final importer in _importers) {
      indegree.putIfAbsent(importer.name, () => 0);
      for (final dep in importer.dependsOn) {
        graph.putIfAbsent(dep, () => <String>[]).add(importer.name);
        indegree[importer.name] = (indegree[importer.name] ?? 0) + 1;
      }
    }

    final queue = <String>[
      ...indegree.entries
          .where((entry) => entry.value == 0)
          .map((entry) => entry.key),
    ];
    final order = <TableImporter>[];

    while (queue.isNotEmpty) {
      final name = queue.removeLast();
      final importer = byName[name];
      if (importer == null) {
        continue;
      }
      order.add(importer);
      for (final next in graph[name] ?? const <String>[]) {
        indegree[next] = (indegree[next] ?? 0) - 1;
        if (indegree[next] == 0) {
          queue.add(next);
        }
      }
    }

    if (order.length != _importers.length) {
      throw StateError('Cycle detected in importer dependencies.');
    }

    return order;
  }

  Future<void> _runPhase({
    required IImportContext ctx,
    required TableImporter importer,
    required TableImportPhase phase,
    required Future<void> Function() action,
    TableImportProgressCallback? onTableProgress,
  }) async {
    final displayName = _displayNameFor(importer);

    onTableProgress?.call(
      TableImportProgressEvent(
        importerName: importer.name,
        displayName: displayName,
        phase: phase,
        status: TableImportStatus.started,
      ),
    );

    try {
      await action();
      onTableProgress?.call(
        TableImportProgressEvent(
          importerName: importer.name,
          displayName: displayName,
          phase: phase,
          status: TableImportStatus.succeeded,
        ),
      );
    } catch (error) {
      ctx.info('[${importer.name}] phase $phase failed: $error');
      onTableProgress?.call(
        TableImportProgressEvent(
          importerName: importer.name,
          displayName: displayName,
          phase: phase,
          status: TableImportStatus.failed,
          message: error.toString(),
        ),
      );
      rethrow;
    }
  }
}

String _displayNameFor(TableImporter importer) {
  if (importer is BaseTableImporter) {
    return importer.displayName;
  }
  return _humanizeName(importer.name);
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
