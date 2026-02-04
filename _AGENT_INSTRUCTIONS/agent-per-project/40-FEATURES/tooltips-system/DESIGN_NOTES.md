# Tooltips System - Design Notes

**Last Updated:** 2026-02-04

---

## Architectural Decisions

### AD-001: Parallel Cassette Architecture

**Decision:** Mirror the sidebar cassette spec system with coordinators, resolvers, and widget builders.

**Rationale:**
- Proven pattern in the codebase
- Familiar to agents and developers
- Clear separation: essentials coordinates, features own content
- Enables future expansion without architectural changes

**Trade-offs:**
- More files than a simple tooltip helper
- Worth it for consistency and scalability

---

### AD-002: Spec-Based Content Ownership

**Decision:** Each feature defines tooltip content via enum keys, similar to info cassette specs.

**Rationale:**
- Feature owns its strings (could be localized later)
- Coordinator doesn't hardcode string content
- Easy to audit all tooltips per feature

**Implementation:**
```dart
// Feature defines the keys
enum ContactsTooltipKey {
  editDisplayName,
  changeContact,
}

// Resolver maps keys to content
String resolve(ContactsTooltipKey key) => switch (key) {
  ContactsTooltipKey.editDisplayName => 'Edit display name',
  ContactsTooltipKey.changeContact => 'Choose a different contact',
};
```

---

### AD-003: Tooltip Presentation Strategy

**Decision:** Use Flutter's built-in `Tooltip` widget.

**Rationale:**
- Simplest implementation - built-in, accessible
- Auto-handles positioning, show/hide debounce
- Good enough for v1; can customize later if needed
- Cross-platform consistent (though not macOS-native)

**Trade-off accepted:** Material styling rather than macOS-native appearance. Future enhancement could add custom decoration.

---

### AD-004: Hover Behavior

**Decision:** 
- Show delay: 500ms (half second)
- Position: Prefer above target, auto-reposition if no room
- Animation: None initially (can add later)

**Rationale:**
- 500ms feels natural - not immediate (startling) but not slow
- Above position feels more desktop-like than below
- Keeping it simple for v1

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     TooltipWrapper Widget                        │
│  (Receives TooltipSpec, wraps child, manages hover state)       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ on hover (after delay)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TooltipCoordinator                            │
│  (Pattern matches spec → routes to feature coordinator)         │
└─────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ ContactsTooltip │  │ MessagesTooltip │  │     Future      │
│   Coordinator   │  │   Coordinator   │  │    Features     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ContactsTooltipResolver                        │
│  (Maps ContactsTooltipKey → TooltipContent)                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      TooltipContent                              │
│  { text: "Edit display name", position?: below }                │
└─────────────────────────────────────────────────────────────────┘
```

---

## File Structure (Final)

```
lib/
├── essentials/
│   └── tooltips/
│       ├── domain/
│       │   └── entities/
│       │       ├── tooltip_spec.dart           # Sealed spec class
│       │       └── tooltip_content.dart        # Resolved content model
│       ├── application/
│       │   └── tooltip_coordinator.dart        # Routes to features
│       ├── presentation/
│       │   └── tooltip_wrapper.dart            # Hover widget
│       └── feature_level_providers.dart
│
└── features/
    └── contacts/
        ├── application/
        │   └── tooltips_spec/
        │       ├── coordinators/
        │       │   └── contacts_tooltip_coordinator.dart
        │       └── resolvers/
        │           └── contacts_tooltip_resolver.dart
        └── domain/
            └── spec_classes/
                └── contacts_tooltip_spec.dart
```

---

## Open Questions Log

| # | Question | Status | Resolution |
|---|----------|--------|------------|
| 1 | macOS native vs custom overlay? | ✅ Resolved | Use Flutter `Tooltip` widget |
| 2 | Hover delay duration? | ✅ Resolved | 500ms default, configurable |
| 3 | Tooltip positioning strategy? | ✅ Resolved | Auto-positioning (Flutter default) |
| 4 | Should tooltips have animations? | ✅ Resolved | Leave space for later, none initially |

---

## References

- Cross-surface spec system: `_AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md`
- Sidebar cassette coordinator: `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart`
- Contacts cassette coordinator: `lib/features/contacts/application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart`
