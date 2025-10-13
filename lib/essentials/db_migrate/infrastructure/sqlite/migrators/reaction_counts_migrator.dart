import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class ReactionCountsMigrator extends BaseTableMigrator {
  const ReactionCountsMigrator();

  @override
  String get name => 'reaction_counts';

  @override
  List<String> get dependsOn => const ['reactions'];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    final reactionRows = await count(ctx.workingDb, 'reactions');
    ctx.log('[reaction_counts] reactions available = $reactionRows');
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[reaction_counts] dry run – skipping copy');
      return;
    }

    await ctx.workingDb.transaction(() async {
      await ctx.workingDb.customStatement('DELETE FROM reaction_counts');
      await ctx.workingDb.customStatement('''
        INSERT OR REPLACE INTO reaction_counts (
          message_guid,
          love,
          like,
          dislike,
          laugh,
          emphasize,
          question
        )
        SELECT
          message_guid,
          CASE WHEN love < 0 THEN 0 ELSE love END AS love,
          CASE WHEN like < 0 THEN 0 ELSE like END AS like,
          CASE WHEN dislike < 0 THEN 0 ELSE dislike END AS dislike,
          CASE WHEN laugh < 0 THEN 0 ELSE laugh END AS laugh,
          CASE WHEN emphasize < 0 THEN 0 ELSE emphasize END AS emphasize,
          CASE WHEN question < 0 THEN 0 ELSE question END AS question
        FROM (
          SELECT
            message_guid,
            SUM(CASE WHEN kind = 'love' THEN delta ELSE 0 END) AS love,
            SUM(CASE WHEN kind = 'like' THEN delta ELSE 0 END) AS like,
            SUM(CASE WHEN kind = 'dislike' THEN delta ELSE 0 END) AS dislike,
            SUM(CASE WHEN kind = 'laugh' THEN delta ELSE 0 END) AS laugh,
            SUM(CASE WHEN kind = 'emphasize' THEN delta ELSE 0 END) AS emphasize,
            SUM(CASE WHEN kind = 'question' THEN delta ELSE 0 END) AS question
          FROM (
            SELECT
              message_guid,
              kind,
              CASE
                WHEN action = 'add' THEN 1
                WHEN action = 'remove' THEN -1
                ELSE 0
              END AS delta
            FROM reactions
            WHERE message_guid IS NOT NULL AND LENGTH(TRIM(message_guid)) > 0
          ) deltas
          GROUP BY message_guid
        ) aggregates;
      ''');
    });

    final inserted = await count(ctx.workingDb, 'reaction_counts');
    ctx.log('[reaction_counts] tallies generated for $inserted message(s)');
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    final distinctSources = await ctx.workingDb.customSelect('''
      SELECT COUNT(*) AS c FROM (
        SELECT DISTINCT message_guid
        FROM reactions
        WHERE message_guid IS NOT NULL AND LENGTH(TRIM(message_guid)) > 0
      ) src;
    ''').get();
    final sourceCount = _extractCount(distinctSources, 'c');
    final tallies = await count(ctx.workingDb, 'reaction_counts');
    ctx.log('[reaction_counts] expected=$sourceCount projected=$tallies');

    await expectTrueOrThrow(
      tallies == sourceCount,
      'REACTION_COUNTS_ROW_MISMATCH',
      'reaction_counts: working has $tallies rows but expected $sourceCount',
    );
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
    if (value == null) {
      return 0;
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
    return int.parse(value.toString());
  }
}
