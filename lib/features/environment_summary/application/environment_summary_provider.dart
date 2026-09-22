import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../../essentials/db/feature_level_providers.dart'
    show dbMaintenanceLockProvider;
import '../../../essentials/onboarding/domain/message_lens_installation_state.dart';
import '../../../essentials/onboarding/domain/startup_installation_validation.dart';
import '../../../essentials/onboarding/domain/startup_validation_telemetry.dart';
import '../../../essentials/onboarding/feature_level_providers.dart'
    show startupValidationTelemetryProvider;
import '../../attachments/feature_level_providers.dart'
    show
        AttachmentArchiveLocationAvailability,
        AttachmentArchiveLocationSnapshot,
        attachmentArchiveLocationObservationProvider;
import '../domain/entities/environment_summary.dart';
import 'environment_evidence_providers.dart';
import 'environment_evidence_repository.dart';

part 'environment_summary_provider.g.dart';

@riverpod
EnvironmentSummary environmentSummary(Ref ref) {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  final packageEvidence = ref.watch(environmentPackageInfoEvidenceProvider);
  final rootEvidence = ref.watch(environmentDataRootEvidenceProvider);
  final attachmentSnapshot = ref.watch(
    attachmentArchiveLocationObservationProvider,
  );
  final messageEvidence = ref.watch(environmentMessageEvidenceProvider);
  final dateRangeEvidence = ref.watch(
    environmentMessageDateRangeEvidenceProvider,
  );
  final contactsEvidence = ref.watch(environmentContactsEvidenceProvider);
  final databaseEvidence = ref.watch(environmentDatabaseEvidenceProvider);
  final ftsEvidence = ref.watch(environmentFtsEvidenceProvider);
  final startupEvidence = _readAlreadyLiveStartupEvidence(ref);
  final maintenanceActive = ref.exists(dbMaintenanceLockProvider)
      ? ref.watch(dbMaintenanceLockProvider)
      : null;

  return EnvironmentSummary(
    installation: EnvironmentInstallationSummary(
      productName: authority.identity.productName,
      semanticVersion: packageEvidence.valueOrNull?.semanticVersion,
      buildNumber: packageEvidence.valueOrNull?.buildNumber,
      environment: authority.identity.environment,
      buildIdentity: authority.identity.buildIdentity,
      bundleIdentifier: authority.identity.bundleIdentifier,
      archiveInstanceId: authority.identity.archiveInstanceId.value,
      runtimeMode: _runtimeMode,
      packageStatus: _sectionStatus(packageEvidence),
      issue: _issue(packageEvidence),
    ),
    dataRoot: _dataRootSummary(
      canonicalRootPath: authority.rootPath,
      evidence: rootEvidence,
    ),
    attachmentArchive: _attachmentSummary(attachmentSnapshot),
    messages: _messageSummary(messageEvidence, dateRangeEvidence),
    contacts: _contactsSummary(contactsEvidence),
    technical: _technicalSummary(
      databaseEvidence: databaseEvidence,
      ftsEvidence: ftsEvidence,
      startupEvidence: startupEvidence,
      maintenanceActive: maintenanceActive,
    ),
  );
}

EnvironmentDataRootSummary _dataRootSummary({
  required String canonicalRootPath,
  required AsyncValue<EnvironmentRootEvidence> evidence,
}) {
  final value = evidence.valueOrNull;
  return EnvironmentDataRootSummary(
    canonicalPath: canonicalRootPath,
    displayVolumeName:
        value?.displayVolumeName ??
        environmentDisplayVolumeName(canonicalRootPath),
    availability: value?.availability ?? EnvironmentAvailability.unknown,
    status: _sectionStatus(evidence),
    issue: value?.issue ?? _issue(evidence),
  );
}

