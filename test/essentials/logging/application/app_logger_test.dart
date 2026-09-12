import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import 'package:remember_this_text/essentials/onboarding/application/startup_validation_telemetry_buffer.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  test('retains in-memory diagnostics before archive admission', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final logger = container.read(appLoggerProvider.notifier);
    logger.info('pre-admission diagnostic', source: 'Test');

    expect(container.read(appLoggerProvider), hasLength(1));
    expect(() => logger.writer, throwsStateError);
  });

  test(
    'flushes buffered startup events after persistent logging is ready',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'messagelens_app_logger_test_',
      );
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await Future<void>.delayed(Duration.zero);
        await fixture.dispose();
      });

      final logger = container.read(appLoggerProvider.notifier);
      final telemetry = StartupValidationTelemetryBuffer()
        ..beginValidation(
          archiveEnvironment: ArchiveEnvironment.test,
          buildIdentity: ArchiveBuildIdentity.testHarness,
        );

      await logger.ready;
      telemetry.flushTo((event) {
        logger.info(
          event.eventName,
          source: 'StartupValidation',
          context: Map<String, dynamic>.from(event.toJson()),
        );
      });
      await logger.writer.flush();

      expect(
        logger.writer.logDir.path,
        fixture.authority.resolvePath('application_logs'),
      );
      final persistedLog = await logger.writer.logFile.readAsString();
      expect(persistedLog, contains('startup_validation_started'));
      expect(persistedLog, contains('StartupValidation'));
    },
  );
}
