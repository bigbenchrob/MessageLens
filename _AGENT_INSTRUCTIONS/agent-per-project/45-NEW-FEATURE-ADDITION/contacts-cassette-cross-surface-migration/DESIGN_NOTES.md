# Contacts Cassette Cross-Surface Migration — Design Notes

This document captures design decisions, rationale, and technical notes encountered during implementation.

---

## Architecture Reference

This migration follows the cross-surface spec architecture documented in:
- [90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md](../../90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md)

### Layer Responsibilities

| Layer | Responsibility | Example |
|-------|---------------|---------|
| Coordinator | Route only, pattern-match on spec | `ContactsCassetteCoordinator` |
| Resolver | Own meaning, data access, business logic | `ChooserContentResolver` |
| Builder | Assemble widgets from resolver output | `ChooserWidgetBuilder` |

---

## Decisions Log

### Decision 1: Async by Default

**Context:** Current `FeatureCassetteSpecCoordinator.buildForSpec` is synchronous.

**Decision:** New coordinator returns `Future<SidebarCassetteCardViewModel>`.

**Rationale:**
- Resolvers will need to call repositories (async)
- Even if some paths are currently sync, uniformity simplifies the interface
- `CassetteWidgetCoordinator` already handles async via `AsyncValue`

---

### Decision 2: Bridge Strategy for Phase 1

**Context:** We need to introduce the new coordinator without breaking existing functionality.

**Decision:** Initially delegate to existing `contactChooserViewBuilder` from the new coordinator.

**Rationale:**
- Allows incremental migration
- Each phase can be validated independently
- Rollback is straightforward if issues arise

**Code Pattern:**
```dart
@riverpod
Future<SidebarCassetteCardViewModel> contactsCassetteCoordinator(
  Ref ref,
  ContactsCassetteSpec spec,
) async {
  return spec.map(
    contactChooser: (s) => _buildContactChooser(ref, s),
    recentContacts: (s) => _buildRecentContacts(ref, s),
    contactHeroSummary: (s) => _buildHeroSummary(ref, s),
  );
}

// Phase 1: Bridge to legacy
Future<SidebarCassetteCardViewModel> _buildContactChooser(
  Ref ref,
  ContactChooserSpec spec,
) async {
  // Temporary bridge - will be replaced in Phase 2
  return ref.watch(contactChooserViewBuilderProvider(spec));
}
```

---

### Decision 3: Resolver Output Types

**Context:** Resolvers need to return structured data that builders consume.

**Decision:** Each resolver returns a Freezed class specific to its content type.

**Rationale:**
- Type-safe interface between resolver and builder
- Enables testing resolvers independently
- Documents the contract clearly

**Example:**
```dart
@freezed
abstract class ChooserContent with _$ChooserContent {
  const factory ChooserContent({
    required PickerMode pickerMode,
    required List<ContactSummary> contacts,
    required List<RecentContact> recents,
    int? selectedContactId,
    required void Function(int) onContactSelected,
  }) = _ChooserContent;
}
```

---

### Decision 4: Builder vs Provider

**Context:** Should builders be Riverpod providers or plain functions?

**Decision:** Start with plain functions; promote to providers if state is needed.

**Rationale:**
- Builders are pure transformations (content → widget)
- No inherent need for provider features (caching, dependencies)
- Can always promote later if requirements change

---

## Open Questions

1. **Q: Should `recentContacts` reuse `ChooserContentResolver` or have its own?**
   - Likely reuse with a flag/variant
   - Decide during Phase 3 implementation

2. **Q: What happens to `application_pre_cassette/` folder?**
   - Audit during Phase 5
   - Move shared utilities; delete presentation builders

---

## Technical Notes

### Existing Widget Reuse

These presentation widgets remain unchanged:
- `ContactsFlatMenuCassette` — simple dropdown-style picker
- `ContactsEnhancedPickerCassette` — rich picker with search
- `ContactHeroSummaryCassette` — hero card display

Builders wrap these; they don't modify them.

### Loading States

Builders should handle loading via placeholder widgets:
```dart
if (content == null) {
  return SidebarCassetteCardViewModel(
    child: const SizedBox(
      height: 100,
      child: Center(child: CircularProgressIndicator.adaptive()),
    ),
  );
}
```

### Error States

Builders should handle errors gracefully:
```dart
Widget buildErrorCard(String message) {
  return SidebarCassetteCardViewModel(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('Error: $message'),
    ),
  );
}
```

---

## Migration Sequence Diagram

```
Before:
┌───────────────────────────────┐
│  CassetteWidgetCoordinator    │
│  (essentials)                 │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ FeatureCassetteSpecCoordinator│
│ (contacts feature_level)      │
└──────────────┬────────────────┘
               │ spec.map(...)
               ▼
┌───────────────────────────────┐
│ contactChooserViewBuilder     │
│ (use_cases) - BUILDS WIDGET   │
└───────────────────────────────┘

After:
┌───────────────────────────────┐
│  CassetteWidgetCoordinator    │
│  (essentials)                 │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ ContactsCassetteCoordinator   │
│ (spec_coordinators) - ROUTES  │
└──────────────┬────────────────┘
               │ switch(spec)
               ▼
┌───────────────────────────────┐
│ ChooserContentResolver        │
│ (spec_cases) - RESOLVES DATA  │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ ChooserWidgetBuilder          │
│ (spec_widget_builders) - UI   │
└───────────────────────────────┘
```

---

## References

- [InfoCassetteCoordinator](../../../../lib/features/contacts/application/spec_coordinators/info_cassette_coordinator.dart) — pattern reference
- [InfoContentResolver](../../../../lib/features/contacts/application/spec_cases/info_content_resolver.dart) — resolver pattern
- [03-feature-implementation-template.md](../../90-CROSS-SURFACE-SPEC-SYSTEMS/03-feature-implementation-template.md) — template
