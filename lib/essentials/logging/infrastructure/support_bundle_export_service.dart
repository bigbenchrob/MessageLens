import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../archive_environment/domain/archive_access_authority.dart';
import '../../db/application/database_health_audit/database_health_audit_service.dart';
import '../../onboarding/domain/startup_validation_telemetry.dart';
import 'log_file_writer.dart';

class SupportBundleExportResult {
  const SupportBundleExportResult({
    required this.bundleDirectory,
    required this.attachmentFiles,
    required this.databaseHealthIncluded,
  });

  final Directory bundleDirectory;
  final List<File> attachmentFiles;
  final bool databaseHealthIncluded;
}

/// Builds a privacy-safe support bundle from derived diagnostics only.
///
/// The bundle never includes raw database files or row-level sampling.
class SupportBundleExportService {
  SupportBundleExportService(
    this._writer,
    this._databaseHealthAuditService,
    this._archiveAuthority,
    this._startupValidationTelemetry,
  );

  final LogFileWriter _writer;
  final DatabaseHealthAuditService _databaseHealthAuditService;
  final ArchiveAccessAuthority _archiveAuthority;
  final StartupValidationTelemetrySnapshotSource _startupValidationTelemetry;

  Future<SupportBundleExportResult> export({
    List<String> headerLines = const <String>[],
  }) async {
    await _writer.flush();

    final logDir = _writer.logDir;
    if (!logDir.existsSync()) {
      throw StateError('Log directory does not exist.');
    }

    final now = DateTime.now();
    final stamp =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final bundleDirectory = Directory('${logDir.path}/support_bundle_$stamp');
    await bundleDirectory.create(recursive: true);

    final attachmentFiles = <File>[];

    final diagnosticLogFile = File(
      '${bundleDirectory.path}/diagnostic_report.log',
    );
    final pipelineAuditLogFiles = _pipelineAuditLogFiles();
    await _writeDiagnosticLog(
      diagnosticLogFile,
      now: now,
      headerLines: headerLines,
      pipelineAuditLogFiles: pipelineAuditLogFiles,
    );
    attachmentFiles.add(diagnosticLogFile);

    attachmentFiles.add(
      await _writeStartupValidationFile(bundleDirectory: bundleDirectory),
    );

    for (final auditLog in pipelineAuditLogFiles.files) {
      final copied = await _copyIfPresent(
        source: auditLog.$2,
        destinationPath:
            '${bundleDirectory.path}/${auditLog.$2.uri.pathSegments.last}',
      );
      if (copied != null) {
        attachmentFiles.add(copied);
      }
    }

    var databaseHealthIncluded = false;
    try {
      final auditOutput = await _databaseHealthAuditService.writePhase1Report(
        outputDirectoryPath: bundleDirectory.path,
      );
      final reportFile = File(auditOutput.reportPath);
      if (_isSafeBundleDiagnosticAttachment(
        bundleDirectory: bundleDirectory,
        file: reportFile,
      )) {
        attachmentFiles.add(reportFile);
        databaseHealthIncluded = true;
      } else {
        attachmentFiles.add(
          await _writeDatabaseHealthErrorFile(
            bundleDirectory: bundleDirectory,
            message:
                'Database health report path was rejected because support '
                'bundles may include only bundle-local diagnostic artifacts.',
          ),
        );
      }
    } catch (error, stackTrace) {
      attachmentFiles.add(
        await _writeDatabaseHealthErrorFile(
          bundleDirectory: bundleDirectory,
          message: error.toString(),
          stackTrace: stackTrace.toString(),
        ),
      );
    }

    return SupportBundleExportResult(
      bundleDirectory: bundleDirectory,
      attachmentFiles: attachmentFiles
          .where((file) => file.existsSync())
          .toList(),
      databaseHealthIncluded: databaseHealthIncluded,
    );
  }

