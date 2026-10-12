import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chats/chat_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('canonical Chats source projection', () {
    test('projects every persisted chat column from source facts', () {
      final appleTimestamp = DateConverter.dateString2Apple('2026-08-16');
      final projection = projectSourceChat(
        input: ChatSourceProjectionInput(
          sourceRowId: 101,
          guid: 'chat-guid',
          serviceName: 'iMessage',
          service: 'SMS',
          groupId: 'group-id',
          originalGroupId: 'original-group-id',
          lastReadMessageTimestamp: appleTimestamp,
        ),
        sourceId: 7,
        batchId: 11,
      );

      expect(projection.sourceRowId, 101);
      expect(projection.ledgerValues, <String, Object?>{
        'ss_id': SourceScopedRowKey.pack(sourceId: 7, sourceRowId: 101),
        'source_id': 7,
        'source_rowid': 101,
        'guid': 'chat-guid',
        'service': 'iMessage',
        'group_id': 'group-id',
        'original_group_id': 'original-group-id',
        'last_read_message_at_utc': DateConverter.appleToIsoString(
          appleTimestamp,
        ),
        'batch_id': 11,
      });
      expect(
        () => projection.ledgerValues['guid'] = 'changed',
        throwsUnsupportedError,
      );
    });

    test('preserves exact service fallback and nullable string behavior', () {
      final cases =
          <
            ({
              Object? serviceName,
              Object? service,
              Object? groupId,
              Object? originalGroupId,
              String? expectedService,
              String? expectedGroupId,
              String? expectedOriginalGroupId,
            })
          >[
            (
              serviceName: '',
              service: 'SMS',
              groupId: '',
              originalGroupId: null,
              expectedService: 'SMS',
              expectedGroupId: null,
              expectedOriginalGroupId: null,
            ),
            (
              serviceName: '   ',
              service: 'fallback',
              groupId: '   ',
              originalGroupId: '  original  ',
              expectedService: '   ',
              expectedGroupId: '   ',
              expectedOriginalGroupId: '  original  ',
            ),
            (
              serviceName: 17,
              service: '衛星 💬',
              groupId: 19,
              originalGroupId: false,
              expectedService: '衛星 💬',
              expectedGroupId: null,
              expectedOriginalGroupId: null,
            ),
          ];

      for (var index = 0; index < cases.length; index += 1) {
        final current = cases[index];
        final projected = projectSourceChat(
          input: ChatSourceProjectionInput(
            sourceRowId: index + 1,
            guid: 'chat-${index + 1}',
            serviceName: current.serviceName,
            service: current.service,
            groupId: current.groupId,
            originalGroupId: current.originalGroupId,
            lastReadMessageTimestamp: null,
          ),
          sourceId: 3,
          batchId: 5,
        );

        expect(projected.ledgerValues['service'], current.expectedService);
        expect(projected.ledgerValues['group_id'], current.expectedGroupId);
        expect(
          projected.ledgerValues['original_group_id'],
          current.expectedOriginalGroupId,
        );
      }
    });

    test('uses the shared Apple timestamp conversion authority', () {
      final cases = <({Object? raw, String? expected})>[
        (raw: 364867200, expected: '2012-07-25T00:00:00.000Z'),
        (raw: 808531200000000000, expected: '2026-08-16T00:00:00.000Z'),
        (raw: 0, expected: null),
        (raw: null, expected: null),
        (raw: 'not-a-timestamp', expected: null),
      ];

      for (var index = 0; index < cases.length; index += 1) {
        final current = cases[index];
        final projected = projectSourceChat(
          input: ChatSourceProjectionInput(
            sourceRowId: index + 1,
            guid: 'chat-${index + 1}',
            serviceName: null,
            service: null,
            groupId: null,
            originalGroupId: null,
            lastReadMessageTimestamp: current.raw,
          ),
          sourceId: 3,
          batchId: 5,
        );

        expect(
          projected.ledgerValues['last_read_message_at_utc'],
          current.expected,
        );
      }
    });

    test('retains required source identity and GUID validation behavior', () {
      expect(
        () => projectSourceChat(
          input: const ChatSourceProjectionInput(
            sourceRowId: null,
            guid: 'chat-guid',
            serviceName: null,
            service: null,
            groupId: null,
            originalGroupId: null,
            lastReadMessageTimestamp: null,
          ),
          sourceId: 3,
          batchId: 5,
        ),
        throwsStateError,
      );
      expect(
        () => projectSourceChat(
          input: const ChatSourceProjectionInput(
            sourceRowId: 1,
            guid: '',
            serviceName: null,
            service: null,
            groupId: null,
            originalGroupId: null,
            lastReadMessageTimestamp: null,
          ),
          sourceId: 3,
          batchId: 5,
        ),
        throwsStateError,
      );
      expect(
        () => projectSourceChat(
          input: const ChatSourceProjectionInput(
            sourceRowId: 1,
            guid: 'chat-guid',
            serviceName: null,
            service: null,
            groupId: null,
            originalGroupId: null,
            lastReadMessageTimestamp: null,
          ),
          sourceId: 0,
          batchId: 5,
        ),
        throwsRangeError,
      );
    });

    test('captures every source-query field without database capability', () {
      final input = ChatSourceProjectionInput.fromSourceRow(<String, Object?>{
        'source_rowid': 101.4,
        'guid': '  会話  ',
        'service_name': 'iMessage',
        'service': 'SMS',
        'group_id': 'group',
        'original_group_id': 'original',
        'last_read_message_timestamp': 808531200000000000,
        'ignored_source_column': 'not projected',
      });

      expect(input.sourceRowId, 101.4);
      expect(input.guid, '  会話  ');
      expect(input.serviceName, 'iMessage');
      expect(input.service, 'SMS');
      expect(input.groupId, 'group');
      expect(input.originalGroupId, 'original');
      expect(input.lastReadMessageTimestamp, 808531200000000000);
      expect(input.requiredSourceRowId, 101);
      expect(input.requiredGuid, '  会話  ');
    });

    test('responds only to material source-projection inputs', () {
      final baselineRow = <String, Object?>{
        'source_rowid': 101,
        'guid': 'chat-guid',
        'service_name': 'iMessage',
        'service': 'SMS',
        'group_id': 'group',
        'original_group_id': 'original',
        'last_read_message_timestamp': 808531200000000000,
        'ignored_source_column': 'first value',
      };

      ProjectedSourceChat project(Map<String, Object?> row) {
        return projectSourceChat(
          input: ChatSourceProjectionInput.fromSourceRow(row),
          sourceId: 3,
          batchId: 5,
        );
      }

      final baseline = project(baselineRow).ledgerValues;
      final irrelevantChange = project(<String, Object?>{
        ...baselineRow,
        'ignored_source_column': 'different value',
      }).ledgerValues;
      final materialChange = project(<String, Object?>{
        ...baselineRow,
        'group_id': 'different group',
      }).ledgerValues;

      expect(irrelevantChange, baseline);
      expect(materialChange, isNot(baseline));
      expect(materialChange['group_id'], 'different group');
    });

    test('does not infer graph group-chat semantics', () {
      final projection = projectSourceChat(
        input: const ChatSourceProjectionInput(
          sourceRowId: 1,
          guid: 'chat-guid',
          serviceName: 'iMessage',
          service: null,
          groupId: 'group-id',
          originalGroupId: 'original-group-id',
          lastReadMessageTimestamp: null,
        ),
        sourceId: 3,
        batchId: 5,
      );

      expect(projection.ledgerValues.keys, isNot(contains('is_group')));
      expect(projection.ledgerValues.keys, isNot(contains('display_name')));
    });
  });
}
