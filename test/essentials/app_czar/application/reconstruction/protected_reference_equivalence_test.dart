import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'protected_reference_equivalence.dart';

const _timestamp = '2026-10-15T00:00:00.000Z';
const _messageGuid = 'GUID-LIVE-30';
const _normalizedHandle = '+16045550100';
const _virtualParticipantId = 1000000000;

final _messageId = _liveId(30);
final _chatId = _liveId(20);
final _rawHandleId = _liveId(40);
final _canonicalHandleId = _liveId(41);
final _attachmentId = _liveId(50);
final _contactId = SourceScopedRowKey.pack(
  sourceId: liveAddressBookSourceId,
  sourceRowId: 10,
);

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('protected-reference schema and production resolution inventory', () {
    test('all supported direct, compatibility, virtual, and local references '
        'resolve identically across independent worlds', () async {
      await _withPair((pair) async {
        const reader = ProtectedReferenceEquivalenceReader();
        final expected = await reader.observe(pair.expected.world);
        final observed = await reader.observe(pair.observed.world);
        final comparison = await reader.compare(
          expected: pair.expected.world,
          observed: pair.observed.world,
        );

        expect(expected.truth, ProtectedReferenceTruth.trueValue);
        expect(observed.truth, ProtectedReferenceTruth.trueValue);
        expect(comparison.truth, ProtectedReferenceTruth.trueValue);
        expect(
          comparison
              .dimensions[ProtectedReferenceDimension.overlayIntentMaterial]!
              .truth,
          ProtectedReferenceTruth.trueValue,
        );
        expect(
          comparison
              .dimensions[ProtectedReferenceDimension.targetIdentity]!
              .truth,
          ProtectedReferenceTruth.trueValue,
        );
        expect(
          comparison
              .dimensions[ProtectedReferenceDimension.compatibilityResolution]!
              .truth,
          ProtectedReferenceTruth.trueValue,
        );
        expect(
          comparison
              .dimensions[ProtectedReferenceDimension
                  .sourceOccurrenceProvenance]!
              .truth,
          ProtectedReferenceTruth.trueValue,
        );
        expect(
          comparison
              .dimensions[ProtectedReferenceDimension
                  .attachmentPayloadCoverage]!
              .assessed,
          isFalse,
        );
        expect(comparison.diagnostics, isEmpty);
      });
    });

    test('missing, extra, rebound, and packed-source allocation changes remain '
        'known contradictions', () async {
      await _withPair((pair) async {
        await pair.observed.graph.executeSql(
          'DELETE FROM contacts WHERE contact_id = ?',
          <Object?>[_contactId],
        );
        final result = await _compare(pair);
        expect(result.truth, ProtectedReferenceTruth.falseValue);
        expect(
          result.diagnostics,
          contains('target.unresolved.favorite_contacts'),
        );
      });

      await _withPair((pair) async {
        await pair.observed.overlay.customStatement(
          'INSERT INTO overlay_settings(key, value) VALUES (?, ?)',
          <Object?>['extra-setting', 'extra-value'],
        );
        final result = await _compare(pair);
        expect(result.truth, ProtectedReferenceTruth.falseValue);
        expect(result.diagnostics, contains('material.extra.overlay_settings'));
      });

      await _withPair((pair) async {
        final reboundHandleId = _liveId(42);
        await pair.observed.graph.executeSql(
          'UPDATE canonical_handles SET normalized_identifier = ? '
          'WHERE canonical_handle_ss_id = ?',
          <Object?>['other@example.test', _canonicalHandleId],
        );
        await pair.observed.graph.executeSql(
          'INSERT INTO canonical_handles ( '
          'canonical_handle_ss_id, display_handle, normalized_identifier, '
          'service, alias_count) VALUES (?, ?, ?, ?, ?)',
          <Object?>[
            reboundHandleId,
            '+1 604 555 0100',
            _normalizedHandle,
            'iMessage',
            1,
          ],
        );
        await pair.observed.graph.executeSql(
          'UPDATE handle_aliases SET canonical_handle_ss_id = ? '
          'WHERE handle_ss_id = ?',
          <Object?>[reboundHandleId, _rawHandleId],
        );
        final result = await _compare(pair);
        expect(result.truth, ProtectedReferenceTruth.falseValue);
        expect(
          result.diagnostics,
          contains('target.rebound.dismissed_handles'),
        );
      });

      await _withPair((pair) async {
        await pair.observed.ledger.database.update(
          'source_registry',
          <String, Object?>{'source_key': 'reallocated-live-source'},
          where: 'source_id = ?',
          whereArgs: <Object?>[liveChatDbSourceId],
        );
        final result = await _compare(pair);
        expect(result.truth, ProtectedReferenceTruth.falseValue);
        expect(
          result.diagnostics.any(
            (value) => value.startsWith('target.rebound.'),
          ),
          isTrue,
        );
      });
    });

    test('GUID fallback is exact and unique; zero and case changes are FALSE '
        'while multiple and historical-live collisions are UNKNOWN', () async {
      await _withPair((pair) async {
        await pair.observed.graph.executeSql(
          'UPDATE messages SET guid = ? WHERE ss_id = ?',
          <Object?>['different-guid', _messageId],
        );
        final observation = await const ProtectedReferenceEquivalenceReader()
            .observe(pair.observed.world);
        expect(observation.truth, ProtectedReferenceTruth.falseValue);
      });

      await _withPair((pair) async {
        await pair.observed.graph.executeSql(
          'UPDATE messages SET guid = ? WHERE ss_id = ?',
          <Object?>[_messageGuid.toLowerCase(), _messageId],
        );
        final observation = await const ProtectedReferenceEquivalenceReader()
            .observe(pair.observed.world);
        expect(observation.truth, ProtectedReferenceTruth.falseValue);
      });

      await _withPair((pair) async {
        await pair.observed.addHistoricalSource();
        final historicalMessageId = _historicalId(30);
        await pair.observed.graph.executeSql(
          'INSERT INTO messages(ss_id, guid, is_from_me) VALUES (?, ?, ?)',
          <Object?>[historicalMessageId, _messageGuid, 0],
        );
        final observation = await const ProtectedReferenceEquivalenceReader()
            .observe(pair.observed.world);
        expect(observation.truth, ProtectedReferenceTruth.unknown);
        expect(
          observation.unknownReason,
          ProtectedReferenceUnknownReason.ambiguousFallback,
        );
      });

      await _withPair((pair) async {
        final reboundMessageId = _liveId(31);
        await pair.observed.graph.executeSql(
          'UPDATE messages SET guid = ? WHERE ss_id = ?',
          <Object?>['other-guid', _messageId],
        );
        await pair.observed.graph.executeSql(
          'INSERT INTO messages(ss_id, guid, is_from_me) VALUES (?, ?, ?)',
          <Object?>[reboundMessageId, _messageGuid, 0],
        );
        final comparison = await _compare(pair);
        expect(comparison.truth, ProtectedReferenceTruth.falseValue);
        expect(
          comparison.diagnostics,
          contains('target.rebound.message_user_flags'),
        );
      });
    });

    test('normalized-handle resolution exposes representative changes and '
        'ambiguous representatives', () async {
      await _withPair((pair) async {
        final reboundHandleId = _liveId(42);
        await pair.observed.graph.executeSql(
          'UPDATE canonical_handles SET normalized_identifier = ? '
          'WHERE canonical_handle_ss_id = ?',
          <Object?>['other@example.test', _canonicalHandleId],
        );
        await pair.observed.graph.executeSql(
          'INSERT INTO canonical_handles ( '
          'canonical_handle_ss_id, display_handle, normalized_identifier, '
          'service, alias_count) VALUES (?, ?, ?, ?, ?)',
          <Object?>[
            reboundHandleId,
            _normalizedHandle,
            _normalizedHandle,
            'iMessage',
            1,
          ],
        );
        await pair.observed.graph.executeSql(
          'UPDATE handle_aliases SET canonical_handle_ss_id = ? '
          'WHERE handle_ss_id = ?',
          <Object?>[reboundHandleId, _rawHandleId],
        );
        final comparison = await _compare(pair);
        expect(comparison.truth, ProtectedReferenceTruth.falseValue);
        expect(
          comparison.diagnostics,
          contains('target.rebound.dismissed_handles'),
        );
      });

      await _withPair((pair) async {
        final competingHandleId = _liveId(42);
        await pair.observed.graph.executeSql(
          'INSERT INTO canonical_handles ( '
          'canonical_handle_ss_id, display_handle, normalized_identifier, '
          'service, alias_count) VALUES (?, ?, ?, ?, ?)',
          <Object?>[
            competingHandleId,
            _normalizedHandle,
            _normalizedHandle,
            'iMessage',
            1,
          ],
        );
        final observation = await const ProtectedReferenceEquivalenceReader()
            .observe(pair.observed.world);
        expect(observation.truth, ProtectedReferenceTruth.unknown);
        expect(
          observation.diagnostics,
          contains('dismissed_handles.ambiguous'),
        );
      });
    });

    test('archive compatibility is live-source scoped and remains distinct from '
        'relationship provenance and payload coverage', () async {
      await _withPair((pair) async {
        await pair.observed.addHistoricalSource();
        final historicalAttachmentId = _historicalId(50);
        await pair.observed.graph.executeSql(
          'DELETE FROM message_to_attachment WHERE attachment_ss_id = ?',
          <Object?>[_attachmentId],
        );
        await pair.observed.graph.executeSql(
          'DELETE FROM attachments WHERE ss_id = ?',
          <Object?>[_attachmentId],
        );
        await pair.observed.graph.executeSql(
          'INSERT INTO attachments(ss_id, guid) VALUES (?, ?)',
          <Object?>[historicalAttachmentId, 'historical-attachment'],
        );
        await pair.observed.graph.executeSql(
          'INSERT INTO message_to_attachment(message_ss_id, attachment_ss_id) '
          'VALUES (?, ?)',
          <Object?>[_messageId, historicalAttachmentId],
        );
        final observation = await const ProtectedReferenceEquivalenceReader()
            .observe(pair.observed.world);
        expect(observation.truth, ProtectedReferenceTruth.falseValue);
        expect(
          observation.diagnostics,
          contains('archived_attachments.unresolved'),
        );
      });

      await _withPair((pair) async {
        await pair.observed.overlay.customStatement(
          'UPDATE archived_attachments SET content_hash = ? '
          'WHERE message_guid = ? AND import_attachment_id = ?',
          <Object?>['different-payload-hash', _messageGuid, 50],
        );
        final comparison = await _compare(pair);
        expect(
          comparison
              .dimensions[ProtectedReferenceDimension.overlayIntentMaterial]!
              .truth,
          ProtectedReferenceTruth.falseValue,
        );
        expect(
          comparison
              .dimensions[ProtectedReferenceDimension.compatibilityResolution]!
              .truth,
          ProtectedReferenceTruth.trueValue,
        );
        expect(
          comparison
              .dimensions[ProtectedReferenceDimension
                  .sourceOccurrenceProvenance]!
              .truth,
          ProtectedReferenceTruth.trueValue,
        );
        expect(
          comparison
              .dimensions[ProtectedReferenceDimension
                  .attachmentPayloadCoverage]!
              .assessed,
          isFalse,
        );
      });
    });

    test('virtual participants and overlay-local tag namespaces are not graph '
        'keys', () async {
      await _withPair((pair) async {
        final baseline = await _compare(pair);
        expect(baseline.truth, ProtectedReferenceTruth.trueValue);

        await pair.observed.overlay.customStatement(
          'UPDATE handle_to_participant_overrides '
          'SET participant_id = ?, virtual_participant_id = NULL '
          'WHERE handle_id = ?',
          <Object?>[_virtualParticipantId, 40],
        );
        final observation = await const ProtectedReferenceEquivalenceReader()
            .observe(pair.observed.world);
        expect(observation.truth, ProtectedReferenceTruth.falseValue);
        expect(
          observation.diagnostics,
          contains('handle_to_participant_overrides.unresolved'),
        );
      });
    });

    test('dangling direct references and direct-versus-fallback contradictions '
        'remain visible', () async {
      await _withPair((pair) async {
        await pair.observed.graph.executeSql(
          'DELETE FROM chats WHERE ss_id = ?',
          <Object?>[_chatId],
        );
        final result = await _compare(pair);
        expect(result.truth, ProtectedReferenceTruth.falseValue);
        expect(
          result.diagnostics,
          contains('target.unresolved.chat_overrides'),
        );
      });

      await _withPair((pair) async {
        final competingHandleId = _liveId(42);
        await pair.observed.graph.executeSql(
          'INSERT INTO canonical_handles ( '
          'canonical_handle_ss_id, display_handle, normalized_identifier, '
          'service, alias_count) VALUES (?, ?, ?, ?, ?)',
          <Object?>[
            competingHandleId,
            _normalizedHandle,
            _normalizedHandle,
            'iMessage',
            1,
          ],
        );
        await pair.observed.graph.executeSql(
          'DELETE FROM chats WHERE ss_id = ?',
          <Object?>[_chatId],
        );
        final result = await _compare(pair);
        expect(result.truth, ProtectedReferenceTruth.falseValue);
        expect(
          result.diagnostics,
          contains('target.ambiguous.dismissed_handles'),
        );
        expect(
          result.diagnostics,
          contains('target.unresolved.chat_overrides'),
        );
      });

      await _withPair((pair) async {
        final fallbackTargetId = _liveId(31);
        await pair.observed.graph.executeSql(
          'UPDATE messages SET guid = ? WHERE ss_id = ?',
          <Object?>['direct-only-guid', _messageId],
        );
        await pair.observed.graph.executeSql(
          'INSERT INTO messages(ss_id, guid, is_from_me) VALUES (?, ?, ?)',
          <Object?>[fallbackTargetId, _messageGuid, 0],
        );
        final result = await _compare(pair);
        expect(result.truth, ProtectedReferenceTruth.falseValue);
        expect(
          result.diagnostics,
          contains('target.rebound.message_user_flags'),
        );
        expect(
          result.diagnostics,
          isNot(contains('target.rebound.message_annotations')),
        );
      });
    });

    test(
      'missing, unsupported, unreadable, unqualified, ambiguous, and bounded '
      'evidence returns UNKNOWN without inventing a target',
      () async {
        await _withPair((pair) async {
          await pair.observed.overlay.customStatement(
            'UPDATE message_user_flags SET message_guid = ?',
            <Object?>[''],
          );
          final observation = await const ProtectedReferenceEquivalenceReader()
              .observe(pair.observed.world);
          expect(observation.truth, ProtectedReferenceTruth.unknown);
          expect(
            observation.unknownReason,
            ProtectedReferenceUnknownReason.missingIdentityField,
          );
        });

        await _withPair((pair) async {
          await pair.observed.overlay.customStatement(
            'PRAGMA user_version = 7',
          );
          final observation = await const ProtectedReferenceEquivalenceReader()
              .observe(pair.observed.world);
          expect(observation.truth, ProtectedReferenceTruth.unknown);
          expect(
            observation.unknownReason,
            ProtectedReferenceUnknownReason.unsupportedSchema,
          );
          final comparison = await const ProtectedReferenceEquivalenceReader()
              .compare(
                expected: pair.expected.world,
                observed: pair.observed.world,
              );
          expect(comparison.truth, ProtectedReferenceTruth.unknown);
          for (final dimension in <ProtectedReferenceDimension>[
            ProtectedReferenceDimension.overlayIntentMaterial,
            ProtectedReferenceDimension.targetIdentity,
            ProtectedReferenceDimension.compatibilityResolution,
            ProtectedReferenceDimension.sourceOccurrenceProvenance,
          ]) {
            expect(comparison.dimensions[dimension]!.assessed, isFalse);
            expect(
              comparison.dimensions[dimension]!.unknownReason,
              ProtectedReferenceUnknownReason.unsupportedSchema,
            );
          }
          expect(
            comparison.diagnostics,
            isNot(contains('material.missing.message_user_flags')),
          );
        });

        await _withPair((pair) async {
          await pair.observed.closeGraph();
          final observation = await const ProtectedReferenceEquivalenceReader()
              .observe(pair.observed.world);
          expect(observation.truth, ProtectedReferenceTruth.unknown);
          expect(
            observation.unknownReason,
            ProtectedReferenceUnknownReason.unreadableSource,
          );
          final comparison = await const ProtectedReferenceEquivalenceReader()
              .compare(
                expected: pair.expected.world,
                observed: pair.observed.world,
              );
          expect(comparison.truth, ProtectedReferenceTruth.unknown);
          expect(
            comparison.diagnostics,
            isNot(contains('material.missing.message_user_flags')),
          );
        });

        await _withPair((pair) async {
          final observation = await const ProtectedReferenceEquivalenceReader()
              .observe(pair.observed.unqualifiedWorld);
          expect(observation.truth, ProtectedReferenceTruth.unknown);
          expect(
            observation.unknownReason,
            ProtectedReferenceUnknownReason.unqualifiedLookup,
          );
        });

        await _withPair((pair) async {
          final observation = await const ProtectedReferenceEquivalenceReader(
            limits: ProtectedReferenceLimits(maxRowsPerTable: 0),
          ).observe(pair.observed.world);
          expect(observation.truth, ProtectedReferenceTruth.unknown);
          expect(
            observation.unknownReason,
            ProtectedReferenceUnknownReason.rowLimit,
          );
        });

        await _withPair((pair) async {
          final observation = await const ProtectedReferenceEquivalenceReader(
            limits: ProtectedReferenceLimits(maxMaterialBytes: 1),
          ).observe(pair.observed.world);
          expect(observation.truth, ProtectedReferenceTruth.unknown);
          expect(
            observation.unknownReason,
            ProtectedReferenceUnknownReason.byteLimit,
          );
        });
      },
    );

    test('diagnostics are deterministic, bounded, non-content-leaking, and '
        'read-only for protected overlay rows', () async {
      await _withPair((pair) async {
        const reader = ProtectedReferenceEquivalenceReader(
          limits: ProtectedReferenceLimits(maxDiagnostics: 2),
        );
        final before = await reader.observe(pair.observed.world);
        await pair.observed.graph.executeSql('DELETE FROM contacts');
        await pair.observed.graph.executeSql('DELETE FROM chats');
        await pair.observed.graph.executeSql('DELETE FROM handles');
        await pair.observed.graph.executeSql('DELETE FROM canonical_handles');
        await pair.observed.graph.executeSql('DELETE FROM handle_aliases');

        final first = await reader.compare(
          expected: pair.expected.world,
          observed: pair.observed.world,
        );
        final second = await reader.compare(
          expected: pair.expected.world,
          observed: pair.observed.world,
        );
        final after = await reader.observe(pair.observed.world);

        expect(first.truth, ProtectedReferenceTruth.falseValue);
        expect(first.diagnostics, second.diagnostics);
        expect(first.diagnostics, hasLength(2));
        expect(first.diagnosticsTruncated, isTrue);
        expect(first.diagnostics.join(' '), isNot(contains(_messageGuid)));
        expect(first.diagnostics.join(' '), isNot(contains(_normalizedHandle)));
        expect(first.diagnostics.join(' '), isNot(contains('private-note')));
        expect(first.diagnostics.join(' '), isNot(contains('/private/tmp')));
        expect(after.materialByReference, before.materialByReference);
      });
    });
  });

  group('disposable resource cleanup', () {
    test('closes handles and deletes directories after success', () async {
      final pair = await _FixturePair.open();
      final root = pair.root;
      final result = await runProtectedReferenceDisposableScope<int>(
        action: () async {
          await const ProtectedReferenceEquivalenceReader().observe(
            pair.expected.world,
          );
          return 7;
        },
        closeHandles: pair.close,
        deleteDirectory: pair.delete,
      );
      expect(result, 7);
      await _expectFixturePairClosedAndDeleted(pair, root);
    });

    test('closes handles and deletes directories after failure', () async {
      final pair = await _FixturePair.open();
      final root = pair.root;
      await expectLater(
        runProtectedReferenceDisposableScope<void>(
          action: () async {
            await const ProtectedReferenceEquivalenceReader().observe(
              pair.expected.world,
            );
            throw StateError('synthetic failure');
          },
          closeHandles: pair.close,
          deleteDirectory: pair.delete,
        ),
        throwsStateError,
      );
      await _expectFixturePairClosedAndDeleted(pair, root);
    });

    test('closes handles and deletes directories after cancellation', () async {
      final pair = await _FixturePair.open();
      final root = pair.root;
      await expectLater(
        runProtectedReferenceDisposableScope<void>(
          action: () async {
            await const ProtectedReferenceEquivalenceReader().observe(
              pair.expected.world,
            );
            throw const _SyntheticCancellation();
          },
          closeHandles: pair.close,
          deleteDirectory: pair.delete,
        ),
        throwsA(isA<_SyntheticCancellation>()),
      );
      await _expectFixturePairClosedAndDeleted(pair, root);
    });
  });
}

