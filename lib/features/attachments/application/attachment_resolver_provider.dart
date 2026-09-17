import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../messages/domain/entities/attachment_info.dart';
import '../domain/constants/attachment_archive_payload_status.dart';
import '../domain/constants/attachment_provenance.dart';
import '../domain/constants/resolved_attachment_availability.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import '../domain/entities/attachment_recovery_metadata.dart';
import '../domain/entities/resolved_attachment.dart';
import 'archive_settings_provider.dart';
import 'attachment_archive_service_provider.dart';
import 'attachment_archive_store_providers.dart'
    show attachmentArchiveReadStoreProvider, attachmentFileAccessProvider;
import 'attachment_file_access.dart';
import 'attachment_recovery_metadata_merge.dart';

part 'attachment_resolver_provider.g.dart';

/// Resolves an attachment file through the app's source-policy boundary.
///
/// Archive disabled:
/// - render directly from the live Messages path when present
/// - otherwise report unresolved availability
///
/// Archive enabled:
/// - render an available MessageLens archive payload first
/// - use the live Messages file as a read-only fallback for custom roots
/// - trigger on-demand ingestion only for the mutation-authorized internal root
/// - preserve root-unavailable evidence without treating it as payload loss
@riverpod
Future<ResolvedAttachment> attachmentResolver(
  AttachmentResolverRef ref,
  AttachmentInfo attachmentInfo,
) async {
  final settings = await ref.watch(archiveSettingsProvider.future);
  final fileAccess = ref.watch(attachmentFileAccessProvider);

  if (!settings.isEnabled) {
    return _resolveForLiveOnlyMode(
      attachmentInfo: attachmentInfo,
      fileAccess: fileAccess,
    );
  }

  return _resolveForArchiveEnabledMode(
    ref,
    attachmentInfo: attachmentInfo,
    archiveKey: attachmentInfo.archiveCompatibilityKey,
    fileAccess: fileAccess,
  );
}

Future<ResolvedAttachment> _resolveForArchiveEnabledMode(
  AttachmentResolverRef ref, {
  required AttachmentInfo attachmentInfo,
  required ArchiveCompatibilityKey? archiveKey,
  required AttachmentFileAccess fileAccess,
}) async {
  final resolvedPath = fileAccess.expandPath(attachmentInfo.localPath);
  final liveFileExists = fileAccess.existingExpandedPath(resolvedPath) != null;
  AttachmentRecoveryMetadata? persistedRecoveryHint;
  AttachmentArchivePayloadStatus? archivePayloadStatus;
  AttachmentArchiveLocationAvailability? archiveRootAvailability;
  int? archiveLocationGeneration;
  String? archiveRootIssue;
  AttachmentArchiveLocationState? archiveLocation;

  if (archiveKey != null) {
    final archiveReadStore = await ref.watch(
      attachmentArchiveReadStoreProvider.future,
    );
    persistedRecoveryHint = await archiveReadStore.readRecoveryHint(archiveKey);
    archiveLocation = archiveReadStore.location;
    archiveRootAvailability = archiveLocation.availability;
    archiveLocationGeneration = archiveLocation.generation;
    archiveRootIssue = archiveLocation.issue;

    final archiveRecord = await archiveReadStore.readArchiveRecord(archiveKey);
    archivePayloadStatus = archiveRecord?.payloadStatus;

    if (archiveRecord != null &&
        archiveRecord.payloadStatus ==
            AttachmentArchivePayloadStatus.available) {
      final provenance = switch (archiveRecord.provenance) {
        'imported_historical' => AttachmentProvenance.importedHistorical,
        _ => AttachmentProvenance.archived,
      };

      return ResolvedAttachment(
        attachmentInfo: attachmentInfo,
        availability: ResolvedAttachmentAvailability.available,
        provenance: provenance,
        resolvedFilePath: archiveRecord.archiveAbsolutePath,
        archivePayloadStatus: archiveRecord.payloadStatus,
        archiveRootAvailability: archiveRecord.locationAvailability,
        archiveLocationGeneration: archiveRecord.locationGeneration,
        archiveRootIssue: archiveRecord.rootIssue,
      );
    }

    if (!archiveLocation.isAvailable) {
      if (liveFileExists && resolvedPath != null) {
        return ResolvedAttachment(
          attachmentInfo: attachmentInfo,
          availability: ResolvedAttachmentAvailability.available,
          provenance: AttachmentProvenance.messagesLive,
          resolvedFilePath: resolvedPath,
          archivePayloadStatus: archiveRecord == null
              ? null
              : archivePayloadStatus,
          archiveRootAvailability: archiveRootAvailability,
          archiveLocationGeneration: archiveLocationGeneration,
          archiveRootIssue: archiveRootIssue,
        );
      }
      return ResolvedAttachment(
        attachmentInfo: attachmentInfo,
        availability: ResolvedAttachmentAvailability.archiveUnavailable,
        archivePayloadStatus: archiveRecord == null
            ? null
            : archivePayloadStatus,
        archiveRootAvailability: archiveRootAvailability,
        archiveLocationGeneration: archiveLocationGeneration,
        archiveRootIssue: archiveRootIssue,
      );
    }
  }

  if (liveFileExists && resolvedPath != null && archiveKey != null) {
    if (archiveLocation != null &&
        !archiveLocation.isWritableMutationEligible) {
      return ResolvedAttachment(
        attachmentInfo: attachmentInfo,
        availability: ResolvedAttachmentAvailability.available,
        provenance: AttachmentProvenance.messagesLive,
        resolvedFilePath: resolvedPath,
        archivePayloadStatus: archivePayloadStatus,
        archiveRootAvailability: archiveRootAvailability,
        archiveLocationGeneration: archiveLocationGeneration,
        archiveRootIssue: archiveRootIssue,
      );
    }
    _triggerOnDemandArchive(
      ref,
      archiveKey: archiveKey,
      resolvedLocalPath: resolvedPath,
      mimeType: attachmentInfo.mimeType,
    );

    return ResolvedAttachment(
      attachmentInfo: attachmentInfo,
      availability: ResolvedAttachmentAvailability.pendingArchive,
      recoveryMetadata: mergeAttachmentRecoveryMetadata(
        base: AttachmentRecoveryMetadata(
          nextRecoveryAttemptAt: DateTime.now().toUtc(),
          recoveryPriority: 1,
        ),
        persistedHint: persistedRecoveryHint,
      ),
      archivePayloadStatus: archivePayloadStatus,
      archiveRootAvailability: archiveRootAvailability,
      archiveLocationGeneration: archiveLocationGeneration,
      archiveRootIssue: archiveRootIssue,
    );
  }

  if (liveFileExists) {
    return ResolvedAttachment(
      attachmentInfo: attachmentInfo,
      availability: ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
      recoveryMetadata: mergeAttachmentRecoveryMetadata(
        base: AttachmentRecoveryMetadata(
          nextRecoveryAttemptAt: DateTime.now().toUtc(),
          lastRecoveryErrorSummary:
              'Live attachment is present but cannot be archived yet.',
        ),
        persistedHint: persistedRecoveryHint,
      ),
      archivePayloadStatus: archivePayloadStatus,
      archiveRootAvailability: archiveRootAvailability,
      archiveLocationGeneration: archiveLocationGeneration,
      archiveRootIssue: archiveRootIssue,
    );
  }

  final isRecoverable = attachmentInfo.hasLocalFile || archiveKey != null;

  return ResolvedAttachment(
    attachmentInfo: attachmentInfo,
    availability: isRecoverable
        ? ResolvedAttachmentAvailability.unavailableAwaitingRecovery
        : ResolvedAttachmentAvailability.nonRecoverable,
    recoveryMetadata: mergeAttachmentRecoveryMetadata(
      base: AttachmentRecoveryMetadata(
        nextRecoveryAttemptAt: isRecoverable ? DateTime.now().toUtc() : null,
        lastRecoveryErrorSummary: isRecoverable
            ? null
            : 'Attachment has no viable live or archive recovery key.',
        isNonRecoverable: !isRecoverable,
      ),
      persistedHint: persistedRecoveryHint,
    ),
    archivePayloadStatus: archivePayloadStatus,
    archiveRootAvailability: archiveRootAvailability,
    archiveLocationGeneration: archiveLocationGeneration,
    archiveRootIssue: archiveRootIssue,
  );
}

