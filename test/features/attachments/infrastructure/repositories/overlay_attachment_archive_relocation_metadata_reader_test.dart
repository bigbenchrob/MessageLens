import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_relocation_metadata_reader.dart';

void main() {
  group('OverlayAttachmentArchiveRelocationMetadataReader', () {
    late OverlayDatabase database;
    late OverlayAttachmentArchiveRelocationMetadataReader reader;

    setUp(() {
      database = OverlayDatabase(NativeDatabase.memory());
      reader = OverlayAttachmentArchiveRelocationMetadataReader(
        overlayDatabase: database,
      );
    });

    tearDown(() => database.close());

    test('deduplicates compatibility rows by physical relative path', () async {
      await _insert(database, 'one', 1, 'aa/payload.bin', 12, _hash('a'));
      await _insert(database, 'two', 2, 'aa/payload.bin', 12, _hash('a'));

      final metadata = await reader.readByRelativePath('aa/payload.bin');

      expect(metadata, isNotNull);
      expect(metadata!.rowCount, 2);
      expect(metadata.fileSizeBytes, 12);
      expect(metadata.contentHash, _hash('a'));
      final page = await reader.readPage(afterRelativePath: null, limit: 10);
      expect(page.entries, hasLength(1));
    });

    test('accepts mixed null and matching known hash rows', () async {
      await _insert(database, 'one', 1, 'aa/payload.bin', 12, null);
      await _insert(database, 'two', 2, 'aa/payload.bin', 12, _hash('b'));

      final metadata = await reader.readByRelativePath('aa/payload.bin');

      expect(metadata!.contentHash, _hash('b'));
      expect(metadata.rowCount, 2);
    });

    test('fails on conflicting size or hash evidence', () async {
      await _insert(database, 'one', 1, 'aa/payload.bin', 12, _hash('a'));
      await _insert(database, 'two', 2, 'aa/payload.bin', 13, _hash('b'));

      await expectLater(
        reader.readByRelativePath('aa/payload.bin'),
        throwsStateError,
      );
    });

    test('pages in stable relative-path order', () async {
      for (var index = 0; index < 5; index++) {
        await _insert(
          database,
          'guid-$index',
          index,
          'aa/payload-$index.bin',
          index,
          null,
        );
      }

      final first = await reader.readPage(afterRelativePath: null, limit: 2);
      final second = await reader.readPage(
        afterRelativePath: first.entries.last.relativePath,
        limit: 2,
      );
      final third = await reader.readPage(
        afterRelativePath: second.entries.last.relativePath,
        limit: 2,
      );

      expect(first.hasMore, isTrue);
      expect(second.hasMore, isTrue);
      expect(third.hasMore, isFalse);
      expect(
        <String>[
          ...first.entries.map((entry) => entry.relativePath),
          ...second.entries.map((entry) => entry.relativePath),
          ...third.entries.map((entry) => entry.relativePath),
        ],
        <String>[
          'aa/payload-0.bin',
          'aa/payload-1.bin',
          'aa/payload-2.bin',
          'aa/payload-3.bin',
          'aa/payload-4.bin',
        ],
      );
    });
  });
}

String _hash(String character) => List<String>.filled(64, character).join();

Future<void> _insert(
  OverlayDatabase database,
  String guid,
  int attachmentId,
  String relativePath,
  int size,
  String? hash,
) {
  return database.customStatement(
    '''
    INSERT INTO archived_attachments (
      message_guid,
      import_attachment_id,
      archive_relative_path,
      archived_at_utc,
      file_size_bytes,
      content_hash,
      provenance
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''',
    <Object?>[
      guid,
      attachmentId,
      relativePath,
      '2026-09-17T00:00:00.000Z',
      size,
      hash,
      'archived',
    ],
  );
}
