import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_relationship_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  test('projects the exact six-field canonical relationship ledger row', () {
    const sourceId = 37;
    const batchId = 43;
    const input = ChatHandleRelationshipSourceProjectionInput(
      sourceChatRowId: 13,
      sourceHandleRowId: 21,
    );

    final projected = projectSourceChatHandleRelationship(
      input,
      sourceId,
      batchId,
    );

    expect(projected.sourceChatRowId, 13);
    expect(projected.sourceHandleRowId, 21);
    expect(projected.ledgerValues.keys.toList(), <String>[
      'source_id',
      'source_chat_rowid',
      'source_handle_rowid',
      'chat_ss_id',
      'handle_ss_id',
      'batch_id',
    ]);
    expect(projected.ledgerValues, <String, Object?>{
      'source_id': sourceId,
      'source_chat_rowid': 13,
      'source_handle_rowid': 21,
      'chat_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: 13,
      ),
      'handle_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: 21,
      ),
      'batch_id': batchId,
    });
    expect(
      () => projected.ledgerValues['source_chat_rowid'] = 999,
      throwsUnsupportedError,
    );
  });

  test('preserves production int and rounded-double coercion', () {
    final input = ChatHandleRelationshipSourceProjectionInput.fromSourceRow(
      <String, Object?>{'chat_id': 10.4, 'handle_id': 20.6},
    );

    final projected = projectSourceChatHandleRelationship(input, 5, 7);

    expect(projected.sourceChatRowId, 10);
    expect(projected.sourceHandleRowId, 21);
  });

  test('preserves exact required-field failure semantics', () {
    for (final malformed
        in <
          ({ChatHandleRelationshipSourceProjectionInput input, String field})
        >[
          (
            input: const ChatHandleRelationshipSourceProjectionInput(
              sourceChatRowId: 'bad',
              sourceHandleRowId: 2,
            ),
            field: 'chat_id',
          ),
          (
            input: const ChatHandleRelationshipSourceProjectionInput(
              sourceChatRowId: 1,
              sourceHandleRowId: null,
            ),
            field: 'handle_id',
          ),
        ]) {
      expect(
        () => projectSourceChatHandleRelationship(malformed.input, 1, 2),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'chat_handle_join.${malformed.field} is required',
          ),
        ),
      );
    }
  });

  test('identical endpoint facts have identical relationship identity', () {
    const first = ChatHandleRelationshipSourceProjectionInput(
      sourceChatRowId: 7,
      sourceHandleRowId: 9,
    );
    const second = ChatHandleRelationshipSourceProjectionInput(
      sourceChatRowId: 7,
      sourceHandleRowId: 9,
    );

    final firstProjected = projectSourceChatHandleRelationship(first, 3, 11);
    final secondProjected = projectSourceChatHandleRelationship(second, 3, 11);

    expect(secondProjected.ledgerValues, firstProjected.ledgerValues);
  });

  test('packs live and non-live endpoints and preserves batch lineage', () {
    const input = ChatHandleRelationshipSourceProjectionInput(
      sourceChatRowId: 23,
      sourceHandleRowId: 29,
    );

    for (final sourceId in <int>[liveChatDbSourceId, 37]) {
      final projected = projectSourceChatHandleRelationship(
        input,
        sourceId,
        47,
      );

      expect(projected.ledgerValues['source_id'], sourceId);
      expect(projected.ledgerValues['batch_id'], 47);
      expect(
        projected.ledgerValues['chat_ss_id'],
        SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 23),
      );
      expect(
        projected.ledgerValues['handle_ss_id'],
        SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 29),
      );
    }
  });

  test('preserves shared packed-key bounds and rejects invalid bounds', () {
    final lower = projectSourceChatHandleRelationship(
      const ChatHandleRelationshipSourceProjectionInput(
        sourceChatRowId: 1,
        sourceHandleRowId: 1,
      ),
      1,
      3,
    );
    final upper = projectSourceChatHandleRelationship(
      const ChatHandleRelationshipSourceProjectionInput(
        sourceChatRowId: SourceScopedRowKey.maxSourceRowId,
        sourceHandleRowId: SourceScopedRowKey.maxSourceRowId,
      ),
      SourceScopedRowKey.maxSourceId,
      5,
    );

    expect(
      lower.ledgerValues['chat_ss_id'],
      1 << SourceScopedRowKey.sourceRowIdBits | 1,
    );
    expect(upper.ledgerValues['handle_ss_id'], 0x7FFFFFFFFFFFFFFF);

    for (final invalidSourceId in <int>[
      0,
      SourceScopedRowKey.maxSourceId + 1,
    ]) {
      expect(
        () => projectSourceChatHandleRelationship(
          const ChatHandleRelationshipSourceProjectionInput(
            sourceChatRowId: 1,
            sourceHandleRowId: 1,
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
      for (final input in <ChatHandleRelationshipSourceProjectionInput>[
        ChatHandleRelationshipSourceProjectionInput(
          sourceChatRowId: invalidRowId,
          sourceHandleRowId: 1,
        ),
        ChatHandleRelationshipSourceProjectionInput(
          sourceChatRowId: 1,
          sourceHandleRowId: invalidRowId,
        ),
      ]) {
        expect(
          () => projectSourceChatHandleRelationship(input, 1, 11),
          throwsRangeError,
        );
      }
    }
  });

  test('ignores non-endpoint context and maps each material fact', () {
    final baselineInput =
        ChatHandleRelationshipSourceProjectionInput.fromSourceRow(
          <String, Object?>{
            'source_rowid': 31,
            'chat_id': 37,
            'handle_id': 41,
            'existing_chat_rowid': 370,
            'existing_handle_rowid': 410,
            'irrelevant_context': ' first ',
          },
        );
    final contextOnlyInput =
        ChatHandleRelationshipSourceProjectionInput.fromSourceRow(
          <String, Object?>{
            'source_rowid': 999,
            'chat_id': 37,
            'handle_id': 41,
            'existing_chat_rowid': null,
            'existing_handle_rowid': null,
            'irrelevant_context': '   ',
          },
        );
    final baseline = projectSourceChatHandleRelationship(baselineInput, 43, 47);
    final contextOnly = projectSourceChatHandleRelationship(
      contextOnlyInput,
      43,
      47,
    );

    expect(contextOnly.ledgerValues, baseline.ledgerValues);

    final changedChat = projectSourceChatHandleRelationship(
      const ChatHandleRelationshipSourceProjectionInput(
        sourceChatRowId: 38,
        sourceHandleRowId: 41,
      ),
      43,
      47,
    );
    expect(changedChat.ledgerValues['source_chat_rowid'], 38);
    expect(
      changedChat.ledgerValues['chat_ss_id'],
      isNot(baseline.ledgerValues['chat_ss_id']),
    );
    expect(
      changedChat.ledgerValues['handle_ss_id'],
      baseline.ledgerValues['handle_ss_id'],
    );

    final changedHandle = projectSourceChatHandleRelationship(
      const ChatHandleRelationshipSourceProjectionInput(
        sourceChatRowId: 37,
        sourceHandleRowId: 42,
      ),
      43,
      47,
    );
    expect(changedHandle.ledgerValues['source_handle_rowid'], 42);
    expect(
      changedHandle.ledgerValues['handle_ss_id'],
      isNot(baseline.ledgerValues['handle_ss_id']),
    );
    expect(
      changedHandle.ledgerValues['chat_ss_id'],
      baseline.ledgerValues['chat_ss_id'],
    );

    final changedBatch = projectSourceChatHandleRelationship(
      baselineInput,
      43,
      48,
    );
    expect(changedBatch.ledgerValues['batch_id'], 48);
    expect(
      Map<String, Object?>.of(changedBatch.ledgerValues)..['batch_id'] = 47,
      baseline.ledgerValues,
    );
  });
}