Future<void> _expectFixturePairClosedAndDeleted(
  _FixturePair pair,
  Directory root,
) async {
  expect(root.existsSync(), isFalse);
  await expectLater(
    pair.expected.overlay.customSelect('SELECT 1').get(),
    throwsA(anything),
  );
  await expectLater(
    pair.expected.graph.selectRows('SELECT 1'),
    throwsA(anything),
  );
  expect(
    () => pair.expected.ledger.database.rawQuery('SELECT 1'),
    throwsA(anything),
  );
}

Future<ProtectedReferenceComparison> _compare(_FixturePair pair) {
  return const ProtectedReferenceEquivalenceReader().compare(
    expected: pair.expected.world,
    observed: pair.observed.world,
  );
}

Future<void> _withPair(Future<void> Function(_FixturePair pair) action) async {
  final pair = await _FixturePair.open();
  await runProtectedReferenceDisposableScope<void>(
    action: () => action(pair),
    closeHandles: pair.close,
    deleteDirectory: pair.delete,
  );
}

final class _FixturePair {
  _FixturePair._({
    required this.root,
    required this.expected,
    required this.observed,
  });

  final Directory root;
  final _Fixture expected;
  final _Fixture observed;

  static Future<_FixturePair> open() async {
    final created = await Directory.systemTemp.createTemp(
      'messagelens_protected_reference_equivalence_',
    );
    final root = Directory(created.resolveSymbolicLinksSync());
    _Fixture? expected;
    _Fixture? observed;
    try {
      expected = await _Fixture.open(Directory('${root.path}/expected'));
      observed = await _Fixture.open(Directory('${root.path}/observed'));
      await expected.seedCanonical();
      await observed.seedCanonical();
      return _FixturePair._(root: root, expected: expected, observed: observed);
    } on Object {
      await expected?.close();
      await observed?.close();
      if (root.existsSync()) {
        await root.delete(recursive: true);
      }
      rethrow;
    }
  }

