import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/presentation/app_czar_startup_harness.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/domain/app_czar_attachment_archive_repair_models.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/presentation/app_czar_attachment_archive_repair_screen.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';

void main() {
  testWidgets(
    'host shows aggregate evidence and requires explicit preservation',
    (tester) async {
      final executor = _ScreenExecutor();
      final restarter = _ScreenRestarter();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appCzarObservationReaderProvider.overrideWithValue(
              const _ScreenRepairReader(),
            ),
            appCzarAttachmentArchiveRepairExecutorFactoryProvider
                .overrideWithValue(_ScreenExecutorFactory(executor)),
            appCzarProcessRestarterProvider.overrideWithValue(restarter),
          ],
          child: const AppCzarStartupHarness(),
        ),
      );
      await _pumpUntilFound(
        tester,
        AppCzarAttachmentArchiveRepairScreen.startKey,
      );

      expect(
        find.byKey(AppCzarAttachmentArchiveRepairScreen.screenKey),
        findsOneWidget,
      );
      expect(find.byKey(AppCzarAssessmentScreen.screenKey), findsNothing);
      expect(find.text('13'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Available from Messages'), findsOneWidget);
      expect(executor.preserveCalls, 0);
      expect(restarter.calls, 0);

      expect(find.textContaining('/Volumes/Private'), findsNothing);
      expect(find.textContaining('private-family-photo.jpg'), findsNothing);
      expect(find.textContaining('private-message-guid'), findsNothing);
      expect(find.textContaining('contact name'), findsNothing);

      await tester.tap(
        find.byKey(AppCzarAttachmentArchiveRepairScreen.startKey),
      );
      await tester.pumpAndSettle();

      expect(executor.preserveCalls, 1);
      expect(find.text('Some payloads still need attention'), findsOneWidget);
      expect(
        find.byKey(AppCzarAttachmentArchiveRepairScreen.checkAgainKey),
        findsOneWidget,
      );
      expect(restarter.calls, 0);

      final exitResponse = await tester.binding.handleRequestAppExit();
      expect(exitResponse, AppExitResponse.exit);
      expect(executor.stopCalls, 1);
      expect(restarter.calls, 0);
    },
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Key key) async {
  for (var attempt = 0; attempt < 200; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 1));
    if (find.byKey(key).evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $key.');
}

final class _ScreenExecutorFactory
    implements AppCzarAttachmentArchiveRepairExecutorFactory {
  _ScreenExecutorFactory(this.executor);

  final AppCzarAttachmentArchiveRepairExecutor executor;

  @override
  AppCzarAttachmentArchiveRepairExecutor create() => executor;
}

final class _ScreenExecutor implements AppCzarAttachmentArchiveRepairExecutor {
  var preserveCalls = 0;
  var stopCalls = 0;

  @override
  Future<AppCzarAttachmentArchiveRepairObservation> inspectCurrent({
    required AppCzarAttachmentArchiveRepairBinding binding,
  }) async {
    return AppCzarAttachmentArchiveRepairObservation(
      kind: AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete,
      binding: binding,
      snapshot: const AppCzarAttachmentArchiveRepairSnapshot(
        requiredCount: 13,
        coveredCount: 10,
        availableFromMessagesCount: 1,
        sourceAbsentCount: 1,
        sourceUnknownCount: 0,
        recordBackedRecoveryCount: 1,
        unsafeOrConflictingCount: 0,
      ),
    );
  }

  @override
  Future<AppCzarAttachmentArchiveRepairObservation> preserveAvailable({
    required AppCzarAttachmentArchiveRepairBinding binding,
    AppCzarAttachmentArchiveRepairProgressObserver? onProgress,
  }) async {
    preserveCalls += 1;
    onProgress?.call(
      const AppCzarAttachmentArchiveRepairProgress(
        completedCount: 1,
        totalCount: 1,
      ),
    );
    return AppCzarAttachmentArchiveRepairObservation(
      kind: AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete,
      binding: binding,
      snapshot: const AppCzarAttachmentArchiveRepairSnapshot(
        requiredCount: 13,
        coveredCount: 11,
        availableFromMessagesCount: 0,
        sourceAbsentCount: 1,
        sourceUnknownCount: 0,
        recordBackedRecoveryCount: 1,
        unsafeOrConflictingCount: 0,
      ),
    );
  }

  @override
  Future<void> stopAndDrain() async {
    stopCalls += 1;
  }
}

final class _ScreenRestarter implements AppCzarProcessRestarter {
  var calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls += 1;
  }
}

final class _ScreenRepairReader implements AppCzarObservationReader {
  const _ScreenRepairReader();

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Private label must not be rendered by repair',
      archiveScopeIdentity: 'private-scope',
      archiveGeneration: 0,
      resolvedPath: '/Volumes/Private/private-family-photo.jpg',
      coverage: AppCzarAttachmentCoverageObservation(
        condition: AppCzarAttachmentCoverageCondition.incomplete,
        requiredCount: 13,
        coveredCount: 10,
        missingCount: 3,
        unverifiableCount: 0,
        archiveScopeIdentity: 'private-scope',
        archiveGeneration: 0,
      ),
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
    return const AppCzarRootObservation(admitted: true, path: '/test/root');
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
