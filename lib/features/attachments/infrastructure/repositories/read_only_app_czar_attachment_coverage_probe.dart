import '../../../../essentials/app_czar/domain/app_czar_models.dart';
import '../../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../../application/required_attachment_evidence_reader.dart';
import 'sqlite_required_attachment_evidence_reader.dart';

/// Reconstructs current required attachment coverage without operation history.
///
/// Required-key selection and item classification belong to the shared
/// [RequiredAttachmentEvidenceReader]. This adapter performs the bounded
/// two-sample stability comparison and maps factual counts into AppCzar's
/// aggregate observation.
final class ReadOnlyAppCzarAttachmentCoverageProbe {
  ReadOnlyAppCzarAttachmentCoverageProbe({
    required ArchiveAccessAuthority archiveAccessAuthority,
    RequiredAttachmentEvidenceReader? evidenceReader,
  }) : _evidenceReader =
           evidenceReader ??
           SqliteRequiredAttachmentEvidenceReader(
             admittedRootPath: archiveAccessAuthority.rootPath,
           );

  final RequiredAttachmentEvidenceReader _evidenceReader;

  Future<AppCzarAttachmentCoverageObservation> readCurrent({
    required String archiveRootPath,
    required String archiveScopeIdentity,
    required int archiveGeneration,
  }) async {
    final binding = RequiredAttachmentEvidenceBinding(
      archiveRootPath: archiveRootPath,
      archiveScopeIdentity: archiveScopeIdentity,
      archiveGeneration: archiveGeneration,
    );
    try {
      final first = await _evidenceReader.readSummary(binding: binding);
      final second = await _evidenceReader.readSummary(binding: binding);
      final secondResult = _classifyCoverage(second);
      if (first.binding != second.binding ||
          first.materialFingerprint != second.materialFingerprint ||
          !_sameMaterialCounts(first, second)) {
        return AppCzarAttachmentCoverageObservation.unknown(
          issue:
              'Attachment graph, archive metadata, or payload state changed during the bounded coverage read.',
          archiveScopeIdentity: archiveScopeIdentity,
          archiveGeneration: archiveGeneration,
          requiredCount: second.requiredCount,
          coveredCount: second.coveredCount,
          missingCount: second.missingCount,
          unverifiableCount: second.unverifiableCount,
        );
      }
      return secondResult;
    } on RequiredAttachmentEvidenceReadException catch (error) {
      return AppCzarAttachmentCoverageObservation.unknown(
        issue: error.issue,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      );
    } on Object {
      return AppCzarAttachmentCoverageObservation.unknown(
        issue: 'Attachment coverage could not be established.',
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      );
    }
  }

  static AppCzarAttachmentCoverageObservation _classifyCoverage(
    RequiredAttachmentEvidenceSummary summary,
  ) {
    final requiredCount = summary.requiredCount;
    final coveredCount = summary.coveredCount;
    final missingCount = summary.missingCount;
    final unverifiableCount = summary.unverifiableCount;
    final binding = summary.binding;
    if (coveredCount + missingCount + unverifiableCount != requiredCount) {
      return AppCzarAttachmentCoverageObservation.unknown(
        issue: 'Attachment coverage counts did not reconcile.',
        archiveScopeIdentity: binding.archiveScopeIdentity,
        archiveGeneration: binding.archiveGeneration,
        requiredCount: requiredCount,
        coveredCount: coveredCount,
        missingCount: missingCount,
        unverifiableCount: unverifiableCount,
      );
    }
    if (missingCount > 0) {
      return AppCzarAttachmentCoverageObservation(
        condition: AppCzarAttachmentCoverageCondition.incomplete,
        requiredCount: requiredCount,
        coveredCount: coveredCount,
        missingCount: missingCount,
        unverifiableCount: unverifiableCount,
        archiveScopeIdentity: binding.archiveScopeIdentity,
        archiveGeneration: binding.archiveGeneration,
        issue: unverifiableCount > 0
            ? 'Some additional required evidence could not be verified.'
            : null,
      );
    }
    if (unverifiableCount > 0) {
      return AppCzarAttachmentCoverageObservation.unknown(
        issue:
            '$unverifiableCount required attachment record(s) could not be verified.',
        archiveScopeIdentity: binding.archiveScopeIdentity,
        archiveGeneration: binding.archiveGeneration,
        requiredCount: requiredCount,
        coveredCount: coveredCount,
        missingCount: 0,
        unverifiableCount: unverifiableCount,
      );
    }
    return AppCzarAttachmentCoverageObservation(
      condition: AppCzarAttachmentCoverageCondition.complete,
      requiredCount: requiredCount,
      coveredCount: coveredCount,
      missingCount: 0,
      unverifiableCount: 0,
      archiveScopeIdentity: binding.archiveScopeIdentity,
      archiveGeneration: binding.archiveGeneration,
    );
  }

  static bool _sameMaterialCounts(
    RequiredAttachmentEvidenceSummary first,
    RequiredAttachmentEvidenceSummary second,
  ) {
    return first.requiredCount == second.requiredCount &&
        first.coveredCount == second.coveredCount &&
        first.missingCount == second.missingCount &&
        first.unverifiableCount == second.unverifiableCount;
  }
}
