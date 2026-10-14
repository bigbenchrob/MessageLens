import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_relationship_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_message_joins/chat_message_relationship_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/message_attachment_joins/message_attachment_relationship_source_projection.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'source_scoped_import_ledger_material_comparator.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'production schema exactly matches the classified ledger manifest',
    () async {
      final ledger = await _openDisposableLedger('schema');

      expect(await sourceScopedImportLedgerSchemaDifferences(ledger), isEmpty);
      expect(sourceScopedImportLedgerTableSpecs, hasLength(11));
      expect(
        sourceScopedImportLedgerTableSpecs.map((spec) => spec.name),
        <String>[
          'source_registry',
          'import_batches',
          'messages',
          'handles',
          'chats',
          'chat_to_message',
          'chat_to_handle',
          'contacts',
          'contact_channels',
          'attachments',
          'message_to_attachment',
        ],
      );
      expect(
        sourceScopedImportLedgerTableSpecs
            .expand((spec) => spec.columns.map((column) => (spec.name, column)))
            .where(
              (entry) =>
                  entry.$2.treatment ==
                  LedgerColumnTreatment.operationalUtcProvenance,
            )
            .map((entry) => '${entry.$1}.${entry.$2.name}'),
        <String>[
          'source_registry.created_at_utc',
          'import_batches.started_at_utc',
          'import_batches.finished_at_utc',
        ],
      );
    },
  );

  test('independent disposable ledgers are equal despite coherent operational '
      'timestamp differences', () async {
    final expectedLedger = await _openDisposableLedger('equal-expected');
    final observedLedger = await _openDisposableLedger('equal-observed');
    await _seedCompleteFixture(
      expectedLedger,
      operationalBase: DateTime.utc(2026, 1, 1),
    );
    await _seedCompleteFixture(
      observedLedger,
      operationalBase: DateTime.utc(2026, 2, 1),
    );

    final expected = await captureSourceScopedImportLedgerSnapshot(
      expectedLedger,
    );
    final observed = await captureSourceScopedImportLedgerSnapshot(
      observedLedger,
    );
    final comparison = compareSourceScopedImportLedgerMaterial(
      expected: expected,
      observed: observed,
    );

    expect(comparison.isEquivalent, isTrue, reason: comparison.description);
    expect(
      expected['messages']!.map((row) => row['ss_id']),
      orderedEquals(<int>[
        _packed(1, 30),
        _packed(1, 31),
        _packed(1, 32),
        _packed(1, 33),
        _packed(3, 130),
      ]),
    );
    expect(
      expected['chat_to_message']!.singleWhere(
        (row) => row['source_id'] == 1 && row['source_rowid'] == 50,
      )['source_rowid'],
      50,
    );
    expect(
      sourceScopedImportLedgerTableSpecs
          .singleWhere((spec) => spec.name == 'chat_to_handle')
          .identityColumns,
      <String>['source_id', 'source_chat_rowid', 'source_handle_rowid'],
    );
  });

  test(
    'missing, extra, and changed rows are detected for every table',
    () async {
      final ledger = await _openDisposableLedger('table-matrix');
      await _seedCompleteFixture(
        ledger,
        operationalBase: DateTime.utc(2026, 3, 1),
      );
      final baseline = await captureSourceScopedImportLedgerSnapshot(ledger);
      final changedColumns = <String, String>{
        'source_registry': 'source_kind',
        'import_batches': 'notes',
        'messages': 'text',
        'handles': 'service',
        'chats': 'group_id',
        'chat_to_message': 'source_message_rowid',
        'chat_to_handle': 'batch_id',
        'contacts': 'organization',
        'contact_channels': 'label',
        'attachments': 'mime_type',
        'message_to_attachment': 'batch_id',
      };

      for (final spec in sourceScopedImportLedgerTableSpecs) {
        final missing = _copySnapshot(baseline);
        missing[spec.name]!.removeLast();
        final missingComparison = compareSourceScopedImportLedgerMaterial(
          expected: baseline,
          observed: missing,
        );
        expect(
          missingComparison.diagnostics.any(
            (diagnostic) =>
                diagnostic.startsWith('${spec.name} ') &&
                diagnostic.contains('expected row missing'),
          ),
          isTrue,
          reason: '${spec.name}: ${missingComparison.description}',
        );

        final extra = _copySnapshot(baseline);
        extra[spec.name]!.add(_extraIdentityRow(spec, extra[spec.name]!.last));
        final extraComparison = compareSourceScopedImportLedgerMaterial(
          expected: baseline,
          observed: extra,
        );
        expect(
          extraComparison.diagnostics.any(
            (diagnostic) =>
                diagnostic.startsWith('${spec.name} ') &&
                diagnostic.contains('extra observed row'),
          ),
          isTrue,
          reason: '${spec.name}: ${extraComparison.description}',
        );

        final changed = _copySnapshot(baseline);
        final column = changedColumns[spec.name]!;
        changed[spec.name]!.last[column] = _differentValue(
          changed[spec.name]!.last[column],
        );
        final changedComparison = compareSourceScopedImportLedgerMaterial(
          expected: baseline,
          observed: changed,
        );
        expect(
          changedComparison.diagnostics.any(
            (diagnostic) =>
                diagnostic.startsWith('${spec.name} ') &&
                diagnostic.contains('field{$column}'),
          ),
          isTrue,
          reason: '${spec.name}: ${changedComparison.description}',
        );
      }
    },
  );

  test('raw and endpoint relationship identities remain distinct', () async {
    final ledger = await _openDisposableLedger('relationship-identities');
    await _seedCompleteFixture(
      ledger,
      operationalBase: DateTime.utc(2026, 4, 1),
    );
    final baseline = await captureSourceScopedImportLedgerSnapshot(ledger);

    final rawOccurrence = _copySnapshot(baseline);
    final chatMessage = rawOccurrence['chat_to_message']!.singleWhere(
      (row) => row['source_id'] == 1,
    );
    chatMessage['source_rowid'] = 51;
    chatMessage['ss_id'] = _packed(1, 51);
    final rawComparison = compareSourceScopedImportLedgerMaterial(
      expected: baseline,
      observed: rawOccurrence,
    );
    expect(rawComparison.description, contains('ss_id=${_packed(1, 50)}'));
    expect(rawComparison.description, contains('ss_id=${_packed(1, 51)}'));

    final endpointTuple = _copySnapshot(baseline);
    endpointTuple['chat_to_handle']!.add(
      Map<String, Object?>.from(endpointTuple['chat_to_handle']!.first),
    );
    final tupleComparison = compareSourceScopedImportLedgerMaterial(
      expected: baseline,
      observed: endpointTuple,
    );
    expect(
      tupleComparison.description,
      contains(
        'duplicate identity source_id,source_chat_rowid,source_handle_rowid',
      ),
    );
  });

  test(
    'registry, batch, packed identity, and endpoints are consequential',
    () async {
      final ledger = await _openDisposableLedger('coherence');
      await _seedCompleteFixture(
        ledger,
        operationalBase: DateTime.utc(2026, 5, 1),
      );
      final baseline = await captureSourceScopedImportLedgerSnapshot(ledger);
      final observed = _copySnapshot(baseline);

      observed['source_registry']!.removeWhere((row) => row['source_id'] == 3);
      observed['messages']!.first['ss_id'] = _packed(1, 999);
      observed['messages']!.first['sender_handle_ss_id'] = _packed(3, 110);
      observed['handles']!.first['batch_id'] = 9999;
      observed['chats']!.first['batch_id'] = 102;
      observed['chat_to_message']!.first['message_ss_id'] = _packed(1, 999);

      final comparison = compareSourceScopedImportLedgerMaterial(
        expected: baseline,
        observed: observed,
      );
      expect(comparison.description, contains('source_id=3 is unregistered'));
      expect(comparison.description, contains('does not encode'));
      expect(comparison.description, contains('belongs to a different source'));
      expect(comparison.description, contains('batch_id=9999 is missing'));
      expect(
        comparison.description,
        contains('batch_id=102 belongs to source_id=2'),
      );
      expect(comparison.description, contains('has no messages endpoint'));
    },
  );

  test('null, empty, whitespace, Unicode, blob, enrichment, and anomalous rows '
      'remain distinguishable', () async {
    final ledger = await _openDisposableLedger('record-fidelity');
    await _seedCompleteFixture(
      ledger,
      operationalBase: DateTime.utc(2026, 6, 1),
    );
    final baseline = await captureSourceScopedImportLedgerSnapshot(ledger);
    final messages = baseline['messages']!;
    expect(messages.map((row) => row['text']), <String?>[
      null,
      '',
      '   ',
      'Café é ☃',
      null,
    ]);
    expect(
      messages.first['attributed_body_blob'],
      orderedEquals(<int>[0, 1, 255]),
    );
    expect(messages.first['has_attributed_body_source'], 1);
    expect(messages.first['raw_item_type'], 99);

    final enriched = _copySnapshot(baseline);
    enriched['messages']!.first['text'] = 'decoded rich text';
    final enrichedComparison = compareSourceScopedImportLedgerMaterial(
      expected: baseline,
      observed: enriched,
    );
    expect(enrichedComparison.description, contains('field{text}'));

    final blobChanged = _copySnapshot(baseline);
    blobChanged['messages']!.first['attributed_body_blob'] = Uint8List.fromList(
      <int>[0, 1, 254],
    );
    final blobComparison = compareSourceScopedImportLedgerMaterial(
      expected: baseline,
      observed: blobChanged,
    );
    expect(blobComparison.description, contains('field{attributed_body_blob}'));

    final absent = _copySnapshot(baseline);
    absent['messages']!.first.remove('text');
    final absentComparison = compareSourceScopedImportLedgerMaterial(
      expected: baseline,
      observed: absent,
    );
    expect(absentComparison.description, contains('field{text} absent'));
    expect(absentComparison.description, contains('observed <absent>'));
  });

  test(
    'operational timestamps require coherent provenance without exact value equality',
    () async {
      final ledger = await _openDisposableLedger('operational');
      await _seedCompleteFixture(
        ledger,
        operationalBase: DateTime.utc(2026, 7, 1),
      );
      final baseline = await captureSourceScopedImportLedgerSnapshot(ledger);

      final differentTimes = _copySnapshot(baseline);
      differentTimes['source_registry']!.first['created_at_utc'] =
          '2030-01-01T00:00:00.000Z';
      differentTimes['import_batches']!.first['started_at_utc'] =
          '2030-01-01T00:00:00.000Z';
      differentTimes['import_batches']!.first['finished_at_utc'] =
          '2030-01-01T00:01:00.000Z';
      expect(
        compareSourceScopedImportLedgerMaterial(
          expected: baseline,
          observed: differentTimes,
        ).isEquivalent,
        isTrue,
      );

      final nullStateChanged = _copySnapshot(baseline);
      nullStateChanged['import_batches']!.first['finished_at_utc'] = null;
      expect(
        compareSourceScopedImportLedgerMaterial(
          expected: baseline,
          observed: nullStateChanged,
        ).description,
        contains('field{finished_at_utc}'),
      );

      final invalid = _copySnapshot(baseline);
      invalid['import_batches']!.first['started_at_utc'] = 'not-utc';
      invalid['import_batches']!.first['finished_at_utc'] =
          '2025-01-01T00:00:00.000Z';
      final invalidComparison = compareSourceScopedImportLedgerMaterial(
        expected: baseline,
        observed: invalid,
      );
      expect(
        invalidComparison.description,
        contains('not coherent UTC provenance'),
      );

      final reversed = _copySnapshot(baseline);
      reversed['import_batches']!.first['started_at_utc'] =
          '2026-07-02T00:00:00.000Z';
      reversed['import_batches']!.first['finished_at_utc'] =
          '2026-07-01T00:00:00.000Z';
      expect(
        compareSourceScopedImportLedgerMaterial(
          expected: baseline,
          observed: reversed,
        ).description,
        contains('finished_at_utc precedes start'),
      );
    },
  );

  test(
    'historical protected provenance and absent endpoints fail closed',
    () async {
      final ledger = await _openDisposableLedger('historical');
      await _seedCompleteFixture(
        ledger,
        operationalBase: DateTime.utc(2026, 8, 1),
      );
      final baseline = await captureSourceScopedImportLedgerSnapshot(ledger);
      final historical = baseline['source_registry']!.singleWhere(
        (row) => row['source_id'] == 3,
      );
      expect(historical['source_kind'], historicalMessagesArchiveSourceKind);
      expect(historical['source_key'], contains('protected-donor'));

      final lostEndpoint = _copySnapshot(baseline);
      lostEndpoint['messages']!.removeWhere((row) => row['source_id'] == 3);
      final comparison = compareSourceScopedImportLedgerMaterial(
        expected: baseline,
        observed: lostEndpoint,
      );
      expect(comparison.isEquivalent, isFalse);
      expect(comparison.description, contains('expected row missing'));
      expect(comparison.description, contains('has no messages endpoint'));
    },
  );

  test(
    'actual schema and in-memory evidence both reject duplicate identities',
    () async {
      final ledger = await _openDisposableLedger('duplicates');
      await _seedCompleteFixture(
        ledger,
        operationalBase: DateTime.utc(2026, 9, 1),
      );
      await expectLater(
        ledger.database.insert(
          'handles',
          Map<String, Object?>.from(
            (await ledger.database.query('handles', limit: 1)).single,
          ),
        ),
        throwsA(isA<DatabaseException>()),
      );

      final baseline = await captureSourceScopedImportLedgerSnapshot(ledger);
      final duplicate = _copySnapshot(baseline);
      duplicate['handles']!.add(
        Map<String, Object?>.from(duplicate['handles']!.first),
      );
      expect(
        compareSourceScopedImportLedgerMaterial(
          expected: baseline,
          observed: duplicate,
        ).description,
        contains('duplicate identity'),
      );
    },
  );

  test(
    'diagnostics are deterministic, bounded, and retain total mismatch count',
    () async {
      final ledger = await _openDisposableLedger('diagnostics');
      await _seedCompleteFixture(
        ledger,
        operationalBase: DateTime.utc(2026, 10, 1),
      );
      final baseline = await captureSourceScopedImportLedgerSnapshot(ledger);
      final observed = _copySnapshot(baseline);
      observed['messages']!.clear();
      observed['handles']!.clear();
      observed['unknown_table'] = <Map<String, Object?>>[
        <String, Object?>{'secret': 'not logged as user content'},
      ];

      final first = compareSourceScopedImportLedgerMaterial(
        expected: baseline,
        observed: observed,
        diagnosticLimit: 2,
      );
      final second = compareSourceScopedImportLedgerMaterial(
        expected: baseline,
        observed: observed,
        diagnosticLimit: 2,
      );
      expect(first.totalDifferenceCount, greaterThan(first.diagnostics.length));
      expect(first.diagnostics, second.diagnostics);
      expect(first.description, contains('additional difference(s) omitted'));
      expect(first.description, contains('(limit 2)'));
      expect(first.description, isNot(contains('not logged as user content')));
    },
  );

  test(
    'schema drift, unclassified fields, and snapshot bounds fail closed',
    () async {
      final ledger = await _openDisposableLedger('drift');
      await ledger.database.execute(
        'ALTER TABLE messages ADD COLUMN future_fact TEXT',
      );
      expect(
        await sourceScopedImportLedgerSchemaDifferences(ledger),
        contains(contains('messages columns')),
      );

      final cleanLedger = await _openDisposableLedger('unclassified');
      await _seedCompleteFixture(
        cleanLedger,
        operationalBase: DateTime.utc(2026, 11, 1),
      );
      final baseline = await captureSourceScopedImportLedgerSnapshot(
        cleanLedger,
      );
      final unclassified = _copySnapshot(baseline);
      unclassified['messages']!.first['future_fact'] = 'classified nowhere';
      expect(
        compareSourceScopedImportLedgerMaterial(
          expected: baseline,
          observed: unclassified,
        ).description,
        contains('unclassified field {future_fact}'),
      );
      await expectLater(
        captureSourceScopedImportLedgerSnapshot(
          cleanLedger,
          maximumRowsPerTable: 1,
        ),
        throwsA(isA<StateError>()),
      );
    },
  );
}

