import '../../domain/i_migrators.dart/table_migrator.dart';
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
        if (indeg[nxt] == 0) q.add(nxt);
      }
    }
    if (order.length != _migrators.length) {
      throw StateError('Cycle in migrator dependencies.');
    }
    return order;
  }

  Future<void> run(MigrationContext ctx) async {
    ctx.log('Preparing working DB…');
    await _prepareWorking(ctx);

    final ordered = _sorted();
    ctx.log('Execution order: ${ordered.map((m) => m.name).join(" → ")}');

    for (final m in ordered) {
      final stamp = DateTime.now().toIso8601String();
      ctx.log('=== [$stamp] ${m.name} :: validatePrereqs ===');
      await m.validatePrereqs(ctx);

      if (!ctx.dryRun) {
        ctx.log('=== ${m.name} :: copy ===');
        await m.copy(ctx);
      } else {
        ctx.log('=== ${m.name} :: copy (skipped, dryRun) ===');
      }

      ctx.log('=== ${m.name} :: postValidate ===');
      await m.postValidate(ctx);
    }

    ctx.log('Migration complete.');
  }

  Future<void> _prepareWorking(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('Dry-run: skipping truncate.');
      return;
    }

    // Enforce FK, make it predictable.
    await ctx.workingDb.customStatement('PRAGMA foreign_keys = ON');

    // Truncate in reverse dependency order to avoid FK errors.
    // You can compute reverse of _sorted() names and DELETE in that order.
    // Example for brevity:
    final tables = [
      'chat_to_handle',
      'messages',
      'attachments',
      'chats',
      'handles',
    ];
    for (final t in tables) {
      ctx.workingDb.customSelect('DELETE FROM $t');
    }
  }
}
