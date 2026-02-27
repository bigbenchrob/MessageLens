import '../../../domain/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class ProjectionStateMigrator extends BaseTableMigrator {
  const ProjectionStateMigrator();

  @override
  String get name => 'projection_state';

  @override
  List<String> get dependsOn => const ['messages', 'attachments'];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {
    final batchId = await _latestBatchId(ctx);
    await expectTrueOrThrow(
      ok: batchId != null,
      errorCode: 'PROJECTION_STATE_NO_BATCH',
      message: 'projection_state: import database contains no batches',
    );
    ctx.log('[projection_state] latest batch id=$batchId');
  }

  @override
  Future<void> copy(IMigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[projection_state] dry run – skipping copy');
      return;
    }

    final batchId = await _latestBatchId(ctx);
    if (batchId == null) {
      return;
    }

    final lastMessageId = await _maxId(ctx, 'messages', 'id');
    final lastAttachmentId = await _maxId(ctx, 'attachments', 'id');
    final timestamp = DateTime.now().toUtc().toIso8601String();

    await ctx.workingDb.customStatement(
      'INSERT OR REPLACE INTO projection_state '
      '(id, last_import_batch_id, last_projected_at_utc, '
      'last_projected_message_id, last_projected_attachment_id) '
      'VALUES (?, ?, ?, ?, ?)',
      <Object?>[1, batchId, timestamp, lastMessageId, lastAttachmentId],
    );

    ctx.log(
      '[projection_state] updated with batch $batchId, lastMessage=$lastMessageId, lastAttachment=$lastAttachmentId',
    );
  }

  @override
  Future<void> postValidate(IMigrationContext ctx) async {
    final rows = await ctx.workingDb
        .customSelect(
          'SELECT last_import_batch_id, last_projected_message_id, last_projected_attachment_id '
          'FROM projection_state WHERE id = 1',
        )
        .get();

    await expectTrueOrThrow(
      ok: rows.length == 1,
      errorCode: 'PROJECTION_STATE_ROW_MISSING',
      message: 'projection_state: expected singleton row with id=1',
    );

    final data = rows.first.data;
    final lastBatch = data['last_import_batch_id'] as int?;
    await expectTrueOrThrow(
      ok: lastBatch != null,
      errorCode: 'PROJECTION_STATE_BATCH_NULL',
      message: 'projection_state: last_import_batch_id is null',
    );
    ctx.log(
      '[projection_state] batch=$lastBatch lastMessage=${data['last_projected_message_id']} lastAttachment=${data['last_projected_attachment_id']}',
    );
  }

  Future<int?> _latestBatchId(IMigrationContext ctx) async {
    final rows = await ctx.importDb.database.then(
      (db) => db.query(
        'import_batches',
        columns: <String>['id'],
        orderBy: 'id DESC',
        limit: 1,
      ),
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first['id'];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  Future<int?> _maxId(IMigrationContext ctx, String table, String column) async {
    final rows = await ctx.workingDb
        .customSelect('SELECT MAX($column) AS m FROM $table')
        .get();
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first.data['m'];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }
}
