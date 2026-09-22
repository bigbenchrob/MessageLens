import 'package:meta/meta.dart';

import '../../../../essentials/archive_environment/domain/archive_build_identity.dart';
import '../../../../essentials/archive_environment/domain/archive_environment.dart';
import '../../../../essentials/onboarding/domain/message_lens_installation_state.dart';
import '../../../../essentials/onboarding/domain/startup_installation_validation.dart';
import '../../../attachments/feature_level_providers.dart'
    show AttachmentArchiveCustomWritePolicy, AttachmentArchiveLocationMode;

enum EnvironmentAvailability {
  connected,
  readOnly,
  permissionRequired,
  disconnected,
  missing,
  invalid,
  unknown,
}

enum EnvironmentSectionStatus {
  ready,
  loading,
  unavailable,
  notRetained,
  failed,
}

enum EnvironmentDatabaseRole {
  sourceImport,
  conversationGraph,
  userOverlay,
  presence,
}

enum EnvironmentMessageSourceKind {
  currentMacMessages,
  historicalMessagesArchive,
}

enum EnvironmentRuntimeMode { debug, profile, release }

@immutable
final class EnvironmentSummary {
  const EnvironmentSummary({
    required this.installation,
    required this.dataRoot,
    required this.attachmentArchive,
    required this.messages,
    required this.contacts,
    required this.technical,
  });

  final EnvironmentInstallationSummary installation;
  final EnvironmentDataRootSummary dataRoot;
  final EnvironmentAttachmentArchiveSummary attachmentArchive;
  final EnvironmentMessageDataSummary messages;
  final EnvironmentContactsDataSummary contacts;
  final EnvironmentTechnicalSummary technical;
}

@immutable
final class EnvironmentInstallationSummary {
  const EnvironmentInstallationSummary({
    required this.productName,
    required this.environment,
    required this.buildIdentity,
    required this.bundleIdentifier,
    required this.archiveInstanceId,
    required this.runtimeMode,
    required this.packageStatus,
    this.semanticVersion,
    this.buildNumber,
    this.issue,
  });

  final String productName;
  final String? semanticVersion;
  final String? buildNumber;
  final ArchiveEnvironment environment;
  final ArchiveBuildIdentity buildIdentity;
  final String bundleIdentifier;
  final String archiveInstanceId;
  final EnvironmentRuntimeMode runtimeMode;
  final EnvironmentSectionStatus packageStatus;
  final String? issue;
}

@immutable
final class EnvironmentDataRootSummary {
  const EnvironmentDataRootSummary({
    required this.canonicalPath,
    required this.displayVolumeName,
    required this.availability,
    required this.status,
    this.issue,
  });

  final String canonicalPath;
  final String displayVolumeName;
  final EnvironmentAvailability availability;
  final EnvironmentSectionStatus status;
  final String? issue;
}

@immutable
final class EnvironmentAttachmentArchiveSummary {
  const EnvironmentAttachmentArchiveSummary({
    required this.status,
    required this.availability,
    required this.isReadable,
    required this.isPhysicallyWritable,
    required this.locationGeneration,
    this.canonicalPath,
    this.displayPath,
    this.volumeName,
    this.configurationMode,
    this.customWritePolicy,
    this.issue,
  });

  final EnvironmentSectionStatus status;
  final String? canonicalPath;
  final String? displayPath;
  final String? volumeName;
  final EnvironmentAvailability availability;
  final AttachmentArchiveLocationMode? configurationMode;
  final AttachmentArchiveCustomWritePolicy? customWritePolicy;
  final bool isReadable;
  final bool isPhysicallyWritable;
  final int locationGeneration;
  final String? issue;
}

@immutable
final class EnvironmentMessageDataSummary {
  EnvironmentMessageDataSummary({
    required this.status,
    required Iterable<EnvironmentMessageSourceSummary> sources,
    this.projectedMessageCount,
    this.conversationCount,
    this.attachmentReferenceCount,
    this.earliestMessageUtc,
    this.latestMessageUtc,
    this.issue,
  }) : sources = List<EnvironmentMessageSourceSummary>.unmodifiable(sources);

