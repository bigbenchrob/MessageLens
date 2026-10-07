import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
import '../../domain/source_scoped_row_key.dart';
import '../source_import_work_progress.dart';
import 'contact_source_projection.dart';

class ContactImportResult {
  const ContactImportResult({
    required this.examinedContactCount,
    required this.insertedContactCount,
    required this.insertedChannelCount,
    this.anomalyCounts = SourceImportAnomalyCounts.empty,
  });

  final int examinedContactCount;
  final int insertedContactCount;
  final int insertedChannelCount;
  final SourceImportAnomalyCounts anomalyCounts;
}

class ContactImporter {
  const ContactImporter({
    required this.addressBookDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveAddressBookSourceId,
  });

  final String addressBookDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<ContactImportResult> importContacts({
    SourceImportWorkObserver? onProgress,
  }) async {
    final sourceDb = await sourceDatabaseOpener.openReadOnly(addressBookDbPath);
    final batchId = await importLedger.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );

    try {
      final contactRows = await sourceDb.query(
        'ZABCDRECORD',
        orderBy: 'Z_PK ASC',
      );
      final emailRows = await sourceDb.query(
        'ZABCDEMAILADDRESS',
        orderBy: 'ZOWNER ASC, ZADDRESS ASC',
      );
      final phoneRows = await sourceDb.query(
        'ZABCDPHONENUMBER',
        orderBy: 'ZOWNER ASC, ZFULLNUMBER ASC',
      );

      var insertedContactCount = 0;
      var insertedChannelCount = 0;
      var completedContactCount = 0;
      var completedEmailCount = 0;
      var completedPhoneCount = 0;
      var omittedContactRecordCount = 0;
      var contactEnrichmentUnavailableCount = 0;
      var omittedContactChannelCount = 0;
      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.contacts,
        completedWorkCount: 0,
        totalWorkCount: contactRows.length,
      );
      await importLedger.writeTransaction((txn) async {
        final validContactRowIds = <int>{};
        for (final row in contactRows) {
          final sourceRowId = _readNullableInt(row['Z_PK']);
          if (sourceRowId == null) {
            omittedContactRecordCount += 1;
            completedContactCount += 1;
            publishSourceImportProgress(
              observer: onProgress,
              unit: SourceImportWorkUnit.contacts,
              completedWorkCount: completedContactCount,
              totalWorkCount: contactRows.length,
              anomalyCounts: SourceImportAnomalyCounts(
                omittedContactRecordCount: omittedContactRecordCount,
              ),
            );
            continue;
          }
          validContactRowIds.add(sourceRowId);

          final first = readTrimmedContactSourceText(row['ZFIRSTNAME']);
          final middle = readTrimmedContactSourceText(row['ZMIDDLENAME']);
          final last = readTrimmedContactSourceText(row['ZLASTNAME']);
          final organization = readTrimmedContactSourceText(
            row['ZORGANIZATION'],
          );
          final displayName = buildContactDisplayName(
            firstName: first,
            middleName: middle,
            lastName: last,
            organization: organization,
          );
          if (displayName == null) {
            contactEnrichmentUnavailableCount += 1;
          }
          final insertedId = await txn
              .insertIgnore('contacts', <String, Object?>{
                'ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceRowId,
                ),
                'source_id': sourceId,
                'source_rowid': sourceRowId,
                'display_name': displayName ?? 'Unknown Contact',
                'first_name': first,
                'last_name': last,
                'organization': organization,
                'created_at_utc': projectContactCreatedAtUtc(
                  row['ZCREATIONDATE'],
                ),
                'batch_id': batchId,
              });
          if (insertedId != 0) {
            insertedContactCount += 1;
          }
          completedContactCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.contacts,
            completedWorkCount: completedContactCount,
            totalWorkCount: contactRows.length,
            lastCompletedSourceRowId: sourceRowId,
            anomalyCounts: SourceImportAnomalyCounts(
              omittedContactRecordCount: omittedContactRecordCount,
              contactEnrichmentUnavailableCount:
                  contactEnrichmentUnavailableCount,
            ),
          );
        }

