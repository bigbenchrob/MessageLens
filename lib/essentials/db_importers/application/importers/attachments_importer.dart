import '../../../../../core/util/date_converter.dart';
import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class AttachmentsImporter extends BaseTableImporter {
  const AttachmentsImporter();

  @override
  String get name => 'attachments';

  @override
  List<String> get dependsOn => const <String>['messages'];

  @override
  Future<void> validatePrereqs(ImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'attachments-not-empty',
      'Attachments table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(ImportContext ctx) async {
    final minRowId = ctx.previousMaxAttachmentRowId;
    final sql = StringBuffer()
      ..writeln('SELECT')
      ..writeln('  attachment.ROWID AS source_rowid,')
      ..writeln('  attachment.guid,')
      ..writeln('  attachment.transfer_name,')
      ..writeln('  attachment.uti,')
      ..writeln('  attachment.mime_type,')
      ..writeln('  attachment.total_bytes,')
      ..writeln('  attachment.is_sticker,')
      ..writeln('  attachment.is_outgoing,')
      ..writeln('  attachment.created_date,')
      ..writeln('  attachment.filename')
      ..writeln('FROM attachment');
    final args = <Object>[];
    if (minRowId != null) {
      sql.writeln('WHERE attachment.ROWID > ?');
      args.add(minRowId);
    }

    final rows = await ctx.messagesDb.rawQuery(sql.toString(), args);
    if (rows.isEmpty) {
      ctx.info('AttachmentsImporter: no new attachments detected.');
      ctx.writeScratch('attachments.inserted', 0);
      ctx.writeScratch('attachments.insertedIds', <int>[]);
      return;
    }

    var processed = 0;
    var inserted = 0;
    final insertedIds = <int>{};

    for (final row in rows) {
      final sourceRowId = row['source_rowid'] as int?;
      final result = await ctx.importDb.insertAttachment(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        guid: row['guid'] as String?,
        transferName: row['transfer_name'] as String?,
        uti: row['uti'] as String?,
        mimeType: row['mime_type'] as String?,
        totalBytes: (row['total_bytes'] as num?)?.toInt(),
        isSticker: (row['is_sticker'] as int? ?? 0) == 1,
        isOutgoing: _nullableBool(row['is_outgoing'] as int?),
        createdAtUtc: DateConverter.appleToIsoString(row['created_date']),
        localPath: row['filename'] as String?,
        batchId: ctx.batchId,
      );

      if (result > 0 && sourceRowId != null) {
        inserted += 1;
        insertedIds.add(sourceRowId);
      }

      processed += 1;
      if (processed % 200 == 0 || processed == rows.length) {
        ctx.info(
          'AttachmentsImporter: processed $processed/${rows.length} '
          'attachments (inserted $inserted)',
        );
      }
    }

    ctx.writeScratch('attachments.inserted', inserted);
    ctx.writeScratch('attachments.insertedIds', insertedIds.toList());

    if (rows.isNotEmpty) {
      final lastRowId = rows.last['source_rowid'];
      if (lastRowId is int) {
        ctx.writeScratch('attachments.lastSourceRowId', lastRowId);
      }
    }
  }

  @override
  Future<void> postValidate(ImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    ctx.info('AttachmentsImporter: ledger now tracks $total attachments.');
  }
}

bool? _nullableBool(int? value) {
  if (value == null) {
    return null;
  }
  if (value == 1) {
    return true;
  }
  if (value == 0) {
    return false;
  }
  return null;
}
