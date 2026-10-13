import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/attachments/attachment_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('canonical Attachments source projection', () {
    test('projects every persisted attachment column from source facts', () {
      final createdDate = DateConverter.dateString2Apple('2026-08-16');
      final projection = projectSourceAttachment(
        input: AttachmentSourceProjectionInput(
          sourceRowId: 101,
          guid: 'attachment-guid',
          filename: '/raw/source/path/photo.jpg',
          transferName: 'photo.jpg',
          uti: 'public.jpeg',
          mimeType: 'image/jpeg',
          totalBytes: 1234,
          createdDate: createdDate,
          createdAt: null,
        ),
        sourceId: 7,
        batchId: 11,
      );

      expect(projection.sourceRowId, 101);
      expect(projection.metadataDegraded, isFalse);
      expect(projection.ledgerValues, <String, Object?>{
        'ss_id': SourceScopedRowKey.pack(sourceId: 7, sourceRowId: 101),
        'source_id': 7,
        'source_rowid': 101,
        'guid': 'attachment-guid',
        'filename': '/raw/source/path/photo.jpg',
        'transfer_name': 'photo.jpg',
        'uti': 'public.jpeg',
        'mime_type': 'image/jpeg',
        'total_bytes': 1234,
        'created_at_utc': DateConverter.appleToIsoString(createdDate),
        'batch_id': 11,
      });
      expect(
        () => projection.ledgerValues['guid'] = 'changed',
        throwsUnsupportedError,
      );
    });

    test('preserves exact nullable metadata and degraded-fact behavior', () {
      final cases =
          <
            ({
              Object? guid,
              Object? filename,
              Object? transferName,
              Object? uti,
              Object? mimeType,
              bool expectedDegraded,
              List<Object?> expectedValues,
            })
          >[
            (
              guid: '',
              filename: null,
              transferName: '',
              uti: 17,
              mimeType: false,
              expectedDegraded: true,
              expectedValues: <Object?>[null, null, null, null, null],
            ),
            (
              guid: '   ',
              filename: '',
              transferName: null,
              uti: null,
              mimeType: null,
              expectedDegraded: false,
              expectedValues: <Object?>['   ', null, null, null, null],
            ),
            (
              guid: '添付-📎',
              filename: '/原資料/写真 📷.heic',
              transferName: '写真 📷.heic',
              uti: 'public.heic',
              mimeType: 'image/heic',
              expectedDegraded: false,
              expectedValues: <Object?>[
                '添付-📎',
                '/原資料/写真 📷.heic',
                '写真 📷.heic',
                'public.heic',
                'image/heic',
              ],
            ),
          ];

      for (var index = 0; index < cases.length; index += 1) {
        final current = cases[index];
        final projected = projectSourceAttachment(
          input: AttachmentSourceProjectionInput(
            sourceRowId: index + 1,
            guid: current.guid,
            filename: current.filename,
            transferName: current.transferName,
            uti: current.uti,
            mimeType: current.mimeType,
            totalBytes: null,
            createdDate: null,
            createdAt: null,
          ),
          sourceId: 3,
          batchId: 5,
        );

        expect(projected.metadataDegraded, current.expectedDegraded);
        expect(<Object?>[
          projected.ledgerValues['guid'],
          projected.ledgerValues['filename'],
          projected.ledgerValues['transfer_name'],
          projected.ledgerValues['uti'],
          projected.ledgerValues['mime_type'],
        ], current.expectedValues);
      }
    });

    test('preserves numeric coercion and boundary source identities', () {
      final rounded = projectSourceAttachment(
        input: const AttachmentSourceProjectionInput(
          sourceRowId: 2.4,
          guid: 'rounded',
          filename: null,
          transferName: null,
          uti: null,
          mimeType: null,
          totalBytes: 12.6,
          createdDate: null,
          createdAt: null,
        ),
        sourceId: 1,
        batchId: 1,
      );
      final boundary = projectSourceAttachment(
        input: const AttachmentSourceProjectionInput(
          sourceRowId: SourceScopedRowKey.maxSourceRowId,
          guid: 'boundary',
          filename: null,
          transferName: null,
          uti: null,
          mimeType: null,
          totalBytes: 9223372036854775807,
          createdDate: null,
          createdAt: null,
        ),
        sourceId: SourceScopedRowKey.maxSourceId,
        batchId: 1,
      );
      final invalidNumber = projectSourceAttachment(
        input: const AttachmentSourceProjectionInput(
          sourceRowId: 3,
          guid: 'invalid-number',
          filename: null,
          transferName: null,
          uti: null,
          mimeType: null,
          totalBytes: 'unknown',
          createdDate: null,
          createdAt: null,
        ),
        sourceId: 1,
        batchId: 1,
      );

      expect(rounded.sourceRowId, 2);
      expect(rounded.ledgerValues['total_bytes'], 13);
      expect(
        boundary.ledgerValues['ss_id'],
        SourceScopedRowKey.pack(
          sourceId: SourceScopedRowKey.maxSourceId,
          sourceRowId: SourceScopedRowKey.maxSourceRowId,
        ),
      );
      expect(boundary.ledgerValues['total_bytes'], 9223372036854775807);
      expect(invalidNumber.ledgerValues['total_bytes'], isNull);
    });

    test('uses created_date first and created_at only as exact fallback', () {
      final oldAppleSeconds = DateConverter.apple2CoreTS(
        DateConverter.dateString2Apple('2012-07-25'),
      );
      final modernAppleNanoseconds = DateConverter.dateString2Apple(
        '2026-08-16',
      );
      final cases =
          <({Object? createdDate, Object? createdAt, String? expected})>[
            (
              createdDate: modernAppleNanoseconds,
              createdAt: oldAppleSeconds,
              expected: DateConverter.appleToIsoString(modernAppleNanoseconds),
            ),
            (
              createdDate: 0,
              createdAt: oldAppleSeconds,
              expected: DateConverter.appleToIsoString(oldAppleSeconds),
            ),
            (
              createdDate: 'invalid',
              createdAt: modernAppleNanoseconds.toDouble(),
              expected: DateConverter.appleToIsoString(modernAppleNanoseconds),
            ),
            (createdDate: null, createdAt: null, expected: null),
          ];

      for (var index = 0; index < cases.length; index += 1) {
        final current = cases[index];
        final projected = projectSourceAttachment(
          input: AttachmentSourceProjectionInput(
            sourceRowId: index + 1,
            guid: 'attachment-${index + 1}',
            filename: null,
            transferName: null,
            uti: null,
            mimeType: null,
            totalBytes: null,
            createdDate: current.createdDate,
            createdAt: current.createdAt,
          ),
          sourceId: 3,
          batchId: 5,
        );

        expect(projected.ledgerValues['created_at_utc'], current.expected);
      }
    });

    test('retains required identity and shared packed-key validation', () {
      expect(
        () => projectSourceAttachment(
          input: const AttachmentSourceProjectionInput(
            sourceRowId: null,
            guid: null,
            filename: null,
            transferName: null,
            uti: null,
            mimeType: null,
            totalBytes: null,
            createdDate: null,
            createdAt: null,
          ),
          sourceId: 3,
          batchId: 5,
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'attachment.source_rowid is required',
          ),
        ),
      );
      expect(
        () => projectSourceAttachment(
          input: const AttachmentSourceProjectionInput(
            sourceRowId: 0,
            guid: null,
            filename: null,
            transferName: null,
            uti: null,
            mimeType: null,
            totalBytes: null,
            createdDate: null,
            createdAt: null,
          ),
          sourceId: 3,
          batchId: 5,
        ),
        throwsRangeError,
      );
      expect(
        () => projectSourceAttachment(
          input: const AttachmentSourceProjectionInput(
            sourceRowId: 1,
            guid: null,
            filename: null,
            transferName: null,
            uti: null,
            mimeType: null,
            totalBytes: null,
            createdDate: null,
            createdAt: null,
          ),
          sourceId: 0,
          batchId: 5,
        ),
        throwsRangeError,
      );
    });

    test('captures only the actual attachment source-query fields', () {
      final input =
          AttachmentSourceProjectionInput.fromSourceRow(<String, Object?>{
            'source_rowid': 101.4,
            'guid': 'attachment-guid',
            'filename': '/raw/path',
            'transfer_name': 'name',
            'uti': 'public.data',
            'mime_type': 'application/octet-stream',
            'total_bytes': 44,
            'created_date': 808531200000000000,
            'created_at': 364867200,
            'ignored_source_column': 'not projected',
          });

      expect(input.sourceRowId, 101.4);
      expect(input.requiredSourceRowId, 101);
      expect(input.guid, 'attachment-guid');
      expect(input.filename, '/raw/path');
      expect(input.transferName, 'name');
      expect(input.uti, 'public.data');
      expect(input.mimeType, 'application/octet-stream');
      expect(input.totalBytes, 44);
      expect(input.createdDate, 808531200000000000);
      expect(input.createdAt, 364867200);
    });

    test('responds only to material source-projection inputs', () {
      final baselineRow = <String, Object?>{
        'source_rowid': 101,
        'guid': 'attachment-guid',
        'filename': '/raw/path',
        'transfer_name': 'name',
        'uti': 'public.data',
        'mime_type': 'application/octet-stream',
        'total_bytes': 44,
        'created_date': 808531200000000000,
        'created_at': 364867200,
        'ignored_source_column': 'first value',
      };

      ProjectedSourceAttachment project(Map<String, Object?> row) {
        return projectSourceAttachment(
          input: AttachmentSourceProjectionInput.fromSourceRow(row),
          sourceId: 3,
          batchId: 5,
        );
      }

      final baseline = project(baselineRow);
      final irrelevantChange = project(<String, Object?>{
        ...baselineRow,
        'ignored_source_column': 'different value',
      });
      final materialChange = project(<String, Object?>{
        ...baselineRow,
        'filename': '/different/raw/path',
      });

      expect(irrelevantChange.ledgerValues, baseline.ledgerValues);
      expect(irrelevantChange.metadataDegraded, baseline.metadataDegraded);
      expect(materialChange.ledgerValues, isNot(baseline.ledgerValues));
      expect(materialChange.ledgerValues['filename'], '/different/raw/path');
    });

    test('does not infer payload, archive, relationship, or graph facts', () {
      final projection = projectSourceAttachment(
        input: const AttachmentSourceProjectionInput(
          sourceRowId: 1,
          guid: 'attachment-guid',
          filename: '/raw/source/path/photo.jpg',
          transferName: 'photo.jpg',
          uti: 'public.jpeg',
          mimeType: 'image/jpeg',
          totalBytes: 1234,
          createdDate: null,
          createdAt: null,
        ),
        sourceId: 3,
        batchId: 5,
      );

      expect(projection.ledgerValues.keys, <String>[
        'ss_id',
        'source_id',
        'source_rowid',
        'guid',
        'filename',
        'transfer_name',
        'uti',
        'mime_type',
        'total_bytes',
        'created_at_utc',
        'batch_id',
      ]);
      expect(projection.ledgerValues.keys, isNot(contains('payload_exists')));
      expect(projection.ledgerValues.keys, isNot(contains('archive_path')));
      expect(projection.ledgerValues.keys, isNot(contains('message_ss_id')));
    });
  });
}