Future<ImportDatabase> _openDisposableLedger(String label) async {
  final root = await Directory.systemTemp.createTemp(
    'messagelens-prompt107-$label-',
  );
  final ledger = await ImportDatabase.open(
    databaseDirectory: root.path,
    databaseName: 'ledger.db',
  );
  addTearDown(() async {
    await ledger.close();
    await root.delete(recursive: true);
  });
  return ledger;
}

Future<void> _seedCompleteFixture(
  ImportDatabase ledger, {
  required DateTime operationalBase,
}) async {
  final started = operationalBase.toUtc().toIso8601String();
  final finished = operationalBase
      .add(const Duration(minutes: 1))
      .toUtc()
      .toIso8601String();
  await ledger.database.insert('source_registry', <String, Object?>{
    'source_id': 3,
    'source_key': '${historicalMessagesArchiveSourceKeyPrefix}protected-donor',
    'source_kind': historicalMessagesArchiveSourceKind,
    'source_label': 'Protected synthetic donor',
    'created_at_utc': started,
  });
  for (final batch in <Map<String, Object?>>[
    <String, Object?>{
      'batch_id': 101,
      'source_id': 1,
      'started_at_utc': started,
      'finished_at_utc': finished,
      'notes': 'synthetic live fixture',
    },
    <String, Object?>{
      'batch_id': 102,
      'source_id': 2,
      'started_at_utc': started,
      'finished_at_utc': finished,
      'notes': 'synthetic contacts fixture',
    },
    <String, Object?>{
      'batch_id': 103,
      'source_id': 3,
      'started_at_utc': started,
      'finished_at_utc': finished,
      'notes': 'synthetic protected historical fixture',
    },
  ]) {
    await ledger.database.insert('import_batches', batch);
  }

  for (final row in <Map<String, Object?>>[
    _handleRow(sourceId: 1, rowId: 10, batchId: 101, isMe: 1),
    _handleRow(sourceId: 3, rowId: 110, batchId: 103, isMe: 0),
  ]) {
    await ledger.database.insert('handles', row);
  }
  for (final row in <Map<String, Object?>>[
    _chatRow(sourceId: 1, rowId: 20, batchId: 101),
    _chatRow(sourceId: 3, rowId: 120, batchId: 103),
  ]) {
    await ledger.database.insert('chats', row);
  }
  for (final row in <Map<String, Object?>>[
    _messageRow(
      sourceId: 1,
      rowId: 30,
      senderRowId: 10,
      batchId: 101,
      text: null,
      blob: Uint8List.fromList(<int>[0, 1, 255]),
      anomaly: true,
    ),
    _messageRow(
      sourceId: 1,
      rowId: 31,
      senderRowId: 10,
      batchId: 101,
      text: '',
    ),
    _messageRow(
      sourceId: 1,
      rowId: 32,
      senderRowId: 10,
      batchId: 101,
      text: '   ',
    ),
    _messageRow(
      sourceId: 1,
      rowId: 33,
      senderRowId: 10,
      batchId: 101,
      text: 'Café é ☃',
    ),
    _messageRow(
      sourceId: 3,
      rowId: 130,
      senderRowId: 110,
      batchId: 103,
      text: null,
      blob: Uint8List.fromList(<int>[3, 1, 4]),
    ),
  ]) {
    await ledger.database.insert('messages', row);
  }
  for (final row in <Map<String, Object?>>[
    _attachmentRow(sourceId: 1, rowId: 40, batchId: 101),
    _attachmentRow(sourceId: 3, rowId: 140, batchId: 103),
  ]) {
    await ledger.database.insert('attachments', row);
  }
  await ledger.database.insert('contacts', <String, Object?>{
    'ss_id': _packed(2, 60),
    'source_id': 2,
    'source_rowid': 60,
    'display_name': 'Synthetic ☃ Contact',
    'first_name': 'Synthetic',
    'last_name': '',
    'organization': null,
    'created_at_utc': '2020-01-01T00:00:00.000Z',
    'batch_id': 102,
  });
  await ledger.database.insert('contact_channels', <String, Object?>{
    'source_id': 2,
    'source_contact_rowid': 60,
    'contact_ss_id': _packed(2, 60),
    'kind': 'email',
    'value': 'synthetic@example.invalid',
    'label': 'work',
    'batch_id': 102,
  });

  for (final relationship in <(int, int, int)>[(1, 50, 20), (3, 150, 120)]) {
    final sourceId = relationship.$1;
    final projected = projectSourceChatMessageRelationship(
      ChatMessageRelationshipSourceProjectionInput(
        sourceRowId: relationship.$2,
        sourceChatRowId: relationship.$3,
        sourceMessageRowId: sourceId == 1 ? 30 : 130,
      ),
      sourceId,
    );
    await ledger.database.insert('chat_to_message', projected.ledgerValues);
  }
  for (final relationship in <(int, int, int, int)>[
    (1, 20, 10, 101),
    (3, 120, 110, 103),
  ]) {
    final projected = projectSourceChatHandleRelationship(
      ChatHandleRelationshipSourceProjectionInput(
        sourceChatRowId: relationship.$2,
        sourceHandleRowId: relationship.$3,
      ),
      relationship.$1,
      relationship.$4,
    );
    await ledger.database.insert('chat_to_handle', projected.ledgerValues);
  }
  for (final relationship in <(int, int, int, int)>[
    (1, 30, 40, 101),
    (3, 130, 140, 103),
  ]) {
    final projected = projectSourceMessageAttachmentRelationship(
      MessageAttachmentRelationshipSourceProjectionInput(
        sourceMessageRowId: relationship.$2,
        sourceAttachmentRowId: relationship.$3,
      ),
      relationship.$1,
      relationship.$4,
    );
    await ledger.database.insert(
      'message_to_attachment',
      projected.ledgerValues,
    );
  }
}