        publishSourceImportProgress(
          observer: onProgress,
          unit: SourceImportWorkUnit.contactEmailChannels,
          completedWorkCount: 0,
          totalWorkCount: emailRows.length,
        );
        for (final row in emailRows) {
          final owner = _readNullableInt(row['ZOWNER']);
          final address = projectContactEmailAddress(row);
          if (owner == null ||
              !validContactRowIds.contains(owner) ||
              address == null) {
            omittedContactChannelCount += 1;
            completedEmailCount += 1;
            publishSourceImportProgress(
              observer: onProgress,
              unit: SourceImportWorkUnit.contactEmailChannels,
              completedWorkCount: completedEmailCount,
              totalWorkCount: emailRows.length,
              lastCompletedSourceRowId: owner,
              anomalyCounts: SourceImportAnomalyCounts(
                omittedContactRecordCount: omittedContactRecordCount,
                contactEnrichmentUnavailableCount:
                    contactEnrichmentUnavailableCount,
                omittedContactChannelCount: omittedContactChannelCount,
              ),
            );
            continue;
          }
          final insertedId = await _insertChannel(
            txn,
            sourceContactRowId: owner,
            kind: 'email',
            value: address,
            label: readTrimmedContactSourceText(row['ZLABEL']),
            batchId: batchId,
          );
          if (insertedId != 0) {
            insertedChannelCount += 1;
          }
          completedEmailCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.contactEmailChannels,
            completedWorkCount: completedEmailCount,
            totalWorkCount: emailRows.length,
            lastCompletedSourceRowId: owner,
            anomalyCounts: SourceImportAnomalyCounts(
              omittedContactRecordCount: omittedContactRecordCount,
              contactEnrichmentUnavailableCount:
                  contactEnrichmentUnavailableCount,
              omittedContactChannelCount: omittedContactChannelCount,
            ),
          );
        }

        publishSourceImportProgress(
          observer: onProgress,
          unit: SourceImportWorkUnit.contactPhoneChannels,
          completedWorkCount: 0,
          totalWorkCount: phoneRows.length,
        );
        for (final row in phoneRows) {
          final owner = _readNullableInt(row['ZOWNER']);
          final projectedNumber = projectContactPhoneNumber(row);
          if (owner == null ||
              !validContactRowIds.contains(owner) ||
              projectedNumber == null) {
            omittedContactChannelCount += 1;
            completedPhoneCount += 1;
            publishSourceImportProgress(
              observer: onProgress,
              unit: SourceImportWorkUnit.contactPhoneChannels,
              completedWorkCount: completedPhoneCount,
              totalWorkCount: phoneRows.length,
              lastCompletedSourceRowId: owner,
              anomalyCounts: SourceImportAnomalyCounts(
                omittedContactRecordCount: omittedContactRecordCount,
                contactEnrichmentUnavailableCount:
                    contactEnrichmentUnavailableCount,
                omittedContactChannelCount: omittedContactChannelCount,
              ),
            );
            continue;
          }
          final insertedId = await _insertChannel(
            txn,
            sourceContactRowId: owner,
            kind: 'phone',
            value: projectedNumber,
            label: readTrimmedContactSourceText(row['ZLABEL']),
            batchId: batchId,
          );
          if (insertedId != 0) {
            insertedChannelCount += 1;
          }
          completedPhoneCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.contactPhoneChannels,
            completedWorkCount: completedPhoneCount,
            totalWorkCount: phoneRows.length,
            lastCompletedSourceRowId: owner,
            anomalyCounts: SourceImportAnomalyCounts(
              omittedContactRecordCount: omittedContactRecordCount,
              contactEnrichmentUnavailableCount:
                  contactEnrichmentUnavailableCount,
              omittedContactChannelCount: omittedContactChannelCount,
            ),
          );
        }
      });

      return ContactImportResult(
        examinedContactCount: contactRows.length,
        insertedContactCount: insertedContactCount,
        insertedChannelCount: insertedChannelCount,
        anomalyCounts: SourceImportAnomalyCounts(
          omittedContactRecordCount: omittedContactRecordCount,
          contactEnrichmentUnavailableCount: contactEnrichmentUnavailableCount,
          omittedContactChannelCount: omittedContactChannelCount,
        ),
      );
    } finally {
      await sourceDb.close();
    }
  }

  Future<int> _insertChannel(
    ImportLedgerWriteTransaction txn, {
    required int sourceContactRowId,
    required String kind,
    required String value,
    required int batchId,
    String? label,
  }) {
    return txn.insertIgnore('contact_channels', <String, Object?>{
      'source_id': sourceId,
      'source_contact_rowid': sourceContactRowId,
      'contact_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceContactRowId,
      ),
      'kind': kind,
      'value': value,
      'label': label,
      'batch_id': batchId,
    });
  }
}

int? _readNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return null;
}
