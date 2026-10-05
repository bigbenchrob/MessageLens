import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/application/required_attachment_evidence_reader.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/sqlite_required_attachment_evidence_reader.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('SqliteRequiredAttachmentEvidenceReader', () {
    test('is the sole owner of the exact required-set SQL marker', () {
      const marker = "NULLIF(TRIM(m.guid), '') IS NOT NULL";
      final owners = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where((file) => file.readAsStringSync().contains(marker))
          .map((file) => path.normalize(file.path))
          .toList(growable: false);

      expect(owners, hasLength(1));
      expect(
        owners.single,
        endsWith(
          path.join(
            'lib',
            'features',
            'attachments',
            'infrastructure',
            'repositories',
            'sqlite_required_attachment_evidence_reader.dart',
          ),
        ),
      );
    });

    test('classifies every required item from one shared definition', () async {
      final fixture = await _EvidenceFixture.create();
      addTearDown(fixture.dispose);
      fixture.addRequired(messageGuid: 'a-covered', attachmentRowId: 10);
      fixture.addRequired(messageGuid: 'b-no-record', attachmentRowId: 11);
      fixture.addRequired(messageGuid: 'c-absent', attachmentRowId: 12);
      fixture.addRequired(messageGuid: 'd-wrong-size', attachmentRowId: 13);
      fixture.addRequired(messageGuid: 'e-unsafe', attachmentRowId: 14);
      fixture.addRequired(messageGuid: 'f-conflict-one', attachmentRowId: 15);
      fixture.addRequired(messageGuid: 'g-conflict-two', attachmentRowId: 16);
      fixture.addRequired(
        messageGuid: 'h-ambiguous',
        attachmentRowId: 0,
        allowInvalidLiveRowId: true,
      );
      fixture.writePayload('objects/covered.bin', <int>[1, 2, 3]);
      fixture.writePayload('objects/wrong.bin', <int>[1, 2]);
      fixture.writePayload('objects/conflict.bin', <int>[1, 2, 3]);
      fixture.writeRecord(
        messageGuid: 'a-covered',
        attachmentRowId: 10,
        relativePath: 'objects/covered.bin',
        size: 3,
      );
      fixture.writeRecord(
        messageGuid: 'c-absent',
        attachmentRowId: 12,
        relativePath: 'objects/absent.bin',
        size: 3,
      );
      fixture.writeRecord(
        messageGuid: 'd-wrong-size',
        attachmentRowId: 13,
        relativePath: 'objects/wrong.bin',
        size: 3,
      );
      fixture.writeRecord(
        messageGuid: 'e-unsafe',
        attachmentRowId: 14,
        relativePath: '../outside.bin',
        size: 3,
      );
      fixture.writeRecord(
        messageGuid: 'f-conflict-one',
        attachmentRowId: 15,
        relativePath: 'objects/conflict.bin',
        size: 3,
      );
      fixture.writeRecord(
        messageGuid: 'g-conflict-two',
        attachmentRowId: 16,
        relativePath: 'objects/conflict.bin',
        size: 4,
      );

      final page = await fixture.reader.readPage(
        binding: fixture.binding,
        limit: 75,
      );

      expect(page.hasMore, isFalse);
      expect(page.binding, fixture.binding);
      expect(
        <String, RequiredAttachmentEvidenceCondition>{
          for (final item in page.items)
            item.cursor.messageGuid: item.condition,
        },
        <String, RequiredAttachmentEvidenceCondition>{
          'a-covered': RequiredAttachmentEvidenceCondition.coveredAndValid,
          'b-no-record': RequiredAttachmentEvidenceCondition.noDurableRecord,
          'c-absent': RequiredAttachmentEvidenceCondition.recordPayloadAbsent,
          'd-wrong-size': RequiredAttachmentEvidenceCondition.recordWrongSize,
          'e-unsafe':
              RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath,
          'f-conflict-one':
              RequiredAttachmentEvidenceCondition.conflictingDurableEvidence,
          'g-conflict-two':
              RequiredAttachmentEvidenceCondition.conflictingDurableEvidence,
          'h-ambiguous':
              RequiredAttachmentEvidenceCondition.ambiguousRequiredIdentity,
        },
      );

      final summary = await fixture.reader.readSummary(
        binding: fixture.binding,
      );
      expect(summary.requiredCount, 8);
      expect(summary.coveredCount, 1);
      expect(summary.missingCount, 3);
      expect(summary.unverifiableCount, 4);
    });

    test('applies the exact live conventional required filters', () async {
      final fixture = await _EvidenceFixture.create();
      addTearDown(fixture.dispose);
      fixture.addRequired(messageGuid: 'included', attachmentRowId: 10);
      fixture.addRequired(messageGuid: '   ', attachmentRowId: 11);
      fixture.addRequired(
        messageGuid: 'blank-filename',
        attachmentRowId: 12,
        filename: '   ',
      );
      fixture.addRequired(
        messageGuid: 'blank-mime',
        attachmentRowId: 13,
        mimeType: '   ',
      );
      fixture.addRequired(
        messageGuid: 'historical-message',
        attachmentRowId: 14,
        messageSourceId: liveChatDbSourceId + 1,
      );
      fixture.addRequired(
        messageGuid: 'historical-attachment',
        attachmentRowId: 15,
        attachmentSourceId: liveChatDbSourceId + 1,
      );

      final page = await fixture.reader.readPage(binding: fixture.binding);

      expect(page.items.map((item) => item.cursor.messageGuid), <String>[
        'included',
      ]);
    });

    test('uses deterministic bounded composite keyset pages', () async {
      final fixture = await _EvidenceFixture.create();
      addTearDown(fixture.dispose);
      fixture.addRequiredBatch(151);

      final first = await fixture.reader.readPage(
        binding: fixture.binding,
        limit: 75,
      );
      final second = await fixture.reader.readPage(
        binding: fixture.binding,
        after: first.nextCursor,
        limit: 75,
      );
      final third = await fixture.reader.readPage(
        binding: fixture.binding,
        after: second.nextCursor,
        limit: 75,
      );

      expect(first.items, hasLength(75));
      expect(second.items, hasLength(75));
      expect(third.items, hasLength(1));
      expect(first.hasMore, isTrue);
      expect(second.hasMore, isTrue);
      expect(third.hasMore, isFalse);
      final cursors = <RequiredAttachmentEvidenceCursor>[
        ...first.items.map((item) => item.cursor),
        ...second.items.map((item) => item.cursor),
        ...third.items.map((item) => item.cursor),
      ];
      expect(cursors.toSet(), hasLength(151));
      expect(
        cursors.map((cursor) => cursor.messageGuid),
        orderedEquals(
          List<String>.generate(
            151,
            (index) => 'message-${index.toString().padLeft(3, '0')}',
          ),
        ),
      );
      expect(
        () => fixture.reader.readPage(binding: fixture.binding, limit: 101),
        throwsArgumentError,
      );
    });

    test(
      'detects required same-path conflicts across pages and ignores unrelated records',
      () async {
        final fixture = await _EvidenceFixture.create();
        addTearDown(fixture.dispose);
        fixture.addRequired(messageGuid: 'a-first', attachmentRowId: 10);
        fixture.addRequired(messageGuid: 'm-good', attachmentRowId: 11);
        fixture.addRequired(messageGuid: 'z-last', attachmentRowId: 12);
        fixture.writePayload('objects/conflict.bin', <int>[1, 2, 3]);
        fixture.writePayload('objects/good.bin', <int>[1, 2, 3]);
        fixture.writeRecord(
          messageGuid: 'a-first',
          attachmentRowId: 10,
          relativePath: 'objects/conflict.bin',
          size: 3,
        );
        fixture.writeRecord(
          messageGuid: 'z-last',
          attachmentRowId: 12,
          relativePath: 'objects/conflict.bin',
          size: 4,
        );
        fixture.writeRecord(
          messageGuid: 'm-good',
          attachmentRowId: 11,
          relativePath: 'objects/good.bin',
          size: 3,
        );
        fixture.writeRecord(
          messageGuid: 'not-required',
          attachmentRowId: 999,
          relativePath: 'objects/good.bin',
          size: 99,
        );

        final first = await fixture.reader.readPage(
          binding: fixture.binding,
          limit: 1,
        );
        final second = await fixture.reader.readPage(
          binding: fixture.binding,
          after: first.nextCursor,
          limit: 1,
        );
        final third = await fixture.reader.readPage(
          binding: fixture.binding,
          after: second.nextCursor,
          limit: 1,
        );

        expect(
          first.items.single.condition,
          RequiredAttachmentEvidenceCondition.conflictingDurableEvidence,
        );
        expect(
          second.items.single.condition,
          RequiredAttachmentEvidenceCondition.coveredAndValid,
        );
        expect(
          third.items.single.condition,
          RequiredAttachmentEvidenceCondition.conflictingDurableEvidence,
        );
      },
    );

    test('disabled preservation has an empty shared universe', () async {
      final fixture = await _EvidenceFixture.create();
      addTearDown(fixture.dispose);
      fixture.addRequired(messageGuid: 'required', attachmentRowId: 10);
      fixture.setArchiveEnabled(enabled: false);

      final page = await fixture.reader.readPage(binding: fixture.binding);
      final summary = await fixture.reader.readSummary(
        binding: fixture.binding,
      );

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
      expect(summary.requiredCount, 0);
      expect(summary.coveredCount, 0);
      expect(summary.missingCount, 0);
      expect(summary.unverifiableCount, 0);
    });

    test('classifies a crossed symbolic link as unsafe evidence', () async {
      final fixture = await _EvidenceFixture.create();
      addTearDown(fixture.dispose);
      fixture.addRequired(messageGuid: 'linked', attachmentRowId: 10);
      final target = fixture.writePayload('target.bin', <int>[1, 2, 3]);
      final linkedPath = path.join(
        fixture.archiveRoot.path,
        'objects',
        'linked.bin',
      );
      Directory(path.dirname(linkedPath)).createSync(recursive: true);
      Link(linkedPath).createSync(target.path);
      fixture.writeRecord(
        messageGuid: 'linked',
        attachmentRowId: 10,
        relativePath: 'objects/linked.bin',
        size: 3,
      );

      final page = await fixture.reader.readPage(binding: fixture.binding);
      final summary = await fixture.reader.readSummary(
        binding: fixture.binding,
      );

      expect(
        page.items.single.condition,
        RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath,
      );
      expect(summary.requiredCount, 1);
      expect(summary.missingCount, 0);
      expect(summary.unverifiableCount, 1);
    });
  });
}

