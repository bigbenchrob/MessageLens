import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_models.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_report_writer.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_service.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_runtime_environment.dart';
import 'package:remember_this_text/essentials/logging/infrastructure/log_file_writer.dart';
import 'package:remember_this_text/essentials/logging/infrastructure/support_bundle_export_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/startup_validation_telemetry_buffer.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_installation_validation.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_validation_telemetry.dart';

void main() {
  test(
    'diagnostic header describes active health and retired cleanup inventory',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'support_bundle_export_service_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final logDirectory = Directory('${tempDirectory.path}/logs')
        ..createSync(recursive: true);
      final service = SupportBundleExportService(
        _FakeLogFileWriter(logDirectory),
        DatabaseHealthAuditService(
          hasFullDiskAccess: true,
          queryLayers: const [],
          runtimeEnvironment: const _FakeRuntimeEnvironment(),
          reportWriter: const _FakeDatabaseHealthReportWriter(),
        ),
        _testAuthority(tempDirectory),
        StartupValidationTelemetryBuffer(),
      );

      final result = await service.export();
      final diagnosticLog = File(
        '${result.bundleDirectory.path}/diagnostic_report.log',
      );

      expect(diagnosticLog.existsSync(), isTrue);
      final content = await diagnosticLog.readAsString();
      expect(content, contains('active graph health'));
      expect(content, contains('retired cleanup inventory'));
      expect(content, contains('No raw database files are included.'));
    },
  );

  test('rejects raw database files returned by health writer', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'support_bundle_export_service_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final logDirectory = Directory('${tempDirectory.path}/logs')
      ..createSync(recursive: true);
    final service = SupportBundleExportService(
      _FakeLogFileWriter(logDirectory),
      DatabaseHealthAuditService(
        hasFullDiskAccess: true,
        queryLayers: const [],
        runtimeEnvironment: const _FakeRuntimeEnvironment(),
        reportWriter: const _RawDatabasePathHealthReportWriter(),
      ),
      _testAuthority(tempDirectory),
      StartupValidationTelemetryBuffer(),
    );

    final result = await service.export();
    final attachmentNames = result.attachmentFiles
        .map((file) => file.uri.pathSegments.last)
        .toSet();

    expect(result.databaseHealthIncluded, isFalse);
    expect(attachmentNames, isNot(contains('working.db')));
    expect(attachmentNames, contains('database_health_error.json'));
  });

  test('rejects health report files outside the support bundle', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'support_bundle_export_service_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final logDirectory = Directory('${tempDirectory.path}/logs')
      ..createSync(recursive: true);
    final outsideDirectory = Directory('${tempDirectory.path}/outside')
      ..createSync(recursive: true);
    final service = SupportBundleExportService(
      _FakeLogFileWriter(logDirectory),
      DatabaseHealthAuditService(
        hasFullDiskAccess: true,
        queryLayers: const [],
        runtimeEnvironment: const _FakeRuntimeEnvironment(),
        reportWriter: _OutsideBundleHealthReportWriter(outsideDirectory),
      ),
      _testAuthority(tempDirectory),
      StartupValidationTelemetryBuffer(),
    );

    final result = await service.export();
    final attachmentPaths = result.attachmentFiles
        .map((file) => file.path)
        .toSet();

    expect(result.databaseHealthIncluded, isFalse);
    expect(
      attachmentPaths.any((filePath) => filePath.contains('/outside/')),
      isFalse,
    );
    expect(
      attachmentPaths.any(
        (filePath) => filePath.endsWith('database_health_error.json'),
      ),
      isTrue,
    );
  });

  test(
    'rejects symlinked health report files inside the support bundle',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'support_bundle_export_service_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final logDirectory = Directory('${tempDirectory.path}/logs')
        ..createSync(recursive: true);
      final outsideFile = File('${tempDirectory.path}/outside_health.json');
      await outsideFile.writeAsString('outside health');
      final service = SupportBundleExportService(
        _FakeLogFileWriter(logDirectory),
        DatabaseHealthAuditService(
          hasFullDiskAccess: true,
          queryLayers: const [],
          runtimeEnvironment: const _FakeRuntimeEnvironment(),
          reportWriter: _SymlinkHealthReportWriter(outsideFile),
        ),
        _testAuthority(tempDirectory),
        StartupValidationTelemetryBuffer(),
      );

      final result = await service.export();
      final attachmentNames = result.attachmentFiles
          .map((file) => file.uri.pathSegments.last)
          .toSet();

      expect(result.databaseHealthIncluded, isFalse);
      expect(attachmentNames, isNot(contains('database_health.json')));
      expect(attachmentNames, contains('database_health_error.json'));
    },
  );

  test('does not append symlinked diagnostic log sources', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'support_bundle_export_service_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final logDirectory = Directory('${tempDirectory.path}/logs')
      ..createSync(recursive: true);
    final protectedFile = File('${tempDirectory.path}/protected.txt');
    await protectedFile.writeAsString('protected content');
    await Link('${logDirectory.path}/app.log').create(protectedFile.path);

    final service = SupportBundleExportService(
      _FakeLogFileWriter(logDirectory),
      DatabaseHealthAuditService(
        hasFullDiskAccess: true,
        queryLayers: const [],
        runtimeEnvironment: const _FakeRuntimeEnvironment(),
        reportWriter: const _FakeDatabaseHealthReportWriter(),
      ),
      _testAuthority(tempDirectory),
      StartupValidationTelemetryBuffer(),
    );

    final result = await service.export();
    final diagnosticLog = File(
      '${result.bundleDirectory.path}/diagnostic_report.log',
    );
    final content = await diagnosticLog.readAsString();

    expect(content, contains('No raw database files are included.'));
    expect(content, isNot(contains('protected content')));
    expect(content, isNot(contains('Application Log (Current Session)')));
  });

  test('includes privacy-safe startup validation evidence', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'support_bundle_export_service_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final logDirectory = Directory('${tempDirectory.path}/logs')
      ..createSync(recursive: true);
    final telemetry = StartupValidationTelemetryBuffer();
    final validationId = telemetry.beginValidation(
      archiveEnvironment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
    );
    telemetry
      ..record(
        StartupValidationTelemetryEvent.boundedInspectionCompleted(
          validationId: validationId,
          occurredAtUtc: DateTime.utc(2026, 9, 12),
          database: InstallationDatabaseKey.conversationGraph,
          evidence: const InstallationDatabaseEvidence.passed(userVersion: 3),
        ),
      )
      ..record(
        StartupValidationTelemetryEvent.admissionDecided(
          validationId: validationId,
          occurredAtUtc: DateTime.utc(2026, 9, 12),
          installationState: const MessageLensInstallationState(
            kind: MessageLensInstallationStateKind.completed,
            reason: 'not exported',
            reasonCode:
                MessageLensInstallationReasonCode.durableStoresReconciled,
          ),
          outcome: StartupValidationAdmissionOutcome.granted,
          basis: StartupAdmissionBasis.boundedInspection,
          totalDurationMicroseconds: 1200,
        ),
      );
    final service = SupportBundleExportService(
      _FakeLogFileWriter(logDirectory),
      DatabaseHealthAuditService(
        hasFullDiskAccess: true,
        queryLayers: const [],
        runtimeEnvironment: const _FakeRuntimeEnvironment(),
        reportWriter: const _FakeDatabaseHealthReportWriter(),
      ),
      _testAuthority(tempDirectory),
      telemetry,
    );

    final result = await service.export();
    final telemetryFile = File(
      '${result.bundleDirectory.path}/startup_validation.json',
    );
    final content = await telemetryFile.readAsString();

    expect(telemetryFile.existsSync(), isTrue);
    expect(
      result.attachmentFiles.map((file) => file.path),
      contains(telemetryFile.path),
    );
    expect(content, contains('startup_validation_started'));
    expect(content, contains('startup_bounded_inspection_completed'));
    expect(content, contains('conversationGraph'));
    expect(content, contains('startup_admission_decided'));
    expect(content, isNot(contains('not exported')));
  });
}

