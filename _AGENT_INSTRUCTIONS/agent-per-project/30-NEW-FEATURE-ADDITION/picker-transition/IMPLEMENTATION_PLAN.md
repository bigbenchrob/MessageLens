# Picker → Selection Control Transition: Implementation Plan

## Overview

This plan implements the perceptual continuity between the Contact Picker cassette and a new "Selection Control" cassette. The user experience goal is that the picker **collapses upward** into a compact control, with the Hero card sliding in beneath.

### Key Principle

> "The Contact Picker and the 'Change contact' control are implemented as separate cassettes, but their transition is animated to preserve perceptual continuity, making the latter feel like a collapsed state of the former."

---

## Current Architecture (Context)

### Cassette Flow Today
```
CassetteRackState                 CassetteWidgetCoordinator
      │                                    │
      ▼                                    ▼
[CassetteSpec.contacts(              Feature Coordinator
  ContactsCassetteSpec.contactChooser    │
)]                                        ▼
      │                               Resolver  
      │ (user selects contact)            │
      ▼                                   ▼
[CassetteSpec.contacts(              Widget Builder
  ContactsCassetteSpec.contactHeroSummary   
)]
```

### Current Contact Selection Behavior
1. User in `ContactsCassetteSpec.contactChooser(chosenContactId: null)`
2. User selects a contact
3. Spec replaced with `ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42)`
4. **Instant swap** — no animation, no transition

### Problem
The instant swap feels like a "page reset" rather than a continuous interaction.

---

## Target Architecture

### New Cassette Structure (Post-Selection)
```
┌─────────────────────────────────────┐
│  Selection Control Cassette         │  ← NEW: "Change contact" control
│  (compact, ~44px height)            │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  Hero Card Cassette                 │  ← Existing, identity context
│  (variable height)                  │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  Content Cassettes                  │  ← Existing (heat map, etc.)
│  (variable)                         │
└─────────────────────────────────────┘
```

### New Spec Variant
```dart
ContactsCassetteSpec.contactSelectionControl(
  chosenContactId: int,
)
```

This is a **distinct cassette** (not merged with Hero), because:
- It has different concerns (navigation vs. identity)
- It can be styled/positioned independently
- The Hero card remains focused on display, not actions

---

## Implementation Phases

### Phase 1: Create Selection Control Cassette (No Animation)

**Goal**: Implement the static Selection Control cassette and wire it into the spec system.

**Tasks**:

1. **Add spec variant** to `contacts_cassette_spec.dart`:
   ```dart
   const factory ContactsCassetteSpec.contactSelectionControl({
     required int chosenContactId,
   }) = _ContactSelectionControlSpec;
   ```

2. **Create resolver** `contact_selection_control_resolver.dart`:
   - Receives `contactId`, `cassetteIndex`
   - Returns `SidebarCassetteCardViewModel` with:
     - `title`: Selected contact name
     - `isControl: true` (compact styling)
     - `child`: `ContactSelectionControlWidget`

3. **Create widget builder** `contact_selection_control_widget.dart`:
   - Displays contact name + "Change" affordance
   - On tap: calls `replaceAtIndexAndCascade` with `contactChooser` spec
   - Uses `InteractiveHints` for hover effect

4. **Wire coordinator** to route `contactSelectionControl` → resolver

5. **Update cascade logic** to produce:
   ```
   contactSelectionControl(id) → contactHeroSummary(id) → [content cassettes]
   ```

6. **Update contact selection** in picker widgets to emit `contactSelectionControl` instead of `contactHeroSummary` as the root spec

**Validation**: Contact selection shows Selection Control + Hero Card stacked, with "Change" button working.

---

### Phase 2: Animated Cassette Container Wrapper

**Goal**: Create an animation wrapper that can animate cassette height changes.

**Rationale**: The animation lives at the **presentation layer**, wrapping cassette widgets. This keeps feature coordinators animation-unaware.

**Tasks**:

1. **Create** `AnimatedCassetteSlot` widget in `essentials/sidebar/presentation/`:
   ```dart
   class AnimatedCassetteSlot extends StatefulWidget {
     const AnimatedCassetteSlot({
       required this.child,
       required this.slotKey,
       this.animateSizeChanges = true,
     });
     
     final Widget child;
     final Key slotKey;
     final bool animateSizeChanges;
   }
   ```
   - Uses `AnimatedSize` or custom `TweenAnimationBuilder` for height
   - Anchors animation to **top edge** (bottom animates up/down)
   - Duration: 200-250ms, curve: `Curves.easeOutCubic`

2. **Integrate** into `_LeftSidebarSurface`:
   - Wrap each cassette widget in `AnimatedCassetteSlot`
   - Use cassette index or spec type as key for identity

3. **Handle slot addition/removal**:
   - New slots animate in (height 0 → full)
   - Removed slots animate out (full → 0)

**Validation**: Add/remove cassettes shows smooth height animation.

---

### Phase 3: Picker Collapse Animation

**Goal**: When contact selected, picker collapses from bottom-to-top.

**Tasks**:

