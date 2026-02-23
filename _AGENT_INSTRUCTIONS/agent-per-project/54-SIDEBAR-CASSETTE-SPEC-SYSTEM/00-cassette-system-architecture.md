# Sidebar Cassette System Architecture

## Overview

The sidebar displays a vertical stack of **cassettes** — self-contained cards
that each show feature-specific content. The sidebar supports multiple modes
(`SidebarMode.messages`, `SidebarMode.settings`) with different initial stacks.

The system has four layers:
1. **Rack state** — what specs should be displayed, in what order
2. **Cascade** — how selecting something in one cassette determines the next
3. **Coordinator dispatch** — routing each spec to the owning feature
4. **Card chrome** — wrapping feature content in visual card containers

---

## 1. CassetteSpec — The Top-Level Sealed Class

`CassetteSpec` is a freezed sealed class with one variant per feature (or feature surface):

```dart
@freezed
abstract class CassetteSpec with _$CassetteSpec {
  const factory CassetteSpec.sidebarUtility(SidebarUtilityCassetteSpec spec) = ...;
  const factory CassetteSpec.presentation(PresentationCassetteSpec spec) = ...;
  const factory CassetteSpec.contacts(ContactsCassetteSpec spec) = ...;
  const factory CassetteSpec.contactsSettings(ContactsSettingsSpec spec) = ...;
  const factory CassetteSpec.contactsInfo(ContactsInfoCassetteSpec spec) = ...;
  const factory CassetteSpec.handles(HandlesCassetteSpec spec) = ...;
  const factory CassetteSpec.handlesInfo(HandlesInfoCassetteSpec spec) = ...;
  const factory CassetteSpec.messages(MessagesCassetteSpec spec) = ...;
}
```

Each variant wraps a **feature-specific inner spec** that the feature alone defines
and interprets. The inner spec is domain data living in the feature's
`domain/spec_classes/` folder.

**Location:** `lib/essentials/sidebar/domain/entities/cassette_spec.dart`

---

## 2. Rack State

The **rack** is an ordered, immutable list of `CassetteSpec` objects representing
what the sidebar currently shows:

```dart
@freezed
abstract class CassetteRack with _$CassetteRack {
  const factory CassetteRack({
    @Default(<CassetteSpec>[]) List<CassetteSpec> cassettes,
  }) = _CassetteRack;
}
```

The `CassetteRackState` provider manages the rack per `SidebarMode`:

```dart
@riverpod
class CassetteRackState extends _$CassetteRackState {
  @override
  CassetteRack build(SidebarMode mode) { ... }  // Returns initial rack for mode
}
```

### Initial stacks

- **Messages mode**: Starts with `SidebarUtilityCassetteSpec.topChatMenu()`, then
  cascades automatically to contacts → messages cassettes
- **Settings mode**: Starts with `SidebarUtilityCassetteSpec.settingsMenu()`, then
  cascades to settings-specific cassettes

### Rack mutations

The rack state provider exposes methods for modifying the stack:

| Method | Purpose |
|---|---|
| `replaceAtIndexAndCascade(index, newSpec)` | Replace a cassette and re-cascade everything below it |
| `truncateAfter(index)` | Remove all cassettes after a given position |
| `pushCassette(spec)` | Append a cassette to the end |
| `updateCassetteAt(index, update)` | Transform a cassette in place |
| `resetToInitial()` | Return to the mode's initial state |

**Location:** `lib/essentials/sidebar/application/cassette_rack_state_provider.dart`

---

## 3. Cascade System

When a cassette is placed or updated, the system needs to determine what cassettes
should appear **below** it. This is the cascade.

### How it works

Every `CassetteSpec` has a `childSpec()` extension method that returns the next
spec in the chain (or `null` to end the chain):

```dart
extension CassetteSpecX on CassetteSpec {
  CassetteSpec? childSpec() => resolveCassetteChild(this);
}
```

`resolveCassetteChild()` dispatches to per-feature **topology extensions** via
`spec.when(...)`. Each feature's inner spec type also exposes a `childSpec()`
method defining what comes next.

