import '../../domain/base_table_migrator.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

class MessageReadMarksMigrator extends BaseTableMigrator {
  const MessageReadMarksMigrator();

  @override
  String get name => 'message_read_marks';

  @override
  List<String> get dependsOn => const ['messages'];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {
    final messagesWithReadAt = await ctx.workingDb.customSelect('''
      SELECT COUNT(*) AS c
      FROM messages
      WHERE read_at_utc IS NOT NULL AND LENGTH(TRIM(read_at_utc)) > 0;
    ''').get();
    final candidates = _extractCount(messagesWithReadAt, 'c');
    ctx.log('[message_read_marks] messages with read_at_utc=$candidates');
  }

  @override
  Future<void> copy(IMigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[message_read_marks] dry run – skipping copy');
      return;
    }

    await ctx.workingDb.transaction(() async {
      await ctx.workingDb.customStatement('DELETE FROM message_read_marks');
      await ctx.workingDb.customStatement('''
        INSERT INTO message_read_marks (message_guid, marked_at_utc)
        SELECT guid, read_at_utc
        FROM messages
        WHERE read_at_utc IS NOT NULL AND LENGTH(TRIM(read_at_utc)) > 0;
      ''');
    });

    final inserted = await count(ctx.workingDb, 'message_read_marks');
    ctx.log('[message_read_marks] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(IMigrationContext ctx) async {
    final expectedRows = await ctx.workingDb.customSelect('''
      SELECT COUNT(*) AS c
      FROM messages
      WHERE read_at_utc IS NOT NULL AND LENGTH(TRIM(read_at_utc)) > 0;
    ''').get();
    final expected = _extractCount(expectedRows, 'c');
    final projected = await count(ctx.workingDb, 'message_read_marks');
    ctx.log('[message_read_marks] expected=$expected projected=$projected');

    if (ctx.incrementalMode) {
      await expectTrueOrThrow(
        ok: projected >= expected,
        errorCode: 'MESSAGE_READ_MARKS_INCREMENTAL_UNDERCOUNT',
        message:
            'message_read_marks: working has $projected rows but expected >= $expected',
      );
    } else {
      await expectTrueOrThrow(
        ok: projected == expected,
        errorCode: 'MESSAGE_READ_MARKS_ROW_MISMATCH',
        message:
            'message_read_marks: working has $projected rows but expected $expected',
      );
    }
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
