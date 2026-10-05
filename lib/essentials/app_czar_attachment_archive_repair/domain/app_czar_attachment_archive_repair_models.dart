import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

/// The maximum number of exact attachment identities one human confirmation
/// may authorize.
const int appCzarAttachmentArchiveRepairMaximumAuthorizedItems = 75;

/// Canonicalizes one admitted archive root without consulting the filesystem.
String canonicalAppCzarAttachmentArchivePath(String rawPath) {
  return path.normalize(path.absolute(rawPath.trim()));
}

/// The exact AppCzar/archive evidence to which one repair occurrence is bound.
///
/// [resolvedArchivePath] is authority evidence only. It must never be rendered
/// by the repair presentation.
@immutable
final class AppCzarAttachmentArchiveRepairBinding {
  factory AppCzarAttachmentArchiveRepairBinding({
    required int occurrenceId,
    required int assessmentGeneration,
    required String archiveScopeIdentity,
    required int archiveGeneration,
    required String resolvedArchivePath,
  }) {
    return AppCzarAttachmentArchiveRepairBinding._(
      occurrenceId: occurrenceId,
      assessmentGeneration: assessmentGeneration,
      archiveScopeIdentity: archiveScopeIdentity,
      archiveGeneration: archiveGeneration,
      resolvedArchivePath: canonicalAppCzarAttachmentArchivePath(
        resolvedArchivePath,
      ),
    );
  }

  const AppCzarAttachmentArchiveRepairBinding._({
    required this.occurrenceId,
    required this.assessmentGeneration,
    required this.archiveScopeIdentity,
    required this.archiveGeneration,
    required this.resolvedArchivePath,
  });

  final int occurrenceId;
  final int assessmentGeneration;
  final String archiveScopeIdentity;
  final int archiveGeneration;
  final String resolvedArchivePath;

  bool hasSameArchiveBinding(AppCzarAttachmentArchiveRepairBinding other) {
    return archiveScopeIdentity == other.archiveScopeIdentity &&
        archiveGeneration == other.archiveGeneration &&
        resolvedArchivePath == other.resolvedArchivePath;
  }
}

/// Privacy-safe presentation handle for one exact, memory-only repair plan.
///
/// This handle is not mutation authority. The occurrence-owned executor keeps
/// the exact ordered compatibility keys and source evidence in memory and will
/// accept this handle only while that same unconsumed plan remains current.
@immutable
final class AppCzarAttachmentArchiveRepairBatchAuthorization {
  const AppCzarAttachmentArchiveRepairBatchAuthorization({
    required this.planIdentity,
    required this.itemCount,
    required this.totalKnownBytes,
  });

  final String planIdentity;
  final int itemCount;

  /// Exact aggregate source bytes, or null when a trustworthy aggregate could
  /// not be established. Unknown byte scope is never automatically admitted.
  final int? totalKnownBytes;

  bool get hasKnownByteScope => totalKnownBytes != null;

  bool get isCoherent {
    final bytes = totalKnownBytes;
    return planIdentity.isNotEmpty &&
        itemCount > 0 &&
        itemCount <= appCzarAttachmentArchiveRepairMaximumAuthorizedItems &&
        (bytes == null || bytes >= 0);
  }
}

/// Privacy-safe current aggregate evidence for required attachment payloads.
@immutable
final class AppCzarAttachmentArchiveRepairSnapshot {
  const AppCzarAttachmentArchiveRepairSnapshot({
    required this.requiredCount,
    required this.coveredCount,
    required this.availableFromMessagesCount,
    required this.sourceAbsentCount,
    required this.sourceUnknownCount,
    required this.recordBackedRecoveryCount,
    required this.unsafeOrConflictingCount,
    this.nextBatchAuthorization,
    this.automaticPreservationAllowed = true,
  });

  final int requiredCount;
  final int coveredCount;
  final int availableFromMessagesCount;
  final int sourceAbsentCount;
  final int sourceUnknownCount;
  final int recordBackedRecoveryCount;
  final int unsafeOrConflictingCount;
  final AppCzarAttachmentArchiveRepairBatchAuthorization?
  nextBatchAuthorization;

  /// A scheduling hint derived from the current archive-location authority.
  ///
  /// This is not mutation authority. The writer must still acquire and
  /// revalidate the callback-local capability and writable-root lease.
  final bool automaticPreservationAllowed;

  int get needAttentionCount => requiredCount - coveredCount;

  bool get hasAutomaticWork {
    final authorization = nextBatchAuthorization;
    return automaticPreservationAllowed &&
        availableFromMessagesCount > 0 &&
        authorization != null &&
        authorization.isCoherent &&
        authorization.hasKnownByteScope;
  }

  bool get isCoherent {
    final counts = <int>[
      requiredCount,
      coveredCount,
      availableFromMessagesCount,
      sourceAbsentCount,
      sourceUnknownCount,
      recordBackedRecoveryCount,
      unsafeOrConflictingCount,
    ];
    if (counts.any((count) => count < 0)) {
      return false;
    }
    final countsAreCoherent =
        coveredCount +
            availableFromMessagesCount +
            sourceAbsentCount +
            sourceUnknownCount +
            recordBackedRecoveryCount +
            unsafeOrConflictingCount ==
        requiredCount;
    if (!countsAreCoherent) {
      return false;
    }
    final authorization = nextBatchAuthorization;
    if (availableFromMessagesCount == 0) {
      return authorization == null;
    }
    return authorization != null &&
        authorization.isCoherent &&
        authorization.itemCount <= availableFromMessagesCount;
  }
}

enum AppCzarAttachmentArchiveRepairObservationKind {
  coverageComplete,
  coverageIncomplete,
  coverageUnknown,
  sourceAccessLost,
  archiveBindingChanged,
  stopped,
}

/// A fresh factual result from inspection or a settled preservation pass.
@immutable
final class AppCzarAttachmentArchiveRepairObservation {
  const AppCzarAttachmentArchiveRepairObservation({
    required this.kind,
    required this.binding,
    this.snapshot,
  });

  final AppCzarAttachmentArchiveRepairObservationKind kind;
  final AppCzarAttachmentArchiveRepairBinding binding;
  final AppCzarAttachmentArchiveRepairSnapshot? snapshot;

  bool get isCoherent {
    return switch (kind) {
      AppCzarAttachmentArchiveRepairObservationKind.coverageComplete =>
        snapshot != null &&
            snapshot!.isCoherent &&
            snapshot!.coveredCount == snapshot!.requiredCount,
      AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete =>
        snapshot != null &&
            snapshot!.isCoherent &&
            snapshot!.needAttentionCount > 0,
      AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown ||
      AppCzarAttachmentArchiveRepairObservationKind.sourceAccessLost ||
      AppCzarAttachmentArchiveRepairObservationKind.archiveBindingChanged ||
      AppCzarAttachmentArchiveRepairObservationKind.stopped => true,
    };
  }
}

@immutable
final class AppCzarAttachmentArchiveRepairProgress {
  const AppCzarAttachmentArchiveRepairProgress({
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  bool get isCoherent {
    return completedCount >= 0 &&
        totalCount >= 0 &&
        completedCount <= totalCount;
  }
}

typedef AppCzarAttachmentArchiveRepairProgressObserver =
    void Function(AppCzarAttachmentArchiveRepairProgress progress);
