import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_source_access/presentation/app_czar_source_access_screen.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access_provider.dart';

void main() {
  testWidgets('host renders bounded Fair-Witness repair and UNKNOWN exit', (
    tester,
  ) async {
    final reader = _ScreenReader();
    final settings = _FakeFullDiskAccess();
    final restarter = _FakeRestarter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCzarObservationReaderProvider.overrideWithValue(reader),
          fullDiskAccessProvider.overrideWithValue(settings),
          appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ],
        child: const AppCzarStartupHarness(),
      ),
    );
    await _pumpUntilFound(tester, AppCzarSourceAccessScreen.screenKey);

    expect(find.byKey(AppCzarAssessmentScreen.screenKey), findsNothing);
    expect(find.text('Messages access needs attention'), findsOneWidget);
    expect(
      find.textContaining('macOS denied this source read'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'cannot determine from this evidence whether Full Disk Access',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Full Disk Access is off'), findsNothing);
    expect(find.textContaining('Full Disk Access is on'), findsNothing);

    await tester.tap(find.byKey(AppCzarSourceAccessScreen.settingsKey));
    await tester.pump();
    expect(settings.openCalls, 1);
    expect(find.text('Current read-only check failed'), findsOneWidget);
    expect(restarter.calls, 0);

    await tester.tap(find.byKey(AppCzarSourceAccessScreen.checkAgainKey));
    await tester.pumpAndSettle();
    expect(reader.sourceReads, 2);
    expect(find.text('Current result is inconclusive'), findsOneWidget);
    expect(
      find.textContaining('inconclusive without a denial'),
      findsOneWidget,
    );
    expect(find.byKey(AppCzarSourceAccessScreen.checkAgainKey), findsNothing);
    expect(find.byKey(AppCzarSourceAccessScreen.restartKey), findsOneWidget);
    expect(restarter.calls, 0);

    await tester.tap(find.byKey(AppCzarSourceAccessScreen.restartKey));
    await tester.pump();
    expect(restarter.calls, 1);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Key key) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 1));
    if (find.byKey(key).evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $key.');
}

final class _ScreenReader implements AppCzarObservationReader {
  int sourceReads = 0;

  @override
  Future<AppCzarSourceObservation> readSource() async {
    sourceReads += 1;
    if (sourceReads == 1) {
      return const AppCzarSourceObservation(
        condition: AppCzarSourceCondition.accessDenied,
        issue: 'macOS denied this source read.',
      );
    }
    return const AppCzarSourceObservation.unknown(
      'The current check was inconclusive without a denial result.',
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
  Future<AppCzarDatabaseObservation> readImportStore() async => _importStore;

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async => _graphStore;

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async => _overlay;

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async => _archive;
}

final class _FakeFullDiskAccess implements FullDiskAccess {
  int openCalls = 0;

  @override
  String get messagesDatabasePath => '/test/Library/Messages/chat.db';

  @override
  bool canReadMessagesDatabase() => false;

  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() =>
      MessagesSourceAccessResult.accessDenied;

  @override
  Future<void> openSettings() async {
    openCalls += 1;
  }
}

final class _FakeRestarter implements AppCzarProcessRestarter {
  int calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls += 1;
  }
}

const _importStore = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 10,
  messageCount: 100,
  liveMessageCount: 100,
  liveMaxSourceRowId: 100,
);
const _graphStore = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 3,
  messageCount: 100,
  chatCount: 4,
  chatMessageEdgeCount: 100,
);
const _overlay = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 8,
);
const _archive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Test archive',
);