1. **Add transition state** to cassette system:
   - Track "outgoing" cassettes that should animate out
   - New type: `CassetteTransition { outgoing: List<CassetteSpec>, incoming: List<CassetteSpec> }`

2. **Modify** `_LeftSidebarSurface` to handle transition state:
   - Render both outgoing (collapsing) and incoming (expanding) during transition
   - Outgoing widgets receive `isExiting: true` flag

3. **Picker content transition**:
   - On `isExiting: true`, picker content fades out
   - Container height animates to 0
   - After animation completes, remove from DOM

4. **Timing orchestration**:
   - Picker collapse begins immediately on selection
   - Selection Control fades in after ~50ms delay
   - Hero Card slides in from below as picker shrinks

**Validation**: Selecting a contact shows smooth upward collapse of picker.

---

### Phase 4: Selection Control Entrance Animation

**Goal**: Selection Control appears to emerge from the collapsing picker.

**Tasks**:

1. **Position continuity**:
   - Selection Control renders at the same top position as the picker
   - Left edge alignment matches picker's content padding

2. **Entrance animation**:
   - Opacity: 0 → 1 over 150ms (starts ~50ms after picker collapse begins)
   - Height: animates from 0 → full height
   - Content appears settled before picker fully collapses

3. **Visual rhythm**:
   - Match horizontal padding with picker
   - Use same surface treatment (card background, shadow)

**Validation**: Selection Control appears to "crystallize" at the top as picker collapses.

---

### Phase 5: Reverse Transition (Change → Picker)

**Goal**: Clicking "Change" on Selection Control expands the picker back.

**Tasks**:

1. **Inverse animation**:
   - Selection Control fades out + collapses to 0 height
   - Picker expands downward from top anchor
   - Hero Card and content slide out below

2. **Entrance timing**:
   - Selection Control begins collapsing immediately
   - Picker content fades in as height expands
   - Final height matches available sidebar space

3. **State preservation**:
   - Consider: should picker remember scroll position?
   - Consider: should picker remember search query?
   - Default: reset to fresh state (user is making a new choice)

**Validation**: Clicking "Change" shows smooth downward expansion of picker.

---

### Phase 6: Polish and Edge Cases

**Goal**: Handle all edge cases and refine animation feel.

**Tasks**:

1. **Loading states**:
   - If contact data is loading, delay animation start?
   - Or: animate with placeholder, then populate

2. **Interruption handling**:
   - User clicks "Change" during collapse animation
   - Reverse animation mid-flight gracefully

3. **Reduced motion**:
   - Respect `MediaQuery.disableAnimations`
   - Fall back to instant transitions

4. **Theme integration**:
   - Animation durations from theme tokens?
   - Or: hardcoded with clear documentation

5. **Performance audit**:
   - Ensure no jank during animation
   - Profile on target hardware

**Validation**: All transitions feel polished and handle edge cases.

---

## File Structure (New/Modified)

```
lib/features/contacts/
├── domain/spec_classes/
│   └── contacts_cassette_spec.dart           # ✏️ Add contactSelectionControl
│
├── application/sidebar_cassette_spec/
│   ├── coordinators/
│   │   └── cassette_coordinator.dart         # ✏️ Route new spec
│   ├── resolvers/
│   │   └── contact_selection_control_resolver.dart  # 🆕
│   └── widget_builders/
│       └── contact_selection_control_widget.dart    # 🆕

lib/essentials/sidebar/
├── application/
│   └── cassette_transition_state_provider.dart      # 🆕 (Phase 3)
│
├── presentation/
│   ├── animated_cassette_slot.dart                  # 🆕 (Phase 2)
│   └── view/
│       └── _left_sidebar_surface.dart               # ✏️ Wrap with animation
```

---

## Success Criteria

| Criteria | Validation |
|----------|------------|
| Selection Control displays after picker | Visual check |
| "Change" returns to picker | Functional test |
| Picker collapses upward on selection | Animation visual check |
| Selection Control emerges at top | Animation visual check |
| Hero Card slides in below | Animation visual check |
| Reverse animation mirrors forward | Animation visual check |
| No widget tree errors | `flutter analyze` clean |
| Reduced motion respected | Test with accessibility setting |

---

## Open Questions (For Discussion)

1. **Animation duration**: 200ms? 250ms? Should collapse and expand be same duration?

2. **Stagger timing**: How much delay between picker collapse start and Selection Control fade-in? (Spec says 50-100ms)

3. **Picker state on return**: Fresh state or preserve scroll/search?

4. **Content cassettes**: Should they animate in staggered, or all at once with Hero?

5. **Keyboard navigation**: Tab order during transition?

---

## Recommended Phase Order

**Start with Phase 1** (static cassette) because:
- Validates the spec design and cascade logic
- Provides testable foundation
- No animation complexity yet
- Allows iteration on layout before adding motion

Then proceed sequentially through Phases 2-6.

---

## References

- [seed.txt](./seed.txt) — Original interaction spec
- [00-cross-surface-spec-system.md](../../90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md) — Coordinator/Resolver/Builder contracts
- [01-cassette-system-architecture.md](../../70-CASSETTE-CONTENT-CONTROL/01-cassette-system-architecture.md) — Cassette rack state management