EnvironmentAttachmentArchiveSummary _attachmentSummary(
  AttachmentArchiveLocationSnapshot? snapshot,
) {
  if (snapshot == null) {
    return const EnvironmentAttachmentArchiveSummary(
      status: EnvironmentSectionStatus.loading,
      availability: EnvironmentAvailability.unknown,
      isReadable: false,
      isPhysicallyWritable: false,
      locationGeneration: 0,
    );
  }
  final displayPath = snapshot.canonicalPath ?? snapshot.lastKnownDisplayPath;
  return EnvironmentAttachmentArchiveSummary(
    status: EnvironmentSectionStatus.ready,
    canonicalPath: snapshot.canonicalPath,
    displayPath: snapshot.lastKnownDisplayPath,
    volumeName:
        snapshot.volumeName ??
        (displayPath == null
            ? null
            : environmentDisplayVolumeName(displayPath)),
    availability: _attachmentAvailability(snapshot.availability),
    configurationMode: snapshot.mode,
    customWritePolicy: snapshot.customWritePolicy,
    isReadable: snapshot.isReadable,
    isPhysicallyWritable: snapshot.isPhysicallyWritable,
    locationGeneration: snapshot.generation,
    issue: snapshot.issue,
  );
}

EnvironmentMessageDataSummary _messageSummary(
  AsyncValue<EnvironmentMessageEvidence> messages,
  AsyncValue<List<EnvironmentMessageDateRangeEvidence>> dateRanges,
) {
  final evidence = messages.valueOrNull;
  if (evidence == null) {
    return EnvironmentMessageDataSummary(
      status: _sectionStatus(messages),
      sources: const <EnvironmentMessageSourceSummary>[],
      issue: _issue(messages),
    );
  }

  final ranges = <int, EnvironmentMessageDateRangeEvidence>{
    for (final range
        in dateRanges.valueOrNull ??
            const <EnvironmentMessageDateRangeEvidence>[])
      range.sourceId: range,
  };
  final dateStatus = _sectionStatus(dateRanges);
  final dateIssue = _issue(dateRanges);
  final sources = <EnvironmentMessageSourceSummary>[
    for (final source in evidence.sources)
      EnvironmentMessageSourceSummary(
        sourceId: source.sourceId,
        sourceKey: source.sourceKey,
        kind: source.kind,
        displayLabel: source.displayLabel,
        registryLabel: source.registryLabel,
        canonicalSourcePath: source.canonicalSourcePath,
        projectedMessageCount: source.projectedMessageCount,
        dateRangeStatus: dateStatus,
        earliestMessageUtc: ranges[source.sourceId]?.earliestMessageUtc,
        latestMessageUtc: ranges[source.sourceId]?.latestMessageUtc,
        dateRangeIssue: dateIssue,
      ),
  ];
  return EnvironmentMessageDataSummary(
    status: EnvironmentSectionStatus.ready,
    projectedMessageCount: evidence.projectedMessageCount,
    conversationCount: evidence.conversationCount,
    attachmentReferenceCount: evidence.attachmentReferenceCount,
    earliestMessageUtc: _earliestDate(sources),
    latestMessageUtc: _latestDate(sources),
    sources: sources,
  );
}

EnvironmentContactsDataSummary _contactsSummary(
  AsyncValue<EnvironmentContactsEvidence> contacts,
) {
  final value = contacts.valueOrNull;
  return EnvironmentContactsDataSummary(
    status: _sectionStatus(contacts),
    projectedContactCount: value?.projectedContactCount,
    linkedHandleCount: value?.linkedHandleCount,
    importedChannelCount: value?.importedChannelCount,
    physicalSourceIdentityRetained: false,
    issue: _issue(contacts),
  );
}

EnvironmentTechnicalSummary _technicalSummary({
  required AsyncValue<List<EnvironmentDatabaseSummary>> databaseEvidence,
  required AsyncValue<EnvironmentFtsEvidence> ftsEvidence,
  required _StartupEvidence startupEvidence,
  required bool? maintenanceActive,
}) {
  final databaseStatus = _sectionStatus(databaseEvidence);
  final ftsStatus = _sectionStatus(ftsEvidence);
  final fts = ftsEvidence.valueOrNull;
  return EnvironmentTechnicalSummary(
    status: _combinedStatus(databaseStatus, ftsStatus),
    databaseStatus: databaseStatus,
    ftsStatus: ftsStatus,
    startupAdmissionBasis: startupEvidence.basis,
    installationState: startupEvidence.installationState,
    maintenanceActive: maintenanceActive,
    ftsAvailable: fts?.isAvailable,
    ftsRowCount: fts?.rowCount,
    databases:
        databaseEvidence.valueOrNull ?? const <EnvironmentDatabaseSummary>[],
    issue: _issue(databaseEvidence) ?? _issue(ftsEvidence),
  );
}

