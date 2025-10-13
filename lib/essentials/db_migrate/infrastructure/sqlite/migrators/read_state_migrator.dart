import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class ReadStateMigrator extends BaseTableMigrator {
  const ReadStateMigrator();

  @override
  String get name => 'read_state';

  @override
  List<String> get dependsOn => const ['chats', 'messages'];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    final chatCount = await count(ctx.workingDb, 'chats');
    ctx.log('[read_state] projected chats=$chatCount');
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[read_state] dry run – skipping copy');
      return;
    }

    await ctx.workingDb.transaction(() async {
      await ctx.workingDb.customStatement('DELETE FROM read_state');
      await ctx.workingDb.customStatement('''
        INSERT INTO read_state (chat_id, last_read_at_utc)
        SELECT chat_id, MAX(read_at_utc)
        FROM messages
        WHERE read_at_utc IS NOT NULL AND LENGTH(TRIM(read_at_utc)) > 0
        GROUP BY chat_id;
      ''');
    });

    final inserted = await count(ctx.workingDb, 'read_state');
    ctx.log('[read_state] inserted $inserted row(s)');
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    final expectedRows = await ctx.workingDb
        .customSelect('''
      SELECT COUNT(*) AS c FROM (
        SELECT chat_id
        FROM messages
        WHERE read_at_utc IS NOT NULL AND LENGTH(TRIM(read_at_utc)) > 0
        GROUP BY chat_id
      ) grouped;
    ''')
        .get();
    final expected = _extractCount(expectedRows, 'c');
    final projected = await count(ctx.workingDb, 'read_state');
    ctx.log('[read_state] expected=$expected projected=$projected');

    await expectTrueOrThrow(
      projected == expected,
      'READ_STATE_ROW_MISMATCH',
      'read_state: working has $projected rows but expected $expected',
    );
  }

  int _extractCount(List<dynamic> rows, String key) {
    if (rows.isEmpty) {
      return 0;
    }
    final first = rows.first;
    if (first is Map<String, Object?>) {
      return _coerceToInt(first[key]);
    }
    final data = (first as dynamic).data as Map<String, Object?>;
    return _coerceToInt(data[key]);
  }

  int _coerceToInt(Object? value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.parse(value.toString());
  }
}