ResolvedAttachment _resolveForLiveOnlyMode({
  required AttachmentInfo attachmentInfo,
  required AttachmentFileAccess fileAccess,
}) {
  final resolvedPath = fileAccess.expandPath(attachmentInfo.localPath);
  final resolvedFilePath = fileAccess.existingExpandedPath(resolvedPath);
  if (resolvedFilePath != null) {
    return ResolvedAttachment(
      attachmentInfo: attachmentInfo,
      availability: ResolvedAttachmentAvailability.available,
      provenance: AttachmentProvenance.messagesLive,
      resolvedFilePath: resolvedFilePath,
    );
  }

  if (attachmentInfo.hasLocalFile) {
    return ResolvedAttachment(
      attachmentInfo: attachmentInfo,
      availability: ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
      recoveryMetadata: AttachmentRecoveryMetadata(
        nextRecoveryAttemptAt: DateTime.now().toUtc(),
      ),
    );
  }

  return ResolvedAttachment(
    attachmentInfo: attachmentInfo,
    availability: ResolvedAttachmentAvailability.nonRecoverable,
    recoveryMetadata: const AttachmentRecoveryMetadata(
      isNonRecoverable: true,
      lastRecoveryErrorSummary:
          'Attachment has no local path for live-only resolution.',
    ),
  );
}

/// Fire-and-forget: archive a locally-available file that may not yet be
/// in the archive. Checks settings to respect the user's preference.
void _triggerOnDemandArchive(
  AttachmentResolverRef ref, {
  required ArchiveCompatibilityKey archiveKey,
  required String resolvedLocalPath,
  required String? mimeType,
}) {
  // Read settings synchronously from cache to avoid blocking resolution.
  final settingsAsync = ref.read(archiveSettingsProvider);
  final settings = settingsAsync.valueOrNull;
  if (settings == null || !settings.isEnabled) {
    return;
  }

  unawaited(
    _archiveOnDemand(
      ref,
      archiveKey: archiveKey,
      resolvedLocalPath: resolvedLocalPath,
      mimeType: mimeType,
    ),
  );
}

Future<void> _archiveOnDemand(
  AttachmentResolverRef ref, {
  required ArchiveCompatibilityKey archiveKey,
  required String resolvedLocalPath,
  required String? mimeType,
}) async {
  try {
    await ref
        .read(attachmentArchiveServiceProvider.notifier)
        .archiveAttachment(
          archiveKey: archiveKey,
          resolvedLocalPath: resolvedLocalPath,
          mimeType: mimeType,
          sha256Hex: null,
        );
  } catch (error, stackTrace) {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'On-demand attachment archive failed',
          source: 'AttachmentResolver',
          context: <String, Object?>{
            'archiveKey': archiveKey.storageKeySegment,
            'resolvedLocalPath': resolvedLocalPath,
            'error': error.toString(),
            'stackTrace': stackTrace.toString(),
          },
        );
  }
}
