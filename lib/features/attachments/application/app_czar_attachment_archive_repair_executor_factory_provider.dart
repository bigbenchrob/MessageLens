import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_executor_provider.dart';
import '../../../essentials/app_czar_attachment_archive_repair/domain/app_czar_attachment_archive_repair_models.dart';
import '../../../essentials/archive_environment/domain/archive_mutation_capability_denied_exception.dart';
import '../../../essentials/archive_environment/domain/archive_mutation_operation.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show
        ArchiveMutationCapability,
        archiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider;
import '../infrastructure/repositories/sqlite_required_attachment_evidence_reader.dart';
import 'admitted_attachment_archive_repair_writer.dart';
import 'app_czar_attachment_archive_repair_executor.dart';
import 'attachment_archive_location_provider.dart';
import 'attachment_archive_repair_providers.dart';
import 'attachment_archive_scope_identity.dart';
import 'current_messages_attachment_source_reader.dart';

part 'app_czar_attachment_archive_repair_executor_factory_provider.g.dart';

/// Feature-owned production composition for the otherwise inert AppCzar port.
@Riverpod(keepAlive: true)
AppCzarAttachmentArchiveRepairExecutorFactory
messageLensAppCzarAttachmentArchiveRepairExecutorFactory(Ref ref) {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  return _MessageLensAttachmentArchiveRepairExecutorFactory(
    createExecutor: () => MessageLensAppCzarAttachmentArchiveRepairExecutor(
      evidenceReader: SqliteRequiredAttachmentEvidenceReader(
        admittedRootPath: authority.rootPath,
      ),
      sourceReaderResolver: () {
        return ref.read(currentMessagesAttachmentSourceReaderProvider.future);
      },
      archiveContextReader: () => _readCurrentArchiveContext(ref),
      mutationBatchExecutor:
          createAdmittedAttachmentArchiveRepairMutationBatchExecutor(
            runAdmitted: (action) {
              return ref
                  .read(archiveMutationCoordinatorProvider.notifier)
                  .runWithCapability<
                    AttachmentArchiveRepairMutationBatchResult
                  >(
                    operation:
                        ArchiveMutationOperation.attachmentReconciliation,
                    ownerLabel: 'app-czar-attachment-archive-repair',
                    action: action,
                  );
            },
            readCurrentContext: () => _readCurrentArchiveContext(ref),
            readWritableAdmission: () {
              return ref.read(
                attachmentArchiveWritableRootAdmissionProvider.future,
              );
            },
            readWriter: () {
              return ref.read(
                admittedAttachmentArchiveRepairWriterProvider.future,
              );
            },
          ),
    ),
  );
}

final class _MessageLensAttachmentArchiveRepairExecutorFactory
    implements AppCzarAttachmentArchiveRepairExecutorFactory {
  const _MessageLensAttachmentArchiveRepairExecutorFactory({
    required AppCzarAttachmentArchiveRepairExecutor Function() createExecutor,
  }) : _createExecutor = createExecutor;

  final AppCzarAttachmentArchiveRepairExecutor Function() _createExecutor;

  @override
  AppCzarAttachmentArchiveRepairExecutor create() => _createExecutor();
}

/// The sole production edge that acquires Attachment Archive Repair tenure.
typedef _RunAdmittedAttachmentArchiveRepairBatch =
    Future<AttachmentArchiveRepairMutationBatchResult> Function(
      Future<AttachmentArchiveRepairMutationBatchResult> Function(
        ArchiveMutationCapability capability,
      )
      action,
    );

