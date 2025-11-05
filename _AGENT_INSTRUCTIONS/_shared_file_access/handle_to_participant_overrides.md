# Handle-to-Participant Overrides Architecture

## 1. What to Store in `user_overlays.db`

Use **stable natural keys** so overrides survive re-imports when integer IDs shift.

### Table: `handle_to_participant_overrides`

| Column | Type | Description |
|--------|------|--------------|
| `id` | INTEGER PRIMARY KEY | |
| `normalized_handle` | TEXT NOT NULL | E.164 or lowercase email |
| `contact_external_key` | TEXT NOT NULL | AddressBook GUID or persistent ID |
| `participant_id` | INTEGER NULL | Cached pointer into working.db |
| `source` | TEXT NOT NULL DEFAULT 'user' | |
| `created_at` | INTEGER NOT NULL | |
| `updated_at` | INTEGER NOT NULL | |
| `active` | INTEGER NOT NULL DEFAULT 1 | |
| `notes` | TEXT NULL | |

**Constraint:** `UNIQUE(normalized_handle) WHERE active = 1`

### Why both `contact_external_key` and `participant_id`?
- `contact_external_key` is stable across rebuilds.
- `participant_id` is a cache, refreshed after each migration.

### Optional Helper Table: `overlay_audit`
Logs changes: old/new participant, reason, timestamp.

---

## 2. Resolution Rules (Single Source of Truth)

1. If an active **user override** exists → use it.
2. Else → use the **working mapping**.
3. If conflict → prefer override and log to `overlay_audit`.

Applies everywhere (Contacts, message headers, composer suggestions).

---

## 3. Where to Combine (Repository Layer)

Avoid gluing providers in the UI. Instead expose **one provider** that returns effective contacts.

### Combine Streams
- `workingDb`: participants + handles.
- `overlaysDb`: active overrides.

### Combine Strategy
1. Build `handle → participant` map from working.
2. Apply overrides (override wins).
3. Derive effective participants and contacts list.

---

## 6. Riverpod Wiring (App-Merge Approach)

```dart
final workingContactsStreamProvider =
    StreamProvider.autoDispose<List<ParticipantWithHandles>>((ref) {
  final dao = ref.watch(workingContactsDaoProvider);
  return dao.watchParticipantsWithHandles();
});

final overlayOverridesStreamProvider =
    StreamProvider.autoDispose<List<HandleOverride>>((ref) {
  final dao = ref.watch(overlaysOverridesDaoProvider);
  return dao.watchActiveOverrides();
});

final effectiveContactsProvider =
    Provider.autoDispose<AsyncValue<List<EffectiveParticipant>>>((ref) {
  final base = ref.watch(workingContactsStreamProvider);
  final ov   = ref.watch(overlayOverridesStreamProvider);

  return AsyncValue.guard(() {
    final baseVal = base.requireValue;
    final ovVal   = ov.requireValue;

    final handleToPart = <String, int>{};
    for (final p in baseVal) {
      for (final h in p.handles) {
        handleToPart[h.normalized] = p.participant.id;
      }
    }

    for (final o in ovVal) {
      if (o.active) {
        final resolvedPid = o.participantId ??
            resolveParticipantIdByExternalKey(o.contactExternalKey, baseVal);
        if (resolvedPid != null) {
          handleToPart[o.normalizedHandle] = resolvedPid;
        }
      }
    }

    final partToHandles = <int, Set<String>>{};
    handleToPart.forEach((handle, pid) {
      partToHandles.putIfAbsent(pid, () => <String>{}).add(handle);
    });

    final byId = {for (final p in baseVal) p.participant.id : p.participant};

    final result = <EffectiveParticipant>[];
    partToHandles.forEach((pid, handles) {
      final baseP = byId[pid];
      if (baseP != null) {
        result.add(EffectiveParticipant(
          participant: baseP,
          handles: handles.toList()..sort(),
          hasOverrides: ovVal.any((o) =>
              o.active &&
              o.participantId == pid &&
              handles.contains(o.normalizedHandle)),
        ));
      }
    });

    result.sort((a, b) =>
        a.participant.displayName.compareTo(b.participant.displayName));
    return result;
  });
});
```

---

## 7. Invalidation & UX

- Adding/removing manual links updates the overlay table, auto-refreshing the combined provider.
- After a migration, the reconciler rebinds `participant_id` fields.
- Optional toast: “Rebuilt contacts mapping.”

---

## 8. Edge Cases & Guardrails

| Case | Handling |
|------|-----------|
| Override points to deleted participant | Keep `participant_id = NULL` and re-resolve |
| Many handles → one participant | OK |
| One handle → multiple participants | Prevented by UNIQUE constraint |
| Audit trail | Logged in `overlay_audit` |

---

## 9. SQL vs App Merge Choice

- **SQL View**: compact, if you can `ATTACH` the overlay DB.
- **App Merge (Recommended)**: cleaner boundaries, testable, one reactive stream.

---

## 10. Summary

- Store user overrides in `user_overlays.db` keyed by normalized handle and external contact key.
- Always merge overrides at the repository/provider layer before UI consumption.
- After migration, reconcile IDs using the contact external key.
- Prefer a single provider exposing effective contacts, ensuring consistency across views.
