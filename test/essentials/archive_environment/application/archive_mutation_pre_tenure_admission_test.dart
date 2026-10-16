import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/application/archive_access_authority_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/application/archive_reset_admission_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/application/verified_archive_checkpoint_provider.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_operation.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_reset_admission.dart';
import 'package:remember_this_text/essentials/exclusive_authority/feature_level_providers.dart';
import 'package:remember_this_text/essentials/startup_presentation_evidence/domain/startup_presentation_evidence.dart';

const _resets = [
  ArchiveMutationOperation.startFresh,
  ArchiveMutationOperation.messageDataReset,
];

void main() {
  for (final operation in _resets) {
    for (final input in ['appCzar', 'missing', 'throwing', 'revoked']) {
      for (final capabilityApi in [false, true]) {
        test(
          'real front door ${operation.name}: $input capability=$capabilityApi',
          () async {
            final root = _input(input);
            var forbiddenReads = 0;
            var callbacks = 0;
            Never forbidden() {
              forbiddenReads += 1;
              throw StateError('Forbidden authority construction');
            }

            final container = ProviderContainer(
              overrides: [
                if (input != 'missing')
                  archiveResetAdmissionProvider.overrideWith((ref) {
                    if (input == 'throwing') {
                      throw StateError('Synthetic private input detail');
                    }
                    ref.onDispose(root.revoke);
                    return root;
                  }),
                exclusiveAuthorityRegistryProvider.overrideWith(() {
                  forbidden();
                }),
                archiveAccessAuthorityProvider.overrideWith(
                  (ref) => forbidden(),
                ),
                verifiedArchiveCheckpointProvider.overrideWith(() {
                  forbidden();
                }),
                archiveCheckpointReceiptValidatorProvider.overrideWith(
                  (ref) => forbidden(),
                ),
              ],
            );
            addTearDown(container.dispose);
            final coordinator = container.read(
              archiveMutationCoordinatorProvider.notifier,
            );
            final future = capabilityApi
                ? coordinator.runWithCapability<void>(
                    operation: operation,
                    ownerLabel: 'synthetic',
                    action: (_) async {
                      callbacks += 1;
                    },
                  )
                : coordinator.run<void>(
                    operation: operation,
                    ownerLabel: 'synthetic',
                    action: () async {
                      callbacks += 1;
                    },
                  );
            await expectLater(future, throwsA(isA<ArchiveResetDenied>()));
            expect(forbiddenReads, 0);
            expect(callbacks, 0);
            expect(
              container.exists(exclusiveAuthorityRegistryProvider),
              isFalse,
            );
            final state = container.read(archiveMutationCoordinatorProvider);
            expect(state.isLocked, isFalse);
            expect(state.activeOperations, isEmpty);
            expect(state.deniedRequests, 0); // No tenure-denial path entered.
          },
        );
      }
    }
    for (final nested in [false, true]) {
      for (final input in [
        'appCzar',
        'missing',
        'throwing',
        'revoked',
        'legacy',
      ]) {
        test(
          'same private helper ${operation.name}: $input candidate=$nested',
          () async {
            final result = await ArchiveMutationAdmissionTestSupport.inspect(
              operation: operation,
              lifetime: input == 'throwing' ? null : _input(input),
              reentrantCandidate: nested,
            );
            expect(result.resetReads, 1);
            final allowed = input == 'legacy';
            expect(result.completed, allowed);
            expect(result.candidateReads, allowed ? 1 : 0);
            expect(result.ordinaryEntries, allowed && !nested ? 1 : 0);
            expect(result.reentrantEntries, allowed && nested ? 1 : 0);
            expect(result.denial, allowed ? isNull : isNotNull);
          },
        );
      }
      test(
        'revocation after inert branch entry ${operation.name}: $nested',
        () async {
          final root = _input('legacy');
          final future = ArchiveMutationAdmissionTestSupport.inspect(
            operation: operation,
            lifetime: root,
            reentrantCandidate: nested,
          );
          root.revoke();
          final result = await future;
          expect(result.ordinaryEntries + result.reentrantEntries, 1);
          expect(result.completed, isFalse);
          expect(result.denial, ArchiveResetDenialReason.revoked);
          // This is the shared late-check primitive after an inert suspension,
          // NOT a real tenure, checkpoint, capability or nested Zone.
        },
      );
    }
  }

  for (final operation in ArchiveMutationOperation.values.where(
    (op) => !_resets.contains(op),
  )) {
    for (final nested in [false, true]) {
      test(
        'non-reset ${operation.name} bypasses throwing input: $nested',
        () async {
          final result = await ArchiveMutationAdmissionTestSupport.inspect(
            operation: operation,
            lifetime: null,
            reentrantCandidate: nested,
          );
          expect(result.resetReads, 0);
          expect(result.completed, isTrue);
          expect(result.denial, isNull);
          expect(result.ordinaryEntries, nested ? 0 : 1);
          expect(result.reentrantEntries, nested ? 1 : 0);
        },
      );
    }
  }
}

ArchiveResetAdmission _input(String kind) {
  if (kind == 'missing' || kind == 'throwing') {
    return ArchiveResetAdmission.unavailable();
  }
  final root = ArchiveResetAdmission.selected(
    kind == 'appCzar'
        ? StartupPresentationComposition.appCzar
        : StartupPresentationComposition.startupApp,
  );
  if (kind == 'revoked') {
    root.revoke();
  }
  return root;
}
