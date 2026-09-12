import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/feature_level_providers.dart'
    show messageLensInstallationStateProvider;
import 'package:remember_this_text/essentials/services/startup_flags_service.dart';
import 'package:remember_this_text/main.dart'
    show StartupApp, shouldRestorePersistedWindowStateAfterClassification;

import 'test_support/test_archive_fixture.dart';

void main() {
  late TestArchiveFixture archiveFixture;

  setUpAll(() async {
    archiveFixture = await TestArchiveFixture.create(
      prefix: 'startup_installation_surface_',
    );
  });

  tearDownAll(() async {
    await archiveFixture.dispose();
  });

  test('only completed classification restores persisted window state', () {
    for (final kind in MessageLensInstallationStateKind.values) {
      final shouldRestore =
          shouldRestorePersistedWindowStateAfterClassification(
            MessageLensInstallationState(kind: kind, reason: 'test'),
          );
      expect(
        shouldRestore,
        kind == MessageLensInstallationStateKind.completed,
        reason: 'Unexpected window restoration policy for ${kind.name}',
      );
    }
  });

  testWidgets(
    'unresolved classification renders a restricted shell before persistence',
    (tester) async {
      final classification = Completer<MessageLensInstallationState>();
      var admittedApplicationBuildCount = 0;
      var persistentInitializationCount = 0;
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWith(
            (ref) => archiveFixture.authority,
          ),
          messageLensInstallationStateProvider.overrideWith((ref) {
            return classification.future;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: StartupApp(
            startupFlags: const StartupFlags.disabled(),
            initializeAfterClassification: (_) async {
              persistentInitializationCount += 1;
            },
            admittedChild: Builder(
              builder: (context) {
                admittedApplicationBuildCount += 1;
                return const MaterialApp(home: Text('Admitted application'));
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Checking databases…'), findsOneWidget);
      expect(find.text('Admitted application'), findsNothing);
      expect(admittedApplicationBuildCount, 0);
      expect(persistentInitializationCount, 0);

      classification.complete(
        const MessageLensInstallationState(
          kind: MessageLensInstallationStateKind.completed,
          reason: 'healthy',
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(persistentInitializationCount, 1);
      expect(admittedApplicationBuildCount, greaterThan(0));
      expect(find.text('Admitted application'), findsOneWidget);
      expect(find.text('Checking databases…'), findsNothing);
    },
  );

  testWidgets(
    'healthy startup admission cannot be reclaimed by later remediation',
    (tester) async {
      var state = const MessageLensInstallationState(
        kind: MessageLensInstallationStateKind.completed,
        reason: 'healthy',
      );
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWith(
            (ref) => archiveFixture.authority,
          ),
          messageLensInstallationStateProvider.overrideWith((ref) async {
            return state;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const StartupApp(
            startupFlags: StartupFlags.disabled(),
            admittedChild: MaterialApp(home: Text('Admitted application')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Admitted application'), findsOne);

      state = const MessageLensInstallationState(
        kind: MessageLensInstallationStateKind.remediationRequired,
        reason: 'later transient inspection failure',
      );
      container.invalidate(messageLensInstallationStateProvider);
      await tester.pumpAndSettle();

      expect(find.text('Admitted application'), findsOne);
      expect(find.text('This MessageLens setup needs attention'), findsNothing);
    },
  );

  testWidgets('initial remediation still blocks startup', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWith(
            (ref) => archiveFixture.authority,
          ),
          messageLensInstallationStateProvider.overrideWith((ref) async {
            return const MessageLensInstallationState(
              kind: MessageLensInstallationStateKind.remediationRequired,
              reason: 'initial contradictory evidence',
            );
          }),
        ],
        child: const StartupApp(
          startupFlags: StartupFlags.disabled(),
          admittedChild: MaterialApp(home: Text('Admitted application')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This MessageLens setup needs attention'), findsOne);
    expect(find.text('Admitted application'), findsNothing);
  });

  testWidgets('abandoned installation naturally offers Start Fresh', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWith(
            (ref) => archiveFixture.authority,
          ),
          messageLensInstallationStateProvider.overrideWith((ref) async {
            return const MessageLensInstallationState(
              kind: MessageLensInstallationStateKind.abandoned,
              reason: 'test abandoned state',
            );
          }),
        ],
        child: const StartupApp(startupFlags: StartupFlags.disabled()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("This MessageLens setup wasn't completed"), findsOne);
    expect(find.text('Start Fresh'), findsOne);
    expect(find.text('Delete MessageLens App Data'), findsNothing);
    final context = tester.element(find.byType(StartupApp));
    final colors = ProviderScope.containerOf(
      context,
    ).read(themeColorsProvider.notifier);
    final barriers = tester.widgetList<ModalBarrier>(find.byType(ModalBarrier));
    expect(
      barriers.any((barrier) => barrier.color == colors.surfaces.canvas),
      isTrue,
    );
  });

  testWidgets('virgin installation continues to the onboarding application', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWith(
            (ref) => archiveFixture.authority,
          ),
          messageLensInstallationStateProvider.overrideWith((ref) async {
            return const MessageLensInstallationState(
              kind: MessageLensInstallationStateKind.virgin,
              reason: 'no installation evidence',
            );
          }),
        ],
        child: const StartupApp(
          startupFlags: StartupFlags.disabled(),
          admittedChild: MaterialApp(home: Text('Onboarding application')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Onboarding application'), findsOneWidget);
    expect(find.text('This MessageLens setup needs attention'), findsNothing);
  });

  testWidgets('completed installation option surface does not offer reset', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWith(
            (ref) => archiveFixture.authority,
          ),
          messageLensInstallationStateProvider.overrideWith((ref) async {
            return const MessageLensInstallationState(
              kind: MessageLensInstallationStateKind.completed,
              reason: 'healthy',
            );
          }),
        ],
        child: const StartupApp(
          startupFlags: StartupFlags(optionLaunchResetRequested: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MessageLens setup is complete'), findsOne);
    expect(find.text('Continue'), findsOne);
    expect(find.text('Start Fresh'), findsNothing);
  });
}