Map<String, Object?> _handleRow({
  required int sourceId,
  required int rowId,
  required int batchId,
  required int isMe,
}) {
  return <String, Object?>{
    'ss_id': _packed(sourceId, rowId),
    'source_id': sourceId,
    'source_rowid': rowId,
    'id': 'synthetic-$sourceId-$rowId@example.invalid',
    'service': 'iMessage',
    'is_me': isMe,
    'batch_id': batchId,
  };
}

Map<String, Object?> _chatRow({
  required int sourceId,
  required int rowId,
  required int batchId,
}) {
  return <String, Object?>{
    'ss_id': _packed(sourceId, rowId),
    'source_id': sourceId,
    'source_rowid': rowId,
    'guid': 'synthetic-chat-$sourceId-$rowId',
    'service': 'iMessage',
    'group_id': 'group-$sourceId',
    'original_group_id': null,
    'last_read_message_at_utc': null,
    'batch_id': batchId,
  };
}

Map<String, Object?> _messageRow({
  required int sourceId,
  required int rowId,
  required int senderRowId,
  required int batchId,
  required String? text,
  Uint8List? blob,
  bool anomaly = false,
}) {
  return <String, Object?>{
    'ss_id': _packed(sourceId, rowId),
    'source_id': sourceId,
    'source_rowid': rowId,
    'guid': 'synthetic-message-$sourceId-$rowId',
    'sender_handle_ss_id': _packed(sourceId, senderRowId),
    'is_from_me': sourceId == 1 ? 1 : 0,
    'date_utc': '2025-01-01T00:00:00.000Z',
    'date_read_utc': null,
    'date_delivered_utc': null,
    'text': text,
    'attributed_body_blob': blob,
    'associated_message_guid': null,
    'raw_item_type': anomaly ? 99 : 0,
    'raw_associated_message_type': null,
    'thread_originator_guid': null,
    'error_code': anomaly ? 42 : 0,
    'is_system_message': anomaly ? 1 : 0,
    'has_attributed_body_source': blob == null ? 0 : 1,
    'has_message_summary_info': 0,
    'has_payload_data_source': anomaly ? 1 : 0,
    'batch_id': batchId,
  };
}

