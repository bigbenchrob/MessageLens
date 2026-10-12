import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/contacts/contact_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('canonical contact source projection', () {
    test('projects every persisted contact column from explicit inputs', () {
      final result = projectSourceContact(
        sourcePrimaryKey: 101,
        rawFirstName: '  Ada ',
        rawMiddleName: ' M ',
        rawLastName: ' Lovelace  ',
        rawOrganization: ' Engine Society ',
        rawCreationDate: 1,
        sourceId: 7,
        batchId: 11,
      );

      expect(result, isA<ProjectedSourceContact>());
      final projected = result as ProjectedSourceContact;
      expect(projected.enrichmentUnavailable, isFalse);
      expect(projected.ledgerValues, <String, Object?>{
        'ss_id': SourceScopedRowKey.pack(sourceId: 7, sourceRowId: 101),
        'source_id': 7,
        'source_rowid': 101,
        'display_name': 'Ada M Lovelace',
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'organization': 'Engine Society',
        'created_at_utc': '2001-01-01T00:00:01.000Z',
        'batch_id': 11,
      });
      expect(
        () => projected.ledgerValues['display_name'] = 'Changed',
        throwsUnsupportedError,
      );
    });

    test('preserves organization and unknown-name fallback behavior', () {
      final organizationOnly =
          projectSourceContact(
                sourcePrimaryKey: 102.0,
                rawFirstName: ' ',
                rawMiddleName: null,
                rawLastName: null,
                rawOrganization: '  Analytical Engines  ',
                rawCreationDate: 0,
                sourceId: 7,
                batchId: 11,
              )
              as ProjectedSourceContact;
      final unknown =
          projectSourceContact(
                sourcePrimaryKey: 103,
                rawFirstName: 123,
                rawMiddleName: '',
                rawLastName: null,
                rawOrganization: ' ',
                rawCreationDate: null,
                sourceId: 7,
                batchId: 11,
              )
              as ProjectedSourceContact;

      expect(organizationOnly.displayName, 'Analytical Engines');
      expect(organizationOnly.createdAtUtc, isNull);
      expect(organizationOnly.enrichmentUnavailable, isFalse);
      expect(unknown.displayName, 'Unknown Contact');
      expect(unknown.firstName, isNull);
      expect(unknown.lastName, isNull);
      expect(unknown.organization, isNull);
      expect(unknown.createdAtUtc, isNull);
      expect(unknown.enrichmentUnavailable, isTrue);
    });

    test('returns a typed omission for an invalid primary key', () {
      final result = projectSourceContact(
        sourcePrimaryKey: 'invalid',
        rawFirstName: 'Ignored',
        rawMiddleName: null,
        rawLastName: null,
        rawOrganization: null,
        rawCreationDate: null,
        sourceId: 7,
        batchId: 11,
      );

      expect(result, isA<OmittedSourceContact>());
      expect(
        (result as OmittedSourceContact).reason,
        ContactSourceOmissionReason.invalidSourcePrimaryKey,
      );
    });

    test('keeps SourceScopedRowKey as the packed identity authority', () {
      expect(
        () => projectSourceContact(
          sourcePrimaryKey: 1,
          rawFirstName: 'Out',
          rawMiddleName: null,
          rawLastName: 'Of Range',
          rawOrganization: null,
          rawCreationDate: null,
          sourceId: 0,
          batchId: 1,
        ),
        throwsRangeError,
      );
    });
  });

  group('canonical contact-channel source projection', () {
    test('projects normalized email and exact lineage columns', () {
      final result = projectSourceContactChannel(
        rawOwner: 101,
        rawPrimaryValue: ' Ada@Example.COM ',
        rawFallbackValue: 'ignored@example.com',
        rawLabel: ' home ',
        kind: ContactChannelKind.email,
        importedContactSourceRowIds: <int>{101},
        sourceId: 7,
        batchId: 11,
      );

      expect(result, isA<ProjectedSourceContactChannel>());
      final projected = result as ProjectedSourceContactChannel;
      expect(projected.ledgerValues, <String, Object?>{
        'source_id': 7,
        'source_contact_rowid': 101,
        'contact_ss_id': SourceScopedRowKey.pack(sourceId: 7, sourceRowId: 101),
        'kind': 'email',
        'value': 'ada@example.com',
        'label': 'home',
        'batch_id': 11,
      });
    });

    test('preserves email fallback and phone raw fallback behavior', () {
      final email =
          projectSourceContactChannel(
                rawOwner: 101,
                rawPrimaryValue: null,
                rawFallbackValue: ' Normalized@Example.COM ',
                rawLabel: null,
                kind: ContactChannelKind.email,
                importedContactSourceRowIds: <int>{101},
                sourceId: 7,
                batchId: 11,
              )
              as ProjectedSourceContactChannel;
      final normalizedPhone =
          projectSourceContactChannel(
                rawOwner: 101,
                rawPrimaryValue: '+1 (604) 555-0100',
                rawFallbackValue: null,
                rawLabel: ' mobile ',
                kind: ContactChannelKind.phone,
                importedContactSourceRowIds: <int>{101},
                sourceId: 7,
                batchId: 11,
              )
              as ProjectedSourceContactChannel;
      final rawPhone =
          projectSourceContactChannel(
                rawOwner: 101,
                rawPrimaryValue: ' extension only ',
                rawFallbackValue: null,
                rawLabel: ' work ',
                kind: ContactChannelKind.phone,
                importedContactSourceRowIds: <int>{101},
                sourceId: 7,
                batchId: 11,
              )
              as ProjectedSourceContactChannel;
      final extensionPhone =
          projectSourceContactChannel(
                rawOwner: 101,
                rawPrimaryValue: ' ',
                rawFallbackValue: ' +1 250 555 0101 x9 ',
                rawLabel: ' ',
                kind: ContactChannelKind.phone,
                importedContactSourceRowIds: <int>{101},
                sourceId: 7,
                batchId: 11,
              )
              as ProjectedSourceContactChannel;

      expect(email.value, 'normalized@example.com');
      expect(normalizedPhone.value, '6045550100');
      expect(normalizedPhone.label, 'mobile');
      expect(rawPhone.value, 'extension only');
      expect(rawPhone.label, 'work');
      expect(extensionPhone.value, '125055501019');
      expect(extensionPhone.label, isNull);
    });

    test('returns explicit owner and value omission decisions', () {
      final invalidOwner =
          projectSourceContactChannel(
                rawOwner: 'invalid',
                rawPrimaryValue: 'valid@example.com',
                rawFallbackValue: null,
                rawLabel: null,
                kind: ContactChannelKind.email,
                importedContactSourceRowIds: <int>{101},
                sourceId: 7,
                batchId: 11,
              )
              as OmittedSourceContactChannel;
      final absentOwner =
          projectSourceContactChannel(
                rawOwner: 999,
                rawPrimaryValue: 'valid@example.com',
                rawFallbackValue: null,
                rawLabel: null,
                kind: ContactChannelKind.email,
                importedContactSourceRowIds: <int>{101},
                sourceId: 7,
                batchId: 11,
              )
              as OmittedSourceContactChannel;
      final missingValue =
          projectSourceContactChannel(
                rawOwner: 101,
                rawPrimaryValue: ' ',
                rawFallbackValue: null,
                rawLabel: 'ignored',
                kind: ContactChannelKind.phone,
                importedContactSourceRowIds: <int>{101},
                sourceId: 7,
                batchId: 11,
              )
              as OmittedSourceContactChannel;

      expect(
        invalidOwner.reason,
        ContactChannelSourceOmissionReason.invalidOwner,
      );
      expect(invalidOwner.sourceContactRowId, isNull);
      expect(
        absentOwner.reason,
        ContactChannelSourceOmissionReason.ownerNotImported,
      );
      expect(absentOwner.sourceContactRowId, 999);
      expect(
        missingValue.reason,
        ContactChannelSourceOmissionReason.missingValue,
      );
      expect(missingValue.sourceContactRowId, 101);
    });

    test(
      'ignores irrelevant owner-set context but honors material identity',
      () {
        ProjectedSourceContactChannel project({
          required Set<int> importedIds,
          required int sourceId,
          required int batchId,
        }) {
          return projectSourceContactChannel(
                rawOwner: 101,
                rawPrimaryValue: 'same@example.com',
                rawFallbackValue: null,
                rawLabel: 'same',
                kind: ContactChannelKind.email,
                importedContactSourceRowIds: importedIds,
                sourceId: sourceId,
                batchId: batchId,
              )
              as ProjectedSourceContactChannel;
        }

        final minimalContext = project(
          importedIds: <int>{101},
          sourceId: 7,
          batchId: 11,
        );
        final irrelevantAdditionalOwner = project(
          importedIds: <int>{101, 777},
          sourceId: 7,
          batchId: 11,
        );
        final differentIdentity = project(
          importedIds: <int>{101},
          sourceId: 8,
          batchId: 12,
        );

        expect(
          irrelevantAdditionalOwner.ledgerValues,
          minimalContext.ledgerValues,
        );
        expect(
          differentIdentity.contactSsId,
          isNot(minimalContext.contactSsId),
        );
        expect(differentIdentity.sourceId, 8);
        expect(differentIdentity.batchId, 12);
      },
    );
  });
}
