import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_verification_metadata_reader.dart';

void main() {
  group('OverlayAttachmentArchiveVerificationMetadataReader', () {
    late OverlayDatabase database;
    late OverlayAttachmentArchiveVerificationMetadataReader reader;

    setUp(() {
      database = OverlayDatabase(NativeDatabase.memory());
      reader = OverlayAttachmentArchiveVerificationMetadataReader(
        overlayDatabase: database,
      );
    });

    tearDown(() => database.close());

    test(
      'groups references by physical relative path without writes',
      () async {
        await _insert(database, 'one', 1, 'aa/payload.bin', 12, _hash('a'));
        await _insert(database, 'two', 2, 'aa/payload.bin', 12, _hash('a'));
        final before = await _rowCount(database);

        final group = await reader.readByRelativePath('aa/payload.bin');
        final page = await reader.readPage(afterRelativePath: null, limit: 10);

        expect(group, isNotNull);
        expect(group!.referenceCount, 2);
        expect(group.fileSizeBytes, 12);
        expect(group.contentHash, _hash('a'));
        expect(page.groups, hasLength(1));
        expect(await _rowCount(database), before);
      },
    );

    test('accepts null plus one matching non-null hash', () async {
      await _insert(database, 'one', 1, 'aa/payload.bin', 12, null);
      await _insert(database, 'two', 2, 'aa/payload.bin', 12, _hash('b'));

      final group = await reader.readByRelativePath('aa/payload.bin');

      expect(group!.contentHash, _hash('b'));
      expect(group.referenceCount, 2);
    });

    test('rejects conflicting size and non-null hash evidence', () async {
      await _insert(database, 'one', 1, 'aa/payload.bin', 12, _hash('a'));
      await _insert(database, 'two', 2, 'aa/payload.bin', 13, _hash('b'));
      await _insert(database, 'three', 3, 'bb/payload.bin', 12, _hash('a'));
      await _insert(database, 'four', 4, 'bb/payload.bin', 12, _hash('b'));

      await expectLater(
        reader.readByRelativePath('aa/payload.bin'),
        throwsStateError,
      );
      await expectLater(
        reader.readByRelativePath('bb/payload.bin'),
        throwsStateError,
      );
    });

    test('rejects unsafe grouped metadata paths', () async {
      await _insert(database, 'unsafe', 1, '../escape.bin', 12, null);

      await expectLater(
        reader.readPage(afterRelativePath: null, limit: 10),
        throwsStateError,
      );
    });

    test('pages in stable grouped relative-path order', () async {
      for (var index = 0; index < 7; index++) {
        await _insert(
          database,
          'guid-$index',
          index,
          'aa/payload-$index.bin',
          index,
          null,
        );
      }

      final paths = <String>[];
      String? cursor;
      while (true) {
        final page = await reader.readPage(afterRelativePath: cursor, limit: 3);
        paths.addAll(page.groups.map((group) => group.relativePath));
        if (!page.hasMore) {
          break;
        }
        cursor = page.groups.last.relativePath;
      }

      expect(
        paths,
        List<String>.generate(7, (index) => 'aa/payload-$index.bin'),
      );
    });
  });
}

String _hash(String character) => List<String>.filled(64, character).join();

Future<int> _rowCount(OverlayDatabase database) async {
  final row = await database
      .customSelect('SELECT COUNT(*) AS count FROM archived_attachments')
      .getSingle();
  return row.read<int>('count');
}

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
      '2026-09-18T00:00:00.000Z',
      size,
      hash,
      'archived',
    ],
  );
}
