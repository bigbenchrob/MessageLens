import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';

void main() {
  group('OnboardingEnvironmentReport', () {
    test(
      'hasPopulatedAppDatabases is true only when both app databases have data',
      () {
        final report = _report();

        expect(report.hasPopulatedAppDatabases, isTrue);
      },
    );

    test('import failure helpers expose persisted failure state', () {
      final report = _report(
        lastImportFailure: const OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.import,
          batchId: 1,
          message: 'Import exploded',
        ),
      );

      expect(report.hasImportFailure, isTrue);
      expect(report.importFailureMessage, 'Import exploded');
      expect(report.hasGraphProjectionFailure, isFalse);
    });

    test('graph projection failure helpers expose persisted failure state', () {
      final report = _report(
        lastGraphProjectionFailure: const OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.graphProjection,
          batchId: 2,
          message: 'Graph projection exploded',
        ),
      );

      expect(report.hasGraphProjectionFailure, isTrue);
      expect(report.graphProjectionFailureMessage, 'Graph projection exploded');
      expect(report.hasImportFailure, isFalse);
    });

    test('absent failure summaries do not report failures', () {
      final report = _report();

      expect(report.hasImportFailure, isFalse);
      expect(report.importFailureMessage, isNull);
      expect(report.hasGraphProjectionFailure, isFalse);
      expect(report.graphProjectionFailureMessage, isNull);
    });

    test(
      'latestFailureRecordedAt prefers graph projection timestamp when present',
      () {
        final importAt = DateTime.utc(2026, 03, 24, 10, 00);
        final graphProjectionAt = DateTime.utc(2026, 03, 24, 11, 00);

        final report = _report(
          lastImportFailure: const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.import,
            batchId: 1,
          ),
          lastGraphProjectionFailure: const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.graphProjection,
            batchId: 2,
          ),
          lastImportFailureRecordedAt: importAt,
          lastGraphProjectionFailureRecordedAt: graphProjectionAt,
        );

        expect(report.latestFailureRecordedAt, graphProjectionAt);
      },
    );

    test('importFailureFreshness is today for same-day failures', () {
      final report = _report(
        lastImportFailureRecordedAt: DateTime(2026, 03, 24, 8, 00),
      );

      expect(
        report.importFailureFreshness(now: DateTime(2026, 03, 24, 20, 00)),
        OnboardingFailureFreshness.today,
      );
    });

    test(
      'graphProjectionFailureFreshness is older for previous-day failures',
      () {
        final report = _report(
          lastGraphProjectionFailureRecordedAt: DateTime(2026, 03, 23, 23, 50),
        );

        expect(
          report.graphProjectionFailureFreshness(
            now: DateTime(2026, 03, 24, 0, 10),
          ),
          OnboardingFailureFreshness.older,
        );
      },
    );

    test(
      'release readiness status carries graph build and live update signals',
      () {
        final graphBuildFinishedAt = DateTime.utc(2026, 06, 29, 12, 30);
        final liveUpdateDetectedAt = DateTime.utc(2026, 06, 29, 12, 45);

        final report = _report(
          graphBuildStatusLabel: 'succeeded',
          graphBuildFinishedAt: graphBuildFinishedAt,
          liveUpdateCursorRowId: 149359,
          liveUpdateLastChangeDetectedAt: liveUpdateDetectedAt,
        );

        expect(report.graphBuildStatusLabel, 'succeeded');
        expect(report.graphBuildFinishedAt, graphBuildFinishedAt);
        expect(report.liveUpdateCursorRowId, 149359);
        expect(report.liveUpdateLastChangeDetectedAt, liveUpdateDetectedAt);
      },
    );
  });
}

OnboardingEnvironmentReport _report({
  OnboardingPipelineFailure? lastImportFailure,
  OnboardingPipelineFailure? lastGraphProjectionFailure,
  DateTime? lastImportFailureRecordedAt,
  DateTime? lastGraphProjectionFailureRecordedAt,
  String graphBuildStatusLabel = 'unknown',
  DateTime? graphBuildFinishedAt,
  int? liveUpdateCursorRowId,
  DateTime? liveUpdateLastChangeDetectedAt,
}) {
  return OnboardingEnvironmentReport(
    state: OnboardingEnvironmentState.ready,
    blockerKind: OnboardingBlockerKind.none,
    syncPlausibility: OnboardingSyncPlausibility.likelySyncedOrLocallyAvailable,
    messagesDatabase: const OnboardingDatabaseProbe(
      path: 'messages.db',
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    addressBookDatabase: const OnboardingDatabaseProbe(
      path: 'addressbook.db',
      exists: true,
      readable: true,
      rowCount: 50,
    ),
    overlayDatabase: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.overlay),
      exists: true,
      readable: true,
    ),
    sourceScopedImportDatabase: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    conversationGraph: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.conversationGraph),
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    attachmentArchiveDirectory: const OnboardingDatabaseProbe(
      path: 'attachment_archive',
      exists: true,
      readable: true,
    ),
    hasFullDiskAccess: true,
    lastImportFailure: lastImportFailure,
    lastGraphProjectionFailure: lastGraphProjectionFailure,
    lastImportFailureRecordedAt: lastImportFailureRecordedAt,
    lastGraphProjectionFailureRecordedAt: lastGraphProjectionFailureRecordedAt,
    graphBuildStatusLabel: graphBuildStatusLabel,
    graphBuildFinishedAt: graphBuildFinishedAt,
    liveUpdateCursorRowId: liveUpdateCursorRowId,
    liveUpdateLastChangeDetectedAt: liveUpdateLastChangeDetectedAt,
  );
}
