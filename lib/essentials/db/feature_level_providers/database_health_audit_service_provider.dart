import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../onboarding/feature_level_providers.dart'
    show onboardingFullDiskAccessProvider;
import '../app_database_files.dart';
import '../application/database_health_audit/database_health_audit_models.dart';
import '../application/database_health_audit/database_health_audit_service.dart';
import '../application/database_health_audit/database_health_database_keys.dart';
import '../application/database_health_audit/database_health_query_layer.dart';
import '../infrastructure/repositories/database_health_audit_queries.dart';
import '../infrastructure/repositories/filesystem_database_health_audit_report_writer.dart';
import '../infrastructure/repositories/local_database_health_runtime_environment.dart';
import 'persistent_database_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        overlayDatabaseProvider,
        sourceScopedImportDatabaseProvider;

part 'database_health_audit_service_provider.g.dart';

@Riverpod(keepAlive: true)
Future<DatabaseHealthAuditService> databaseHealthAuditService(Ref ref) async {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  final sourceScopedImportDb = await ref.read(
    sourceScopedImportDatabaseProvider.future,
  );
  final conversationGraphDb = await ref.read(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.read(overlayDatabaseProvider.future);
  final hasFullDiskAccess = ref.read(onboardingFullDiskAccessProvider);
  final packageInfo = await PackageInfo.fromPlatform();

  return DatabaseHealthAuditService(
    appInfo: DatabaseHealthAppInfo(
      name: packageInfo.appName,
      bundleId: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildChannel: kReleaseMode
          ? 'release'
          : kProfileMode
          ? 'profile'
          : 'debug',
    ),
    hasFullDiskAccess: hasFullDiskAccess,
    runtimeEnvironment: const LocalDatabaseHealthRuntimeEnvironment(),
    reportWriter: const FilesystemDatabaseHealthAuditReportWriter(),
    queryLayers: <DatabaseHealthQueryLayer>[
      RetiredCleanupSqliteFileHealthQueryLayer(
        databaseKey: databaseHealthKeyRetiredMacosImport,
        role: databaseHealthRoleRetiredMacosImportCleanup,
        databasePath: appDatabasePath(
          AppDatabaseFile.retiredMacosImport,
          databaseDirectory: authority.rootPath,
        ),
      ),
      RetiredCleanupSqliteFileHealthQueryLayer(
        databaseKey: databaseHealthKeyRetiredWorking,
        role: databaseHealthRoleRetiredWorkingCleanup,
        databasePath: appDatabasePath(
          AppDatabaseFile.retiredWorking,
          databaseDirectory: authority.rootPath,
        ),
      ),
      SourceScopedImportDatabaseHealthQueryLayer(
        database: sourceScopedImportDb,
        databasePath: appDatabasePath(
          AppDatabaseFile.sourceScopedImport,
          databaseDirectory: authority.rootPath,
        ),
      ),
      ConversationGraphDatabaseHealthQueryLayer(
        database: conversationGraphDb,
        databasePath: appDatabasePath(
          AppDatabaseFile.conversationGraph,
          databaseDirectory: authority.rootPath,
        ),
      ),
      OverlayDatabaseHealthQueryLayer(
        database: overlayDb,
        databasePath: appDatabasePath(
          AppDatabaseFile.overlay,
          databaseDirectory: authority.rootPath,
        ),
      ),
    ],
  );
}