final class _EvidenceFixture {
  _EvidenceFixture({required this.root, required this.archiveRoot})
    : reader = SqliteRequiredAttachmentEvidenceReader(
        admittedRootPath: root.path,
      ),
      binding = RequiredAttachmentEvidenceBinding(
        archiveRootPath: archiveRoot.path,
        archiveScopeIdentity: 'fixture-scope',
        archiveGeneration: 7,
      );

  static Future<_EvidenceFixture> create() async {
    final root = await Directory.systemTemp.createTemp(
      'required_attachment_evidence_',
    );
    final archiveRoot = Directory(path.join(root.path, 'attachment_archive'))
      ..createSync();
    final graph = sqlite3.open(
      appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: root.path,
      ),
    );
    graph
      ..execute('CREATE TABLE messages (ss_id INTEGER PRIMARY KEY, guid TEXT)')
      ..execute('''
CREATE TABLE attachments (
  ss_id INTEGER PRIMARY KEY,
  filename TEXT,
  mime_type TEXT
)
''')
      ..execute('''
CREATE TABLE message_to_attachment (
  message_ss_id INTEGER NOT NULL,
  attachment_ss_id INTEGER NOT NULL
)
''')
      ..dispose();
    final overlay = sqlite3.open(
      appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path),
    );
    overlay
      ..execute(
        'CREATE TABLE overlay_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      )
      ..execute('''
CREATE TABLE archived_attachments (
  message_guid TEXT NOT NULL,
  import_attachment_id INTEGER NOT NULL,
  archive_relative_path,
  file_size_bytes,
  content_hash,
  UNIQUE (message_guid, import_attachment_id)
)
''')
      ..dispose();
    return _EvidenceFixture(root: root, archiveRoot: archiveRoot);
  }

  final Directory root;
  final Directory archiveRoot;
  final SqliteRequiredAttachmentEvidenceReader reader;
  final RequiredAttachmentEvidenceBinding binding;

  String get _graphPath => appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: root.path,
  );
  String get _overlayPath =>
      appDatabasePath(AppDatabaseFile.overlay, databaseDirectory: root.path);

  Future<void> dispose() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  }

  void addRequired({
    required String messageGuid,
    required int attachmentRowId,
    String filename = '/source/payload.bin',
    String? mimeType = 'application/octet-stream',
    int messageSourceId = liveChatDbSourceId,
    int attachmentSourceId = liveChatDbSourceId,
    bool allowInvalidLiveRowId = false,
  }) {
    final messageRowId = 1000 + attachmentRowId;
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: messageSourceId,
      sourceRowId: messageRowId < 1 ? 1000 : messageRowId,
    );
    final attachmentSsId = allowInvalidLiveRowId
        ? attachmentSourceId << SourceScopedRowKey.sourceRowIdBits
        : SourceScopedRowKey.pack(
            sourceId: attachmentSourceId,
            sourceRowId: attachmentRowId,
          );
    final graph = sqlite3.open(_graphPath);
    graph
      ..execute('INSERT INTO messages VALUES (?, ?)', <Object?>[
        messageSsId,
        messageGuid,
      ])
      ..execute('INSERT INTO attachments VALUES (?, ?, ?)', <Object?>[
        attachmentSsId,
        filename,
        mimeType,
      ])
      ..execute('INSERT INTO message_to_attachment VALUES (?, ?)', <Object?>[
        messageSsId,
        attachmentSsId,
      ])
      ..dispose();
  }

  void addRequiredBatch(int count) {
    final graph = sqlite3.open(_graphPath);
    graph.execute('BEGIN;');
    try {
      for (var index = 0; index < count; index += 1) {
        final sourceRowId = index + 1;
        final messageSsId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: sourceRowId,
        );
        final attachmentSsId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: sourceRowId,
        );
        graph
          ..execute('INSERT INTO messages VALUES (?, ?)', <Object?>[
            messageSsId,
            'message-${index.toString().padLeft(3, '0')}',
          ])
          ..execute('INSERT INTO attachments VALUES (?, ?, ?)', <Object?>[
            attachmentSsId,
            '/source/$index.bin',
            'application/octet-stream',
          ])
          ..execute(
            'INSERT INTO message_to_attachment VALUES (?, ?)',
            <Object?>[messageSsId, attachmentSsId],
          );
      }
      graph.execute('COMMIT;');
    } catch (_) {
      graph.execute('ROLLBACK;');
      rethrow;
    } finally {
      graph.dispose();
    }
  }

  void writeRecord({
    required String messageGuid,
    required int attachmentRowId,
    required String relativePath,
    required int size,
    String? hash,
  }) {
    final overlay = sqlite3.open(_overlayPath);
    overlay
      ..execute(
        'INSERT INTO archived_attachments VALUES (?, ?, ?, ?, ?)',
        <Object?>[messageGuid, attachmentRowId, relativePath, size, hash],
      )
      ..dispose();
  }

  File writePayload(String relativePath, List<int> bytes) {
    final file = File(path.join(archiveRoot.path, relativePath));
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes, flush: true);
    return file;
  }

  void setArchiveEnabled({required bool enabled}) {
    final overlay = sqlite3.open(_overlayPath);
    overlay
      ..execute(
        'INSERT OR REPLACE INTO overlay_settings VALUES (?, ?)',
        <Object?>['attachment_archive_enabled', enabled.toString()],
      )
      ..dispose();
  }
}
