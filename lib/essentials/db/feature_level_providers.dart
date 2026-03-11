///***************************************************************** */
///* The entry point for dependency injection for the database layer.
///***************************************************************** */

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db_importers/application/debug_settings_provider.dart';
import '../logging/application/app_logger.dart';

import 'infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'infrastructure/data_sources/local/working/working_database.dart';

export 'feature_level_providers/db_maintenance_lock_provider.dart';
export 'feature_level_providers/message_data_version_provider.dart';

part 'feature_level_providers.g.dart';

/// The directory where all application databases are stored.
///
/// Initialized once at app startup via [initDatabaseDirectoryPath].
/// Exposed for use by the onboarding existence checker.
/// All DB providers below also use this path.
late final String databaseDirectoryPath; //~/Library/Application Support/com.bigbenchsoftware.MessageLens/

/// Must be called once in `main()` after `WidgetsFlutterBinding.ensureInitialized()`.
Future<void> initDatabaseDirectoryPath() async {
  final appSupportDir = await getApplicationSupportDirectory();
  databaseDirectoryPath = appSupportDir.path;
}

Future<void> _ensureDatabaseDirectoryExists() async {
  final directory = Directory(databaseDirectoryPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }
}

/// Provides access to the Sqflite-powered import ledger database.
@Riverpod(keepAlive: true)
Future<SqfliteImportDatabase> sqfliteImportDatabase(
  SqfliteImportDatabaseRef ref,
) async {
  await _ensureDatabaseDirectoryExists();
  final database = SqfliteImportDatabase(
    databaseDirectory: databaseDirectoryPath,
    databaseName: 'macos_import.db',
    debugSettings: ref.watch(importDebugSettingsProvider),
  );

  // Ensure the database file is created immediately so dependent services can query schema metadata.
  await database.database;

  ref.onDispose(() async {
    await database.close();
  });

  return database;
}

/// Provides access to the Drift projection database used by the UI.
@Riverpod(keepAlive: true)
Future<WorkingDatabase> driftWorkingDatabase(
  DriftWorkingDatabaseRef ref,
) async {
  await _ensureDatabaseDirectoryExists();
  final dbPath = path.join(databaseDirectoryPath, 'working.db');

  final database = WorkingDatabase(
    NativeDatabase.createInBackground(File(dbPath)),
  );

  await database.doWhenOpened((_) async {
    await database.customStatement('PRAGMA foreign_keys = ON');
  });

  ref.onDispose(() async {
    ref
        .read(appLoggerProvider.notifier)
        .debug(
          'Disposing WorkingDatabase for $dbPath',
          source: 'WorkingDbProvider',
        );
    await database.close();
  });

  return database;
}

/// Provides access to the overlay database for user preferences and customizations.
@Riverpod(keepAlive: true)
Future<OverlayDatabase> overlayDatabase(OverlayDatabaseRef ref) async {
  await _ensureDatabaseDirectoryExists();
  final dbPath = path.join(databaseDirectoryPath, 'user_overlays.db');

  final database = OverlayDatabase(
    NativeDatabase.createInBackground(File(dbPath)),
  );

  await database.doWhenOpened((_) async {
    await database.customStatement('PRAGMA foreign_keys = ON');
  });

  ref.onDispose(() async {
    await database.close();
  });

  return database;
}