  Future<void> close() async {
    await expected.close();
    await observed.close();
  }

  Future<void> delete() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  }
}

final class _Fixture {
  _Fixture._({
    required this.root,
    required this.overlay,
    required this.graph,
    required this.ledger,
  });

  final Directory root;
  final OverlayDatabase overlay;
  final ConversationGraphDatabase graph;
  final ImportDatabase ledger;
  var _graphClosed = false;
  var _closed = false;

  ProtectedReferenceWorld get world => ProtectedReferenceWorld(
    overlay: overlay,
    graph: graph,
    ledger: ledger.database,
  );

  ProtectedReferenceWorld get unqualifiedWorld => ProtectedReferenceWorld(
    overlay: overlay,
    graph: graph,
    ledger: ledger.database,
    productionLookupQualified: false,
  );

  static Future<_Fixture> open(Directory root) async {
    await root.create(recursive: true);
    final overlay = OverlayDatabase(
      NativeDatabase(File('${root.path}/user_overlays.db')),
    );
    final graph = ConversationGraphDatabase(
      NativeDatabase(File('${root.path}/conversation_graph.db')),
    );
    ImportDatabase? ledger;
    try {
      await overlay.customSelect('SELECT 1').get();
      await graph.selectRows('SELECT 1');
      ledger = await ImportDatabase.open(
        databaseDirectory: root.path,
        databaseName: 'source_ledger.db',
      );
      return _Fixture._(
        root: root,
        overlay: overlay,
        graph: graph,
        ledger: ledger,
      );
    } on Object {
      await overlay.close();
      await graph.close();
      await ledger?.close();
      rethrow;
    }
  }

