## Migration Orchestrator: Table Migrator Playbook

This note captures how we expect the forthcoming `MigrationOrchestrator` pipeline to use the SQLite table migrators that already live in `lib/essentials/db_migrate/infrastructure/sqlite/migrators`. The goal is to retire the legacy `LedgerToWorkingMigrationService` once every migrator performs robust pre-flight validation and copy logic for its table slice.

### Lifecycle Recap

Each migrator extends `BaseTableMigrator` and participates in three phases:

1. **`validatePrereqs(MigrationContext ctx)`** – Run *fine-grained* checks against the attached import database before any writes occur. Fail fast with a `MigrationException` when the import data is known-bad.
2. **`copy(MigrationContext ctx)`** – Perform the actual projection into the working database. Always wrap the copy in a transaction, `ATTACH` the import database once, and use idempotent `INSERT ... ON CONFLICT` semantics.
3. **`postValidate(MigrationContext ctx)`** – Confirm the projection landed as expected (row counts, FK spot checks) once the copy finishes.

`MigrationOrchestrator` will respect the `dependsOn` graph declared by each migrator, ensuring parent tables run before their children, and will stop the entire run on the first validation error.

### Shared Utilities

- **`ctx.importDb` / `ctx.workingDb`** expose `sqflite` connections bound to the import and working databases.
- **`count(DatabaseExecutor db, String table)`** and **`expectTrueOrThrow`** already live on `BaseTableMigrator` for quick asserts.
- Always enable FK enforcement inside transactional copy steps (`PRAGMA foreign_keys = ON`).
- When helpful, collect a small sample (`LIMIT 10`) of offending rows in the `details` payload of raised exceptions.

### Example: `HandlesMigrator`

Handles are the root of the messaging projection; their prereqs should guard against malformed rows in the import ledger.

```dart
class HandlesMigrator extends BaseTableMigrator {
	const HandlesMigrator();

	@override
	String get name => 'handles';

	@override
	List<String> get dependsOn => const [];

	static const _attachAlias = 'import_handles';

	@override
	Future<void> validatePrereqs(MigrationContext ctx) async {
		await ctx.importDb.execute('PRAGMA foreign_keys = ON');

		final integrity = await ctx.importDb
				.rawQuery('PRAGMA integrity_check')
				.then((rows) => rows.first.values.first as String);
		await expectTrueOrThrow(
			integrity == 'ok',
			'HANDLES_INTEGRITY_CHECK_FAILED',
			'handles: PRAGMA integrity_check returned "$integrity"',
		);

		final duplicateIds = await _singleInt(ctx.importDb, '''
			SELECT COUNT(*) FROM (
				SELECT id FROM handles GROUP BY id HAVING COUNT(*) > 1
			)
		''');
		await expectTrueOrThrow(
			duplicateIds == 0,
			'HANDLES_DUPLICATE_PRIMARY_KEY',
			'handles: duplicate id values detected in import database',
		);

		final nullIdentifiers = await _singleInt(ctx.importDb, '''
			SELECT COUNT(*) FROM handles
			WHERE raw_identifier IS NULL OR TRIM(raw_identifier) = ''
		''');
		await expectTrueOrThrow(
			nullIdentifiers == 0,
			'HANDLES_MISSING_IDENTIFIER',
			'handles: raw_identifier contains NULL or empty values',
		);

		final badService = await _singleInt(ctx.importDb, '''
			SELECT COUNT(*) FROM handles
			WHERE service NOT IN ('iMessage','iMessageLite','SMS','RCS','Unknown')
		''');
		await expectTrueOrThrow(
			badService == 0,
			'HANDLES_INVALID_SERVICE',
			'handles: unexpected service value detected in import database',
		);
	}

	@override
	Future<void> copy(MigrationContext ctx) async {
		if (ctx.dryRun) {
			ctx.log('[handles] dry run – skipping copy');
			return;
		}

		final importSqlite = await ctx.importDb.database;
		final importPath = importSqlite.path.replaceAll("'", "''");

		await ctx.workingDb.customStatement(
			"ATTACH DATABASE '$importPath' AS $_attachAlias",
		);

		try {
			await ctx.workingDb.transaction((txn) async {
				await txn.customStatement('PRAGMA foreign_keys = ON');
				await txn.customStatement('''
					INSERT OR REPLACE INTO handles (
						id,
						raw_identifier,
						normalized_identifier,
						service,
						is_ignored,
						is_visible,
						is_blacklisted,
						country,
						last_seen_utc,
						batch_id
					)
					SELECT
						h.id,
						h.raw_identifier,
						h.normalized_identifier,
						COALESCE(h.service, 'Unknown') AS service,
						h.is_ignored,
						CASE WHEN h.is_ignored = 1 THEN 0 ELSE 1 END AS is_visible,
						0 AS is_blacklisted,
						h.country,
						h.last_seen_utc,
						h.batch_id
					FROM $_attachAlias.handles h;
				''');
			});
		} finally {
			await ctx.workingDb.customStatement('DETACH DATABASE $_attachAlias');
		}
	}

	@override
	Future<void> postValidate(MigrationContext ctx) async {
		final src = await count(ctx.importDb, 'handles');
		final dst = await count(ctx.workingDb, 'handles');
		await expectTrueOrThrow(
			dst == src,
			'HANDLES_ROW_MISMATCH',
			'handles: working has $dst rows but import has $src',
		);
	}

	Future<int> _singleInt(DatabaseExecutor db, String sql) async {
		final rows = await db.rawQuery(sql);
		return (rows.first.values.first as num).toInt();
	}
}
```

