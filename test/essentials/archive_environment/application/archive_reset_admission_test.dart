import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/application/archive_reset_admission_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_operation.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_reset_admission.dart';
import 'package:remember_this_text/essentials/startup_presentation_evidence/domain/startup_presentation_evidence.dart';

void main() {
  for (final operation in [
    ArchiveMutationOperation.startFresh,
    ArchiveMutationOperation.messageDataReset,
  ]) {
    test('explicit selection controls only reset veto: ${operation.name}', () {
      final legacy = ArchiveResetAdmission.selected(
        StartupPresentationComposition.startupApp,
      );
      expect(() => legacy.bind().requireAllowed(operation), returnsNormally);
      for (final root in [
        ArchiveResetAdmission.unavailable(),
        ArchiveResetAdmission.selected(StartupPresentationComposition.appCzar),
      ]) {
        expect(
          () => root.bind().requireAllowed(operation),
          throwsA(isA<ArchiveResetDenied>()),
        );
      }
      legacy.revoke();
      expect(legacy.state, ArchiveResetAdmissionState.revoked);
      expect(
        () => legacy.bind().requireAllowed(operation),
        throwsA(isA<ArchiveResetDenied>()),
      );
    });
  }

  test('ABA cannot revive an old root or consumer; epochs differ', () {
    final first = ArchiveResetAdmission.selected(
      StartupPresentationComposition.startupApp,
    );
    final old = first.bind();
    first.revoke();
    first.revoke();
    final next = ArchiveResetAdmission.selected(
      StartupPresentationComposition.startupApp,
    );
    expect(identical(first.epoch, next.epoch), isFalse);
    expect(identical(old.epoch, first.epoch), isTrue);
    expect(old.isCurrentFor(ArchiveMutationOperation.startFresh), isFalse);
    expect(
      next.bind().isCurrentFor(ArchiveMutationOperation.startFresh),
      isTrue,
    );
  });

  test('closing one binding cannot revoke parent or sibling', () {
    final root = ArchiveResetAdmission.selected(
      StartupPresentationComposition.startupApp,
    );
    final first = root.bind();
    final second = root.bind();
    first.close();
    first.close();
    expect(first.isCurrentFor(ArchiveMutationOperation.startFresh), isFalse);
    expect(second.isCurrentFor(ArchiveMutationOperation.startFresh), isTrue);
    expect(root.state, ArchiveResetAdmissionState.startupApp);
    root.revoke();
    expect(second.isCurrentFor(ArchiveMutationOperation.startFresh), isFalse);
  });

  test('default provider is unavailable and disposal revokes it', () {
    final container = ProviderContainer();
    final root = container.read(archiveResetAdmissionProvider);
    expect(root.state, ArchiveResetAdmissionState.unavailable);
    container.dispose();
    expect(root.state, ArchiveResetAdmissionState.revoked);
  });

  test(
    'root override lifecycle revokes the same object without reselection',
    () async {
      final root = ArchiveResetAdmission.selected(
        StartupPresentationComposition.startupApp,
      );
      var disposals = 0;
      final container = ProviderContainer(
        overrides: [
          archiveResetAdmissionProvider.overrideWith((ref) {
            ref.onDispose(() {
              disposals += 1;
              root.revoke();
            });
            return root;
          }),
        ],
      );
      final captured = container.read(archiveResetAdmissionProvider).bind();
      container.invalidate(archiveResetAdmissionProvider);
      await container.pump();
      expect(disposals, 1);
      expect(root.state, ArchiveResetAdmissionState.revoked);
      expect(
        identical(container.read(archiveResetAdmissionProvider), root),
        isTrue,
      );
      expect(
        captured.isCurrentFor(ArchiveMutationOperation.startFresh),
        isFalse,
      );
      container.dispose();
      expect(disposals, 2); // One callback per realized provider lifetime.
      expect(
        root.state,
        ArchiveResetAdmissionState.revoked,
      ); // Never reselected.
    },
  );

  test(
    'default invalidation produces unavailable, never implicit legacy',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final old = container.read(archiveResetAdmissionProvider);
      container.invalidate(archiveResetAdmissionProvider);
      await container.pump();
      final next = container.read(archiveResetAdmissionProvider);
      expect(old.state, ArchiveResetAdmissionState.revoked);
      expect(next.state, ArchiveResetAdmissionState.unavailable);
      expect(identical(old.epoch, next.epoch), isFalse);
    },
  );

  test('denial contains only a bounded reason', () {
    const error = ArchiveResetDenied(ArchiveResetDenialReason.unavailable);
    expect(error.toString(), 'Archive reset denied: unavailable.');
  });

  test(
    'non-reset operation policy and checkpoint distinction are unchanged',
    () {
      expect(
        ArchiveMutationOperation.messageDataReset.requiresVerifiedCheckpoint,
        isTrue,
      );
      expect(
        ArchiveMutationOperation.startFresh.requiresVerifiedCheckpoint,
        isFalse,
      );
      for (final operation in ArchiveMutationOperation.values) {
        if (!ArchiveResetAdmission.appliesTo(operation)) {
          final binding = ArchiveResetAdmission.unavailable().bind()..close();
          expect(() => binding.requireAllowed(operation), returnsNormally);
        }
      }
    },
  );
}
