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
import '../../domain/entities/attachment_archive_location_configuration.dart';

final class ReadOnlyAppCzarAttachmentArchiveProbe
    implements AppCzarAttachmentArchiveProbe {
  const ReadOnlyAppCzarAttachmentArchiveProbe({
    required ArchiveAccessAuthority archiveAccessAuthority,
    required AttachmentArchiveBookmarkAdapter bookmarkAdapter,
  }) : _archiveAccessAuthority = archiveAccessAuthority,
       _bookmarkAdapter = bookmarkAdapter;

  final ArchiveAccessAuthority _archiveAccessAuthority;
  final AttachmentArchiveBookmarkAdapter _bookmarkAdapter;

  @override
  Future<AppCzarArchiveObservation> readCurrent() async {
    final configurationRead = _readConfiguration();
    if (configurationRead.issue case final issue?) {
      return AppCzarArchiveObservation.unknown(issue);
    }
    final configuration = configurationRead.configuration!;
    return switch (configuration.mode) {
      AttachmentArchiveLocationMode.defaultInternal => _readDefaultInternal(),
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

  AppCzarArchiveObservation _readDefaultInternal() {
    final archivePath = _archiveAccessAuthority.resolvePath(
      AttachmentArchiveLocationController.defaultArchiveDirectoryName,
    );
    final entityType = FileSystemEntity.typeSync(
      archivePath,
      followLinks: false,
    );
    if (entityType == FileSystemEntityType.notFound) {
      return AppCzarArchiveObservation(
        condition: AppCzarArchiveCondition.notCreated,
        label: 'Default attachment archive',
        resolvedPath: archivePath,
      );
    }
    if (entityType != FileSystemEntityType.directory) {
      return AppCzarArchiveObservation(
        condition: AppCzarArchiveCondition.unavailable,
        label: 'Default attachment archive',
        resolvedPath: archivePath,
        issue: 'The default attachment archive is not a regular directory.',
      );
    }
    return AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.available,
      label: 'Default attachment archive',
      resolvedPath: archivePath,
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
        AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.available,
          label: label,
          resolvedPath: resolvedPath,
        ),
      AttachmentArchiveBookmarkResolutionStatus.readOnly =>
        AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.readOnly,
          label: label,
          resolvedPath: resolvedPath,
          issue: resolution.issue,
        ),
      AttachmentArchiveBookmarkResolutionStatus.unavailable ||
      AttachmentArchiveBookmarkResolutionStatus.permissionDenied ||
      AttachmentArchiveBookmarkResolutionStatus.configuredDirectoryMissing ||
      AttachmentArchiveBookmarkResolutionStatus.invalidBookmark =>
        AppCzarArchiveObservation(
          condition: AppCzarArchiveCondition.unavailable,
          label: label,
          resolvedPath: resolvedPath,
          issue:
              resolution.issue ??
              'The configured attachment archive is unavailable.',
        ),
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