Notable differences from the legacy service:

- `validatePrereqs` refuses to continue when the import ledger contains obvious defects (duplicate `id`, missing `raw_identifier`, invalid `service`).
- The copy path no longer hardcodes `is_blacklisted = is_ignored`; user state will be re-applied later by the overlay or orchestration.
- `postValidate` double-checks row counts before downstream migrators depend on handles.

### Example: `ChatToHandleMigrator`

Join tables should confirm that their references exist *inside the import database* before attempting a copy. That catches orphaned FKs caused by corrupted source snapshots.

```dart
class ChatToHandleMigrator extends BaseTableMigrator {
	const ChatToHandleMigrator();

	@override
	String get name => 'chat_to_handle';

	@override
	List<String> get dependsOn => const ['chats', 'handles'];

	static const _attachAlias = 'import_chat_to_handle';

	@override
	Future<void> validatePrereqs(MigrationContext ctx) async {
		final missingHandles = await _singleInt(ctx.importDb, '''
			SELECT COUNT(*) FROM chat_to_handle cth
			LEFT JOIN handles h ON h.id = cth.handle_id
			WHERE h.id IS NULL
		''');
		await expectTrueOrThrow(
			missingHandles == 0,
			'CHAT_TO_HANDLE_ORPHAN_HANDLE',
			'chat_to_handle: references missing handles in import database',
		);

		final missingChats = await _singleInt(ctx.importDb, '''
			SELECT COUNT(*) FROM chat_to_handle cth
			LEFT JOIN chats c ON c.id = cth.chat_id
			WHERE c.id IS NULL
		''');
		await expectTrueOrThrow(
			missingChats == 0,
			'CHAT_TO_HANDLE_ORPHAN_CHAT',
			'chat_to_handle: references missing chats in import database',
		);
	}

	@override
	Future<void> copy(MigrationContext ctx) async {
		if (ctx.dryRun) {
			ctx.log('[chat_to_handle] dry run – skipping copy');
			return;
		}

		final importSqlite = await ctx.importDb.database;
		final importPath = importSqlite.path.replaceAll("'", "''");

		await ctx.workingDb.customStatement(
			"ATTACH DATABASE '$importPath' AS $_attachAlias",
		);

		try {
			await ctx.workingDb.transaction((txn) async {
				await txn.customStatement('PRAGMA foreign_keys = ON');
				await txn.customStatement('''
					INSERT OR IGNORE INTO chat_to_handle (
						chat_id,
						handle_id,
						role,
						added_at_utc,
						is_ignored
					)
					SELECT
						cth.chat_id,
						cth.handle_id,
						COALESCE(cth.role, 'member'),
						cth.added_at_utc,
						CASE
							WHEN c.is_ignored = 1 OR h.is_ignored = 1 THEN 1
							ELSE 0
						END AS is_ignored
					FROM $_attachAlias.chat_to_handle cth
					JOIN $_attachAlias.chats c ON c.id = cth.chat_id
					JOIN $_attachAlias.handles h ON h.id = cth.handle_id;
				''');
			});
		} finally {
			await ctx.workingDb.customStatement('DETACH DATABASE $_attachAlias');
		}
	}

	@override
	Future<void> postValidate(MigrationContext ctx) async {
		final fkBreaks = await _singleInt(ctx.workingDb, '''
			SELECT COUNT(*) FROM chat_to_handle cth
			LEFT JOIN chats c ON c.id = cth.chat_id
			LEFT JOIN handles h ON h.id = cth.handle_id
			WHERE c.id IS NULL OR h.id IS NULL
		''');
		await expectTrueOrThrow(
			fkBreaks == 0,
			'CHAT_TO_HANDLE_POST_FK_CHECK',
			'chat_to_handle: detected orphaned rows after copy',
		);
	}

	Future<int> _singleInt(DatabaseExecutor db, String sql) async {
		final rows = await db.rawQuery(sql);
		return (rows.first.values.first as num).toInt();
	}
}
```

