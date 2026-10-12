import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
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
          final projection = projectSourceContact(
            sourcePrimaryKey: row['Z_PK'],
            rawFirstName: row['ZFIRSTNAME'],
            rawMiddleName: row['ZMIDDLENAME'],
            rawLastName: row['ZLASTNAME'],
            rawOrganization: row['ZORGANIZATION'],
            rawCreationDate: row['ZCREATIONDATE'],
            sourceId: sourceId,
            batchId: batchId,
          );
          if (projection is OmittedSourceContact) {
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
          final projectedContact = projection as ProjectedSourceContact;
          validContactRowIds.add(projectedContact.sourceRowId);

          if (projectedContact.enrichmentUnavailable) {
            contactEnrichmentUnavailableCount += 1;
          }
          final insertedId = await txn.insertIgnore(
            'contacts',
            projectedContact.ledgerValues,
          );
          if (insertedId != 0) {
            insertedContactCount += 1;
          }
          completedContactCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.contacts,
            completedWorkCount: completedContactCount,
            totalWorkCount: contactRows.length,
            lastCompletedSourceRowId: projectedContact.sourceRowId,
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
          final projection = projectSourceContactChannel(
            rawOwner: row['ZOWNER'],
            rawPrimaryValue: row['ZADDRESS'],
            rawFallbackValue: row['ZADDRESSNORMALIZED'],
            rawLabel: row['ZLABEL'],
            kind: ContactChannelKind.email,
            importedContactSourceRowIds: validContactRowIds,
            sourceId: sourceId,
            batchId: batchId,
          );
          if (projection is OmittedSourceContactChannel) {
            omittedContactChannelCount += 1;
            completedEmailCount += 1;
            publishSourceImportProgress(
              observer: onProgress,
              unit: SourceImportWorkUnit.contactEmailChannels,
              completedWorkCount: completedEmailCount,
              totalWorkCount: emailRows.length,
              lastCompletedSourceRowId: projection.sourceContactRowId,
              anomalyCounts: SourceImportAnomalyCounts(
                omittedContactRecordCount: omittedContactRecordCount,
                contactEnrichmentUnavailableCount:
                    contactEnrichmentUnavailableCount,
                omittedContactChannelCount: omittedContactChannelCount,
              ),
            );
            continue;
          }
          final projectedChannel = projection as ProjectedSourceContactChannel;
          final insertedId = await txn.insertIgnore(
            'contact_channels',
            projectedChannel.ledgerValues,
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
            lastCompletedSourceRowId: projectedChannel.sourceContactRowId,
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
          final projection = projectSourceContactChannel(
            rawOwner: row['ZOWNER'],
            rawPrimaryValue: row['ZFULLNUMBER'],
            rawFallbackValue: row['ZVALUE'],
            rawLabel: row['ZLABEL'],
            kind: ContactChannelKind.phone,
            importedContactSourceRowIds: validContactRowIds,
            sourceId: sourceId,
            batchId: batchId,
          );
          if (projection is OmittedSourceContactChannel) {
            omittedContactChannelCount += 1;
            completedPhoneCount += 1;
            publishSourceImportProgress(
              observer: onProgress,
              unit: SourceImportWorkUnit.contactPhoneChannels,
              completedWorkCount: completedPhoneCount,
              totalWorkCount: phoneRows.length,
              lastCompletedSourceRowId: projection.sourceContactRowId,
              anomalyCounts: SourceImportAnomalyCounts(
                omittedContactRecordCount: omittedContactRecordCount,
                contactEnrichmentUnavailableCount:
                    contactEnrichmentUnavailableCount,
                omittedContactChannelCount: omittedContactChannelCount,
              ),
            );
            continue;
          }
          final projectedChannel = projection as ProjectedSourceContactChannel;
          final insertedId = await txn.insertIgnore(
            'contact_channels',
            projectedChannel.ledgerValues,
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
            lastCompletedSourceRowId: projectedChannel.sourceContactRowId,
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
}
