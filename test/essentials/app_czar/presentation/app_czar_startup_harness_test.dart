import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_session_visual_initializer_provider.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';

void main() {
  testWidgets(
    'healthy current evidence replaces assessment with Operating once',
    (tester) async {
      var displayIdentityResolverBuilds = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _HealthyReader(),
            ),
            appCzarOperatingSessionVisualInitializerProvider.overrideWithValue(
              const _ImmediateVisualInitializer(),
            ),
            displayIdentityResolverProvider.overrideWith((ref) async {
              displayIdentityResolverBuilds += 1;
              throw StateError('Operating test child must remain isolated.');
            }),
          ],
          child: const AppCzarStartupHarness(
            operatingSessionApp: SizedBox(
              key: Key('admitted-operating-session'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('admitted-operating-session')),
        findsOneWidget,
      );
      expect(find.byKey(AppCzarAssessmentScreen.screenKey), findsNothing);
      expect(displayIdentityResolverBuilds, 0);
    },
  );

  testWidgets(
    'Operating visual admission disables reassessment and reports once after entry',
    (tester) async {
      final initializer = _BlockingVisualInitializer();
      var operatingAdmissionReports = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _HealthyReader(),
            ),
            appCzarOperatingSessionVisualInitializerProvider.overrideWithValue(
              initializer,
            ),
          ],
          child: AppCzarStartupHarness(
            operatingSessionApp: const SizedBox(
              key: Key('admitted-operating-session'),
            ),
            onOperatingAdmitted: () {
              operatingAdmissionReports += 1;
            },
          ),
        ),
      );

      for (
        var attempt = 0;
        attempt < 100 && !initializer.hasStarted;
        attempt += 1
      ) {
        await tester.pump(const Duration(milliseconds: 1));
      }
      expect(initializer.hasStarted, isTrue);
      final runAgain = tester.widget<TextButton>(
        find.byKey(AppCzarAssessmentScreen.runAgainKey),
      );
      expect(runAgain.onPressed, isNull);
      expect(operatingAdmissionReports, 0);

      initializer.release();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('admitted-operating-session')),
        findsOneWidget,
      );
      expect(operatingAdmissionReports, 1);
      await tester.pump();
      expect(operatingAdmissionReports, 1);
    },
  );

  testWidgets('shows genuine pending state before evidence resolves', (
    tester,
  ) async {
    var displayIdentityResolverBuilds = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(
            _NeverCompletingReader(),
          ),
          displayIdentityResolverProvider.overrideWith((ref) async {
            displayIdentityResolverBuilds += 1;
            throw StateError('Assessment must not construct identities.');
          }),
        ],
        child: const AppCzarStartupHarness(),
      ),
    );
    await tester.pump();

    expect(find.text('Still assessing…'), findsOneWidget);
    expect(find.text('Not selected yet'), findsOneWidget);
    expect(find.text('Checking'), findsNWidgets(9));
    expect(find.textContaining('Full Disk Access'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(displayIdentityResolverBuilds, 0);
  });
}

final class _ImmediateVisualInitializer
    implements AppCzarOperatingSessionVisualInitializer {
  const _ImmediateVisualInitializer();

  @override
  Future<void> initializeVisualWindowState() async {}
}

final class _BlockingVisualInitializer
    implements AppCzarOperatingSessionVisualInitializer {
  final Completer<void> _release = Completer<void>();
  bool hasStarted = false;

  void release() {
    if (!_release.isCompleted) {
      _release.complete();
    }
  }

  @override
  Future<void> initializeVisualWindowState() async {
    hasStarted = true;
    await _release.future;
  }
}

final class _HealthyReader implements AppCzarObservationReader {
  const _HealthyReader();

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Toshiba',
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 3,
      messageCount: 100,
      chatCount: 4,
      chatMessageEdgeCount: 100,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 10,
      messageCount: 100,
      liveMessageCount: 100,
      liveMaxSourceRowId: 100,
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 8,
    );
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return const AppCzarRootObservation(
      admitted: true,
      path: '/Volumes/WD_ELEMENTS/MessageLens Development',
    );
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    return const AppCzarSourceObservation(
      condition: AppCzarSourceCondition.readable,
      messageCount: 100,
      maxRowId: 100,
      sampleStable: true,
    );
  }
}

final class _NeverCompletingReader implements AppCzarObservationReader {
  final _never = Completer<void>().future;

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    await _never;
    throw StateError('unreachable');
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    await _never;
    throw StateError('unreachable');
  }
}
