import '../../domain/base_table_importer.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';
import 'identifier_utils.dart';

class ContactChannelsImporter extends BaseTableImporter
    with RowProgressReporter {
  ContactChannelsImporter();

  @override
  String get name => 'contact_phone_email';

  @override
  List<String> get dependsOn => const <String>['contacts'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'contact-phone-email-not-empty',
      'Contact channel table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    var inserted = 0;

    // Pre-load valid contact Z_PKs so we can skip channels whose ZOWNER
    // doesn't match an imported contact (avoids FK violation).
    final importDb = await ctx.importDb.database;
    final contactRows = await importDb.query('contacts', columns: ['Z_PK']);
    final validOwners = <int>{};
    for (final r in contactRows) {
      final zpk = r['Z_PK'];
      if (zpk is int) {
        validOwners.add(zpk);
      }
    }

    // Collect row counts for combined progress
    final emailRows = await ctx.addressBookDb.query('ZABCDEMAILADDRESS');
    final phoneRows = await ctx.addressBookDb.query('ZABCDPHONENUMBER');
    final totalRows = emailRows.length + phoneRows.length;
    var overallProcessed = 0;
    var skippedOrphan = 0;

    // Process email rows
    for (final row in emailRows) {
      final owner = row['ZOWNER'] as int?;
      if (owner == null || !validOwners.contains(owner)) {
        if (owner != null) {
          skippedOrphan += 1;
        }
        overallProcessed += 1;
        continue;
      }

      final addressNormalized = _trim(row['ZADDRESSNORMALIZED']);
      final address = _trim(row['ZADDRESS']) ?? addressNormalized;
      if (address == null || address.isEmpty) {
        overallProcessed += 1;
        continue;
      }

      final normalized = address.toLowerCase();

      // INSERT OR IGNORE relies on UNIQUE(kind, value) — no existence check needed.
      await ctx.importDb.insertContactChannel(
        zOwner: owner,
        kind: 'email',
        value: normalized,
        label: _trim(row['ZLABEL']),
      );
      inserted += 1;
      overallProcessed += 1;

      if (overallProcessed % 200 == 0) {
        ctx.info(
          'ContactChannelsImporter: processed $overallProcessed/$totalRows '
          'rows (inserted $inserted)',
        );
        reportRowProgress(processed: overallProcessed, total: totalRows);
      }
    }

    // Process phone rows
    for (final row in phoneRows) {
      final owner = row['ZOWNER'] as int?;
      if (owner == null || !validOwners.contains(owner)) {
        if (owner != null) {
          skippedOrphan += 1;
        }
        overallProcessed += 1;
        continue;
      }

      final rawNumber = _trim(row['ZFULLNUMBER']) ?? _trim(row['ZVALUE']);
      if (rawNumber == null || rawNumber.isEmpty) {
        overallProcessed += 1;
        continue;
      }

      final normalized = normalizeIdentifier(rawNumber) ?? rawNumber;

      // INSERT OR IGNORE relies on UNIQUE(kind, value) — no existence check needed.
      await ctx.importDb.insertContactChannel(
        zOwner: owner,
        kind: 'phone',
        value: normalized,
        label: _trim(row['ZLABEL']),
      );
      inserted += 1;
      overallProcessed += 1;

      if (overallProcessed % 200 == 0 || overallProcessed == totalRows) {
        ctx.info(
          'ContactChannelsImporter: processed $overallProcessed/$totalRows '
          'rows (inserted $inserted)',
        );
        reportRowProgress(processed: overallProcessed, total: totalRows);
      }
    }

    // Final progress report if not already reported
    if (totalRows > 0 && overallProcessed % 200 != 0) {
      reportRowProgress(processed: overallProcessed, total: totalRows);
    }

    if (skippedOrphan > 0) {
      ctx.info(
        'ContactChannelsImporter: skipped $skippedOrphan channels '
        'with unknown ZOWNER (no matching contact).',
      );
    }

    ctx.writeScratch('contactChannels.inserted', inserted);
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    ctx.info(
      'ContactChannelsImporter: ledger now tracks $total contact channels.',
    );
  }
}

String? _trim(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
  return null;
}