  Future<void> seedCanonical() async {
    await _seedGraph();
    await _seedOverlay();
  }

  Future<void> addHistoricalSource() async {
    await ledger.database.insert('source_registry', <String, Object?>{
      'source_id': 3,
      'source_key': 'historical-messages-archive:test',
      'source_kind': 'historical_messages_archive',
      'source_label': 'Synthetic historical source',
      'created_at_utc': _timestamp,
    });
  }

  Future<void> closeGraph() async {
    if (!_graphClosed) {
      await graph.close();
      _graphClosed = true;
    }
  }

  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await overlay.close();
    if (!_graphClosed) {
      await graph.close();
      _graphClosed = true;
    }
    await ledger.close();
  }

  Future<void> _seedGraph() async {
    await graph.executeSql(
      'INSERT INTO messages(ss_id, guid, is_from_me, text) '
      'VALUES (?, ?, ?, ?)',
      <Object?>[_messageId, _messageGuid, 0, 'synthetic message'],
    );
    await graph.executeSql(
      'INSERT INTO chats(ss_id, guid, service, is_group) '
      'VALUES (?, ?, ?, ?)',
      <Object?>[_chatId, 'chat-guid', 'iMessage', 0],
    );
    await graph.executeSql(
      'INSERT INTO contacts(contact_id, display_name) VALUES (?, ?)',
      <Object?>[_contactId, 'Synthetic Contact'],
    );
    await graph.executeSql(
      'INSERT INTO handles(ss_id, id, service, is_me) VALUES (?, ?, ?, ?)',
      <Object?>[_rawHandleId, '+1 (604) 555-0100', 'iMessage', 0],
    );
    await graph.executeSql(
      'INSERT INTO canonical_handles ( '
      'canonical_handle_ss_id, display_handle, normalized_identifier, '
      'service, alias_count) VALUES (?, ?, ?, ?, ?)',
      <Object?>[
        _canonicalHandleId,
        '+1 (604) 555-0100',
        _normalizedHandle,
        'iMessage',
        1,
      ],
    );
    await graph.executeSql(
      'INSERT INTO handle_aliases ( '
      'handle_ss_id, canonical_handle_ss_id, raw_identifier, '
      'normalized_identifier, alias_kind) VALUES (?, ?, ?, ?, ?)',
      <Object?>[
        _rawHandleId,
        _canonicalHandleId,
        '+1 (604) 555-0100',
        _normalizedHandle,
        'exact',
      ],
    );
    await graph.executeSql(
      'INSERT INTO attachments(ss_id, guid, filename) VALUES (?, ?, ?)',
      <Object?>[_attachmentId, 'attachment-guid', 'synthetic.dat'],
    );
    await graph.executeSql(
      'INSERT INTO message_to_attachment(message_ss_id, attachment_ss_id) '
      'VALUES (?, ?)',
      <Object?>[_messageId, _attachmentId],
    );
  }

  Future<void> _seedOverlay() async {
    await overlay.customStatement(
      'INSERT INTO participant_overrides ( '
      'participant_id, display_name_override, created_at_utc, updated_at_utc) '
      'VALUES (?, ?, ?, ?)',
      <Object?>[10, 'Private participant name', _timestamp, _timestamp],
    );
    await overlay.customStatement(
      'INSERT INTO chat_overrides ( '
      'chat_id, custom_name, custom_color, notes, created_at_utc, updated_at_utc) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[
        20,
        'Private chat name',
        null,
        'private-note',
        _timestamp,
        _timestamp,
      ],
    );
    await overlay.customStatement(
      'INSERT INTO message_annotations ( '
      'message_id, tags, is_starred, is_archived, user_notes, priority, '
      'remind_at, created_at_utc, updated_at_utc) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        30,
        '["private"]',
        1,
        0,
        'private-note',
        5,
        null,
        _timestamp,
        _timestamp,
      ],
    );
    await overlay.customStatement(
      'INSERT INTO message_intent_overlays ( '
      'message_ss_id, is_saved, is_starred, is_archived, user_notes, priority, '
      'remind_at, created_at_utc, updated_at_utc) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        _messageId,
        1,
        1,
        0,
        'private-note',
        4,
        null,
        _timestamp,
        _timestamp,
      ],
    );
    await overlay.customStatement(
      'INSERT INTO message_intent_tags ( '
      'message_ss_id, tag_display, tag_normalized, created_at_utc, updated_at_utc) '
      'VALUES (?, ?, ?, ?, ?)',
      <Object?>[_messageId, 'Private', 'private', _timestamp, _timestamp],
    );
    await overlay.customStatement(
      'INSERT INTO message_user_flags ( '
      'message_guid, is_saved, created_at_utc, updated_at_utc) '
      'VALUES (?, ?, ?, ?)',
      <Object?>[_messageGuid, 1, _timestamp, _timestamp],
    );
    await overlay.customStatement(
      'INSERT INTO message_user_tags ( '
      'message_guid, tag_display, tag_normalized, created_at_utc, updated_at_utc) '
      'VALUES (?, ?, ?, ?, ?)',
      <Object?>[_messageGuid, 'Private', 'private', _timestamp, _timestamp],
    );
    await overlay.customStatement(
      'INSERT INTO conversation_tags ( '
      'id, display_name, normalized_name, visibility_policy, '
      'created_at_utc, updated_at_utc) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[
        1,
        'Private tag',
        'private-tag',
        'ordinary',
        _timestamp,
        _timestamp,
      ],
    );
    await overlay.customStatement(
      'INSERT INTO conversation_tag_assignments ( '
      'conversation_id, tag_id, created_at_utc, updated_at_utc) '
      'VALUES (?, ?, ?, ?)',
      <Object?>[20, 1, _timestamp, _timestamp],
    );
    await overlay.customStatement(
      'INSERT INTO virtual_participants ( '
      'id, display_name, notes, created_at_utc, updated_at_utc) '
      'VALUES (?, ?, ?, ?, ?)',
      <Object?>[
        _virtualParticipantId,
        'Private virtual participant',
        'private-note',
        _timestamp,
        _timestamp,
      ],
    );
    await overlay.customStatement(
      'INSERT INTO handle_to_participant_overrides ( '
      'handle_id, participant_id, virtual_participant_id, reviewed_at, '
      'created_at_utc, updated_at_utc) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[
        40,
        null,
        _virtualParticipantId,
        _timestamp,
        _timestamp,
        _timestamp,
      ],
    );
    await overlay.customStatement(
      'INSERT INTO overlay_settings(key, value) VALUES (?, ?)',
      <Object?>['private-setting', 'private-value'],
    );
    await overlay.customStatement(
      'INSERT INTO favorite_contacts ( '
      'participant_id, sort_order, created_at_utc, last_interaction_utc, '
      'is_favorited, updated_at_utc) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[10, 0, _timestamp, _timestamp, 1, _timestamp],
    );
    await overlay.customStatement(
      'INSERT INTO handle_visibility_overrides ( '
      'handle_id, is_visible, is_blacklisted, updated_at_utc) '
      'VALUES (?, ?, ?, ?)',
      <Object?>[_canonicalHandleId, 1, 0, _timestamp],
    );
    await overlay.customStatement(
      'INSERT INTO dismissed_handles(normalized_handle, dismissed_at_utc) '
      'VALUES (?, ?)',
      <Object?>[_normalizedHandle, _timestamp],
    );
    await overlay.customStatement(
      'INSERT INTO archived_attachments ( '
      'message_guid, import_attachment_id, archive_relative_path, '
      'archived_at_utc, file_size_bytes, content_hash, provenance, '
      'original_local_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        _messageGuid,
        50,
        'aa/synthetic.dat',
        _timestamp,
        7,
        'payload-hash',
        'archived',
        'Attachments/private/source.dat',
      ],
    );
  }
}

final class _SyntheticCancellation implements Exception {
  const _SyntheticCancellation();
}

int _liveId(int rowId) =>
    SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: rowId);

int _historicalId(int rowId) =>
    SourceScopedRowKey.pack(sourceId: 3, sourceRowId: rowId);
