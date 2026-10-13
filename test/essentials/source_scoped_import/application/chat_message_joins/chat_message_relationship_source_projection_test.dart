import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_message_joins/chat_message_relationship_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  test('projects the exact seven-field canonical relationship ledger row', () {
    const sourceId = 37;
    const input = ChatMessageRelationshipSourceProjectionInput(
      sourceRowId: 8,
      sourceChatRowId: 13,
      sourceMessageRowId: 21,
    );

    final projected = projectSourceChatMessageRelationship(input, sourceId);

    expect(projected.sourceRowId, 8);
    expect(projected.sourceChatRowId, 13);
    expect(projected.sourceMessageRowId, 21);
    expect(projected.ledgerValues.keys.toList(), <String>[
      'ss_id',
      'source_id',
      'source_rowid',
      'source_chat_rowid',
      'source_message_rowid',
      'chat_ss_id',
      'message_ss_id',
    ]);
    expect(projected.ledgerValues, <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 8),
      'source_id': sourceId,
      'source_rowid': 8,
      'source_chat_rowid': 13,
      'source_message_rowid': 21,
      'chat_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: 13,
      ),
      'message_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: 21,
      ),
    });
    expect(
      () => projected.ledgerValues['source_rowid'] = 999,
      throwsUnsupportedError,
    );
  });

  test('preserves production int and rounded-double coercion', () {
    final input = ChatMessageRelationshipSourceProjectionInput.fromSourceRow(
      <String, Object?>{
        'source_rowid': 3.6,
        'chat_id': 10.4,
        'message_id': 20.6,
      },
    );

    final projected = projectSourceChatMessageRelationship(input, 5);

    expect(projected.sourceRowId, 4);
    expect(projected.sourceChatRowId, 10);
    expect(projected.sourceMessageRowId, 21);
  });

  test('preserves exact required-field failure semantics', () {
    for (final malformed
        in <
          ({ChatMessageRelationshipSourceProjectionInput input, String field})
        >[
          (
            input: const ChatMessageRelationshipSourceProjectionInput(
              sourceRowId: 'bad',
              sourceChatRowId: 1,
              sourceMessageRowId: 2,
            ),
            field: 'source_rowid',
          ),
          (
            input: const ChatMessageRelationshipSourceProjectionInput(
              sourceRowId: 1,
              sourceChatRowId: null,
              sourceMessageRowId: 2,
            ),
            field: 'chat_id',
          ),
          (
            input: const ChatMessageRelationshipSourceProjectionInput(
              sourceRowId: 1,
              sourceChatRowId: 2,
              sourceMessageRowId: Object(),
            ),
            field: 'message_id',
          ),
        ]) {
      expect(
        () => projectSourceChatMessageRelationship(malformed.input, 1),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'chat_message_join.${malformed.field} is required',
          ),
        ),
      );
    }
  });

  test('duplicate endpoints retain distinct raw relationship identities', () {
    const first = ChatMessageRelationshipSourceProjectionInput(
      sourceRowId: 100,
      sourceChatRowId: 7,
      sourceMessageRowId: 9,
    );
    const second = ChatMessageRelationshipSourceProjectionInput(
      sourceRowId: 101,
      sourceChatRowId: 7,
      sourceMessageRowId: 9,
    );

    final firstProjected = projectSourceChatMessageRelationship(first, 3);
    final secondProjected = projectSourceChatMessageRelationship(second, 3);

    expect(
      firstProjected.ledgerValues['ss_id'],
      isNot(secondProjected.ledgerValues['ss_id']),
    );
    expect(
      firstProjected.ledgerValues['chat_ss_id'],
      secondProjected.ledgerValues['chat_ss_id'],
    );
    expect(
      firstProjected.ledgerValues['message_ss_id'],
      secondProjected.ledgerValues['message_ss_id'],
    );
  });

  test('packs live and non-live source identities without losing lineage', () {
    const input = ChatMessageRelationshipSourceProjectionInput(
      sourceRowId: 19,
      sourceChatRowId: 23,
      sourceMessageRowId: 29,
    );

    for (final sourceId in <int>[liveChatDbSourceId, 37]) {
      final projected = projectSourceChatMessageRelationship(input, sourceId);

      expect(projected.ledgerValues['source_id'], sourceId);
      expect(
        projected.ledgerValues['ss_id'],
        SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 19),
      );
      expect(
        projected.ledgerValues['chat_ss_id'],
        SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 23),
      );
      expect(
        projected.ledgerValues['message_ss_id'],
        SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 29),
      );
    }
  });

  test('preserves shared packed-key bounds and rejects invalid bounds', () {
    final lower = projectSourceChatMessageRelationship(
      const ChatMessageRelationshipSourceProjectionInput(
        sourceRowId: 1,
        sourceChatRowId: 1,
        sourceMessageRowId: 1,
      ),
      1,
    );
    final upper = projectSourceChatMessageRelationship(
      const ChatMessageRelationshipSourceProjectionInput(
        sourceRowId: SourceScopedRowKey.maxSourceRowId,
        sourceChatRowId: SourceScopedRowKey.maxSourceRowId,
        sourceMessageRowId: SourceScopedRowKey.maxSourceRowId,
      ),
      SourceScopedRowKey.maxSourceId,
    );

    expect(
      lower.ledgerValues['ss_id'],
      1 << SourceScopedRowKey.sourceRowIdBits | 1,
    );
    expect(upper.ledgerValues['ss_id'], 0x7FFFFFFFFFFFFFFF);

    for (final invalidSourceId in <int>[
      0,
      SourceScopedRowKey.maxSourceId + 1,
    ]) {
      expect(
        () => projectSourceChatMessageRelationship(
          const ChatMessageRelationshipSourceProjectionInput(
            sourceRowId: 1,
            sourceChatRowId: 1,
            sourceMessageRowId: 1,
          ),
          invalidSourceId,
        ),
        throwsRangeError,
      );
    }

    for (final invalidRowId in <int>[
      0,
      SourceScopedRowKey.maxSourceRowId + 1,
    ]) {
      for (final input in <ChatMessageRelationshipSourceProjectionInput>[
        ChatMessageRelationshipSourceProjectionInput(
          sourceRowId: invalidRowId,
          sourceChatRowId: 1,
          sourceMessageRowId: 1,
        ),
        ChatMessageRelationshipSourceProjectionInput(
          sourceRowId: 1,
          sourceChatRowId: invalidRowId,
          sourceMessageRowId: 1,
        ),
        ChatMessageRelationshipSourceProjectionInput(
          sourceRowId: 1,
          sourceChatRowId: 1,
          sourceMessageRowId: invalidRowId,
        ),
      ]) {
        expect(
          () => projectSourceChatMessageRelationship(input, 1),
          throwsRangeError,
        );
      }
    }
  });

  test('ignores raw context and maps each material fact canonically', () {
    final baselineInput =
        ChatMessageRelationshipSourceProjectionInput.fromSourceRow(
          <String, Object?>{
            'source_rowid': 31,
            'chat_id': 37,
            'message_id': 41,
            'existing_chat_rowid': 370,
            'existing_message_rowid': 410,
            'irrelevant_context': 'first',
          },
        );
    final contextOnlyInput =
        ChatMessageRelationshipSourceProjectionInput.fromSourceRow(
          <String, Object?>{
            'source_rowid': 31,
            'chat_id': 37,
            'message_id': 41,
            'existing_chat_rowid': null,
            'existing_message_rowid': null,
            'irrelevant_context': Object(),
          },
        );
    final baseline = projectSourceChatMessageRelationship(baselineInput, 43);
    final contextOnly = projectSourceChatMessageRelationship(
      contextOnlyInput,
      43,
    );

    expect(contextOnly.ledgerValues, baseline.ledgerValues);

    final changedRelationship = projectSourceChatMessageRelationship(
      const ChatMessageRelationshipSourceProjectionInput(
        sourceRowId: 32,
        sourceChatRowId: 37,
        sourceMessageRowId: 41,
      ),
      43,
    );
    expect(changedRelationship.ledgerValues['source_rowid'], 32);
    expect(
      changedRelationship.ledgerValues['ss_id'],
      isNot(baseline.ledgerValues['ss_id']),
    );
    expect(
      changedRelationship.ledgerValues['chat_ss_id'],
      baseline.ledgerValues['chat_ss_id'],
    );
    expect(
      changedRelationship.ledgerValues['message_ss_id'],
      baseline.ledgerValues['message_ss_id'],
    );

    final changedChat = projectSourceChatMessageRelationship(
      const ChatMessageRelationshipSourceProjectionInput(
        sourceRowId: 31,
        sourceChatRowId: 38,
        sourceMessageRowId: 41,
      ),
      43,
    );
    expect(changedChat.ledgerValues['source_chat_rowid'], 38);
    expect(
      changedChat.ledgerValues['chat_ss_id'],
      isNot(baseline.ledgerValues['chat_ss_id']),
    );
    expect(changedChat.ledgerValues['ss_id'], baseline.ledgerValues['ss_id']);
    expect(
      changedChat.ledgerValues['message_ss_id'],
      baseline.ledgerValues['message_ss_id'],
    );

    final changedMessage = projectSourceChatMessageRelationship(
      const ChatMessageRelationshipSourceProjectionInput(
        sourceRowId: 31,
        sourceChatRowId: 37,
        sourceMessageRowId: 42,
      ),
      43,
    );
    expect(changedMessage.ledgerValues['source_message_rowid'], 42);
    expect(
      changedMessage.ledgerValues['message_ss_id'],
      isNot(baseline.ledgerValues['message_ss_id']),
    );
    expect(
      changedMessage.ledgerValues['ss_id'],
      baseline.ledgerValues['ss_id'],
    );
    expect(
      changedMessage.ledgerValues['chat_ss_id'],
      baseline.ledgerValues['chat_ss_id'],
    );
  });
}