_StartupEvidence _readAlreadyLiveStartupEvidence(Ref ref) {
  if (!ref.exists(startupValidationTelemetryProvider)) {
    return const _StartupEvidence();
  }
  final snapshot = ref.watch(startupValidationTelemetryProvider).snapshot();
  for (final event in snapshot.events.reversed) {
    if (event.kind == StartupValidationEventKind.admissionDecided) {
      return _StartupEvidence(
        basis: event.admissionBasis,
        installationState: event.installationKind,
      );
    }
  }
  return const _StartupEvidence();
}

EnvironmentAvailability _attachmentAvailability(
  AttachmentArchiveLocationAvailability availability,
) {
  return switch (availability) {
    AttachmentArchiveLocationAvailability.defaultAvailable ||
    AttachmentArchiveLocationAvailability.customAvailable =>
      EnvironmentAvailability.connected,
    AttachmentArchiveLocationAvailability.customReadOnly =>
      EnvironmentAvailability.readOnly,
    AttachmentArchiveLocationAvailability.customUnavailable =>
      EnvironmentAvailability.disconnected,
    AttachmentArchiveLocationAvailability.permissionDenied =>
      EnvironmentAvailability.permissionRequired,
    AttachmentArchiveLocationAvailability.configuredDirectoryMissing =>
      EnvironmentAvailability.missing,
    AttachmentArchiveLocationAvailability.configurationInvalid =>
      EnvironmentAvailability.invalid,
  };
}

EnvironmentSectionStatus _sectionStatus<T>(AsyncValue<T> value) {
  if (value.isLoading) {
    return EnvironmentSectionStatus.loading;
  }
  if (value.hasError) {
    return value.error is EnvironmentEvidenceUnavailableException
        ? EnvironmentSectionStatus.unavailable
        : EnvironmentSectionStatus.failed;
  }
  return EnvironmentSectionStatus.ready;
}

EnvironmentSectionStatus _combinedStatus(
  EnvironmentSectionStatus first,
  EnvironmentSectionStatus second,
) {
  if (first == EnvironmentSectionStatus.failed ||
      second == EnvironmentSectionStatus.failed) {
    return EnvironmentSectionStatus.failed;
  }
  if (first == EnvironmentSectionStatus.unavailable ||
      second == EnvironmentSectionStatus.unavailable) {
    return EnvironmentSectionStatus.unavailable;
  }
  if (first == EnvironmentSectionStatus.loading ||
      second == EnvironmentSectionStatus.loading) {
    return EnvironmentSectionStatus.loading;
  }
  return EnvironmentSectionStatus.ready;
}

String? _issue<T>(AsyncValue<T> value) {
  return value.hasError ? value.error.toString() : null;
}

DateTime? _earliestDate(List<EnvironmentMessageSourceSummary> sources) {
  DateTime? result;
  for (final source in sources) {
    final date = source.earliestMessageUtc;
    if (date != null && (result == null || date.isBefore(result))) {
      result = date;
    }
  }
  return result;
}

DateTime? _latestDate(List<EnvironmentMessageSourceSummary> sources) {
  DateTime? result;
  for (final source in sources) {
    final date = source.latestMessageUtc;
    if (date != null && (result == null || date.isAfter(result))) {
      result = date;
    }
  }
  return result;
}

EnvironmentRuntimeMode get _runtimeMode {
  if (kReleaseMode) {
    return EnvironmentRuntimeMode.release;
  }
  if (kProfileMode) {
    return EnvironmentRuntimeMode.profile;
  }
  return EnvironmentRuntimeMode.debug;
}

final class _StartupEvidence {
  const _StartupEvidence({this.basis, this.installationState});

  final StartupAdmissionBasis? basis;
  final MessageLensInstallationStateKind? installationState;
}
