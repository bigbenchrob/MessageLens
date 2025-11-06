---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2025-11-05
source_of_truth: This file
links:
  - ./00-all-databases-accessed.md
  - ./06-addressbook-path-resolution.md
  - ./01-db-import.md
  - ./10-group-import-working.md
  - ../20-MIGRATIONS/schema-reference.md
tests: []
---

# `db-address-book` — macOS Contacts Source (`AddressBook-v22.abcddb`)

`db-address-book` is the live macOS AddressBook database shipped with the operating system. It is the canonical source of truth for contacts that ultimately populate `working_participants` and participate in handle linking.

- **Alias**: `db-address-book`
- **Physical File**: `AddressBook-v22.abcddb` inside the most recent `~/Library/Application Support/AddressBook/Sources/<UUID>/` folder
- **Primary Consumer**: Import orchestrator (read-only)

## Resolution & Location

| Item | Value |
| --- | --- |
| Resolution | `getFolderAggregateEitherProvider` → `AddressBookFolderAggregate.mostRecentFolderPath` |
| Runtime storage | Resolved dynamically at import time |
| Requires | Full Disk Access (macOS security)

Never hardcode the path. Apple maintains multiple historical bundles and only one contains the active data. See `06-addressbook-path-resolution.md` for the provider chain that locates the live bundle.

## Provider Access Pattern

- **Riverpod entry point**: `getFolderAggregateEitherProvider`
- **Location**: `lib/features/address_book_folders/application/get_folder_aggregate_either_provider.dart`
- **Return type**: `Future<Either<FolderRetrievalFailure, AddressBookFolderAggregate>>`

Usage template:

```dart
final aggregateEither = await ref.read(
  getFolderAggregateEitherProvider.future,
);

final aggregate = aggregateEither.getOrElse(
  (failure) => throw Exception('AddressBook resolution failed: ${failure.message}'),
);

final activePath = aggregate.mostRecentFolderPath.value;
```

Only the import pipeline should open the sqlite file. Application code interacts with the projected data via `db-working`.

## Key Tables Consumed During Import

| Table | Purpose |
| --- | --- |
| `ZABCDRECORD` | Primary contact records (names, organization flags). |
| `ZABCDPHONENUMBER` / `ZABCDEMAILADDRESS` | Phone and email handles associated with contacts. |
| `ZABCDEINTERNALMETADATA` | Provider metadata (used for deduplication diagnostics). |
| `ZABCDCONTACTINDEX` | Search metadata leveraged during import health checks. |

The import pipeline copies this data into ledger tables (`contacts`, `contact_phone_email`, and `contact_to_chat_handle`) while preserving `Z_PK` identifiers. See `01-db-import.md` for ledger schema expectations.

## Usage Rules

1. **Read-only access**: Never modify the macOS AddressBook; treat it as an immutable source.
2. **Resolve paths at runtime**: Always go through the provider chain—user systems may surface different bundle IDs.
3. **Validate record counts**: Importers verify that the active database contains a reasonable number of contacts (>10). Abort if validation fails to avoid ingesting archived bundles.
4. **Provide overrides in tests**: Flutter tests cannot rely on `path_provider`. Override `getFolderAggregateEitherProvider` with deterministic paths when testing import logic.

## Cross-References

- `06-addressbook-path-resolution.md` — Full provider chain and testing guidance.
- `01-db-import.md` — Ledger destination after AddressBook data is staged.
- `10-group-import-working.md` — Contract guaranteeing `Z_PK` propagation into `db-working`.
- `../20-MIGRATIONS/schema-reference.md` — Ledger table definitions referencing AddressBook data.
