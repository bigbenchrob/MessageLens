import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../db/feature_level_providers.dart'
    show databaseHealthAuditServiceProvider;
import '../../onboarding/feature_level_providers.dart'
    show startupValidationTelemetryProvider;
import '../infrastructure/log_export_service.dart';
import '../infrastructure/support_bundle_diagnostic_report_exporter.dart';
import '../infrastructure/support_bundle_export_service.dart';
import 'app_logger.dart';
import 'diagnostic_report_exporter.dart';

part 'diagnostic_report_provider.g.dart';

@riverpod
Future<DiagnosticReportExporter> diagnosticReportExporter(Ref ref) async {
  final writer = ref.read(appLoggerProvider.notifier).writer;
  final databaseHealthAuditService = await ref.watch(
    databaseHealthAuditServiceProvider.future,
  );

  return SupportBundleDiagnosticReportExporter(
    LogExportService(
      SupportBundleExportService(
        writer,
        databaseHealthAuditService,
        ref.watch(archiveAccessAuthorityProvider),
        ref.watch(startupValidationTelemetryProvider),
      ),
    ),
  );
}

@riverpod
String diagnosticLogDirectoryPath(Ref ref) {
  return ref.read(appLoggerProvider.notifier).writer.logDir.path;
}
