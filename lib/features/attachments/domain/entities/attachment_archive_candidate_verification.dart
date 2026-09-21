import 'package:meta/meta.dart';

import 'attachment_archive_location_configuration.dart';

enum AttachmentArchiveCandidateVerificationOutcome {
  candidateComplete,
  candidateBehind,
  candidateInvalid,
  sourceUnavailable,
  candidateUnavailable,
  verificationFailed,
}

enum AttachmentArchivePreservationClassification {
  metadataKnown,
  contentAddressedUnreferenced,
  byIdUnreferenced,
  installerDebris,
}

enum AttachmentArchiveVerificationPhase {
  preparing,
  metadata,
  sourceCoverage,
  candidateExtras,
}

/// Process-local structural classification retained for approval revalidation.
///
/// This is comparison evidence only. It is never serialized, projected into
/// workflow presentation state, or accepted as archive mutation authority.
enum AttachmentArchiveStructuralEntryKind {
  directory,
  preservationPayload,
  installerDebris,
}

/// One ordered source entry from a full archive verification.
///
/// Directory evidence retains only path and kind because adding a descendant
/// legitimately changes parent directory timestamps. Regular-file evidence
/// additionally retains size, modified/change timestamps, preservation
/// classification, and any grouped metadata size/hash/reference-count facts.
/// This is bounded by archive entry count and never retains payload bytes.
@immutable
final class AttachmentArchiveStructuralEntryEvidence {
  const AttachmentArchiveStructuralEntryEvidence({
    required this.relativePath,
    required this.kind,
    required this.sizeBytes,
    required this.modifiedMicros,
    required this.changedMicros,
    required this.classification,
    required this.metadataFileSizeBytes,
    required this.metadataContentHash,
    required this.metadataReferenceCount,
  });

  final String relativePath;
  final AttachmentArchiveStructuralEntryKind kind;
  final int sizeBytes;
  final int? modifiedMicros;
  final int? changedMicros;
  final AttachmentArchivePreservationClassification? classification;
  final int? metadataFileSizeBytes;
  final String? metadataContentHash;
  final int? metadataReferenceCount;

  bool hasSameExistingEvidence(AttachmentArchiveStructuralEntryEvidence other) {
    return relativePath == other.relativePath &&
        kind == other.kind &&
        sizeBytes == other.sizeBytes &&
        modifiedMicros == other.modifiedMicros &&
        changedMicros == other.changedMicros &&
        classification == other.classification &&
        metadataFileSizeBytes == other.metadataFileSizeBytes &&
        metadataContentHash == other.metadataContentHash &&
        metadataReferenceCount == other.metadataReferenceCount;
  }
}

/// Ordered, process-local source structure retained by a full verifier pass.
///
/// The Settings workflow keeps the complete/behind result in a private field;
/// this baseline is intentionally absent from the public workflow state and
/// from the durable adoption transaction.
@immutable
final class AttachmentArchiveVerificationStructuralBaseline {
  AttachmentArchiveVerificationStructuralBaseline({
    required List<AttachmentArchiveStructuralEntryEvidence> sourceEntries,
  }) : sourceEntries = List.unmodifiable(sourceEntries);

  final List<AttachmentArchiveStructuralEntryEvidence> sourceEntries;
}

@immutable
final class AttachmentArchiveCandidateAccess {
  const AttachmentArchiveCandidateAccess({
    required this.directoryPath,
    required this.isPhysicallyWritable,
  });

  /// A bookmark-resolved path supplied by the future application workflow.
  final String directoryPath;

  /// Bounded native availability evidence. Verification never probes writes.
  final bool isPhysicallyWritable;
}

@immutable
final class AttachmentArchiveVerificationProgress {
  const AttachmentArchiveVerificationProgress({
    required this.phase,
    required this.filesChecked,
    required this.bytesChecked,
    this.totalFiles,
    this.totalBytes,
  });

  final AttachmentArchiveVerificationPhase phase;
  final int filesChecked;
  final int bytesChecked;
  final int? totalFiles;
  final int? totalBytes;

  bool get isDeterminate => totalFiles != null && totalBytes != null;

