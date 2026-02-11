# Tooltips System - Feature Proposal

**Status:** ✅ Approved  
**Author:** Agent  
**Date:** 2026-02-04  
**Branch:** `Ftr.tooltip`  

---

## Summary

Build a tooltips system that parallels the sidebar cassette architecture, with feature-level coordinators, resolvers, and widget builders. This enables consistent, spec-driven tooltip display throughout the app while keeping tooltip content ownership within features.

## Motivation

1. **Hero card edit trigger** - Change from "edit" text link to a pen icon, requiring a tooltip to communicate the action on hover
2. **Consistent tooltip UX** - Establish a pattern for tooltips app-wide
3. **Feature ownership** - Each feature defines its own tooltip content via enum keys, following the info-cassette pattern
4. **Separation of concerns** - Tooltip presentation logic lives in essentials; content decisions live in features

## Goals

- [ ] Create `lib/essentials/tooltips/` with non-feature-specific coordination
- [ ] Define a `TooltipSpec` sealed class with feature-specific variants
- [ ] Enable features to define tooltip enums for their content
- [ ] Implement feature-level coordinator → resolver → widget builder flow
- [ ] First use case: Hero card name edit icon with "Edit display name" tooltip
- [ ] Support hover-triggered display with configurable delay
- [ ] macOS-native appearance (system tooltip style or close facsimile)

## Non-Goals

- Complex rich-content tooltips (images, interactive elements)
- Tooltip positioning customization beyond standard anchor points
- Accessibility announcements (future enhancement)
- Touch device support (macOS-only app)

## Proposed Architecture

```
lib/
├── essentials/
│   └── tooltips/
│       ├── domain/
│       │   └── entities/
│       │       └── tooltip_spec.dart          # TooltipSpec sealed class
│       ├── application/
│       │   └── tooltip_coordinator.dart       # Routes specs to features
│       ├── presentation/
│       │   └── tooltip_wrapper.dart           # Hover-triggered tooltip widget
│       └── feature_level_providers.dart
│
├── features/
│   └── contacts/
│       └── application/
│           └── tooltips_spec/
│               ├── coordinators/
│               │   └── contacts_tooltip_coordinator.dart
│               ├── resolver_tools/
│               │   └── (shared utilities if needed)
│               ├── resolvers/
│               │   └── contacts_tooltip_resolver.dart
│               └── widget_builders/
│                   └── (if tooltips need custom widgets)
│       └── domain/
│           └── spec_classes/
│               └── contacts_tooltip_spec.dart  # Enum keys for contact tooltips
```

## Spec Design

```dart
// lib/essentials/tooltips/domain/entities/tooltip_spec.dart
@freezed
sealed class TooltipSpec with _$TooltipSpec {
  /// Contacts feature tooltips
  const factory TooltipSpec.contacts(ContactsTooltipSpec spec) = ContactsTooltip;
  
  /// Messages feature tooltips (future)
  const factory TooltipSpec.messages(MessagesTooltipSpec spec) = MessagesTooltip;
  
  // ... other features as needed
}

// lib/features/contacts/domain/spec_classes/contacts_tooltip_spec.dart
enum ContactsTooltipKey {
  editDisplayName,
  changeContact,
  // ... future keys
}

@freezed
sealed class ContactsTooltipSpec with _$ContactsTooltipSpec {
  const factory ContactsTooltipSpec.simple({
    required ContactsTooltipKey key,
  }) = ContactsTooltipSimple;
}
```

## Widget Integration

```dart
// Usage in hero card
TooltipWrapper(
  spec: TooltipSpec.contacts(
    ContactsTooltipSpec.simple(key: ContactsTooltipKey.editDisplayName),
  ),
  child: IconButton(
    icon: Icon(CupertinoIcons.pencil),
    onPressed: onEdit,
  ),
)
```

## Resolution Flow

1. `TooltipWrapper` receives a `TooltipSpec`
2. On hover, calls `TooltipCoordinator.resolve(spec)`
3. Coordinator pattern-matches spec → routes to feature coordinator
4. Feature coordinator → resolver → returns tooltip text/config
5. `TooltipWrapper` displays the resolved content

## Open Questions (Resolved)

1. **macOS native vs custom?** - ✅ **Use Flutter `Tooltip` widget** (simplest approach)
2. **Delay configuration** - ✅ **Global default (500ms)** configurable in essentials/tooltips
3. **Positioning** - ✅ **Auto-positioning** (Flutter Tooltip default)
4. **Animation** - ✅ **Leave space for later** (no custom animation initially)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Over-engineering for one icon | Keep minimal; infrastructure pays off as tooltips spread |
| Tooltip flicker on fast mouse movement | Debounce hover events |
| Conflicts with macOS system tooltips | Override accessibility tooltip attribute |

## Dependencies

- Freezed (already in project)
- Riverpod (already in project)
- Theme colors provider (for consistent styling)

## Effort Estimate

| Phase | Effort |
|-------|--------|
| Essentials scaffolding | ~2 hours |
| Contacts feature integration | ~1 hour |
| Hero card update | ~30 min |
| Testing & polish | ~1 hour |
| **Total** | **~4-5 hours** |

---

## Approval

**Please review and approve/request changes before implementation begins.**
