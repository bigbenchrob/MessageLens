import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';

void main() {
  group('AttachmentArchiveWritableRootLease admission', () {
    test(
      'default available admits a generation-bound destructive lease',
      () async {
        final location = AttachmentArchiveLocationState.defaultAvailable(
          archiveRootPath: '/internal/attachment_archive',
        );
        final harness = _LeaseHarness(location);
        addTearDown(harness.dispose);

        final admission = await harness.admission;

        expect(admission.isAdmitted, isTrue);
        expect(admission.lease?.archiveRootPath, location.archiveRootPath);
        expect(admission.lease?.locationGeneration, 0);
        expect(admission.lease?.permitsDestructiveReset, isTrue);
      },
    );

    test(
      'selected custom root stays denied until verified activation',
      () async {
        final harness = _LeaseHarness(
          AttachmentArchiveLocationState.customAvailable(
            configuration: _customConfiguration(),
            archiveRootPath: '/Volumes/Selected/Archive',
          ),
        );
        addTearDown(harness.dispose);

        final admission = await harness.admission;

        expect(admission.isAdmitted, isFalse);
        expect(
          admission.deferredReason,
          AttachmentArchiveMutationDeferredReason.customArchiveNotActivated,
        );
      },
    );

    test(
      'explicitly activated custom root admits non-destructive writes',
      () async {
        final harness = _LeaseHarness(
          AttachmentArchiveLocationState.customAvailable(
            configuration: _customConfiguration(
              writePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
            ),
            archiveRootPath: '/Volumes/Activated/Archive',
          ),
        );
        addTearDown(harness.dispose);

        final admission = await harness.admission;
        final lease = admission.lease!;
        final validation = await lease.validate(
          operation: ArchiveMutationOperation.attachmentReconciliation,
          boundary: AttachmentArchiveMutationBoundary.operationStart,
        );
        final destructiveValidation = await lease.validate(
          operation: ArchiveMutationOperation.attachmentClearing,
          boundary: AttachmentArchiveMutationBoundary.beforeDestructiveReset,
        );

        expect(validation.isValid, isTrue);
        expect(lease.permitsDestructiveReset, isFalse);
        expect(destructiveValidation.isValid, isFalse);
        expect(
          destructiveValidation.deferredReason,
          AttachmentArchiveMutationDeferredReason.destructiveResetNotPermitted,
        );
      },
    );

    test('non-writable location states return exact typed reasons', () async {
      final configuration = _customConfiguration(
        writePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
      );
      final cases =
          <
            (
              AttachmentArchiveLocationState,
              AttachmentArchiveMutationDeferredReason,
            )
          >[
            (
              AttachmentArchiveLocationState.customReadOnly(
                configuration: configuration,
                archiveRootPath: '/Volumes/ReadOnly/Archive',
              ),
              AttachmentArchiveMutationDeferredReason.customArchiveReadOnly,
            ),
            (
              AttachmentArchiveLocationState.customUnavailable(
                configuration: configuration,
                issue: 'Disconnected.',
              ),
              AttachmentArchiveMutationDeferredReason.customArchiveUnavailable,
            ),
            (
              AttachmentArchiveLocationState.permissionDenied(
                configuration: configuration,
                issue: 'Denied.',
              ),
              AttachmentArchiveMutationDeferredReason.permissionDenied,
            ),
            (
              AttachmentArchiveLocationState.configuredDirectoryMissing(
                configuration: configuration,
                issue: 'Missing.',
              ),
              AttachmentArchiveMutationDeferredReason
                  .configuredDirectoryMissing,
            ),
            (
              AttachmentArchiveLocationState.configurationInvalid(
                issue: 'Invalid.',
              ),
              AttachmentArchiveMutationDeferredReason.configurationInvalid,
            ),
          ];

      for (final testCase in cases) {
        final harness = _LeaseHarness(testCase.$1);
        final admission = await harness.admission;
        expect(admission.lease, isNull);
        expect(admission.deferredReason, testCase.$2);
        harness.dispose();
      }
    });

    test('generation change invalidates an already-issued lease', () async {
      final initial = AttachmentArchiveLocationState.defaultAvailable(
        archiveRootPath: '/internal/attachment_archive',
        generation: 4,
      );
      final harness = _LeaseHarness(initial);
      addTearDown(harness.dispose);
      final lease = (await harness.admission).lease!;

      harness.replace(initial.withGeneration(5));
      final validation = await lease.validate(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        boundary: AttachmentArchiveMutationBoundary.beforeFinalInstall,
      );

      expect(validation.isValid, isFalse);
      expect(
        validation.deferredReason,
        AttachmentArchiveMutationDeferredReason.staleGeneration,
      );
    });

    test(
      'configuration identity change invalidates same-generation lease',
      () async {
        final first = AttachmentArchiveLocationState.customAvailable(
          configuration: _customConfiguration(
            bookmarkByte: 1,
            writePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
          ),
          archiveRootPath: '/Volumes/Archive',
          generation: 9,
        );
        final harness = _LeaseHarness(first);
        addTearDown(harness.dispose);
        final lease = (await harness.admission).lease!;

        harness.replace(
          AttachmentArchiveLocationState.customAvailable(
            configuration: _customConfiguration(
              bookmarkByte: 2,
              writePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
            ),
            archiveRootPath: '/Volumes/Archive',
            generation: 9,
          ),
        );
        final validation = await lease.validate(
          operation: ArchiveMutationOperation.attachmentReconciliation,
          boundary: AttachmentArchiveMutationBoundary.beforeMetadataCommit,
        );

        expect(validation.isValid, isFalse);
        expect(
          validation.deferredReason,
          AttachmentArchiveMutationDeferredReason.staleConfigurationIdentity,
        );
      },
    );

    test(
      'disposing the issuing location authority revokes its lease',
      () async {
        final harness = _LeaseHarness(
          AttachmentArchiveLocationState.defaultAvailable(
            archiveRootPath: '/internal/attachment_archive',
          ),
        );
        addTearDown(harness.dispose);
        final lease = (await harness.admission).lease!;

        await harness.resetLocationAuthority();
        final validation = await lease.validate(
          operation: ArchiveMutationOperation.attachmentReconciliation,
          boundary: AttachmentArchiveMutationBoundary.beforeFinalInstall,
        );

        expect(validation.isValid, isFalse);
        expect(
          validation.deferredReason,
          AttachmentArchiveMutationDeferredReason.staleGeneration,
        );
      },
    );
  });
}

