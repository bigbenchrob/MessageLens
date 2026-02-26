import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class ContactChannelsImporter extends BaseTableImporter {
  const ContactChannelsImporter();

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

    Future<void> importEmailRows() async {
      final rows = await ctx.addressBookDb.query('ZABCDEMAILADDRESS');
      if (rows.isEmpty) {
        return;
      }
      var processed = 0;
      for (final row in rows) {
        final owner = row['ZOWNER'] as int?;
        if (owner == null) {
          processed += 1;
          continue;
        }

        final addressNormalized = _trim(row['ZADDRESSNORMALIZED']);
        final address = _trim(row['ZADDRESS']) ?? addressNormalized;
        if (address == null || address.isEmpty) {
          processed += 1;
          continue;
        }

        final normalized = address.toLowerCase();
        final alreadyImported = await ctx.importDb.contactChannelExists(
          kind: 'email',
          value: normalized,
        );
        if (alreadyImported) {
          processed += 1;
          continue;
        }

        await ctx.importDb.insertContactChannel(
          zOwner: owner,
          kind: 'email',
          value: normalized,
          label: _trim(row['ZLABEL']),
        );
        inserted += 1;
        processed += 1;

        if (processed % 200 == 0 || processed == rows.length) {
          ctx.info(
            'ContactChannelsImporter: processed $processed/${rows.length} '
            'email rows (inserted $inserted)',
          );
        }
      }
    }

    Future<void> importPhoneRows() async {
      final rows = await ctx.addressBookDb.query('ZABCDPHONENUMBER');
      if (rows.isEmpty) {
        return;
      }
      var processed = 0;
      for (final row in rows) {
        final owner = row['ZOWNER'] as int?;
        if (owner == null) {
          processed += 1;
          continue;
        }

        final rawNumber = _trim(row['ZFULLNUMBER']) ?? _trim(row['ZVALUE']);
        if (rawNumber == null || rawNumber.isEmpty) {
          processed += 1;
          continue;
        }

        final normalized = _normalizeIdentifier(rawNumber) ?? rawNumber;
        final alreadyImported = await ctx.importDb.contactChannelExists(
          kind: 'phone',
          value: normalized,
        );
        if (alreadyImported) {
          processed += 1;
          continue;
        }

        await ctx.importDb.insertContactChannel(
          zOwner: owner,
          kind: 'phone',
          value: normalized,
          label: _trim(row['ZLABEL']),
        );
        inserted += 1;
        processed += 1;

        if (processed % 200 == 0 || processed == rows.length) {
          ctx.info(
            'ContactChannelsImporter: processed $processed/${rows.length} '
            'phone rows (inserted $inserted)',
          );
        }
      }
    }

    await importEmailRows();
    await importPhoneRows();

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
