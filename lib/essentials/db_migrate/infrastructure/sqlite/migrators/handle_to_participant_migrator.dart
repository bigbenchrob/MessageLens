import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class HandleToParticipantMigrator extends BaseTableMigrator {
  const HandleToParticipantMigrator();

  static const _attachAlias = 'import_handle_links';

  @override
  String get name => 'handle_to_participant';

  @override
  List<String> get dependsOn => const ['handles', 'participants'];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    final importLinks = await _countJoinableImportLinks(ctx);
    ctx.log('[handle_to_participant] import joinable links = $importLinks');

    if (importLinks == 0) {
      ctx.log(
        '[handle_to_participant] nothing to link – skipping prerequisites',
      );
      return;
    }

    final handleCount = await count(ctx.workingDb, 'handles_canonical');
    await expectTrueOrThrow(
      ok: handleCount > 0,
      errorCode: 'HANDLE_LINKS_REQUIRES_HANDLES',
      message:
          'handle_to_participant: import has $importLinks links but working database has no canonical handles',
    );

    final participantCount = await count(ctx.workingDb, 'participants');
    await expectTrueOrThrow(
      ok: participantCount > 0,
      errorCode: 'HANDLE_LINKS_REQUIRES_PARTICIPANTS',
      message:
          'handle_to_participant: import has $importLinks links but working database has no participants',
    );
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[handle_to_participant] dry run – skipping copy');
      return;
    }

    final inserted = await _withAttachedImport(ctx, () async {
      final missingParticipants = await ctx.workingDb.customSelect('''
        SELECT DISTINCT cth.contact_Z_PK AS participant_id
        FROM $_attachAlias.contact_to_chat_handle cth
        JOIN $_attachAlias.contacts c ON c.Z_PK = cth.contact_Z_PK AND c.is_ignored = 0
        JOIN $_attachAlias.handles h ON h.id = cth.chat_handle_id AND h.is_ignored = 0
        LEFT JOIN participants p ON p.id = c.Z_PK
        WHERE p.id IS NULL
      ''').get();
      if (missingParticipants.isNotEmpty) {
        final ids =
            missingParticipants
                .map((row) => _coerceToNullableInt(row.data['participant_id']))
                .whereType<int>()
                .toList()
              ..sort();
        final preview = ids.take(5).join(', ');
        final suffix = ids.length > 5 ? '…' : '';
        ctx.log(
          '[handle_to_participant] skipping ${ids.length} link(s); missing participants: $preview$suffix',
        );
      }

      final missingHandles = await ctx.workingDb.customSelect('''
        SELECT DISTINCT cth.chat_handle_id AS handle_id
        FROM $_attachAlias.contact_to_chat_handle cth
        JOIN $_attachAlias.contacts c ON c.Z_PK = cth.contact_Z_PK AND c.is_ignored = 0
        JOIN $_attachAlias.handles h ON h.id = cth.chat_handle_id AND h.is_ignored = 0
        LEFT JOIN handle_canonical_map map
          ON map.source_handle_id = cth.chat_handle_id
        LEFT JOIN handles_canonical wh ON wh.id = map.canonical_handle_id
        WHERE map.canonical_handle_id IS NULL OR wh.id IS NULL
      ''').get();
      if (missingHandles.isNotEmpty) {
        final ids =
            missingHandles
                .map((row) => _coerceToNullableInt(row.data['handle_id']))
                .whereType<int>()
                .toList()
              ..sort();
        final preview = ids.take(5).join(', ');
        final suffix = ids.length > 5 ? '…' : '';
        ctx.log(
          '[handle_to_participant] skipping ${ids.length} link(s); missing handles: $preview$suffix',
        );
      }

      await ctx.workingDb.customStatement('''
        INSERT OR IGNORE INTO handle_to_participant (
          handle_id,
          participant_id,
          confidence,
          source
        )
        SELECT
          map.canonical_handle_id,
          c.Z_PK,
          1.0 AS confidence,
          'addressbook' AS source
        FROM $_attachAlias.contact_to_chat_handle cth
        JOIN $_attachAlias.contacts c ON c.Z_PK = cth.contact_Z_PK AND c.is_ignored = 0
        JOIN $_attachAlias.handles h ON h.id = cth.chat_handle_id AND h.is_ignored = 0
        JOIN handle_canonical_map map
          ON map.source_handle_id = cth.chat_handle_id
        JOIN handles_canonical wh ON wh.id = map.canonical_handle_id
        JOIN participants p ON p.id = c.Z_PK;
      ''');

      final rows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      final insertCount = _extractCount(rows, 'c');

      // Debug: Check if any were skipped due to OR IGNORE
      final expectedToInsert = await ctx.workingDb.customSelect('''
        SELECT COUNT(*) AS c
        FROM $_attachAlias.contact_to_chat_handle cth
        JOIN $_attachAlias.contacts c ON c.Z_PK = cth.contact_Z_PK AND c.is_ignored = 0
        JOIN $_attachAlias.handles h ON h.id = cth.chat_handle_id AND h.is_ignored = 0
        JOIN handle_canonical_map map
          ON map.source_handle_id = cth.chat_handle_id
        JOIN handles_canonical wh ON wh.id = map.canonical_handle_id
        JOIN participants p ON p.id = c.Z_PK
      ''').get();
      final expectedCount = _extractCount(expectedToInsert, 'c');

      if (insertCount < expectedCount) {
        ctx.log(
          '[handle_to_participant] INSERT OR IGNORE skipped ${expectedCount - insertCount} duplicate(s)',
        );

        // Find which ones were skipped
        final duplicates = await ctx.workingDb.customSelect('''
          SELECT 
            map.canonical_handle_id,
            c.Z_PK AS participant_id,
            h.id AS source_handle_id
          FROM $_attachAlias.contact_to_chat_handle cth
          JOIN $_attachAlias.contacts c ON c.Z_PK = cth.contact_Z_PK AND c.is_ignored = 0
          JOIN $_attachAlias.handles h ON h.id = cth.chat_handle_id AND h.is_ignored = 0
          JOIN handle_canonical_map map
            ON map.source_handle_id = cth.chat_handle_id
          JOIN handles_canonical wh ON wh.id = map.canonical_handle_id
          JOIN participants p ON p.id = c.Z_PK
          WHERE EXISTS (
            SELECT 1 FROM handle_to_participant htp
            WHERE htp.handle_id = map.canonical_handle_id
              AND htp.participant_id = c.Z_PK
          )
        ''').get();

        for (final dup in duplicates) {
          final handleId = _coerceToInt(dup.data['canonical_handle_id']);
          final participantId = _coerceToInt(dup.data['participant_id']);
          final sourceHandleId = _coerceToInt(dup.data['source_handle_id']);
          ctx.log(
            '[handle_to_participant] duplicate: source_handle=$sourceHandleId → canonical_handle=$handleId, participant=$participantId (already exists)',
          );
        }
      }

      return insertCount;
    });

    ctx.log('[handle_to_participant] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    final expected = await _withAttachedImport(ctx, () async {
      final rows = await ctx.workingDb.customSelect('''
        SELECT COUNT(DISTINCT map.canonical_handle_id || '-' || c.Z_PK) AS c
        FROM $_attachAlias.contact_to_chat_handle cth
        JOIN $_attachAlias.contacts c ON c.Z_PK = cth.contact_Z_PK AND c.is_ignored = 0
        JOIN $_attachAlias.handles h ON h.id = cth.chat_handle_id AND h.is_ignored = 0
        JOIN handle_canonical_map map
          ON map.source_handle_id = cth.chat_handle_id
        JOIN handles_canonical wh ON wh.id = map.canonical_handle_id
        JOIN participants p ON p.id = c.Z_PK
      ''').get();
      return _extractCount(rows, 'c');
    });

    final projected = await count(ctx.workingDb, 'handle_to_participant');
    ctx.log('[handle_to_participant] expected=$expected projected=$projected');

    if (expected == 0) {
      await expectTrueOrThrow(
        ok: projected == 0,
        errorCode: 'HANDLE_LINKS_UNEXPECTED_ROWS',
        message:
            'handle_to_participant: working has $projected rows but import had none',
      );
      return;
    }

    await expectTrueOrThrow(
      ok: projected == expected,
      errorCode: 'HANDLE_LINKS_ROW_MISMATCH',
      message:
          'handle_to_participant: working has $projected rows but expected $expected',
    );
  }

  Future<int> _countJoinableImportLinks(MigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c '
      'FROM contact_to_chat_handle cth '
      'JOIN contacts c ON c.Z_PK = cth.contact_Z_PK '
      'JOIN handles h ON h.id = cth.chat_handle_id '
      'WHERE c.is_ignored = 0 AND h.is_ignored = 0',
    );
    if (rows.isEmpty) {
      return 0;
    }
    return _coerceToInt(rows.first['c']);
  }

  Future<T> _withAttachedImport<T>(
    MigrationContext ctx,
    Future<T> Function() run,
  ) async {
    final importSqlite = await ctx.importDb.database;
    final escapedPath = importSqlite.path.replaceAll("'", "''");
    await ctx.workingDb.customStatement(
      "ATTACH DATABASE '$escapedPath' AS $_attachAlias",
    );
    try {
      return await run();
    } finally {
      await ctx.workingDb.customStatement('DETACH DATABASE $_attachAlias');
    }
  }

  int _extractCount(List<dynamic> rows, String key) {
    if (rows.isEmpty) {
      return 0;
    }
    final first = rows.first;
    if (first is Map<String, Object?>) {
      return _coerceToInt(first[key]);
    }
    final data = (first as dynamic).data as Map<String, Object?>;
    return _coerceToInt(data[key]);
  }

  int _coerceToInt(Object? value) {
    final coerced = _coerceToNullableInt(value);
    return coerced ?? 0;
  }

  int? _coerceToNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is BigInt) {
      return value.toInt();
    }
    final parsed = int.tryParse(value.toString());
    return parsed;
  }
}
