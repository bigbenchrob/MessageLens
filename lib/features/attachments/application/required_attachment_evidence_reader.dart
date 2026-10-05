import 'package:meta/meta.dart';

import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';

/// Opaque, deterministic cursor for the current required attachment universe.
///
/// Ordering is by message GUID and then by the original live `chat.db`
/// attachment ROWID. Neither component is suitable for presentation.
@immutable
final class RequiredAttachmentEvidenceCursor {
  const RequiredAttachmentEvidenceCursor({
    required this.messageGuid,
    required this.liveAttachmentRowId,
  });

  final String messageGuid;
  final int liveAttachmentRowId;

  @override
  bool operator ==(Object other) {
    return other is RequiredAttachmentEvidenceCursor &&
        other.messageGuid == messageGuid &&
        other.liveAttachmentRowId == liveAttachmentRowId;
  }

  @override
  int get hashCode => Object.hash(messageGuid, liveAttachmentRowId);
}

/// The archive location binding against which evidence was observed.
@immutable
final class RequiredAttachmentEvidenceBinding {
  const RequiredAttachmentEvidenceBinding({
    required this.archiveRootPath,
    required this.archiveScopeIdentity,
    required this.archiveGeneration,
  });

  final String archiveRootPath;
  final String archiveScopeIdentity;
  final int archiveGeneration;

  @override
  bool operator ==(Object other) {
    return other is RequiredAttachmentEvidenceBinding &&
        other.archiveRootPath == archiveRootPath &&
        other.archiveScopeIdentity == archiveScopeIdentity &&
        other.archiveGeneration == archiveGeneration;
  }

  @override
  int get hashCode {
    return Object.hash(
      archiveRootPath,
      archiveScopeIdentity,
      archiveGeneration,
    );
  }
}

/// Current factual classification for one required attachment identity.
enum RequiredAttachmentEvidenceCondition {
  coveredAndValid,
  noDurableRecord,
  recordPayloadAbsent,
  recordWrongSize,
  unsafeOrUnverifiablePath,
  conflictingDurableEvidence,
  ambiguousRequiredIdentity,
}

final class RequiredAttachmentEvidenceItem {
  const RequiredAttachmentEvidenceItem({
    required this.cursor,
    required this.archiveKey,
    required this.condition,
    required this.materialFingerprint,
  });

  final RequiredAttachmentEvidenceCursor cursor;

  /// Null only when the current graph evidence cannot establish one exact
  /// compatibility identity. Such an item is never automatically repairable.
  final ArchiveCompatibilityKey? archiveKey;
  final RequiredAttachmentEvidenceCondition condition;

  /// Privacy-safe digest of the material evidence used for this
  /// classification. It detects bounded-read changes without publishing a
  /// source filename or archive-relative path.
  final String materialFingerprint;

  bool get isCovered {
    return condition == RequiredAttachmentEvidenceCondition.coveredAndValid;
  }

  bool get isMissing {
    return switch (condition) {
      RequiredAttachmentEvidenceCondition.noDurableRecord ||
      RequiredAttachmentEvidenceCondition.recordPayloadAbsent ||
      RequiredAttachmentEvidenceCondition.recordWrongSize => true,
      RequiredAttachmentEvidenceCondition.coveredAndValid ||
      RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath ||
      RequiredAttachmentEvidenceCondition.conflictingDurableEvidence ||
      RequiredAttachmentEvidenceCondition.ambiguousRequiredIdentity => false,
    };
  }

  bool get isUnverifiable => !isCovered && !isMissing;
}

final class RequiredAttachmentEvidencePage {
  RequiredAttachmentEvidencePage({
    required Iterable<RequiredAttachmentEvidenceItem> items,
    required this.nextCursor,
    required this.hasMore,
    required this.binding,
  }) : items = List<RequiredAttachmentEvidenceItem>.unmodifiable(items);

  final List<RequiredAttachmentEvidenceItem> items;
  final RequiredAttachmentEvidenceCursor? nextCursor;
  final bool hasMore;
  final RequiredAttachmentEvidenceBinding binding;
}

/// Constant-memory aggregate of a complete keyset scan.
final class RequiredAttachmentEvidenceSummary {
  const RequiredAttachmentEvidenceSummary({
    required this.requiredCount,
    required this.coveredCount,
    required this.missingCount,
    required this.unverifiableCount,
    required this.materialFingerprint,
    required this.binding,
  });

  final int requiredCount;
  final int coveredCount;
  final int missingCount;
  final int unverifiableCount;
  final String materialFingerprint;
  final RequiredAttachmentEvidenceBinding binding;
}

final class RequiredAttachmentEvidenceReadException implements Exception {
  const RequiredAttachmentEvidenceReadException(this.issue);

  final String issue;

  @override
  String toString() => issue;
}

/// Singular read-only definition of the required attachment universe and its
/// current durable coverage evidence.
abstract interface class RequiredAttachmentEvidenceReader {
  Future<RequiredAttachmentEvidencePage> readPage({
    required RequiredAttachmentEvidenceBinding binding,
    RequiredAttachmentEvidenceCursor? after,
    int limit = 75,
  });

  Future<RequiredAttachmentEvidenceSummary> readSummary({
    required RequiredAttachmentEvidenceBinding binding,
    int pageSize = 75,
  });
}