AttachmentArchiveLocationConfiguration _customConfiguration({
  int bookmarkByte = 1,
  AttachmentArchiveCustomWritePolicy writePolicy =
      AttachmentArchiveCustomWritePolicy.readOnlyUntilVerifiedAdoption,
}) {
  return AttachmentArchiveLocationConfiguration.customExternal(
    bookmarkDataBase64: base64Encode(<int>[bookmarkByte]),
    lastKnownPath: '/Volumes/Archive',
    customWritePolicy: writePolicy,
  );
}

final class _LeaseHarness {
  _LeaseHarness(AttachmentArchiveLocationState initial)
    : container = ProviderContainer(
        overrides: [
          attachmentArchiveLocationProvider.overrideWith(
            () => _MutableAttachmentArchiveLocation(initial),
          ),
        ],
      );

  final ProviderContainer container;

  Future<AttachmentArchiveWritableRootAdmission> get admission =>
      container.read(attachmentArchiveWritableRootAdmissionProvider.future);

  void replace(AttachmentArchiveLocationState location) {
    final active = container.read(attachmentArchiveLocationProvider.notifier);
    (active as _MutableAttachmentArchiveLocation).replace(location);
  }

  Future<void> resetLocationAuthority() async {
    container.invalidate(attachmentArchiveLocationProvider);
    await container.read(attachmentArchiveLocationProvider.future);
  }

  void dispose() => container.dispose();
}

final class _MutableAttachmentArchiveLocation
    extends AttachmentArchiveLocation {
  _MutableAttachmentArchiveLocation(this.initial);

  final AttachmentArchiveLocationState initial;

  @override
  Future<AttachmentArchiveLocationState> build() async => initial;

  void replace(AttachmentArchiveLocationState location) {
    state = AsyncData(location);
  }
}
