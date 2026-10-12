import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/handles/handle_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('canonical Handles source projection', () {
    test('projects every persisted handle column from source facts', () {
      const sourceId = 7;
      const batchId = 11;
      final projection = projectSourceHandle(
        input: const HandleSourceProjectionInput(
          sourceRowId: 101,
          identifier: ' +1 (604) 555-0100 ',
          service: 'iMessage',
        ),
        sourceId: sourceId,
        batchId: batchId,
        isMe: true,
      );

      expect(projection.sourceRowId, 101);
      expect(projection.rawIdentifier, ' +1 (604) 555-0100 ');
      expect(
        projection.identifierInterpretation,
        isA<NormalizedHandleIdentifier>().having(
          (value) => value.normalizedIdentifier,
          'normalizedIdentifier',
          '6045550100',
        ),
      );
      expect(projection.ledgerValues, <String, Object?>{
        'ss_id': SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 101),
        'source_id': sourceId,
        'source_rowid': 101,
        'id': ' +1 (604) 555-0100 ',
        'service': 'iMessage',
        'is_me': 1,
        'batch_id': batchId,
      });
      expect(
        () => projection.ledgerValues['id'] = 'changed',
        throwsUnsupportedError,
      );
    });

    test(
      'preserves raw identifiers and existing nullable service behavior',
      () {
        final cases =
            <({String identifier, Object? service, Object? expected})>[
              (identifier: '  café 💬  ', service: null, expected: null),
              (identifier: 'malformed value', service: '', expected: null),
              (
                identifier: 'value@example.com',
                service: '   ',
                expected: '   ',
              ),
              (
                identifier: 'mailto:User@Example.COM',
                service: 'SMS',
                expected: 'SMS',
              ),
            ];

        for (var index = 0; index < cases.length; index += 1) {
          final sourceRowId = index + 1;
          final current = cases[index];
          final projection = projectSourceHandle(
            input: HandleSourceProjectionInput(
              sourceRowId: sourceRowId,
              identifier: current.identifier,
              service: current.service,
            ),
            sourceId: 3,
            batchId: 5,
            isMe: false,
          );

          expect(projection.rawIdentifier, current.identifier);
          expect(projection.ledgerValues['id'], current.identifier);
          expect(projection.ledgerValues['service'], current.expected);
          expect(projection.ledgerValues['is_me'], 0);
        }
      },
    );

    test('preserves only typed normalization failures', () {
      final projection = projectSourceHandle(
        input: const HandleSourceProjectionInput(
          sourceRowId: 1,
          identifier: 'typed failure',
          service: null,
        ),
        sourceId: 3,
        batchId: 5,
        isMe: false,
        handleIdentifierInterpreter: (_) {
          throw const HandleIdentifierNormalizationException('synthetic');
        },
      );

      expect(
        projection.identifierInterpretation,
        isA<PreservedUnnormalizedHandleIdentifier>(),
      );
      expect(projection.ledgerValues['id'], 'typed failure');
      expect(
        () => projectSourceHandle(
          input: const HandleSourceProjectionInput(
            sourceRowId: 2,
            identifier: 'systemic failure',
            service: null,
          ),
          sourceId: 3,
          batchId: 5,
          isMe: false,
          handleIdentifierInterpreter: (_) {
            throw StateError('synthetic systemic failure');
          },
        ),
        throwsStateError,
      );
    });

    test('retains required source identity validation behavior', () {
      expect(
        () => projectSourceHandle(
          input: const HandleSourceProjectionInput(
            sourceRowId: null,
            identifier: 'value@example.com',
            service: null,
          ),
          sourceId: 3,
          batchId: 5,
          isMe: false,
        ),
        throwsStateError,
      );
      expect(
        () => projectSourceHandle(
          input: const HandleSourceProjectionInput(
            sourceRowId: 1,
            identifier: '',
            service: null,
          ),
          sourceId: 3,
          batchId: 5,
          isMe: false,
        ),
        throwsStateError,
      );
      expect(
        () => projectSourceHandle(
          input: const HandleSourceProjectionInput(
            sourceRowId: 1,
            identifier: 'value@example.com',
            service: null,
          ),
          sourceId: 0,
          batchId: 5,
          isMe: false,
        ),
        throwsRangeError,
      );
    });

    test('captures every source-query field without database capability', () {
      final input = HandleSourceProjectionInput.fromSourceRow(<String, Object?>{
        'source_rowid': 101.4,
        'id': '  user@example.com  ',
        'service': 'RCS',
      });

      expect(input.sourceRowId, 101.4);
      expect(input.identifier, '  user@example.com  ');
      expect(input.service, 'RCS');
      expect(input.requiredSourceRowId, 101);
      expect(input.requiredIdentifier, '  user@example.com  ');
    });

    test('does not infer local-account identity from source-row facts', () {
      const input = HandleSourceProjectionInput(
        sourceRowId: 101,
        identifier: 'local@example.com',
        service: 'iMessage',
      );
      final notLocal = projectSourceHandle(
        input: input,
        sourceId: 3,
        batchId: 5,
        isMe: false,
      );
      final local = projectSourceHandle(
        input: input,
        sourceId: 3,
        batchId: 5,
        isMe: true,
      );

      expect(<String, Object?>{
        ...notLocal.ledgerValues,
        'is_me': 1,
      }, local.ledgerValues);
      expect(
        notLocal.identifierInterpretation.runtimeType,
        local.identifierInterpretation.runtimeType,
      );
    });
  });
}
