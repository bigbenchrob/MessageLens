import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/attachment_archive_relocation_metadata_reader.dart';

final class OverlayAttachmentArchiveRelocationMetadataReader
    implements AttachmentArchiveRelocationMetadataReader {
  const OverlayAttachmentArchiveRelocationMetadataReader({
    required OverlayDatabase overlayDatabase,
  }) : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<AttachmentArchiveRelocationMetadata?> readByRelativePath(
    String relativePath,
  ) async {
    final rows = await _overlayDatabase
        .customSelect(
          '''
      SELECT archive_relative_path,
             MIN(file_size_bytes) AS min_size,
             MAX(file_size_bytes) AS max_size,
             COUNT(DISTINCT file_size_bytes) AS size_variants,
             MAX(content_hash) AS selected_hash,
             COUNT(DISTINCT content_hash) AS hash_variants,
             COUNT(*) AS row_count
      FROM archived_attachments
      WHERE archive_relative_path = ?
      GROUP BY archive_relative_path
      ''',
          variables: <Variable<Object>>[Variable<String>(relativePath)],
        )
        .get();
    if (rows.isEmpty) {
      return null;
    }
    return _decode(rows.single);
  }

  @override
  Future<AttachmentArchiveRelocationMetadataPage> readPage({
    required String? afterRelativePath,
    required int limit,
  }) async {
    if (limit <= 0 || limit > 1000) {
      throw ArgumentError.value(limit, 'limit', 'Page limit is out of range.');
    }
    final rows = await _overlayDatabase
        .customSelect(
          '''
      SELECT archive_relative_path,
             MIN(file_size_bytes) AS min_size,
             MAX(file_size_bytes) AS max_size,
             COUNT(DISTINCT file_size_bytes) AS size_variants,
             MAX(content_hash) AS selected_hash,
             COUNT(DISTINCT content_hash) AS hash_variants,
             COUNT(*) AS row_count
      FROM archived_attachments
      WHERE (? IS NULL OR archive_relative_path > ?)
      GROUP BY archive_relative_path
      ORDER BY archive_relative_path
      LIMIT ?
      ''',
          variables: <Variable<Object>>[
            Variable<String>(afterRelativePath),
            Variable<String>(afterRelativePath),
            Variable<int>(limit + 1),
          ],
        )
        .get();
    final hasMore = rows.length > limit;
    final selectedRows = hasMore ? rows.take(limit) : rows;
    return AttachmentArchiveRelocationMetadataPage(
      entries: List<AttachmentArchiveRelocationMetadata>.unmodifiable(
        selectedRows.map(_decode),
      ),
      hasMore: hasMore,
    );
  }

  static AttachmentArchiveRelocationMetadata _decode(QueryRow row) {
    final relativePath = row.read<String>('archive_relative_path');
    final sizeVariants = row.read<int>('size_variants');
    final hashVariants = row.read<int>('hash_variants');
    if (sizeVariants != 1) {
      throw StateError('Conflicting attachment sizes reference $relativePath.');
    }
    if (hashVariants > 1) {
      throw StateError(
        'Conflicting attachment hashes reference $relativePath.',
      );
    }
    final minimumSize = row.read<int>('min_size');
    final maximumSize = row.read<int>('max_size');
    if (minimumSize != maximumSize || minimumSize < 0) {
      throw StateError('Invalid attachment size metadata for $relativePath.');
    }
    final selectedHash = row.readNullable<String>('selected_hash');
    if (selectedHash != null &&
        !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(selectedHash)) {
      throw StateError('Invalid attachment hash metadata for $relativePath.');
    }
    return AttachmentArchiveRelocationMetadata(
      relativePath: relativePath,
      fileSizeBytes: minimumSize,
      contentHash: selectedHash?.toLowerCase(),
      rowCount: row.read<int>('row_count'),
    );
  }
}
