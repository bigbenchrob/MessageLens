import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/attachment_archive_verification_metadata_reader.dart';

/// Groups overlay references by physical archive path without mutating them.
class OverlayAttachmentArchiveVerificationMetadataReader
    implements AttachmentArchiveVerificationMetadataReader {
  const OverlayAttachmentArchiveVerificationMetadataReader({
    required OverlayDatabase overlayDatabase,
  }) : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<AttachmentArchiveVerificationMetadataGroup?> readByRelativePath(
    String relativePath,
  ) async {
    final rows = await _overlayDatabase
        .customSelect(
          _groupedSelect(whereClause: 'WHERE archive_relative_path = ?'),
          variables: <Variable<Object>>[Variable<String>(relativePath)],
        )
        .get();
    if (rows.isEmpty) {
      return null;
    }
    return _decode(rows.single);
  }

  @override
  Future<AttachmentArchiveVerificationMetadataPage> readPage({
    required String? afterRelativePath,
    required int limit,
  }) async {
    if (limit <= 0 || limit > 1000) {
      throw ArgumentError.value(limit, 'limit', 'Page limit is out of range.');
    }
    final rows = await _overlayDatabase
        .customSelect(
          '''
${_groupedSelect(whereClause: 'WHERE (? IS NULL OR archive_relative_path > ?)')}
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
    return AttachmentArchiveVerificationMetadataPage(
      groups: List<AttachmentArchiveVerificationMetadataGroup>.unmodifiable(
        selectedRows.map(_decode),
      ),
      hasMore: hasMore,
    );
  }

  static String _groupedSelect({required String whereClause}) {
    return '''
SELECT archive_relative_path,
       MIN(file_size_bytes) AS min_size,
       MAX(file_size_bytes) AS max_size,
       COUNT(DISTINCT file_size_bytes) AS size_variants,
       MAX(content_hash) AS selected_hash,
       COUNT(DISTINCT content_hash) AS hash_variants,
       COUNT(*) AS reference_count
FROM archived_attachments
$whereClause
GROUP BY archive_relative_path
''';
  }

  static AttachmentArchiveVerificationMetadataGroup _decode(QueryRow row) {
    final relativePath = row.read<String>('archive_relative_path');
    final normalizedRelativePath = path.normalize(relativePath);
    if (relativePath.isEmpty ||
        path.isAbsolute(relativePath) ||
        normalizedRelativePath != relativePath ||
        normalizedRelativePath == '.' ||
        normalizedRelativePath == '..' ||
        normalizedRelativePath.startsWith('../')) {
      throw StateError(
        'Attachment archive metadata contains an unsafe path: $relativePath.',
      );
    }
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
    return AttachmentArchiveVerificationMetadataGroup(
      relativePath: relativePath,
      fileSizeBytes: minimumSize,
      contentHash: selectedHash?.toLowerCase(),
      referenceCount: row.read<int>('reference_count'),
    );
  }
}
