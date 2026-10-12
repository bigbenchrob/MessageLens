import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('canonical Messages source projection', () {
    test('projects every persisted message column from source facts', () {
      const sourceId = 7;
      const batchId = 11;
      const readDate = 789004800000000000;
      const deliveredDate = 789091200000000000;
      final projection = projectSourceMessage(
        input: MessageSourceProjectionInput(
          sourceRowId: 101,
          guid: 'message-101',
          handleId: 202,
          isFromMe: -1,
          date: 364929382,
          dateRead: readDate,
          dateDelivered: deliveredDate,
          text: 'source text',
          attributedBody: Uint8List.fromList(<int>[1, 2, 3]),
          associatedMessageGuid: 'p:0/target-101',
          itemType: 7,
          associatedMessageType: 2000,
          threadOriginatorGuid: 'thread-101',
          error: 42,
          isSystemMessage: 1,
          hasChatRelationship: 1,
          hasMessageSummaryInfo: 1,
          hasPayloadDataSource: 1,
        ),
        sourceId: sourceId,
        batchId: batchId,
      );

      expect(projection.sourceRowId, 101);
      expect(projection.dateUtc, DateConverter.appleToIsoString(364929382));
      expect(projection.associatedMessageReference, 'p:0/target-101');
      expect(projection.associatedMessageType, 2000);
      expect(projection.ledgerValues, <String, Object?>{
        'ss_id': SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 101),
        'source_id': sourceId,
        'source_rowid': 101,
        'guid': 'message-101',
        'sender_handle_ss_id': SourceScopedRowKey.pack(
          sourceId: sourceId,
          sourceRowId: 202,
        ),
        'is_from_me': 1,
        'date_utc': DateConverter.appleToIsoString(364929382),
        'date_read_utc': DateConverter.appleToIsoString(readDate),
        'date_delivered_utc': DateConverter.appleToIsoString(deliveredDate),
        'text': 'source text',
        'attributed_body_blob': Uint8List.fromList(<int>[1, 2, 3]),
        'associated_message_guid': 'p:0/target-101',
        'raw_item_type': 7,
        'raw_associated_message_type': 2000,
        'thread_originator_guid': 'thread-101',
        'error_code': 42,
        'is_system_message': 1,
        'has_attributed_body_source': 1,
        'has_message_summary_info': 1,
        'has_payload_data_source': 1,
        'batch_id': batchId,
      });
      expect(
        () => projection.ledgerValues['guid'] = 'changed',
        throwsUnsupportedError,
      );
    });

    test(
      'preserves nullable, empty, numeric, and blob conversion behavior',
      () {
        final projection = projectSourceMessage(
          input: const MessageSourceProjectionInput(
            sourceRowId: 101.4,
            guid: 'message-101',
            handleId: 0,
            isFromMe: 0,
            date: null,
            dateRead: null,
            dateDelivered: null,
            text: '',
            attributedBody: <int>[4, 5],
            associatedMessageGuid: '',
            itemType: 3.6,
            associatedMessageType: null,
            threadOriginatorGuid: '',
            error: 9.2,
            isSystemMessage: null,
            hasChatRelationship: null,
            hasMessageSummaryInfo: 0,
            hasPayloadDataSource: -1,
          ),
          sourceId: 7,
          batchId: 11,
        );

        expect(projection.sourceRowId, 101);
        expect(projection.dateUtc, isNull);
        expect(projection.associatedMessageReference, isNull);
        expect(projection.associatedMessageType, isNull);
        expect(projection.ledgerValues['sender_handle_ss_id'], isNull);
        expect(projection.ledgerValues['date_utc'], isNull);
        expect(projection.ledgerValues['date_read_utc'], isNull);
        expect(projection.ledgerValues['date_delivered_utc'], isNull);
        expect(projection.ledgerValues['text'], isNull);
        expect(
          projection.ledgerValues['attributed_body_blob'],
          orderedEquals(<int>[4, 5]),
        );
        expect(projection.ledgerValues['raw_item_type'], 4);
        expect(projection.ledgerValues['raw_associated_message_type'], isNull);
        expect(projection.ledgerValues['thread_originator_guid'], isNull);
        expect(projection.ledgerValues['error_code'], 9);
        expect(projection.ledgerValues['is_system_message'], 0);
        expect(projection.ledgerValues['has_attributed_body_source'], 1);
        expect(projection.ledgerValues['has_message_summary_info'], 0);
        expect(projection.ledgerValues['has_payload_data_source'], 1);
      },
    );

    test('retains required identity and source-state validation behavior', () {
      MessageSourceProjectionInput input({Object? guid = 'message-101'}) {
        return MessageSourceProjectionInput(
          sourceRowId: 101,
          guid: guid,
          handleId: null,
          isFromMe: 0,
          date: null,
          dateRead: null,
          dateDelivered: null,
          text: null,
          attributedBody: null,
          associatedMessageGuid: null,
          itemType: null,
          associatedMessageType: null,
          threadOriginatorGuid: null,
          error: null,
          isSystemMessage: null,
          hasChatRelationship: null,
          hasMessageSummaryInfo: null,
          hasPayloadDataSource: null,
        );
      }

      expect(
        () => projectSourceMessage(
          input: input(guid: ''),
          sourceId: 7,
          batchId: 11,
        ),
        throwsStateError,
      );
      expect(
        () => projectSourceMessage(input: input(), sourceId: 0, batchId: 11),
        throwsRangeError,
      );
      expect(
        () => projectSourceMessage(
          input: const MessageSourceProjectionInput(
            sourceRowId: null,
            guid: 'message-101',
            handleId: null,
            isFromMe: 0,
            date: null,
            dateRead: null,
            dateDelivered: null,
            text: null,
            attributedBody: null,
            associatedMessageGuid: null,
            itemType: null,
            associatedMessageType: null,
            threadOriginatorGuid: null,
            error: null,
            isSystemMessage: null,
            hasChatRelationship: null,
            hasMessageSummaryInfo: null,
            hasPayloadDataSource: null,
          ),
          sourceId: 7,
          batchId: 11,
        ),
        throwsStateError,
      );
    });

    test('captures every source-query field without database capability', () {
      final input = MessageSourceProjectionInput.fromSourceRow(
        <String, Object?>{
          'source_rowid': 101,
          'guid': 'message-101',
          'handle_id': 202,
          'is_from_me': 1,
          'date': 364929382,
          'date_read': 364929383,
          'date_delivered': 364929384,
          'text': 'source text',
          'attributedBody': <int>[1],
          'associated_message_guid': 'p:0/target-101',
          'item_type': 7,
          'associated_message_type': 2000,
          'thread_originator_guid': 'thread-101',
          'error': 42,
          'is_system_message': 1,
          'has_chat_relationship': 1,
          'has_message_summary_info': 1,
          'has_payload_data_source': 1,
        },
      );

      expect(input.sourceRowId, 101);
      expect(input.guid, 'message-101');
      expect(input.handleId, 202);
      expect(input.isFromMe, 1);
      expect(input.date, 364929382);
      expect(input.dateRead, 364929383);
      expect(input.dateDelivered, 364929384);
      expect(input.text, 'source text');
      expect(input.attributedBody, <int>[1]);
      expect(input.associatedMessageGuid, 'p:0/target-101');
      expect(input.itemType, 7);
      expect(input.associatedMessageType, 2000);
      expect(input.threadOriginatorGuid, 'thread-101');
      expect(input.error, 42);
      expect(input.isSystemMessage, 1);
      expect(input.hasChatRelationship, 1);
      expect(input.hasMessageSummaryInfo, 1);
      expect(input.hasPayloadDataSource, 1);
    });

    test('preserves source text and input facts without enrichment', () {
      final row = <String, Object?>{
        'source_rowid': 101,
        'guid': 'message-101',
        'handle_id': null,
        'is_from_me': 0,
        'date': null,
        'date_read': null,
        'date_delivered': null,
        'text': '  café 👋  ',
        'attributedBody': <int>[8, 9],
        'associated_message_guid': null,
        'item_type': null,
        'associated_message_type': null,
        'thread_originator_guid': null,
        'error': null,
        'is_system_message': null,
        'has_chat_relationship': 1,
        'has_message_summary_info': null,
        'has_payload_data_source': null,
      };
      final beforeProjection = Map<String, Object?>.from(row);

      final projection = projectSourceMessage(
        input: MessageSourceProjectionInput.fromSourceRow(row),
        sourceId: 7,
        batchId: 11,
      );

      expect(row, beforeProjection);
      expect(projection.ledgerValues['text'], '  café 👋  ');
      expect(
        projection.ledgerValues['attributed_body_blob'],
        orderedEquals(<int>[8, 9]),
      );
    });

    test(
      'ignores anomaly-only context but changes with material source facts',
      () {
        MessageSourceProjectionInput input({
          required Object? hasChatRelationship,
          required Object? text,
        }) {
          return MessageSourceProjectionInput(
            sourceRowId: 101,
            guid: 'message-101',
            handleId: null,
            isFromMe: 0,
            date: null,
            dateRead: null,
            dateDelivered: null,
            text: text,
            attributedBody: null,
            associatedMessageGuid: null,
            itemType: null,
            associatedMessageType: null,
            threadOriginatorGuid: null,
            error: null,
            isSystemMessage: null,
            hasChatRelationship: hasChatRelationship,
            hasMessageSummaryInfo: null,
            hasPayloadDataSource: null,
          );
        }

        final noChatRelationship = projectSourceMessage(
          input: input(hasChatRelationship: 0, text: 'same'),
          sourceId: 7,
          batchId: 11,
        );
        final linkedChat = projectSourceMessage(
          input: input(hasChatRelationship: 1, text: 'same'),
          sourceId: 7,
          batchId: 11,
        );
        final changedText = projectSourceMessage(
          input: input(hasChatRelationship: 1, text: 'changed'),
          sourceId: 7,
          batchId: 11,
        );

        expect(noChatRelationship.ledgerValues, linkedChat.ledgerValues);
        expect(
          noChatRelationship.ledgerValues['text'],
          isNot(changedText.ledgerValues['text']),
        );
      },
    );
  });
}
