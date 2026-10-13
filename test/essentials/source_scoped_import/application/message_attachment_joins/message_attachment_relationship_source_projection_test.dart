import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/message_attachment_joins/message_attachment_relationship_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  test('projects the exact seven-field canonical relationship ledger row', () {
    const sourceId = 37;
    const batchId = 43;
    const input = MessageAttachmentRelationshipSourceProjectionInput(
      sourceMessageRowId: 13,
      sourceAttachmentRowId: 21,
    );

    final projected = projectSourceMessageAttachmentRelationship(
      input,
      sourceId,
      batchId,
    );

    expect(projected.sourceMessageRowId, 13);
    expect(projected.sourceAttachmentRowId, 21);
    expect(projected.ledgerValues.keys.toList(), <String>[
      'message_source_id',
      'attachment_source_id',
      'source_message_rowid',
      'source_attachment_rowid',
      'message_ss_id',
      'attachment_ss_id',
      'batch_id',
    ]);
    expect(projected.ledgerValues, <String, Object?>{
      'message_source_id': sourceId,
      'attachment_source_id': sourceId,
      'source_message_rowid': 13,
      'source_attachment_rowid': 21,
      'message_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: 13,
      ),
      'attachment_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: 21,
      ),
      'batch_id': batchId,
    });
    expect(
      () => projected.ledgerValues['source_message_rowid'] = 999,
      throwsUnsupportedError,
    );
  });

  test('preserves production int and rounded-double coercion', () {
    final input =
        MessageAttachmentRelationshipSourceProjectionInput.fromSourceRow(
          <String, Object?>{'message_id': 10.4, 'attachment_id': 20.6},
        );

    final projected = projectSourceMessageAttachmentRelationship(input, 5, 7);

    expect(projected.sourceMessageRowId, 10);
    expect(projected.sourceAttachmentRowId, 21);
  });

  test('preserves exact required-field failure semantics', () {
    for (final malformed
        in <
          ({
            MessageAttachmentRelationshipSourceProjectionInput input,
            String field,
          })
        >[
          (
            input: const MessageAttachmentRelationshipSourceProjectionInput(
              sourceMessageRowId: 'bad',
              sourceAttachmentRowId: 2,
            ),
            field: 'message_id',
          ),
          (
            input: const MessageAttachmentRelationshipSourceProjectionInput(
              sourceMessageRowId: 1,
              sourceAttachmentRowId: null,
            ),
            field: 'attachment_id',
          ),
        ]) {
      expect(
        () => projectSourceMessageAttachmentRelationship(malformed.input, 1, 2),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'message_attachment_join.${malformed.field} is required',
          ),
        ),
      );
    }
  });

  test('identical endpoint facts have identical relationship identity', () {
    const first = MessageAttachmentRelationshipSourceProjectionInput(
      sourceMessageRowId: 7,
      sourceAttachmentRowId: 9,
    );
    const second = MessageAttachmentRelationshipSourceProjectionInput(
      sourceMessageRowId: 7,
      sourceAttachmentRowId: 9,
    );

    final firstProjected = projectSourceMessageAttachmentRelationship(
      first,
      3,
      11,
    );
    final secondProjected = projectSourceMessageAttachmentRelationship(
      second,
      3,
      11,
    );

    expect(secondProjected.ledgerValues, firstProjected.ledgerValues);
  });

  test(
    'packs live and non-live endpoints with one source and batch lineage',
    () {
      const input = MessageAttachmentRelationshipSourceProjectionInput(
        sourceMessageRowId: 23,
        sourceAttachmentRowId: 29,
      );

      for (final sourceId in <int>[liveChatDbSourceId, 37]) {
        final projected = projectSourceMessageAttachmentRelationship(
          input,
          sourceId,
          47,
        );

        expect(projected.ledgerValues['message_source_id'], sourceId);
        expect(projected.ledgerValues['attachment_source_id'], sourceId);
        expect(projected.ledgerValues['batch_id'], 47);
        expect(
          projected.ledgerValues['message_ss_id'],
          SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 23),
        );
        expect(
          projected.ledgerValues['attachment_ss_id'],
          SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 29),
        );
      }
    },
  );

  test('preserves shared packed-key bounds and rejects invalid bounds', () {
    final lower = projectSourceMessageAttachmentRelationship(
      const MessageAttachmentRelationshipSourceProjectionInput(
        sourceMessageRowId: 1,
        sourceAttachmentRowId: 1,
      ),
      1,
      3,
    );
    final upper = projectSourceMessageAttachmentRelationship(
      const MessageAttachmentRelationshipSourceProjectionInput(
        sourceMessageRowId: SourceScopedRowKey.maxSourceRowId,
        sourceAttachmentRowId: SourceScopedRowKey.maxSourceRowId,
      ),
      SourceScopedRowKey.maxSourceId,
      5,
    );

    expect(
      lower.ledgerValues['message_ss_id'],
      1 << SourceScopedRowKey.sourceRowIdBits | 1,
    );
    expect(upper.ledgerValues['attachment_ss_id'], 0x7FFFFFFFFFFFFFFF);

    for (final invalidSourceId in <int>[
      0,
      SourceScopedRowKey.maxSourceId + 1,
    ]) {
      expect(
        () => projectSourceMessageAttachmentRelationship(
          const MessageAttachmentRelationshipSourceProjectionInput(
            sourceMessageRowId: 1,
            sourceAttachmentRowId: 1,
          ),
          invalidSourceId,
          7,
        ),
        throwsRangeError,
      );
    }

    for (final invalidRowId in <int>[
      0,
      SourceScopedRowKey.maxSourceRowId + 1,
    ]) {
      for (final input in <MessageAttachmentRelationshipSourceProjectionInput>[
        MessageAttachmentRelationshipSourceProjectionInput(
          sourceMessageRowId: invalidRowId,
          sourceAttachmentRowId: 1,
        ),
        MessageAttachmentRelationshipSourceProjectionInput(
          sourceMessageRowId: 1,
          sourceAttachmentRowId: invalidRowId,
        ),
      ]) {
        expect(
          () => projectSourceMessageAttachmentRelationship(input, 1, 11),
          throwsRangeError,
        );
      }
    }
  });

  test('ignores non-endpoint context and maps each material fact', () {
    final baselineInput =
        MessageAttachmentRelationshipSourceProjectionInput.fromSourceRow(
          <String, Object?>{
            'source_rowid': 31,
            'message_id': 37,
            'attachment_id': 41,
            'existing_message_rowid': 370,
            'existing_attachment_rowid': 410,
            'irrelevant_context': ' first ',
          },
        );
    final contextOnlyInput =
        MessageAttachmentRelationshipSourceProjectionInput.fromSourceRow(
          <String, Object?>{
            'source_rowid': 999,
            'message_id': 37,
            'attachment_id': 41,
            'existing_message_rowid': null,
            'existing_attachment_rowid': null,
            'irrelevant_context': '   ',
          },
        );
    final baseline = projectSourceMessageAttachmentRelationship(
      baselineInput,
      43,
      47,
    );
    final contextOnly = projectSourceMessageAttachmentRelationship(
      contextOnlyInput,
      43,
      47,
    );

    expect(contextOnly.ledgerValues, baseline.ledgerValues);

    final changedMessage = projectSourceMessageAttachmentRelationship(
      const MessageAttachmentRelationshipSourceProjectionInput(
        sourceMessageRowId: 38,
        sourceAttachmentRowId: 41,
      ),
      43,
      47,
    );
    expect(changedMessage.ledgerValues['source_message_rowid'], 38);
    expect(changedMessage.ledgerValues, isNot(baseline.ledgerValues));

    final changedAttachment = projectSourceMessageAttachmentRelationship(
      const MessageAttachmentRelationshipSourceProjectionInput(
        sourceMessageRowId: 37,
        sourceAttachmentRowId: 42,
      ),
      43,
      47,
    );
    expect(changedAttachment.ledgerValues['source_attachment_rowid'], 42);
    expect(changedAttachment.ledgerValues, isNot(baseline.ledgerValues));

    final changedSource = projectSourceMessageAttachmentRelationship(
      baselineInput,
      44,
      47,
    );
    expect(changedSource.ledgerValues['message_source_id'], 44);
    expect(changedSource.ledgerValues['attachment_source_id'], 44);
    expect(changedSource.ledgerValues, isNot(baseline.ledgerValues));

    final changedBatch = projectSourceMessageAttachmentRelationship(
      baselineInput,
      43,
      48,
    );
    expect(changedBatch.ledgerValues['batch_id'], 48);
    expect(changedBatch.ledgerValues, isNot(baseline.ledgerValues));
  });
}
