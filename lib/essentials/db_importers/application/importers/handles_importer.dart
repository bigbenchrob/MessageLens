import '../../../../../core/util/date_converter.dart';
import '../../../db/shared/handle_identifier_utils.dart';
import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class HandlesImporter extends BaseTableImporter {
  const HandlesImporter();

  @override
  String get name => 'handles';

  @override
  List<String> get dependsOn => const <String>[];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'handles-not-empty',
      'Handles table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final minRowId = ctx.previousMaxHandleRowId;
    final rows = await ctx.messagesDb.query(
      'handle',
      where: minRowId == null ? null : 'ROWID > ?',
      whereArgs: minRowId == null ? null : <Object>[minRowId],
      orderBy: 'ROWID ASC',
    );

    if (rows.isEmpty) {
      ctx.info('HandlesImporter: no new handles detected.');
      ctx.writeScratch('handles.inserted', 0);
      return;
    }

    var processed = 0;
    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final rawIdentifier = (row['id'] as String?)?.trim();
      final normalizedIdentifier = _normalizeIdentifier(rawIdentifier);
      final service = sanitizeHandleService(row['service'] as String?);
      final compoundIdentifier = buildCompoundIdentifier(
        normalizedIdentifier: normalizedIdentifier,
        rawIdentifier: rawIdentifier,
        service: service,
      );
      final country = (row['country'] as String?)?.trim();
      final lastSeen =
          DateConverter.toIntSafe(row['last_read_date']) ??
          DateConverter.toIntSafe(row['last_use']);
      final lastSeenUtc = DateConverter.appleToIsoString(lastSeen);

      await ctx.importDb.insertHandle(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        service: service,
        rawIdentifier: rawIdentifier ?? 'unknown',
        normalizedIdentifier: normalizedIdentifier,
        compoundIdentifier: compoundIdentifier,
        country: country,
        lastSeenUtc: lastSeenUtc,
        batchId: ctx.batchId,
      );

      processed += 1;
      if (processed % 200 == 0 || processed == rows.length) {
        ctx.info(
          'HandlesImporter: processed $processed/${rows.length} handles from chat.db',
        );
      }
    }

    ctx.writeScratch('handles.inserted', processed);
    if (rows.isNotEmpty) {
      final lastRowId = rows.last['ROWID'];
      if (lastRowId is int) {
        ctx.writeScratch('handles.lastSourceRowId', lastRowId);
      }
    }
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    await expectTrueOrThrow(
      ok: total > 0,
      errorCode: 'handles-empty',
      message: 'Handles table should contain rows after import.',
    );
  }
}

String? _normalizeIdentifier(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed.contains('@')) {
    return trimmed.toLowerCase();
  }
  final digits = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.isEmpty) {
    return null;
  }
  final normalized = digits.startsWith('+') ? digits.substring(1) : digits;
  if (normalized.length == 11 && normalized.startsWith('1')) {
    return normalized.substring(1);
  }
  return normalized;
}
