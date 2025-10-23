/// One-time script to reformat existing handle display_name values
///
/// Run with: dart run tool/reformat_handle_display_names.dart
///
/// This will update all phone numbers in working.db to use human-friendly formatting.

// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../lib/essentials/db/shared/handle_identifier_utils.dart';

void main() async {
  // Database is at /Users/rob/sqlite_rmc/remember_every_text/working.db
  final dbPath = '/Users/rob/sqlite_rmc/remember_every_text/working.db';

  if (!File(dbPath).existsSync()) {
    print('ERROR: Database not found at $dbPath');
    exit(1);
  }

  print('Opening database: $dbPath');
  final db = sqlite3.open(dbPath);

  try {
    // Read all handles
    final result = db.select(
      'SELECT id, raw_identifier, display_name FROM handles',
    );

    print('Found ${result.length} handles');

    var updated = 0;
    var skipped = 0;

    for (final row in result) {
      final id = row['id'] as int?;
      final rawIdentifier = row['raw_identifier'] as String?;
      final currentDisplay = row['display_name'] as String?;

      if (id == null || rawIdentifier == null || rawIdentifier.trim().isEmpty) {
        skipped++;
        continue;
      }

      final formatted = formatPhoneNumberForDisplay(rawIdentifier);

      // Only update if the formatting changed
      if (formatted != currentDisplay && formatted.isNotEmpty) {
        db.execute('UPDATE handles SET display_name = ? WHERE id = ?', [
          formatted,
          id,
        ]);

        updated++;
        if (updated <= 10) {
          print('  Updated: "$rawIdentifier" → "$formatted"');
        } else if (updated == 11) {
          print('  ... (suppressing further output)');
        }
      } else {
        skipped++;
      }
    }

    print('\nComplete!');
    print('  Updated: $updated handles');
    print('  Skipped: $skipped handles (no change needed)');
  } finally {
    db.dispose();
  }
}
