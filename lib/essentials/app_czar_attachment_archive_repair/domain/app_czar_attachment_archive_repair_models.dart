import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

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
    this.automaticPreservationAllowed = true,
  });

  final int requiredCount;
  final int coveredCount;
  final int availableFromMessagesCount;
  final int sourceAbsentCount;
  final int sourceUnknownCount;
  final int recordBackedRecoveryCount;
  final int unsafeOrConflictingCount;

  /// A scheduling hint derived from the current archive-location authority.
  ///
  /// This is not mutation authority. The writer must still acquire and
  /// revalidate the callback-local capability and writable-root lease.
  final bool automaticPreservationAllowed;

  int get needAttentionCount => requiredCount - coveredCount;

  bool get hasAutomaticWork {
    return automaticPreservationAllowed && availableFromMessagesCount > 0;
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
    return coveredCount +
            availableFromMessagesCount +
            sourceAbsentCount +
            sourceUnknownCount +
            recordBackedRecoveryCount +
            unsafeOrConflictingCount ==
        requiredCount;
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
