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
  metadata,
  sourceCoverage,
  candidateExtras,
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
  });

  final AttachmentArchiveVerificationPhase phase;
  final int filesChecked;
  final int bytesChecked;
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

  int get operationalDebrisCount =>
      sourceOperationalDebrisCount + candidateOperationalDebrisCount;
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