  final EnvironmentSectionStatus status;
  final int? projectedMessageCount;
  final int? conversationCount;
  final int? attachmentReferenceCount;
  final DateTime? earliestMessageUtc;
  final DateTime? latestMessageUtc;
  final List<EnvironmentMessageSourceSummary> sources;
  final String? issue;
}

@immutable
final class EnvironmentMessageSourceSummary {
  const EnvironmentMessageSourceSummary({
    required this.sourceId,
    required this.sourceKey,
    required this.kind,
    required this.displayLabel,
    required this.projectedMessageCount,
    required this.dateRangeStatus,
    this.registryLabel,
    this.canonicalSourcePath,
    this.earliestMessageUtc,
    this.latestMessageUtc,
    this.lastRecordedSuccessfulImportUtc,
    this.dateRangeIssue,
  });

  final int sourceId;
  final String sourceKey;
  final EnvironmentMessageSourceKind kind;
  final String displayLabel;
  final String? registryLabel;
  final String? canonicalSourcePath;
  final int projectedMessageCount;
  final EnvironmentSectionStatus dateRangeStatus;
  final DateTime? earliestMessageUtc;
  final DateTime? latestMessageUtc;
  final DateTime? lastRecordedSuccessfulImportUtc;
  final String? dateRangeIssue;

  EnvironmentMessageSourceSummary withDateRange({
    required EnvironmentSectionStatus status,
    DateTime? earliestMessageUtc,
    DateTime? latestMessageUtc,
    String? issue,
  }) {
    return EnvironmentMessageSourceSummary(
      sourceId: sourceId,
      sourceKey: sourceKey,
      kind: kind,
      displayLabel: displayLabel,
      projectedMessageCount: projectedMessageCount,
      dateRangeStatus: status,
      registryLabel: registryLabel,
      canonicalSourcePath: canonicalSourcePath,
      earliestMessageUtc: earliestMessageUtc,
      latestMessageUtc: latestMessageUtc,
      lastRecordedSuccessfulImportUtc: lastRecordedSuccessfulImportUtc,
      dateRangeIssue: issue,
    );
  }
}

@immutable
final class EnvironmentContactsDataSummary {
  const EnvironmentContactsDataSummary({
    required this.status,
    required this.physicalSourceIdentityRetained,
    this.projectedContactCount,
    this.linkedHandleCount,
    this.importedChannelCount,
    this.issue,
  });

  final EnvironmentSectionStatus status;
  final int? projectedContactCount;
  final int? linkedHandleCount;
  final int? importedChannelCount;
  final bool physicalSourceIdentityRetained;
  final String? issue;
}

@immutable
final class EnvironmentTechnicalSummary {
  EnvironmentTechnicalSummary({
    required this.status,
    required this.databaseStatus,
    required this.ftsStatus,
    required Iterable<EnvironmentDatabaseSummary> databases,
    this.startupAdmissionBasis,
    this.installationState,
    this.maintenanceActive,
    this.ftsAvailable,
    this.ftsRowCount,
    this.issue,
  }) : databases = List<EnvironmentDatabaseSummary>.unmodifiable(databases);

  final EnvironmentSectionStatus status;
  final EnvironmentSectionStatus databaseStatus;
  final EnvironmentSectionStatus ftsStatus;
  final StartupAdmissionBasis? startupAdmissionBasis;
  final MessageLensInstallationStateKind? installationState;
  final bool? maintenanceActive;
  final bool? ftsAvailable;
  final int? ftsRowCount;
  final List<EnvironmentDatabaseSummary> databases;
  final String? issue;
}

@immutable
final class EnvironmentDatabaseSummary {
  const EnvironmentDatabaseSummary({
    required this.role,
    required this.path,
    required this.exists,
    required this.readable,
    required this.expectedVersion,
    this.sizeBytes,
    this.userVersion,
    this.issue,
  });

  final EnvironmentDatabaseRole role;
  final String path;
  final bool exists;
  final bool readable;
  final int? sizeBytes;
  final int? userVersion;
  final int expectedVersion;
  final String? issue;
}