### Topology files

Each feature that participates in cascading has a topology file:

```
lib/essentials/sidebar/domain/entities/cascade/
├── cassette_child_resolver.dart       ← top-level dispatcher
├── sidebar_utility_topology.dart      ← SidebarUtilityCassetteSpec cascades
├── contacts_cassette_topology.dart    ← ContactsCassetteSpec cascades
├── contacts_info_topology.dart
├── contacts_settings_topology.dart
├── handles_cassette_topology.dart
├── handles_info_topology.dart
├── messages_cassette_topology.dart
└── links/
    ├── contacts_to_messages.dart      ← cross-feature: contacts → messages
    └── sidebar_utility_to_contacts.dart  ← cross-feature: utility → contacts
```

### Cross-feature links

When a cascade needs to cross a feature boundary (e.g., selecting a contact should
show that contact's messages below), the link files in `cascade/links/` define the
transition. These are the **only** place where one feature's spec type connects to
another's.

### Cascade on rack mutation

When `replaceAtIndexAndCascade()` is called, the rack state provider:
1. Replaces the spec at the given index
2. Calls `childSpec()` repeatedly to build the cascade chain
3. Replaces everything below the index with the new chain

---

## 4. CassetteWidgetCoordinator — App-Level Dispatch

The `CassetteWidgetCoordinator` is the app-level async provider that transforms
the rack into rendered widgets:

```dart
@riverpod
class CassetteWidgetCoordinator extends _$CassetteWidgetCoordinator {
  @override
  Future<List<Widget>> build(SidebarMode mode) async { ... }
}
```

### What it does

1. **Watches** `cassetteRackStateProvider(mode)` — rebuilds when rack changes
2. **Iterates** each `CassetteSpec` in the rack
3. **Routes** each spec to the owning feature's coordinator via `spec.when(...)`:
   ```dart
   spec.when(
     contacts: (innerSpec) => ref
       .read(contacts_feature.contactsCassetteCoordinatorProvider.notifier)
       .buildViewModel(innerSpec, cassetteIndex: i),
     messages: (innerSpec) => ref
       .read(messages_feature.messagesCassetteCoordinatorProvider.notifier)
       .buildViewModel(innerSpec, cassetteIndex: i),
     // ... one branch per CassetteSpec variant
   );
   ```
4. **Awaits** the returned `Future<SidebarCassetteCardViewModel>` from each feature
5. **Wraps** the view model in the appropriate card widget based on `cardType`:
   - `CassetteCardType.standard` → `SidebarCassetteCard`
   - `CassetteCardType.info` → `SidebarInfoCard`
   - `CassetteCardType.sidebarNavigation` → `SidebarNavigationCard`
6. **Returns** `List<Widget>` — the fully composed sidebar

### Feature import pattern

The coordinator imports each feature via its barrel with an alias:

```dart
import '.../features/contacts/feature_level_providers.dart' as contacts_feature;
import '.../features/messages/feature_level_providers.dart' as messages_feature;
import '.../features/handles/feature_level_providers.dart' as handles_feature;
```

This prevents provider name collisions and enforces the barrel-only import rule.

**Location:** `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart`

---

## 5. SidebarCassetteCardViewModel

The single canonical payload that every feature coordinator returns:

```dart
class SidebarCassetteCardViewModel {
  const SidebarCassetteCardViewModel({
    required this.title,
    this.subtitle,
    this.sectionTitle,
    this.footerText,
    required this.child,            // The feature-owned widget content
    this.cardType = CassetteCardType.standard,
    this.layoutStyle = SidebarCardLayoutStyle.standard,
    this.infoBodyText,
    this.infoAction,
    this.isControl = false,
    this.isNaked = false,
    bool? shouldExpand,
  });
}
```

### Key fields

| Field | Purpose |
|---|---|
| `title` | Card header text |
| `subtitle` | Optional secondary text in header |
| `child` | The feature's widget (a widget builder output) |
| `cardType` | Determines which card chrome is used |
| `layoutStyle` | Controls horizontal rails (margin/padding/gaps) |
| `isControl` | When true, card is a navigation control (non-expanding) |
| `isNaked` | When true, card has no chrome at all |
| `shouldExpand` | Whether card fills available vertical space |

The resolver decides all field values. The app-level coordinator reads `cardType`
to choose the card widget. The card widget renders the chrome and slots in `child`.

**Location:** `lib/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart`

---

## 6. Card Widgets (Chrome)

Three card widgets correspond to `CassetteCardType`:

| Card type | Widget | Purpose |
|---|---|---|
| `standard` | `SidebarCassetteCard` | Standard cassette with title, optional subtitle/footer, expandable body |
| `info` | `SidebarInfoCard` | Informational card with body text and optional action widget |
| `sidebarNavigation` | `SidebarNavigationCard` | Navigation control card (compact, non-expanding) |

These are **essentials-owned** presentation widgets. Features never construct or
return these cards — they return a `SidebarCassetteCardViewModel` and the
coordinator wraps it.

---

## 7. View Model → Widget Translation and Expandability

The `CassetteWidgetCoordinator` translates each `SidebarCassetteCardViewModel`
into a card widget. This section documents exactly how VM properties map to
widget behaviour, with particular focus on vertical sizing.

### 7a. Card Type Routing

The coordinator switches on `cardType` to select the chrome widget:

| `cardType` | Widget created | VM properties forwarded |
|---|---|---|
| `.standard` | `SidebarCassetteCard` | `title`, `subtitle`, `sectionTitle`, `footerText`, `isControl`, `isNaked`, **`shouldExpand`**, **`layoutStyle`**, `child` |
| `.info` | `SidebarInfoCard` | `title` (if non-empty), `infoBodyText` → body, `footerText` → footnote, `infoAction` → action |
| `.sidebarNavigation` | `SidebarNavigationCard` | `child` only |

**Key detail:** Only `SidebarCassetteCard` receives `shouldExpand`. The other two
card types are always intrinsic-height — `shouldExpand` on the VM is irrelevant
for `.info` and `.sidebarNavigation` cards.

### 7b. Sidebar Surface Layout (`_LeftSidebarSurface`)

The sidebar surface in `panel_widget_providers.dart` sorts cassette widgets into
two zones:

**Controls zone** (pinned at top, never expands):
- Any `SidebarCassetteCard` where `isControl == true` or `isNaked == true`
- Rendered as individual `SliverToBoxAdapter` widgets — always intrinsic height

**Content zone** (remaining cards):
- Everything that isn't a control
- Each widget is tagged with a `shouldExpand` value extracted per type:
  - `SidebarCassetteCard` → reads the widget's own `shouldExpand` field
  - All other widget types → `false`

### 7c. Expansion Strategy

The content zone uses a **conditional layout strategy** based on whether any
content item needs to expand:

**When any content item has `shouldExpand: true`:**
All content items are placed in a single `SliverFillRemaining(hasScrollBody: true)`
containing a `_ContentFillColumn`. Inside that column:
- Expanding items are wrapped in `Expanded` — they share remaining space equally
- Non-expanding items sit at intrinsic height

**When no content items want to expand:**
Each content item is individually wrapped in a `SliverToBoxAdapter` — all cards
render at their intrinsic height. No vertical space filling occurs.

This means a single info card alone in the sidebar will **not** stretch to fill
the viewport — it will sit at its natural height.

### 7d. Inner Card Expansion (`SidebarCassetteCard`)

`SidebarCassetteCard` has its own internal expansion logic using `LayoutBuilder`:

```dart
if (hasBoundedHeight && shouldExpand)
  Expanded(child: body)
else
  body
```

This is defensive: if the card somehow receives unbounded height constraints
(e.g., placed in a `SliverToBoxAdapter`), it won't use `Expanded` even if
`shouldExpand: true`, avoiding layout errors. The bounded-height check acts as
a safety net.

### 7e. Expandability Defaults — Opt-In System

`SidebarCassetteCardViewModel` defaults `shouldExpand` to **`false`**. Cards
are intrinsic-height unless the resolver explicitly opts in:

```dart
// Scrollable list — needs vertical space:
SidebarCassetteCardViewModel(
  title: 'Contacts',
  shouldExpand: true,  // explicit opt-in
  child: ContactFlatListWidget(...),
);

// Info card — fixed content:
SidebarCassetteCardViewModel(
  title: 'Contact Names',
  // shouldExpand defaults to false — no override needed
  child: ContactDisplayNameInfoCassette(),
);
```

**Rule of thumb:** Set `shouldExpand: true` only for cards whose child widget
contains a scrollable list or other content that meaningfully benefits from
filling available space. All other cards (info text, summaries, heatmaps,
controls) should leave the default.

### 7f. Complete Height Constraint Flow

```
Resolver sets shouldExpand on VM
    │
    ▼
CassetteWidgetCoordinator
    ├─ standard → SidebarCassetteCard(shouldExpand: vm.shouldExpand)
    ├─ info → SidebarInfoCard (always intrinsic, mainAxisSize: min)
    └─ nav → SidebarNavigationCard (always intrinsic)
    │
    ▼
_LeftSidebarSurface sorts widgets
    ├─ Controls (naked/isControl) → SliverToBoxAdapter → intrinsic
    └─ Content → tagged with shouldExpand per widget type
        │
        ├─ Any expanding? → SliverFillRemaining → _ContentFillColumn
        │    ├─ shouldExpand: true items → Expanded (share remaining space)
        │    └─ shouldExpand: false items → intrinsic
        │
        └─ None expanding? → individual SliverToBoxAdapter → all intrinsic
            │
            ▼
SidebarCassetteCard.build (inner LayoutBuilder)
    ├─ hasBoundedHeight && shouldExpand → Expanded(child: body)
    └─ else → body at intrinsic height
```

---

## 8. Card Configuration Patterns

This section provides guidance for choosing the right card configuration based on
the cassette's purpose and content characteristics.

### 8a. Card Types (`CassetteCardType`)

The `cardType` determines which **chrome widget** wraps the content:

| Type | When to use | Example cassettes |
|---|---|---|
| `standard` | Interactive content, lists, forms, data displays | Contact lists, message threads, stray handles review |
| `info` | Explanatory text, onboarding, contextual help | "Why am I seeing this?", feature explanations |
| `sidebarNavigation` | Navigation controls to return to previous states | "Back to all contacts" strip |

**Default:** Most cassettes use `standard`. Use `info` sparingly for educational
content. Use `sidebarNavigation` only for drill-down escape hatches.

### 8b. Layout Styles (`SidebarCardLayoutStyle`)

The `layoutStyle` controls **horizontal rails** (margin, padding, section gaps)
without changing the card's structural behavior:

| Style | Horizontal inset | Section gap | When to use |
|---|---|---|---|
| `standard` | 32pt (16pt margin + 16pt padding) | 8pt | Most cassettes, moderate content density |
| `listDense` | 12pt (0pt margin + 12pt padding) | 4pt | Space-sensitive scrollable lists |

**Use `listDense` when:**
- The cassette contains a scrollable list with per-row metadata
- Rows have overlaid action buttons (e.g., dismiss/restore) that need gutter space
- Long text values (phone numbers, email addresses) need horizontal room
- You want dividers and content edges to align tightly

**Layout values (AppSpacing reference):**
- `standard`: margin=`(v: sm=8, h: md=16)`, padding=`all(md=16)`, sectionTitleGap=`sm=8`
- `listDense`: margin=`(v: xs=4, h: 0)`, padding=`(h: 12, v: sm=8)`, sectionTitleGap=`xs=4`

### 8c. Behavioral Flags

#### `isControl`

Marks the cassette as a **navigation control** rather than content:
- Pinned in the "controls zone" at the top of the sidebar
- Never expands vertically
- Receives reduced visual emphasis (tighter margins)

**Use for:** Menu selectors, mode switchers, filter dropdowns.

#### `isNaked`

Removes **all card chrome** — no title, no padding structure:
- Only horizontal margin remains (to align with card edges)
- Child widget owns all padding, typography, and interaction

**Use for:** Dropdowns, popup menus, and controls that should align flush with
the sidebar edge and need full control over their layout.

#### `shouldExpand`

Opts the card into **vertical space filling**:
- When `true`, card expands to fill remaining sidebar height
- When `false` (default), card takes intrinsic height
- Only meaningful for `CassetteCardType.standard`

**Use for:** Scrollable lists that should fill available space (contact lists,
message threads, stray handles review). Leave `false` for fixed-height content
(info cards, summaries, heatmaps).

### 8d. Decision Matrix

| Cassette purpose | `cardType` | `layoutStyle` | `isControl` | `isNaked` | `shouldExpand` |
|---|---|---|---|---|---|
| Scrollable contact/message list | `standard` | `standard` | `false` | `false` | `true` |
| Dense list with action overlays | `standard` | `listDense` | `false` | `false` | `true` |
| Menu/filter dropdown | `standard` | `standard` | `true` | `true` | `false` |
| Mode switcher popup | `standard` | `standard` | `true` | `true` | `false` |
| Explanatory help text | `info` | — | `false` | `false` | `false` |
| "Back to X" navigation strip | `sidebarNavigation` | — | `false` | `false` | `false` |
| Summary statistics card | `standard` | `standard` | `false` | `false` | `false` |

### 8e. Action Gutter Pattern

For lists with per-row action buttons (dismiss, restore, etc.), use the
**action gutter** pattern:

1. Define a fixed `actionGutterWidth` constant (e.g., 32pt)
2. Apply as right padding to the data content — data never overlaps action area
3. Position action buttons as overlays anchored at `right: 0`
4. Set divider `endIndent` to `actionGutterWidth` — dividers stop at data boundary
5. Non-actionable rows leave gutter empty but still reserve the space

This keeps action buttons vertically aligned in a dedicated column, visually
separate from the data region.

```dart
// Example: Stray handles review cassette
static const double actionGutterWidth = 32;

// Row data padding
Padding(
  padding: const EdgeInsets.only(right: actionGutterWidth),
  child: Row(children: [/* data content */]),
)

// Divider stops at data boundary
Divider(endIndent: actionGutterWidth)

// Action button overlay
Positioned(
  right: 0,
  top: 0,
  bottom: 2,  // nudge up to align with metadata cluster
  child: Center(child: DismissButton()),
)
```

---

## 9. Sidebar Rendering

The `leftPanelWidget()` provider in `lib/essentials/navigation/application/panel_widget_providers.dart`:
1. Watches `cassetteWidgetCoordinatorProvider(mode)`
2. Uses stale-while-revalidate: shows previous widgets while new ones load
3. Wraps the widget list in `_LeftSidebarSurface` (padding, scroll, layout)

---

## Complete Data Flow

```
SidebarMode
    │
    ▼
CassetteRackState.build(mode)
    │  produces initial CassetteRack via cascade
    ▼
CassetteRack.cassettes  →  [CassetteSpec, CassetteSpec, ...]
    │
    ▼
CassetteWidgetCoordinator.build(mode)
    │  iterates each CassetteSpec
    │  routes to feature coordinator via spec.when(...)
    │
    ├──→ Feature coordinator.buildViewModel(innerSpec, cassetteIndex)
    │       │  pattern-matches inner spec
    │       │  calls resolver with explicit params
    │       │
    │       ├──→ Resolver.resolve(...)
    │       │       │  domain logic, data lookups
    │       │       │  constructs widget via widget builder
    │       │       │  returns Future<SidebarCassetteCardViewModel>
    │       │       ▼
    │       │    SidebarCassetteCardViewModel
    │       ▼
    │    Future<SidebarCassetteCardViewModel>
    │
    ▼
CassetteWidgetCoordinator wraps VM in card widget
    │  standard → SidebarCassetteCard
    │  info     → SidebarInfoCard
    │  sidebarNavigation → SidebarNavigationCard
    │
    ▼
List<Widget>  →  leftPanelWidget()  →  _LeftSidebarSurface  →  UI
```