/// Exposes the production admitted-batch composition for focused lifecycle
/// tests without making its concrete implementation part of the feature API.
@visibleForTesting
AttachmentArchiveRepairMutationBatchExecutor
createAdmittedAttachmentArchiveRepairMutationBatchExecutor({
  required Future<AttachmentArchiveRepairMutationBatchResult> Function(
    Future<AttachmentArchiveRepairMutationBatchResult> Function(
      ArchiveMutationCapability capability,
    )
    action,
  )
  runAdmitted,
  required AttachmentArchiveRepairArchiveContextReader readCurrentContext,
  required Future<AttachmentArchiveWritableRootAdmission> Function()
  readWritableAdmission,
  required Future<AdmittedAttachmentArchiveRepairWriter> Function() readWriter,
}) {
  return _AdmittedAttachmentArchiveRepairMutationBatchExecutor(
    runAdmitted: runAdmitted,
    readCurrentContext: readCurrentContext,
    readWritableAdmission: readWritableAdmission,
    readWriter: readWriter,
  );
}

final class _AdmittedAttachmentArchiveRepairMutationBatchExecutor
    implements AttachmentArchiveRepairMutationBatchExecutor {
  const _AdmittedAttachmentArchiveRepairMutationBatchExecutor({
    required _RunAdmittedAttachmentArchiveRepairBatch runAdmitted,
    required AttachmentArchiveRepairArchiveContextReader readCurrentContext,
    required Future<AttachmentArchiveWritableRootAdmission> Function()
    readWritableAdmission,
    required Future<AdmittedAttachmentArchiveRepairWriter> Function()
    readWriter,
  }) : _runAdmitted = runAdmitted,
       _readCurrentContext = readCurrentContext,
       _readWritableAdmission = readWritableAdmission,
       _readWriter = readWriter;

  static const _operation = ArchiveMutationOperation.attachmentReconciliation;
  final _RunAdmittedAttachmentArchiveRepairBatch _runAdmitted;
  final AttachmentArchiveRepairArchiveContextReader _readCurrentContext;
  final Future<AttachmentArchiveWritableRootAdmission> Function()
  _readWritableAdmission;
  final Future<AdmittedAttachmentArchiveRepairWriter> Function() _readWriter;

  @override
  Future<AttachmentArchiveRepairMutationBatchResult> preserveNoRecordBatch({
    required AppCzarAttachmentArchiveRepairBinding binding,
    required List<CurrentMessagesAttachmentSourceObservation> sources,
    required bool Function() shouldStop,
  }) {
    if (sources.length > appCzarAttachmentArchiveRepairPageSize) {
      throw ArgumentError.value(
        sources.length,
        'sources',
        'must fit one bounded repair page',
      );
    }
    if (shouldStop()) {
      return Future.value(
        const AttachmentArchiveRepairMutationBatchResult.stopped(),
      );
    }
    return _runAdmitted((capability) async {
          capability.requireOperation(_operation);
          if (shouldStop()) {
            return const AttachmentArchiveRepairMutationBatchResult.stopped();
          }

          final currentContext = await _readCurrentContext();
          if (!currentContext.matches(binding)) {
            return const AttachmentArchiveRepairMutationBatchResult(
              status: AttachmentArchiveRepairMutationBatchStatus
                  .archiveBindingChanged,
              processedCount: 0,
              preservedCount: 0,
            );
          }
          final admission = await _readWritableAdmission();
          final lease = admission.lease;
          if (lease == null ||
              lease.locationGeneration != binding.archiveGeneration ||
              canonicalAppCzarAttachmentArchivePath(lease.archiveRootPath) !=
                  binding.resolvedArchivePath) {
            return const AttachmentArchiveRepairMutationBatchResult(
              status: AttachmentArchiveRepairMutationBatchStatus
                  .archiveBindingChanged,
              processedCount: 0,
              preservedCount: 0,
            );
          }
          await lease.requireValid(
            operation: _operation,
            boundary: AttachmentArchiveMutationBoundary.operationStart,
          );
          capability.requireOperation(_operation);

          final writer = await _readWriter();
          var processed = 0;
          var preserved = 0;
          for (final source in sources) {
            if (shouldStop()) {
              return AttachmentArchiveRepairMutationBatchResult(
                status: AttachmentArchiveRepairMutationBatchStatus.stopped,
                processedCount: processed,
                preservedCount: preserved,
              );
            }
            capability.requireOperation(_operation);
            final result = await writer.preserveNoRecord(
              capability: capability,
              writableRootLease: lease,
              expectedSource: source,
            );
            processed += 1;
            if (result.isPreserved) {
              preserved += 1;
            }
            switch (result.status) {
              case AdmittedAttachmentArchiveRepairWriteStatus.sourceUnavailable:
                return AttachmentArchiveRepairMutationBatchResult(
                  status: AttachmentArchiveRepairMutationBatchStatus
                      .sourceAccessLost,
                  processedCount: processed,
                  preservedCount: preserved,
                );
              case AdmittedAttachmentArchiveRepairWriteStatus
                  .sourceInconclusive:
                return AttachmentArchiveRepairMutationBatchResult(
                  status: AttachmentArchiveRepairMutationBatchStatus
                      .sourceInconclusive,
                  processedCount: processed,
                  preservedCount: preserved,
                );
              case AdmittedAttachmentArchiveRepairWriteStatus.deferred:
                return AttachmentArchiveRepairMutationBatchResult(
                  status: AttachmentArchiveRepairMutationBatchStatus
                      .archiveBindingChanged,
                  processedCount: processed,
                  preservedCount: preserved,
                );
              case AdmittedAttachmentArchiveRepairWriteStatus.preserved:
              case AdmittedAttachmentArchiveRepairWriteStatus.recordAppeared:
              case AdmittedAttachmentArchiveRepairWriteStatus.sourceAbsent:
              case AdmittedAttachmentArchiveRepairWriteStatus.sourceUnreadable:
              case AdmittedAttachmentArchiveRepairWriteStatus.itemInconclusive:
              case AdmittedAttachmentArchiveRepairWriteStatus.sourceChanged:
              case AdmittedAttachmentArchiveRepairWriteStatus
                  .installationFailed:
              case AdmittedAttachmentArchiveRepairWriteStatus
                  .metadataCommitFailed:
              case AdmittedAttachmentArchiveRepairWriteStatus
                  .verificationFailed:
                break;
            }
          }
          capability.requireOperation(_operation);
          await lease.requireValid(
            operation: _operation,
            boundary:
                AttachmentArchiveMutationBoundary.beforePayloadVerification,
          );
          return AttachmentArchiveRepairMutationBatchResult(
            status: AttachmentArchiveRepairMutationBatchStatus.settled,
            processedCount: processed,
            preservedCount: preserved,
          );
        })
        .onError<ArchiveMutationCapabilityDeniedException>((error, stackTrace) {
          Error.throwWithStackTrace(error, stackTrace);
        })
        .onError<AttachmentArchiveMutationDeferredException>(
          (error, stackTrace) =>
              const AttachmentArchiveRepairMutationBatchResult(
                status: AttachmentArchiveRepairMutationBatchStatus
                    .archiveBindingChanged,
                processedCount: 0,
                preservedCount: 0,
              ),
        );
  }
}

Future<AttachmentArchiveRepairArchiveContext> _readCurrentArchiveContext(
  Ref ref,
) async {
  await ref.read(attachmentArchiveLocationProvider.notifier).refresh();
  final location = await ref.read(attachmentArchiveLocationProvider.future);
  final configuration = location.configuration;
  final archiveRootPath = location.archiveRootPath;
  if (!location.isAvailable ||
      configuration == null ||
      archiveRootPath == null ||
      archiveRootPath.trim().isEmpty) {
    throw StateError('The current attachment archive binding is unavailable.');
  }
  final authority = ref.read(archiveAccessAuthorityProvider);
  return AttachmentArchiveRepairArchiveContext(
    archiveScopeIdentity: attachmentArchiveScopeIdentity(
      archiveInstanceId: authority.identity.archiveInstanceId.value,
      configuration: configuration,
      archiveRootPath: archiveRootPath,
    ),
    archiveGeneration: location.generation,
    resolvedArchivePath: archiveRootPath,
    automaticPreservationAllowed: location.isWritableMutationEligible,
  );
}