Key behavior:

- `validatePrereqs` rejects orphaned `chat_to_handle` rows early, so we never kick off a long migration that is guaranteed to fail later.
- The copy phase joins against the attached import tables to compute `is_ignored` consistently with the existing rules.
- `postValidate` double-checks that the projected join table still has no orphaned references inside `working.db`.

### Recommendations for Remaining Migrators

1. **Participants** – Verify `Z_PK` uniqueness, reject rows with missing `display_name`, and ensure any join tables (e.g., `contact_to_chat_handle`) do not point at ignored rows when the migrator expects them filtered out.
2. **Messages** – Validate that every `chat_id` and `sender_handle_id` in `import.messages` exists before copying. Consider enforcing GUID uniqueness and rejecting NULL `guid` values.
3. **Attachments / Reactions** – Similar anti-join checks against their parent message IDs.
4. **Global preflight** – Run `PRAGMA foreign_key_check` once before orchestrating individual migrators. If the import schema lacks FK declarations, rely on migrator-specific anti-joins instead.

With these guards in place, `MigrationOrchestrator` can trust that missing or corrupt rows get detected during `validatePrereqs`, long before they reach the working projection.

### Appendix: chat.db Handle Format Quirks

The Messages `handles` table often contains legacy variants of the same phone or email identity. Expect to see both the raw E.164 form and URI-prefixed form stored side-by-side:

- `+14127362358`
- `tel:+14127362358`
- (For email addresses: `foo@example.com` and `mailto:foo@example.com`)

Key observations to keep in mind when validating or normalizing the ledger:

1. **Multiple ingest paths** (SMS vs. iMessage vs. continuity/relay) write slightly different canonical forms. Historical rows are rarely backfilled when Apple changes its preferred format, so older chats keep the bare E.164 string while newer inserts may use `tel:`.
2. **Service-specific providers** also normalize differently—even when `service = 'iMessage'`, internal plumbing can emit either variant.
3. **`uncanonicalized_id` is usually `NULL`** because the value in `id` is already considered the canonical representation for that ingest path. Apple only fills `uncanonicalized_id` when they need to preserve the original raw input.

When projecting into the working database, treat these variants as aliases of the same logical handle by normalizing to a single canonical value (strip schemes, trim punctuation, apply E.164 formatting for phones, lowercase emails, etc.).
