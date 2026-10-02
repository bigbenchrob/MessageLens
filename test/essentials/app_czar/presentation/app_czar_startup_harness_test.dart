import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';

void main() {
  testWidgets(
    'projects current facts, diagnosis, and one virtual coordinator',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _HealthyReader(),
            ),
          ],
          child: const AppCzarStartupHarness(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(AppCzarAssessmentScreen.screenKey), findsOneWidget);
      expect(find.text('TRUE'), findsNothing);
      expect(find.text('FALSE'), findsNothing);
      expect(find.textContaining('Full Disk Access'), findsNothing);
      expect(find.text('New messages'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Source and MessageLens are current.'), findsOneWidget);
      expect(
        find.text(
          'This appears to be a healthy current MessageLens installation.',
        ),
        findsOneWidget,
      );
      expect(find.text('Operating Session'), findsOneWidget);
      expect(
        find.text('Diagnostic only. No coordinator has been started.'),
        findsOneWidget,
      );
      expect(find.text('Checking databases…'), findsNothing);
      expect(find.text('Checking what MessageLens needs'), findsNothing);

      final details = find.byKey(AppCzarAssessmentScreen.detailsKey);
      await tester.ensureVisible(details);
      await tester.tap(details);
      await tester.pumpAndSettle();
      expect(find.textContaining('Message count: 100.'), findsWidgets);
      expect(find.textContaining('High-water: 100.'), findsWidgets);
    },
  );

  testWidgets('shows genuine pending state before evidence resolves', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(
            _NeverCompletingReader(),
          ),
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
  });
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