  double? get fractionComplete {
    final files = totalFiles;
    final bytes = totalBytes;
    if (files == null || bytes == null) {
      return null;
    }
    if (bytes > 0) {
      return (bytesChecked / bytes).clamp(0, 1);
    }
    if (files > 0) {
      return (filesChecked / files).clamp(0, 1);
    }
    return 1;
  }
}

/// Exact source evidence for one payload absent from an otherwise safe copy.
///
/// The verifier retains this only for a bounded verified-behind result. It is
/// process-local review evidence, not durable remediation authority.
@immutable
final class AttachmentArchiveVerifiedMissingPayload {
  const AttachmentArchiveVerifiedMissingPayload({
    required this.relativePath,
    required this.expectedSizeBytes,
    required this.expectedSha256,
  });

  final String relativePath;
  final int expectedSizeBytes;
  final String expectedSha256;
}

@immutable
final class AttachmentArchiveCandidateVerificationContext {
  const AttachmentArchiveCandidateVerificationContext({
    required this.sourceLocationConfiguration,
    required this.sourceLocationGeneration,
    required this.requestedSourcePath,
    required this.requestedCandidatePath,
    required this.verifiedAtUtc,
    required this.candidateWasPhysicallyWritable,
    this.sourceCanonicalIdentity,
    this.candidateCanonicalIdentity,
  });

  final AttachmentArchiveLocationConfiguration? sourceLocationConfiguration;
  final int sourceLocationGeneration;
  final String? requestedSourcePath;
  final String requestedCandidatePath;
  final DateTime verifiedAtUtc;
  final bool candidateWasPhysicallyWritable;
  final String? sourceCanonicalIdentity;
  final String? candidateCanonicalIdentity;

  AttachmentArchiveCandidateVerificationContext withCanonicalIdentities({
    String? sourceCanonicalIdentity,
    String? candidateCanonicalIdentity,
  }) {
    return AttachmentArchiveCandidateVerificationContext(
      sourceLocationConfiguration: sourceLocationConfiguration,
      sourceLocationGeneration: sourceLocationGeneration,
      requestedSourcePath: requestedSourcePath,
      requestedCandidatePath: requestedCandidatePath,
      verifiedAtUtc: verifiedAtUtc,
      candidateWasPhysicallyWritable: candidateWasPhysicallyWritable,
      sourceCanonicalIdentity:
          sourceCanonicalIdentity ?? this.sourceCanonicalIdentity,
      candidateCanonicalIdentity:
          candidateCanonicalIdentity ?? this.candidateCanonicalIdentity,
    );
  }
}

@immutable
final class AttachmentArchiveVerificationDiagnostics {
  const AttachmentArchiveVerificationDiagnostics({
    required this.missingPathExamples,
    required this.conflictingPathExamples,
    required this.allowedExtraPathExamples,
    required this.operationalDebrisPathExamples,
    required this.sourceAnomalyPathExamples,
  });

  final List<String> missingPathExamples;
  final List<String> conflictingPathExamples;
  final List<String> allowedExtraPathExamples;
  final List<String> operationalDebrisPathExamples;
  final List<String> sourceAnomalyPathExamples;
}

@immutable
final class AttachmentArchiveCandidateVerificationEvidence {
  const AttachmentArchiveCandidateVerificationEvidence({
    required this.sourceCanonicalIdentity,
    required this.candidateCanonicalIdentity,
    required this.sourceLocationConfiguration,
    required this.sourceLocationGeneration,
    required this.verifiedAtUtc,
    required this.candidateWasPhysicallyWritable,
    required this.requiredSourcePhysicalFileCount,
    required this.requiredSourceBytes,
    required this.verifiedFileCount,
    required this.verifiedBytes,
    required this.metadataReferenceCount,
    required this.unreferencedPreservationCount,
    required this.sourceOperationalDebrisCount,
    required this.candidateOperationalDebrisCount,
    required this.allowedCandidateExtraCount,
    required this.allowedCandidateExtraBytes,
    required this.missingCount,
    required this.missingBytes,
    required this.contentCoverageDigest,
    required this.sourceStructuralSnapshotFingerprint,
    required this.candidateStructuralSnapshotFingerprint,
    required this.diagnostics,
    this.structuralBaseline,
    this.missingPayloads = const [],
    this.missingPayloadEvidenceIsComplete = true,
  });

