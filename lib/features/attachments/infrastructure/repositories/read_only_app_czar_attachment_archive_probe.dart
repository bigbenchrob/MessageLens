import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../../../essentials/app_czar/application/app_czar_observation_reader.dart';
import '../../../../essentials/app_czar/domain/app_czar_models.dart';
import '../../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../../../../essentials/db/app_database_files.dart';
import '../../../../essentials/db/application/read_only_sql_guard.dart';
import '../../application/attachment_archive_bookmark_adapter.dart';
import '../../application/attachment_archive_location_controller.dart';
import '../../application/attachment_archive_scope_identity.dart';
import '../../domain/entities/attachment_archive_location_configuration.dart';
import '../../domain/entities/attachment_archive_location_state.dart';
import 'read_only_app_czar_attachment_coverage_probe.dart';

final class ReadOnlyAppCzarAttachmentArchiveProbe
    implements AppCzarAttachmentArchiveProbe {
  ReadOnlyAppCzarAttachmentArchiveProbe({
    required ArchiveAccessAuthority archiveAccessAuthority,
    required AttachmentArchiveBookmarkAdapter bookmarkAdapter,
    ReadOnlyAppCzarAttachmentCoverageProbe? coverageProbe,
  }) : _archiveAccessAuthority = archiveAccessAuthority,
       _bookmarkAdapter = bookmarkAdapter,
       _coverageProbe =
           coverageProbe ??
           ReadOnlyAppCzarAttachmentCoverageProbe(
             archiveAccessAuthority: archiveAccessAuthority,
           );

  final ArchiveAccessAuthority _archiveAccessAuthority;
  final AttachmentArchiveBookmarkAdapter _bookmarkAdapter;
  final ReadOnlyAppCzarAttachmentCoverageProbe _coverageProbe;

  @override
  Future<AppCzarArchiveObservation> readCurrent() async {
    final configurationRead = _readConfiguration();
    if (configurationRead.issue case final issue?) {
      return AppCzarArchiveObservation.unknown(issue);
    }
    final configuration = configurationRead.configuration!;
    return switch (configuration.mode) {
      AttachmentArchiveLocationMode.defaultInternal => _readDefaultInternal(
        configuration,
      ),
      AttachmentArchiveLocationMode.customExternal => _readCustomExternal(
        configuration,
      ),
    };
  }

  _AttachmentConfigurationRead _readConfiguration() {
    final overlayPath = appDatabasePath(
      AppDatabaseFile.overlay,
      databaseDirectory: _archiveAccessAuthority.rootPath,
    );
    if (!File(overlayPath).existsSync()) {
      return const _AttachmentConfigurationRead.configuration(
        AttachmentArchiveLocationConfiguration.defaultInternal(),
      );
    }

    Database database;
    try {
      database = sqlite3.open(overlayPath, mode: OpenMode.readOnly);
    } on Object catch (error) {
      return _AttachmentConfigurationRead.issue(
        'Attachment configuration could not be opened read-only: $error',
      );
    }
    try {
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');
      const tableSql =
          "SELECT 1 FROM sqlite_master WHERE type = 'table' "
          "AND name = 'overlay_settings' LIMIT 1";
      assertReadOnlySql(
        tableSql,
        boundary: 'AppCzar attachment setting table inspection',
      );
      if (database.select(tableSql).isEmpty) {
        return const _AttachmentConfigurationRead.issue(
          'Attachment configuration cannot be read because overlay settings '
          'are unavailable.',
        );
      }

      const settingSql =
          'SELECT value FROM overlay_settings WHERE key = ? LIMIT 1';
      assertReadOnlySql(
        settingSql,
        boundary: 'AppCzar attachment setting read',
      );
      final rows = database.select(settingSql, <Object?>[
        attachmentArchiveLocationSettingKey,
      ]);
      if (rows.isEmpty) {
        return const _AttachmentConfigurationRead.configuration(
          AttachmentArchiveLocationConfiguration.defaultInternal(),
        );
      }
      final value = rows.single['value'];
      if (value is! String || value.trim().isEmpty) {
        return const _AttachmentConfigurationRead.configuration(
          AttachmentArchiveLocationConfiguration.defaultInternal(),
        );
      }
      try {
        return _AttachmentConfigurationRead.configuration(
          AttachmentArchiveLocationConfiguration.fromPersistedValue(value),
        );
      } on FormatException catch (error) {
        return _AttachmentConfigurationRead.issue(
          'Attachment configuration is invalid: ${error.message}',
        );
      }
    } on Object catch (error) {
      return _AttachmentConfigurationRead.issue(
        'Attachment configuration could not be inspected: $error',
      );
    } finally {
      database.dispose();
    }
  }

  Future<AppCzarArchiveObservation> _readDefaultInternal(
    AttachmentArchiveLocationConfiguration configuration,
  ) async {
    final archivePath = _archiveAccessAuthority.resolvePath(
      AttachmentArchiveLocationController.defaultArchiveDirectoryName,
    );
    final entityType = FileSystemEntity.typeSync(
      archivePath,
      followLinks: false,
    );
    if (entityType == FileSystemEntityType.notFound) {
      return _readCoverageForStableScope(
        condition: AppCzarArchiveCondition.notCreated,
        label: 'Default attachment archive',
        configuration: configuration,
        archiveRootPath: archivePath,
      );
    }
    if (entityType != FileSystemEntityType.directory) {
      return AppCzarArchiveObservation(
        condition: AppCzarArchiveCondition.unavailable,
        label: 'Default attachment archive',
        coverage: const AppCzarAttachmentCoverageObservation.unknown(
          issue: 'The default attachment archive is not a regular directory.',
        ),
        resolvedPath: archivePath,
        issue: 'The default attachment archive is not a regular directory.',
      );
    }
    return _readCoverageForStableScope(
      condition: AppCzarArchiveCondition.available,
      label: 'Default attachment archive',
      configuration: configuration,
      archiveRootPath: archivePath,
    );
  }

  Future<AppCzarArchiveObservation> _readCustomExternal(
    AttachmentArchiveLocationConfiguration configuration,
  ) async {
    final bookmarkData = configuration.bookmarkDataBase64;
    if (bookmarkData == null || bookmarkData.isEmpty) {
      return const AppCzarArchiveObservation(
        condition: AppCzarArchiveCondition.unavailable,
        label: 'Configured attachment archive',
        coverage: AppCzarAttachmentCoverageObservation.unknown(
          issue: 'The configured attachment archive bookmark is missing.',
        ),
        issue: 'The configured attachment archive bookmark is missing.',
      );
    }
    final resolution = await _bookmarkAdapter.resolveBookmark(
      bookmarkDataBase64: bookmarkData,
    );
    final resolvedPath = resolution.resolvedPath;
    final label = _archiveLabel(
      volumeName: resolution.volumeName ?? configuration.volumeName,
      resolvedPath: resolvedPath,
      lastKnownPath: configuration.lastKnownPath,
    );
    return switch (resolution.status) {
      AttachmentArchiveBookmarkResolutionStatus.available =>
        _readCoverageForStableScope(
          condition: AppCzarArchiveCondition.available,
          label: label,
          configuration: configuration,
          archiveRootPath: resolvedPath!,
        ),
      AttachmentArchiveBookmarkResolutionStatus.readOnly =>
        _readCoverageForStableScope(
          condition: AppCzarArchiveCondition.readOnly,
          label: label,
          configuration: configuration,
          archiveRootPath: resolvedPath!,
          issue: resolution.issue,
        ),
      AttachmentArchiveBookmarkResolutionStatus.unavailable ||
      AttachmentArchiveBookmarkResolutionStatus.permissionDenied ||
      AttachmentArchiveBookmarkResolutionStatus.configuredDirectoryMissing ||
      AttachmentArchiveBookmarkResolutionStatus.invalidBookmark =>
        AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.unavailable,
          label: label,
          coverage: AppCzarAttachmentCoverageObservation.unknown(
            issue:
                resolution.issue ??
                'The configured attachment archive is unavailable.',
          ),
          resolvedPath: resolvedPath,
          issue:
              resolution.issue ??
              'The configured attachment archive is unavailable.',
        ),
    };
  }

  Future<AppCzarArchiveObservation> _readCoverageForStableScope({
    required AppCzarArchiveCondition condition,
    required String label,
    required AttachmentArchiveLocationConfiguration configuration,
    required String archiveRootPath,
    String? issue,
  }) async {
    final initialScope = attachmentArchiveScopeIdentity(
      archiveInstanceId:
          _archiveAccessAuthority.identity.archiveInstanceId.value,
      configuration: configuration,
      archiveRootPath: archiveRootPath,
    );
    final evidence = await _coverageProbe.readArchiveEvidence(
      archiveRootPath: archiveRootPath,
      archiveScopeIdentity: initialScope,
      archiveGeneration: AttachmentArchiveLocationState.initialGeneration,
    );

    final endingConfigurationRead = _readConfiguration();
    final endingConfiguration = endingConfigurationRead.configuration;
    if (endingConfigurationRead.issue != null ||
        endingConfiguration != configuration) {
      return AppCzarArchiveObservation(
        condition: condition,
        label: label,
        archiveScopeIdentity: initialScope,
        archiveGeneration: AttachmentArchiveLocationState.initialGeneration,
        coverage: AppCzarAttachmentCoverageObservation.unknown(
          issue:
              'The attachment archive configuration changed during coverage inspection.',
          archiveScopeIdentity: initialScope,
          archiveGeneration: AttachmentArchiveLocationState.initialGeneration,
          requiredCount: evidence.coverage.requiredCount,
          coveredCount: evidence.coverage.coveredCount,
          missingCount: evidence.coverage.missingCount,
          unverifiableCount: evidence.coverage.unverifiableCount,
        ),
        repairability: AppCzarAttachmentRepairabilityObservation.unknown(
          issue:
              'The attachment archive configuration changed during repairability inspection.',
          archiveScopeIdentity: initialScope,
          archiveGeneration: AttachmentArchiveLocationState.initialGeneration,
        ),
        resolvedPath: archiveRootPath,
        issue: issue,
      );
    }

    final endingRootPath = await _resolveCurrentRoot(endingConfiguration!);
    final endingScope = endingRootPath == null
        ? null
        : attachmentArchiveScopeIdentity(
            archiveInstanceId:
                _archiveAccessAuthority.identity.archiveInstanceId.value,
            configuration: endingConfiguration,
            archiveRootPath: endingRootPath,
          );
    final stable = endingScope == initialScope;
    return AppCzarArchiveObservation(
      condition: condition,
      label: label,
      archiveScopeIdentity: initialScope,
      archiveGeneration: AttachmentArchiveLocationState.initialGeneration,
      coverage: stable
          ? evidence.coverage
          : AppCzarAttachmentCoverageObservation.unknown(
              issue:
                  'The attachment archive root changed during coverage inspection.',
              archiveScopeIdentity: initialScope,
              archiveGeneration:
                  AttachmentArchiveLocationState.initialGeneration,
              requiredCount: evidence.coverage.requiredCount,
              coveredCount: evidence.coverage.coveredCount,
              missingCount: evidence.coverage.missingCount,
              unverifiableCount: evidence.coverage.unverifiableCount,
            ),
      repairability: stable
          ? evidence.repairability
          : AppCzarAttachmentRepairabilityObservation.unknown(
              issue:
                  'The attachment archive root changed during repairability inspection.',
              archiveScopeIdentity: initialScope,
              archiveGeneration:
                  AttachmentArchiveLocationState.initialGeneration,
            ),
      resolvedPath: archiveRootPath,
      issue: issue,
    );
  }

  Future<String?> _resolveCurrentRoot(
    AttachmentArchiveLocationConfiguration configuration,
  ) async {
    if (configuration.mode == AttachmentArchiveLocationMode.defaultInternal) {
      return _archiveAccessAuthority.resolvePath(
        AttachmentArchiveLocationController.defaultArchiveDirectoryName,
      );
    }
    final bookmarkData = configuration.bookmarkDataBase64;
    if (bookmarkData == null || bookmarkData.isEmpty) {
      return null;
    }
    final resolution = await _bookmarkAdapter.resolveBookmark(
      bookmarkDataBase64: bookmarkData,
    );
    return switch (resolution.status) {
      AttachmentArchiveBookmarkResolutionStatus.available ||
      AttachmentArchiveBookmarkResolutionStatus.readOnly =>
        resolution.resolvedPath,
      _ => null,
    };
  }

  static String _archiveLabel({
    required String? volumeName,
    required String? resolvedPath,
    required String? lastKnownPath,
  }) {
    final normalizedVolumeName = volumeName?.trim();
    if (normalizedVolumeName != null && normalizedVolumeName.isNotEmpty) {
      return normalizedVolumeName;
    }
    final candidatePath = resolvedPath ?? lastKnownPath;
    if (candidatePath != null && candidatePath.trim().isNotEmpty) {
      return path.basename(candidatePath.trim());
    }
    return 'Configured attachment archive';
  }
}

final class _AttachmentConfigurationRead {
  const _AttachmentConfigurationRead.configuration(
    AttachmentArchiveLocationConfiguration this.configuration,
  ) : issue = null;

  const _AttachmentConfigurationRead.issue(String this.issue)
    : configuration = null;

  final AttachmentArchiveLocationConfiguration? configuration;
  final String? issue;
}
