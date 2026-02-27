import '../../../../../core/util/date_converter.dart';

import '../../../domain/base_table_importer.dart';
import '../../sqlite/import_context_sqlite.dart';

class ContactsImporter extends BaseTableImporter {
  const ContactsImporter();

  @override
  String get name => 'contacts';

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
      'contacts-not-empty',
      'Contacts table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final rows = await ctx.addressBookDb.query('ZABCDRECORD');
    if (rows.isEmpty) {
      ctx.info('ContactsImporter: no contacts detected in AddressBook.');
      ctx.writeScratch('contacts.inserted', 0);
      return;
    }

    var processed = 0;
    var inserted = 0;

    for (final row in rows) {
      final recordId = row['Z_PK'] as int?;
      if (recordId == null) {
        processed += 1;
        continue;
      }

      final alreadyImported = await ctx.importDb.contactExists(recordId);
      if (alreadyImported) {
        processed += 1;
        if (processed % 200 == 0 || processed == rows.length) {
          ctx.info(
            'ContactsImporter: processed $processed/${rows.length} contacts '
            '(skipping existing entries)',
          );
        }
        continue;
      }

      final first = _trim(row['ZFIRSTNAME']);
      final middle = _trim(row['ZMIDDLENAME']);
      final last = _trim(row['ZLASTNAME']);
      final organization = _trim(row['ZORGANIZATION']);
      final nickname = _trim(row['ZNICKNAME']);

      final displayName = _buildContactDisplayName(
        firstName: first,
        middleName: middle,
        lastName: last,
        organization: organization,
      );
      final shortName = _buildShortName(
        nickname: nickname,
        firstName: first,
        organization: organization,
      );

      await ctx.importDb.insertContact(
        zPk: recordId,
        firstName: first,
        lastName: last,
        organization: organization,
        displayName: displayName,
        shortName: shortName,
        createdAtUtc: DateConverter.appleToIsoString(row['ZCREATIONDATE']),
        batchId: ctx.batchId,
      );

      inserted += 1;
      processed += 1;

      if (processed % 200 == 0 || processed == rows.length) {
        ctx.info(
          'ContactsImporter: processed $processed/${rows.length} contacts '
          '(inserted $inserted)',
        );
      }
    }

    ctx.writeScratch('contacts.inserted', inserted);
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    await expectTrueOrThrow(
      ok: total > 0,
      errorCode: 'contacts-empty',
      message: 'Contacts table should contain rows after import.',
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

String _buildContactDisplayName({
  String? firstName,
  String? middleName,
  String? lastName,
  String? organization,
}) {
  final parts = <String>[
    if (firstName != null) firstName,
    if (middleName != null) middleName,
    if (lastName != null) lastName,
  ];

  if (parts.isNotEmpty) {
    return parts.join(' ');
  }

  if (organization != null) {
    return organization;
  }

  return 'Unknown Contact';
}

String? _buildShortName({
  String? nickname,
  String? firstName,
  String? organization,
}) {
  if (nickname != null && nickname.isNotEmpty) {
    return nickname;
  }
  if (firstName != null && firstName.isNotEmpty) {
    return firstName;
  }
  if (organization != null && organization.isNotEmpty) {
    return organization;
  }
  return null;
}
