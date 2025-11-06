# Provider Strategy: Contact Menus (Working + Overlay DBs)

This document describes the **simplest and clearest provider strategy** for supplying both:

1. A list of **all contacts** (Menu B) — including those not linked to any chat handle.  
2. A list of **contacts that are linked** to at least one chat handle (Menu A), where the link may originate either from the working database or the user overlay database.

---

## 1. Background and Goals

**Problem:**  
Originally, only contacts with matching chat handles were migrated into the working database. This meant that contacts without any linked handle were unavailable for manual handle matching.

**Solution:**  
- Migrate *all* contacts into the working database.  
- Use a `user_overlays.db` table to persist user-created handle-to-contact links.  
- Use two menus in the UI:  

| Menu | Description | Data Source |
|------|--------------|--------------|
| **A** | Contacts linked to at least one handle (via import or user override) | working.db + overlay.db |
| **B** | All contacts, regardless of linkage | working.db |

---

## 2. Database Model Overview

### Working Database (`working.db`)

| Table | Description |
|--------|--------------|
| `participants` | All imported contacts |
| `handles` | All handles (phone numbers, emails, etc.) |
| `handle_to_participant` | Links handles to participants (from import) |

### Overlay Database (`user_overlays.db`)

| Table | Description |
|--------|--------------|
| `handle_to_participant_overrides` | User-directed handle → contact links that persist through re-imports |

A participant is considered “chat-linked” if its ID appears in **either** of the link tables above.

---

## 3. Menu B – All Contacts

### Repository Helper

```dart
class ParticipantsRepository {
  final WorkingDb _db;

  ParticipantsRepository(this._db);

  Future<List<Participant>> getAllOrderedByDisplayName() {
    return (_db.select(_db.participants)
          ..orderBy([(p) => OrderingTerm(expression: p.displayName)]))
        .get();
  }
}
```

### Riverpod Provider

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'contact_menu_providers.g.dart';

@riverpod
Future<List<Participant>> contactsMenuB(ContactsMenuBRef ref) async {
  final repo = ref.watch(participantsRepositoryProvider);
  return repo.getAllOrderedByDisplayName();
}
```

### Usage

```dart
final contactsAsync = ref.watch(contactsMenuBProvider);

contactsAsync.when(
  data: (contacts) => DropdownButton<Participant>(
    value: selected,
    items: contacts.map((p) => DropdownMenuItem(
      value: p,
      child: Text(p.displayName ?? p.fallbackLabel),
    )).toList(),
    onChanged: onChanged,
  ),
  loading: () => const CircularProgressIndicator(),
  error: (e, st) => Text('Failed to load contacts: $e'),
);
```

Invalidate when needed (e.g. after a migration):
```dart
ref.invalidate(contactsMenuBProvider);
```

---

## 4. Menu A – Linked Contacts (Working + Overlay)

### Repository Helpers

**Working DB:**
```dart
class HandleLinksRepository {
  final WorkingDb _db;
  HandleLinksRepository(this._db);

  Future<Set<int>> getParticipantIdsWithLinks() async {
    final rows = await (_db.select(_db.handleToParticipant)..distinct = true).get();
    return rows.map((r) => r.participantId).toSet();
  }
}
```

**Overlay DB:**
```dart
class OverlayHandleLinksRepository {
  final UserOverlaysDb _db;
  OverlayHandleLinksRepository(this._db);

  Future<Set<int>> getParticipantIdsWithOverrides() async {
    final rows = await (_db.select(_db.handleToParticipantOverrides)..distinct = true).get();
    return rows.map((r) => r.participantId).toSet();
  }
}
```

### Combined Provider

```dart
@riverpod
Future<List<Participant>> contactsMenuA(ContactsMenuARef ref) async {
  // 1. All contacts (reuse Menu B)
  final participantsFuture = ref.watch(contactsMenuBProvider.future);

  // 2. Linked participant IDs from working DB
  final workingLinkedFuture =
      ref.watch(handleLinksRepositoryProvider).getParticipantIdsWithLinks();

  // 3. Linked participant IDs from overlay DB
  final overlayLinkedFuture =
      ref.watch(overlayHandleLinksRepositoryProvider).getParticipantIdsWithOverrides();

  final participants = await participantsFuture;
  final workingLinkedIds = await workingLinkedFuture;
  final overlayLinkedIds = await overlayLinkedFuture;

  // 4. Union IDs
  final linkedIds = <int>{}
    ..addAll(workingLinkedIds)
    ..addAll(overlayLinkedIds);

  // 5. Filter contacts to those in linked set
  return participants.where((p) => linkedIds.contains(p.id)).toList(growable: false);
}
```

### Usage

```dart
final linkedContactsAsync = ref.watch(contactsMenuAProvider);

linkedContactsAsync.when(
  data: (contacts) => buildLinkedContactsDropdown(contacts),
  loading: () => const CircularProgressIndicator(),
  error: (e, st) => Text('Error loading linked contacts: $e'),
);
```

### Invalidation

Whenever user links a handle or re-imports data:
```dart
ref.invalidate(contactsMenuAProvider);
```

You can also invalidate both menus for simplicity:
```dart
ref.invalidate(contactsMenuAProvider);
ref.invalidate(contactsMenuBProvider);
```

---

## 5. Why This Design Is Ideal

✅ **Readable and Explicit:** All logic is local in the provider; no hidden cross-db SQL joins.  
✅ **Drift-friendly:** Each DB is queried independently.  
✅ **Future-proof:** Overlay logic can be extended later (e.g. user tags, notes).  
✅ **Stable UI Flow:** Menus update only on meaningful app events (migration or override).  

---

### Summary

| Menu | Description | Provider | Data Source |
|------|--------------|-----------|--------------|
| **Menu A** | Linked contacts (working + overlay) | `contactsMenuAProvider` | `working.db`, `user_overlays.db` |
| **Menu B** | All contacts | `contactsMenuBProvider` | `working.db` |

This approach keeps your **migration, repository, and UI layers clean** and separates *what is persisted* from *what is presented*.