  final String sourceCanonicalIdentity;
  final String candidateCanonicalIdentity;
  final AttachmentArchiveLocationConfiguration sourceLocationConfiguration;
  final int sourceLocationGeneration;
  final DateTime verifiedAtUtc;
  final bool candidateWasPhysicallyWritable;
  final int requiredSourcePhysicalFileCount;
  final int requiredSourceBytes;
  final int verifiedFileCount;
  final int verifiedBytes;
  final int metadataReferenceCount;
  final int unreferencedPreservationCount;
  final int sourceOperationalDebrisCount;
  final int candidateOperationalDebrisCount;
  final int allowedCandidateExtraCount;
  final int allowedCandidateExtraBytes;
  final int missingCount;
  final int missingBytes;
  final String contentCoverageDigest;
  final String sourceStructuralSnapshotFingerprint;
  final String candidateStructuralSnapshotFingerprint;
  final AttachmentArchiveVerificationDiagnostics diagnostics;
  final AttachmentArchiveVerificationStructuralBaseline? structuralBaseline;
  final List<AttachmentArchiveVerifiedMissingPayload> missingPayloads;
  final bool missingPayloadEvidenceIsComplete;

  int get operationalDebrisCount =>
      sourceOperationalDebrisCount + candidateOperationalDebrisCount;

  bool get hasCompleteMissingPayloadEvidence {
    return missingPayloadEvidenceIsComplete &&
        missingPayloads.length == missingCount;
  }
}

@immutable
sealed class AttachmentArchiveCandidateVerificationResult {
  const AttachmentArchiveCandidateVerificationResult({
    required this.outcome,
    required this.context,
    this.evidence,
    this.issue,
  });

  final AttachmentArchiveCandidateVerificationOutcome outcome;
  final AttachmentArchiveCandidateVerificationContext context;
  final AttachmentArchiveCandidateVerificationEvidence? evidence;
  final String? issue;
}

final class AttachmentArchiveCandidateComplete
    extends AttachmentArchiveCandidateVerificationResult {
  const AttachmentArchiveCandidateComplete({
    required super.context,
    required AttachmentArchiveCandidateVerificationEvidence super.evidence,
  }) : super(
         outcome:
             AttachmentArchiveCandidateVerificationOutcome.candidateComplete,
       );
}

final class AttachmentArchiveCandidateBehind
    extends AttachmentArchiveCandidateVerificationResult {
  const AttachmentArchiveCandidateBehind({
    required super.context,
    required AttachmentArchiveCandidateVerificationEvidence super.evidence,
  }) : super(
         outcome: AttachmentArchiveCandidateVerificationOutcome.candidateBehind,
       );
}

final class AttachmentArchiveCandidateInvalid
    extends AttachmentArchiveCandidateVerificationResult {
  const AttachmentArchiveCandidateInvalid({
    required super.context,
    required String super.issue,
    super.evidence,
  }) : super(
         outcome:
             AttachmentArchiveCandidateVerificationOutcome.candidateInvalid,
       );
}

final class AttachmentArchiveVerificationSourceUnavailable
    extends AttachmentArchiveCandidateVerificationResult {
  const AttachmentArchiveVerificationSourceUnavailable({
    required super.context,
    required String super.issue,
  }) : super(
         outcome:
             AttachmentArchiveCandidateVerificationOutcome.sourceUnavailable,
       );
}

final class AttachmentArchiveVerificationCandidateUnavailable
    extends AttachmentArchiveCandidateVerificationResult {
  const AttachmentArchiveVerificationCandidateUnavailable({
    required super.context,
    required String super.issue,
  }) : super(
         outcome:
             AttachmentArchiveCandidateVerificationOutcome.candidateUnavailable,
       );
}

final class AttachmentArchiveCandidateVerificationFailed
    extends AttachmentArchiveCandidateVerificationResult {
  const AttachmentArchiveCandidateVerificationFailed({
    required super.context,
    required String super.issue,
  }) : super(
         outcome:
             AttachmentArchiveCandidateVerificationOutcome.verificationFailed,
       );
}

final class AttachmentArchiveCandidateVerificationCancelled
    implements Exception {
  const AttachmentArchiveCandidateVerificationCancelled();

  @override
  String toString() => 'Attachment archive candidate verification cancelled.';
}
