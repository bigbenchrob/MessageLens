import '../../../../essentials/app_czar/domain/app_czar_models.dart';
import '../../../../essentials/app_czar/infrastructure/sqlite_app_czar_observation_reader.dart';
import '../../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../../../../essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import '../../application/attachment_repairability_evidence_reader.dart';
import '../../application/current_messages_attachment_source_reader.dart';
import '../../application/required_attachment_evidence_reader.dart';
import 'source_database_current_messages_attachment_source_reader.dart';
import 'sqlite_required_attachment_evidence_reader.dart';

final class AppCzarAttachmentArchiveEvidenceObservation {
  const AppCzarAttachmentArchiveEvidenceObservation({
    required this.coverage,
    required this.repairability,
  });

  final AppCzarAttachmentCoverageObservation coverage;
  final AppCzarAttachmentRepairabilityObservation repairability;
}

/// Reconstructs current required attachment coverage and repairability without
/// operation history.
///
/// Required-key selection and the source-availability partition belong to the
/// shared [AttachmentRepairabilityEvidenceReader]. This adapter maps that one
/// bounded read into AppCzar's factual coverage and actionability observations.
final class ReadOnlyAppCzarAttachmentCoverageProbe {
  ReadOnlyAppCzarAttachmentCoverageProbe({
    required ArchiveAccessAuthority archiveAccessAuthority,
    RequiredAttachmentEvidenceReader? evidenceReader,
    AttachmentRepairabilitySourceReaderResolver? sourceReaderResolver,
    AttachmentRepairabilityEvidenceReader? repairabilityEvidenceReader,
  }) : _repairabilityEvidenceReader =
           repairabilityEvidenceReader ??
           AttachmentRepairabilityEvidenceReader(
             requiredEvidenceReader:
                 evidenceReader ??
                 SqliteRequiredAttachmentEvidenceReader(
                   admittedRootPath: archiveAccessAuthority.rootPath,
                 ),
             sourceReaderResolver:
                 sourceReaderResolver ?? _defaultSourceReaderResolver,
           );

  final AttachmentRepairabilityEvidenceReader _repairabilityEvidenceReader;

  Future<AppCzarAttachmentCoverageObservation> readCurrent({
    required String archiveRootPath,
    required String archiveScopeIdentity,
    required int archiveGeneration,
  }) async {
    return (await readArchiveEvidence(
      archiveRootPath: archiveRootPath,
      archiveScopeIdentity: archiveScopeIdentity,
      archiveGeneration: archiveGeneration,
    )).coverage;
  }

  Future<AppCzarAttachmentArchiveEvidenceObservation> readArchiveEvidence({
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
      final evidence = await _repairabilityEvidenceReader.readCurrent(
        binding: binding,
      );
      return AppCzarAttachmentArchiveEvidenceObservation(
        coverage: _coverageFromEvidence(evidence, binding),
        repairability: _repairabilityFromEvidence(evidence, binding),
      );
    } on RequiredAttachmentEvidenceReadException catch (error) {
      return _unknownEvidence(
        issue: error.issue,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      );
    } on Object {
      return _unknownEvidence(
        issue:
            'Attachment coverage and repairability could not be established.',
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      );
    }
  }

  static Future<CurrentMessagesAttachmentSourceReader>
  _defaultSourceReaderResolver() async {
    return SourceDatabaseCurrentMessagesAttachmentSourceReader(
      databasePath:
          SqliteAppCzarObservationReader.defaultMacosMessagesDatabasePath(),
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );
  }

  static AppCzarAttachmentCoverageObservation _coverageFromEvidence(
    AttachmentRepairabilityEvidence evidence,
    RequiredAttachmentEvidenceBinding binding,
  ) {
    final summary = evidence.summary;
    if (!evidence.coverageIsStable || summary == null) {
      return AppCzarAttachmentCoverageObservation.unknown(
        issue:
            evidence.issue ??
            'Attachment coverage changed during the bounded evidence read.',
        archiveScopeIdentity: binding.archiveScopeIdentity,
        archiveGeneration: binding.archiveGeneration,
        requiredCount: summary?.requiredCount,
        coveredCount: summary?.coveredCount,
        missingCount: summary?.missingCount,
        unverifiableCount: summary?.unverifiableCount,
      );
    }
    return _classifyCoverage(summary);
  }

  static AppCzarAttachmentRepairabilityObservation _repairabilityFromEvidence(
    AttachmentRepairabilityEvidence evidence,
    RequiredAttachmentEvidenceBinding binding,
  ) {
    if (!evidence.isSettledAndCoherent) {
      return AppCzarAttachmentRepairabilityObservation.unknown(
        issue:
            evidence.issue ??
            'Current attachment repairability is inconclusive.',
        archiveScopeIdentity: binding.archiveScopeIdentity,
        archiveGeneration: binding.archiveGeneration,
      );
    }
    final condition =
        evidence.sourceUnknownCount > 0 || evidence.unsafeOrConflictingCount > 0
        ? AppCzarAttachmentRepairOpportunityCondition.unknown
        : evidence.availableFromMessagesCount > 0
        ? AppCzarAttachmentRepairOpportunityCondition.present
        : AppCzarAttachmentRepairOpportunityCondition.absent;
    if (condition == AppCzarAttachmentRepairOpportunityCondition.unknown) {
      return AppCzarAttachmentRepairabilityObservation.unknown(
        issue: 'Some uncovered attachment evidence is unknown or conflicting.',
        archiveScopeIdentity: binding.archiveScopeIdentity,
        archiveGeneration: binding.archiveGeneration,
        availableFromMessagesCount: evidence.availableFromMessagesCount,
        sourceAbsentCount: evidence.sourceAbsentCount,
        sourceUnknownCount: evidence.sourceUnknownCount,
        recordBackedRecoveryCount: evidence.recordBackedRecoveryCount,
        unsafeOrConflictingCount: evidence.unsafeOrConflictingCount,
      );
    }
    return AppCzarAttachmentRepairabilityObservation(
      condition: condition,
      availableFromMessagesCount: evidence.availableFromMessagesCount,
      sourceAbsentCount: evidence.sourceAbsentCount,
      sourceUnknownCount: evidence.sourceUnknownCount,
      recordBackedRecoveryCount: evidence.recordBackedRecoveryCount,
      unsafeOrConflictingCount: evidence.unsafeOrConflictingCount,
      archiveScopeIdentity: binding.archiveScopeIdentity,
      archiveGeneration: binding.archiveGeneration,
    );
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

  static AppCzarAttachmentArchiveEvidenceObservation _unknownEvidence({
    required String issue,
    required String archiveScopeIdentity,
    required int archiveGeneration,
  }) {
    return AppCzarAttachmentArchiveEvidenceObservation(
      coverage: AppCzarAttachmentCoverageObservation.unknown(
        issue: issue,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      ),
      repairability: AppCzarAttachmentRepairabilityObservation.unknown(
        issue: issue,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      ),
    );
  }
}
