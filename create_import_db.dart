import 'dart:io';
import 'package:drift/native.dart';
import 'lib/essentials/db/infrastructure/data_sources/local/import/import_database.dart';

void main() async {
  // Ensure directory exists
  final dir = Directory('/Users/rob/sqlite_rmc/remember_every_text');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final dbFile = File(
    '/Users/rob/sqlite_rmc/remember_every_text/macos_import_schema.db',
  );
  final fileDb = ImportDatabase(NativeDatabase(dbFile));

  print('Creating import database schema...');
  await fileDb.transaction(() async {
    await fileDb.customStatement('PRAGMA foreign_keys = ON');
  });

  print('Created import database at: ${dbFile.path}');
  print('Tables created:');

  final result = await fileDb
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      )
      .get();
  for (final row in result) {
    print('  - ${row.data['name']}');
  }

  await fileDb.close();

  print('\nYou can now inspect the database with:');
  print('sqlite3 ${dbFile.path} ".schema"');
}
