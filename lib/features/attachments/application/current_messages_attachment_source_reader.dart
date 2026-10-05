import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';

const int currentMessagesAttachmentSourceObservationPageLimit = 100;

/// Current, read-only evidence about one exact live Messages attachment.
enum CurrentMessagesAttachmentSourceCondition {
  available,
  absent,
  unreadable,
  sourceUnavailable,
  sourceInconclusive,
  unknown,
}

/// Source evidence bound to the archive compatibility key that requested it.
///
/// [sourcePath] is intentionally an application-only value. Presentation must
/// project aggregate conditions rather than exposing private filenames.
final class CurrentMessagesAttachmentSourceObservation {
  const CurrentMessagesAttachmentSourceObservation({
    required this.archiveKey,
    required this.condition,
    this.sourcePath,
    this.mimeType,
    this.fileSizeBytes,
    this.modifiedAtMicrosecondsSinceEpoch,
    this.issue,
  });

  const CurrentMessagesAttachmentSourceObservation.available({
    required ArchiveCompatibilityKey archiveKey,
    required String sourcePath,
    required String mimeType,
    required int fileSizeBytes,
    required int modifiedAtMicrosecondsSinceEpoch,
  }) : this(
         archiveKey: archiveKey,
         condition: CurrentMessagesAttachmentSourceCondition.available,
         sourcePath: sourcePath,
         mimeType: mimeType,
         fileSizeBytes: fileSizeBytes,
         modifiedAtMicrosecondsSinceEpoch: modifiedAtMicrosecondsSinceEpoch,
       );

  const CurrentMessagesAttachmentSourceObservation.absent({
    required ArchiveCompatibilityKey archiveKey,
    String? issue,
  }) : this(
         archiveKey: archiveKey,
         condition: CurrentMessagesAttachmentSourceCondition.absent,
         issue: issue,
       );

  const CurrentMessagesAttachmentSourceObservation.unreadable({
    required ArchiveCompatibilityKey archiveKey,
    String? issue,
  }) : this(
         archiveKey: archiveKey,
         condition: CurrentMessagesAttachmentSourceCondition.unreadable,
         issue: issue,
       );

  const CurrentMessagesAttachmentSourceObservation.sourceUnavailable({
    required ArchiveCompatibilityKey archiveKey,
    String? issue,
  }) : this(
         archiveKey: archiveKey,
         condition: CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
         issue: issue,
       );

  const CurrentMessagesAttachmentSourceObservation.sourceInconclusive({
    required ArchiveCompatibilityKey archiveKey,
    String? issue,
  }) : this(
         archiveKey: archiveKey,
         condition: CurrentMessagesAttachmentSourceCondition.sourceInconclusive,
         issue: issue,
       );

  const CurrentMessagesAttachmentSourceObservation.unknown({
    required ArchiveCompatibilityKey archiveKey,
    String? issue,
  }) : this(
         archiveKey: archiveKey,
         condition: CurrentMessagesAttachmentSourceCondition.unknown,
         issue: issue,
       );

  final ArchiveCompatibilityKey archiveKey;
  final CurrentMessagesAttachmentSourceCondition condition;
  final String? sourcePath;
  final String? mimeType;
  final int? fileSizeBytes;
  final int? modifiedAtMicrosecondsSinceEpoch;
  final String? issue;

  bool get isAvailable =>
      condition == CurrentMessagesAttachmentSourceCondition.available;

  String requireSourcePath() {
    final value = sourcePath;
    if (!isAvailable || value == null || value.isEmpty) {
      throw StateError('Current Messages source payload is not available.');
    }
    return value;
  }

  /// Whether two observations prove the same material source file evidence.
  bool hasSameMaterialEvidenceAs(
    CurrentMessagesAttachmentSourceObservation other,
  ) {
    return isAvailable &&
        other.isAvailable &&
        archiveKey == other.archiveKey &&
        sourcePath == other.sourcePath &&
        mimeType == other.mimeType &&
        fileSizeBytes == other.fileSizeBytes &&
        modifiedAtMicrosecondsSinceEpoch ==
            other.modifiedAtMicrosecondsSinceEpoch;
  }
}

/// Reads current `chat.db` and current payload metadata for one exact key.
///
/// Implementations must prove both the message GUID and original live
/// attachment ROWID. A retained imported filename is not authoritative.
abstract interface class CurrentMessagesAttachmentSourceReader {
  Future<CurrentMessagesAttachmentSourceObservation> observeCurrent(
    ArchiveCompatibilityKey archiveKey,
  );

  /// Observes at most 100 exact keys using one bounded source database read.
  ///
  /// Results retain input order. Payload metadata/readability checks are
  /// performed sequentially so a page never opens an unbounded set of files.
  Future<List<CurrentMessagesAttachmentSourceObservation>> observeCurrentPage(
    List<ArchiveCompatibilityKey> archiveKeys,
  );
}