Map<String, Object?> _attachmentRow({
  required int sourceId,
  required int rowId,
  required int batchId,
}) {
  return <String, Object?>{
    'ss_id': _packed(sourceId, rowId),
    'source_id': sourceId,
    'source_rowid': rowId,
    'guid': 'synthetic-attachment-$sourceId-$rowId',
    'filename': '/synthetic/$sourceId/$rowId',
    'transfer_name': 'fixture-$rowId.bin',
    'uti': 'public.data',
    'mime_type': 'application/octet-stream',
    'total_bytes': 3,
    'created_at_utc': '2025-01-01T00:00:00.000Z',
    'batch_id': batchId,
  };
}

LedgerMaterialSnapshot _copySnapshot(LedgerMaterialSnapshot source) {
  return <String, List<Map<String, Object?>>>{
    for (final entry in source.entries)
      entry.key: <Map<String, Object?>>[
        for (final row in entry.value) Map<String, Object?>.from(row),
      ],
  };
}

Map<String, Object?> _extraIdentityRow(
  LedgerTableSpec spec,
  Map<String, Object?> original,
) {
  final row = Map<String, Object?>.from(original);
  switch (spec.name) {
    case 'source_registry':
      row['source_id'] = 99;
      row['source_key'] = 'synthetic-extra-source';
    case 'import_batches':
      row['batch_id'] = 999;
    case 'messages':
    case 'handles':
    case 'chats':
    case 'contacts':
    case 'attachments':
      final sourceId = row['source_id']! as int;
      row['source_rowid'] = 999;
      row['ss_id'] = _packed(sourceId, 999);
    case 'chat_to_message':
      final sourceId = row['source_id']! as int;
      row['source_rowid'] = 999;
      row['ss_id'] = _packed(sourceId, 999);
    case 'chat_to_handle':
      row['source_handle_rowid'] = 999;
      row['handle_ss_id'] = _packed(row['source_id']! as int, 999);
    case 'contact_channels':
      row['value'] = 'extra@example.invalid';
    case 'message_to_attachment':
      row['source_attachment_rowid'] = 999;
      row['attachment_ss_id'] = _packed(
        row['attachment_source_id']! as int,
        999,
      );
  }
  return row;
}

Object? _differentValue(Object? value) {
  return switch (value) {
    null => 'now-present',
    final int number => number + 1,
    final String text => '$text-changed',
    final List<int> bytes => Uint8List.fromList(<int>[...bytes, 99]),
    _ => throw StateError('unsupported fixture value $value'),
  };
}

int _packed(int sourceId, int rowId) {
  return SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: rowId);
}