  Future<File> _writeStartupValidationFile({
    required Directory bundleDirectory,
  }) async {
    final telemetryFile = File(
      '${bundleDirectory.path}/startup_validation.json',
    );
    await telemetryFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(_startupValidationTelemetry.snapshot().toJson())}\n',
    );
    return telemetryFile;
  }

  Future<void> _writeDiagnosticLog(
    File exportFile, {
    required DateTime now,
    required List<String> headerLines,
    required _PipelineAuditLogFiles pipelineAuditLogFiles,
  }) async {
    final sink = exportFile.openWrite();
    sink.write(_buildHeader(now, headerLines: headerLines));

    await _appendFileIfPresent(
      sink,
      file: _writer.logFile,
      title: 'Application Log (Current Session)',
    );
    await _appendFileIfPresent(
      sink,
      file: _writer.prevLogFile,
      title: 'Application Log (Previous Session)',
    );
    if (pipelineAuditLogFiles.unavailableReason case final reason?) {
      sink.write('--- Pipeline Audit Logs ---\n');
      sink.write('$reason\n\n');
    }
    for (final auditLog in pipelineAuditLogFiles.files) {
      await _appendFileIfPresent(sink, file: auditLog.$2, title: auditLog.$1);
    }

    await sink.flush();
    await sink.close();
  }

  String _buildHeader(DateTime now, {required List<String> headerLines}) {
    final macosVersion = Platform.operatingSystemVersion;
    final buffer = StringBuffer()
      ..writeln('=== MessageLens — Support Bundle ===')
      ..writeln('macOS: $macosVersion')
      ..writeln('Exported: ${now.toUtc().toIso8601String()}')
      ..writeln(
        'Contains: diagnostic_report.log, startup validation, active graph health, and retired cleanup inventory when available',
      )
      ..writeln('No raw database files are included.')
      ..writeln('====================================');

    headerLines.forEach(buffer.writeln);
    buffer.writeln();
    return buffer.toString();
  }

  Future<File> _writeDatabaseHealthErrorFile({
    required Directory bundleDirectory,
    required String message,
    String? stackTrace,
  }) async {
    final errorFile = File(
      '${bundleDirectory.path}/database_health_error.json',
    );
    await errorFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'generated_at': DateTime.now().toUtc().toIso8601String(),
        'artifact': 'database_health.json',
        'status': 'failed',
        'message': message,
        if (stackTrace != null) 'stack_trace': stackTrace,
        'notes': <String>['Support bundle export continued after database health generation failed.', 'No raw database copies were exported.'],
      })}\n',
    );
    return errorFile;
  }

  bool _isSafeBundleDiagnosticAttachment({
    required Directory bundleDirectory,
    required File file,
  }) {
    if (!_isSafeDiagnosticSourceFile(file)) {
      return false;
    }

    final bundleRoot = path.normalize(path.absolute(bundleDirectory.path));
    final filePath = path.normalize(path.absolute(file.path));
    final isInsideBundle =
        path.equals(bundleRoot, path.dirname(filePath)) ||
        path.isWithin(bundleRoot, filePath);
    if (!isInsideBundle) {
      return false;
    }

    final basename = path.basename(filePath).toLowerCase();
    return !(basename.endsWith('.db') ||
        basename.endsWith('.db-wal') ||
        basename.endsWith('.db-shm'));
  }

  Future<void> _appendFileIfPresent(
    IOSink sink, {
    required File file,
    required String title,
  }) async {
    if (!file.existsSync()) {
      return;
    }
    if (!_isSafeDiagnosticSourceFile(file)) {
      return;
    }

    sink.write('--- $title ---\n');
    sink.write(await file.readAsString());
    sink.write('\n');
  }

  _PipelineAuditLogFiles _pipelineAuditLogFiles() {
    try {
      return _PipelineAuditLogFiles(
        files: [
          (
            'Retired Import Audit Log',
            File(_archiveAuthority.resolvePath('import_log')),
          ),
          (
            'Retired Projection Audit Log',
            File(_archiveAuthority.resolvePath('migrate_log')),
          ),
          (
            'Pipeline Incident Log',
            File(_archiveAuthority.resolvePath('pipeline_incident_log')),
          ),
        ],
      );
    } catch (error) {
      return _PipelineAuditLogFiles(
        files: const <(String, File)>[],
        unavailableReason:
            'Pipeline audit log paths could not be resolved: $error',
      );
    }
  }

  Future<File?> _copyIfPresent({
    required File source,
    required String destinationPath,
  }) async {
    if (!source.existsSync()) {
      return null;
    }
    if (!_isSafeDiagnosticSourceFile(source)) {
      return null;
    }
    return source.copy(destinationPath);
  }

  bool _isSafeDiagnosticSourceFile(File source) {
    if (FileSystemEntity.typeSync(source.path, followLinks: false) !=
        FileSystemEntityType.file) {
      return false;
    }

    final basename = path.basename(source.path).toLowerCase();
    return !(basename.endsWith('.db') ||
        basename.endsWith('.db-wal') ||
        basename.endsWith('.db-shm'));
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _PipelineAuditLogFiles {
  const _PipelineAuditLogFiles({required this.files, this.unavailableReason});

  final List<(String, File)> files;
  final String? unavailableReason;
}