ArchiveAccessAuthority _testAuthority(Directory root) {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: ArchiveInstanceId(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      ),
      canonicalRootPath: root.path,
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
      productName: 'MessageLens Tests',
    ),
  );
}

class _FakeLogFileWriter extends LogFileWriter {
  _FakeLogFileWriter(this._logDir) : super(logDirectory: _logDir);

  final Directory _logDir;

  @override
  Directory get logDir => _logDir;

  @override
  File get logFile => File('${_logDir.path}/app.log');

  @override
  File get prevLogFile => File('${_logDir.path}/app.log.1');

  @override
  Future<void> flush() async {}
}

class _FakeRuntimeEnvironment implements DatabaseHealthRuntimeEnvironment {
  const _FakeRuntimeEnvironment();

  @override
  DatabaseHealthRuntimeEnvironmentSnapshot read() {
    return const DatabaseHealthRuntimeEnvironmentSnapshot(
      platform: 'test',
      platformVersion: 'test-version',
      timezone: 'test-zone',
    );
  }
}

class _FakeDatabaseHealthReportWriter
    implements DatabaseHealthAuditReportWriter {
  const _FakeDatabaseHealthReportWriter();

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    final file = File('$outputDirectoryPath/database_health.json');
    await file.writeAsString('{}\n');
    return file.path;
  }
}

class _RawDatabasePathHealthReportWriter
    implements DatabaseHealthAuditReportWriter {
  const _RawDatabasePathHealthReportWriter();

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    final file = File('$outputDirectoryPath/working.db');
    await file.writeAsString('not really sqlite\n');
    return file.path;
  }
}

class _OutsideBundleHealthReportWriter
    implements DatabaseHealthAuditReportWriter {
  const _OutsideBundleHealthReportWriter(this._outsideDirectory);

  final Directory _outsideDirectory;

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    final file = File('${_outsideDirectory.path}/database_health.json');
    await file.writeAsString('{}\n');
    return file.path;
  }
}

class _SymlinkHealthReportWriter implements DatabaseHealthAuditReportWriter {
  const _SymlinkHealthReportWriter(this._outsideFile);

  final File _outsideFile;

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    final link = Link('$outputDirectoryPath/database_health.json');
    await link.create(_outsideFile.path);
    return link.path;
  }
}
