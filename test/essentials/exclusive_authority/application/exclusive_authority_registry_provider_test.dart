import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/exclusive_authority/application/exclusive_authority_registry_provider.dart'
    show
        ExclusiveAuthorityRegistryTestSupport,
        ExclusiveAuthorityScopeCleanupTestHandle;
import 'package:remember_this_text/essentials/exclusive_authority/domain/exclusive_authority_key.dart'
    show ExclusiveAuthorityKeyTestSupport;
import 'package:remember_this_text/essentials/exclusive_authority/feature_level_providers.dart';

void main() {
  test('free acquisition issues Ball 1', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    final started = Completer<void>();
    final release = Completer<void>();
    late ExclusiveAuthorityTenure tenure;

    final operation = harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'first-owner',
      action: (issuedTenure) {
        tenure = issuedTenure;
        started.complete();
        return release.future;
      },
    );

    await started.future;
    expect(tenure.diagnosticOccurrence, 1);
    expect(tenure.authority, ExclusiveAuthorityKey.archiveMutation);
    expect(
      harness.diagnostic(ExclusiveAuthorityKey.archiveMutation).isHeld,
      isTrue,
    );
    expect(
      () => harness.registry.requireCurrent(
        authority: ExclusiveAuthorityKey.archiveMutation,
        tenure: tenure,
      ),
      returnsNormally,
    );

    release.complete();
    await operation;
  });

  test('foreign acquisition is denied before its action starts', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    var deniedActionStarted = false;

    final first = harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'first-owner',
      action: (_) {
        firstStarted.complete();
        return releaseFirst.future;
      },
    );
    await firstStarted.future;

    await expectLater(
      harness.registry.runExclusive<void>(
        authority: ExclusiveAuthorityKey.archiveMutation,
        ownerLabel: 'foreign-owner',
        action: (_) async {
          deniedActionStarted = true;
        },
      ),
      throwsA(isA<ExclusiveAuthorityDeniedException>()),
    );
    expect(deniedActionStarted, isFalse);

    releaseFirst.complete();
    await first;
  });

  test('explicitly delegated Ball remains current across awaits', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'awaiting-owner',
      action: (tenure) async {
        await Future<void>.value();
        await Future<void>.value();
        expect(
          () => harness.registry.requireCurrent(
            authority: ExclusiveAuthorityKey.archiveMutation,
            tenure: tenure,
          ),
          returnsNormally,
        );
      },
    );
  });

  test('re-entry reuses Ball 1 and increments hold count', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'reentrant-owner',
      action: (tenure) async {
        expect(harness.diagnostic(tenure.authority).holdCount, 1);
        await harness.registry.runReentrant<void>(
          tenure: tenure,
          action: () async {
            expect(tenure.diagnosticOccurrence, 1);
            expect(harness.diagnostic(tenure.authority).holdCount, 2);
            harness.registry.requireCurrent(
              authority: tenure.authority,
              tenure: tenure,
            );
          },
        );
        expect(harness.diagnostic(tenure.authority).holdCount, 1);
      },
    );
  });

  test('final release permanently kills Ball 1', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    late ExclusiveAuthorityTenure tenure;

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'released-owner',
      action: (issuedTenure) async {
        tenure = issuedTenure;
      },
    );

    expect(
      () => harness.registry.requireCurrent(
        authority: ExclusiveAuthorityKey.archiveMutation,
        tenure: tenure,
      ),
      throwsA(
        isA<ExclusiveAuthorityProofDeniedException>().having(
          (error) => error.reason,
          'reason',
          ExclusiveAuthorityProofDenialReason.staleOrReleased,
        ),
      ),
    );
    expect(harness.diagnostic(tenure.authority).isHeld, isFalse);
  });

  test('reacquisition issues distinct Ball 2', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    late ExclusiveAuthorityTenure first;
    late ExclusiveAuthorityTenure second;

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'owner',
      action: (tenure) async {
        first = tenure;
      },
    );
    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'owner',
      action: (tenure) async {
        second = tenure;
      },
    );

    expect(second, isNot(same(first)));
    expect(first.diagnosticOccurrence, 1);
    expect(second.diagnosticOccurrence, 2);
  });

  test(
    'provider remains stable and usable for its container lifetime',
    () async {
      final harness = _RegistryHarness.create();
      addTearDown(harness.dispose);
      final originalRegistry = harness.registry;

      await originalRegistry.runExclusive<void>(
        authority: ExclusiveAuthorityKey.archiveMutation,
        ownerLabel: 'first-container-lifetime-owner',
        action: (_) async {},
      );
      await Future<void>.value();

      expect(harness.registry, same(originalRegistry));
      await harness.registry.runExclusive<void>(
        authority: ExclusiveAuthorityKey.archiveMutation,
        ownerLabel: 'second-container-lifetime-owner',
        action: (tenure) async {
          expect(tenure.diagnosticOccurrence, 2);
        },
      );
    },
  );

  test('stale Ball 1 cannot act on live Ball 2', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    late ExclusiveAuthorityTenure first;
    late ExclusiveAuthorityTenure second;
    final secondStarted = Completer<void>();
    final releaseSecond = Completer<void>();

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'first-owner',
      action: (tenure) async {
        first = tenure;
      },
    );
    final secondOperation = harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'second-owner',
      action: (tenure) {
        second = tenure;
        secondStarted.complete();
        return releaseSecond.future;
      },
    );
    await secondStarted.future;

    await expectLater(
      harness.registry.runReentrant<void>(tenure: first, action: () async {}),
      throwsA(isA<ExclusiveAuthorityProofDeniedException>()),
    );
    harness.registry.requireCurrent(
      authority: ExclusiveAuthorityKey.archiveMutation,
      tenure: second,
    );
    expect(harness.diagnostic(second.authority).holdCount, 1);

    releaseSecond.complete();
    await secondOperation;
  });

  test(
    'outer exception releases and preserves the original exception',
    () async {
      final harness = _RegistryHarness.create();
      addTearDown(harness.dispose);
      final failure = StateError('original failure');

      await expectLater(
        harness.registry.runExclusive<void>(
          authority: ExclusiveAuthorityKey.archiveMutation,
          ownerLabel: 'failing-owner',
          action: (_) async {
            throw failure;
          },
        ),
        throwsA(same(failure)),
      );
      expect(
        harness.diagnostic(ExclusiveAuthorityKey.archiveMutation).isHeld,
        isFalse,
      );
    },
  );

  test('inner exception releases only the re-entrant scope', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'outer-owner',
      action: (tenure) async {
        await expectLater(
          harness.registry.runReentrant<void>(
            tenure: tenure,
            action: () async {
              throw StateError('inner failure');
            },
          ),
          throwsStateError,
        );
        harness.registry.requireCurrent(
          authority: tenure.authority,
          tenure: tenure,
        );
        expect(harness.diagnostic(tenure.authority).holdCount, 1);
      },
    );
  });

  test(
    'unrelated async task without the Ball cannot acquire authority',
    () async {
      final harness = _RegistryHarness.create();
      addTearDown(harness.dispose);
      final ownerStarted = Completer<void>();
      final releaseOwner = Completer<void>();
      var unrelatedActionStarted = false;

      final owner = harness.registry.runExclusive<void>(
        authority: ExclusiveAuthorityKey.archiveMutation,
        ownerLabel: 'owner',
        action: (_) {
          ownerStarted.complete();
          return releaseOwner.future;
        },
      );
      await ownerStarted.future;

      final unrelated = Future<void>(() async {
        await harness.registry.runExclusive<void>(
          authority: ExclusiveAuthorityKey.archiveMutation,
          ownerLabel: 'unrelated',
          action: (_) async {
            unrelatedActionStarted = true;
          },
        );
      });
      await expectLater(
        unrelated,
        throwsA(isA<ExclusiveAuthorityDeniedException>()),
      );
      expect(unrelatedActionStarted, isFalse);

      releaseOwner.complete();
      await owner;
    },
  );

  test(
    'detached callback with a Ball works only while tenure is live',
    () async {
      final harness = _RegistryHarness.create();
      addTearDown(harness.dispose);
      final started = Completer<void>();
      final release = Completer<void>();
      late void Function() proveCurrent;

      final operation = harness.registry.runExclusive<void>(
        authority: ExclusiveAuthorityKey.archiveMutation,
        ownerLabel: 'delegating-owner',
        action: (tenure) {
          proveCurrent = () => harness.registry.requireCurrent(
            authority: tenure.authority,
            tenure: tenure,
          );
          started.complete();
          return release.future;
        },
      );
      await started.future;
      expect(proveCurrent, returnsNormally);

      release.complete();
      await operation;
      expect(
        proveCurrent,
        throwsA(isA<ExclusiveAuthorityProofDeniedException>()),
      );
    },
  );

  test('two typed keys can be held independently', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'archive-owner',
      action: (archiveTenure) async {
        await harness.registry.runExclusive<void>(
          authority: ExclusiveAuthorityKeyTestSupport.independent,
          ownerLabel: 'test-owner',
          action: (testTenure) async {
            harness.registry.requireCurrent(
              authority: ExclusiveAuthorityKey.archiveMutation,
              tenure: archiveTenure,
            );
            harness.registry.requireCurrent(
              authority: ExclusiveAuthorityKeyTestSupport.independent,
              tenure: testTenure,
            );
            expect(harness.diagnostic(archiveTenure.authority).isHeld, isTrue);
            expect(harness.diagnostic(testTenure.authority).isHeld, isTrue);
          },
        );
      },
    );
  });

  test('wrong-key proof fails closed', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'archive-owner',
      action: (tenure) async {
        expect(
          () => harness.registry.requireCurrent(
            authority: ExclusiveAuthorityKeyTestSupport.independent,
            tenure: tenure,
          ),
          throwsA(
            isA<ExclusiveAuthorityProofDeniedException>().having(
              (error) => error.reason,
              'reason',
              ExclusiveAuthorityProofDenialReason.wrongAuthority,
            ),
          ),
        );
      },
    );
  });

  test('tenure from another registry fails closed', () async {
    final first = _RegistryHarness.create();
    final second = _RegistryHarness.create();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await first.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'first-registry-owner',
      action: (tenure) async {
        expect(
          () => second.registry.requireCurrent(
            authority: ExclusiveAuthorityKey.archiveMutation,
            tenure: tenure,
          ),
          throwsA(
            isA<ExclusiveAuthorityProofDeniedException>().having(
              (error) => error.reason,
              'reason',
              ExclusiveAuthorityProofDenialReason.foreignRegistry,
            ),
          ),
        );
      },
    );
  });

  test('stale proof cannot decrement or clear a newer tenure', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    late ExclusiveAuthorityTenure stale;
    final currentStarted = Completer<void>();
    final releaseCurrent = Completer<void>();
    late ExclusiveAuthorityTenure current;

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'same-label',
      action: (tenure) async {
        stale = tenure;
      },
    );
    final currentOperation = harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'same-label',
      action: (tenure) {
        current = tenure;
        currentStarted.complete();
        return releaseCurrent.future;
      },
    );
    await currentStarted.future;

    await expectLater(
      harness.registry.runReentrant<void>(tenure: stale, action: () async {}),
      throwsA(isA<ExclusiveAuthorityProofDeniedException>()),
    );
    expect(harness.diagnostic(current.authority).holdCount, 1);
    harness.registry.requireCurrent(
      authority: current.authority,
      tenure: current,
    );

    releaseCurrent.complete();
    await currentOperation;
  });

  test('stale and double internal cleanup cannot alter Ball 2', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    late ExclusiveAuthorityScopeCleanupTestHandle staleCleanup;

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'ball-1-owner',
      action: (tenure) async {
        staleCleanup = ExclusiveAuthorityRegistryTestSupport.instance
            .captureOnlyActiveScope(
              registry: harness.registry,
              authority: tenure.authority,
            );
      },
    );

    final ball2Started = Completer<void>();
    final releaseBall2 = Completer<void>();
    late ExclusiveAuthorityTenure ball2;
    final ball2Operation = harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'ball-2-owner',
      action: (tenure) {
        ball2 = tenure;
        ball2Started.complete();
        return releaseBall2.future;
      },
    );
    await ball2Started.future;

    ExclusiveAuthorityRegistryTestSupport.instance.replayCleanup(staleCleanup);
    ExclusiveAuthorityRegistryTestSupport.instance.replayCleanup(staleCleanup);

    harness.registry.requireCurrent(
      authority: ExclusiveAuthorityKey.archiveMutation,
      tenure: ball2,
    );
    expect(harness.diagnostic(ball2.authority).holdCount, 1);

    releaseBall2.complete();
    await ball2Operation;
  });

  test('outer completion leaves an explicit re-entrant child live', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    final childStarted = Completer<void>();
    final releaseChild = Completer<void>();
    late ExclusiveAuthorityTenure tenure;
    late Future<void> childOperation;

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'outer-owner',
      action: (issuedTenure) async {
        tenure = issuedTenure;
        childOperation = harness.registry.runReentrant<void>(
          tenure: issuedTenure,
          action: () {
            childStarted.complete();
            return releaseChild.future;
          },
        );
        await childStarted.future;
      },
    );

    harness.registry.requireCurrent(
      authority: tenure.authority,
      tenure: tenure,
    );
    expect(harness.diagnostic(tenure.authority).holdCount, 1);

    releaseChild.complete();
    await childOperation;
    expect(
      () => harness.registry.requireCurrent(
        authority: tenure.authority,
        tenure: tenure,
      ),
      throwsA(isA<ExclusiveAuthorityProofDeniedException>()),
    );
  });

  test('registry disposal invalidates a live tenure', () async {
    final harness = _RegistryHarness.create();
    final registry = harness.registry;
    final started = Completer<void>();
    final release = Completer<void>();
    late ExclusiveAuthorityTenure tenure;

    final operation = registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'disposed-owner',
      action: (issuedTenure) {
        tenure = issuedTenure;
        started.complete();
        return release.future;
      },
    );
    await started.future;
    harness.dispose();

    expect(
      () =>
          registry.requireCurrent(authority: tenure.authority, tenure: tenure),
      throwsA(
        isA<ExclusiveAuthorityProofDeniedException>().having(
          (error) => error.reason,
          'reason',
          ExclusiveAuthorityProofDenialReason.registryDisposed,
        ),
      ),
    );
    release.complete();
    await operation;
  });

  test('diagnostics expose occupancy but no tenure proof', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'diagnostic-owner',
      action: (tenure) async {
        final diagnostic = harness.diagnostic(tenure.authority);
        expect(diagnostic.isHeld, isTrue);
        expect(diagnostic.tenureOccurrence, tenure.diagnosticOccurrence);
        expect(diagnostic.ownerLabel, 'diagnostic-owner');
        expect(diagnostic.holdCount, 1);
        expect(diagnostic, isNot(isA<ExclusiveAuthorityTenure>()));
      },
    );
  });

  test('equal owner labels do not revive an old tenure', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    late ExclusiveAuthorityTenure oldTenure;

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'reused-label',
      action: (tenure) async {
        oldTenure = tenure;
      },
    );
    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'reused-label',
      action: (newTenure) async {
        expect(newTenure, isNot(same(oldTenure)));
        expect(
          () => harness.registry.requireCurrent(
            authority: ExclusiveAuthorityKey.archiveMutation,
            tenure: oldTenure,
          ),
          throwsA(isA<ExclusiveAuthorityProofDeniedException>()),
        );
      },
    );
  });

  test('denied acquisition does not consume an occurrence', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();

    final first = harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'first-owner',
      action: (tenure) {
        expect(tenure.diagnosticOccurrence, 1);
        firstStarted.complete();
        return releaseFirst.future;
      },
    );
    await firstStarted.future;
    await expectLater(
      harness.registry.runExclusive<void>(
        authority: ExclusiveAuthorityKey.archiveMutation,
        ownerLabel: 'denied-owner',
        action: (_) async {},
      ),
      throwsA(isA<ExclusiveAuthorityDeniedException>()),
    );
    releaseFirst.complete();
    await first;

    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'next-owner',
      action: (tenure) async {
        expect(tenure.diagnosticOccurrence, 2);
        expect(harness.diagnostic(tenure.authority).deniedRequests, 1);
      },
    );
  });

  test('denial creates no queue or fairness entitlement', () async {
    final harness = _RegistryHarness.create();
    addTearDown(harness.dispose);
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    var deniedActionStarted = false;

    final first = harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'first-owner',
      action: (_) {
        firstStarted.complete();
        return releaseFirst.future;
      },
    );
    await firstStarted.future;
    await expectLater(
      harness.registry.runExclusive<void>(
        authority: ExclusiveAuthorityKey.archiveMutation,
        ownerLabel: 'denied-owner',
        action: (_) async {
          deniedActionStarted = true;
        },
      ),
      throwsA(isA<ExclusiveAuthorityDeniedException>()),
    );
    releaseFirst.complete();
    await first;

    var freshActionStarted = false;
    await harness.registry.runExclusive<void>(
      authority: ExclusiveAuthorityKey.archiveMutation,
      ownerLabel: 'fresh-claimant',
      action: (_) async {
        freshActionStarted = true;
      },
    );
    expect(deniedActionStarted, isFalse);
    expect(freshActionStarted, isTrue);
  });
}

final class _RegistryHarness {
  _RegistryHarness._(this.container);

  final ProviderContainer container;

  ExclusiveAuthorityRegistry get registry =>
      container.read(exclusiveAuthorityRegistryProvider.notifier);

  ExclusiveAuthorityDiagnostic diagnostic(ExclusiveAuthorityKey authority) {
    return container
        .read(exclusiveAuthorityRegistryProvider)
        .diagnosticFor(authority);
  }

  static _RegistryHarness create() {
    return _RegistryHarness._(ProviderContainer());
  }

  void dispose() {
    container.dispose();
  }
}
