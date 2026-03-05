import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../feature_level_providers.dart' show databaseDirectoryPath;
import 'message_data_version_provider.dart';

part 'working_db_populated_provider.g.dart';

/// Whether `working.db` contains data (file exists and is non-empty).
///
/// Watches [messageDataVersionProvider] so it re-evaluates after migration
/// bumps that signal. Used to gate sidebar cascades and the top menu prompt
/// on first launch.
@Riverpod(keepAlive: true)
class WorkingDbPopulated extends _$WorkingDbPopulated {
  @override
  bool build() {
    // Re-evaluate whenever the data-version signal fires (e.g. after migration).
    ref.watch(messageDataVersionProvider);

    final workingFile = File(path.join(databaseDirectoryPath, 'working.db'));
    return workingFile.existsSync() && workingFile.lengthSync() > 0;
  }
}
