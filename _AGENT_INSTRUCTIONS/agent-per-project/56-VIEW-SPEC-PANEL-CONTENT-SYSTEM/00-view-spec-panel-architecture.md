# View Spec Panel Architecture

## Overview

The panel content system manages what appears in the **center** and **right** panels
of the macOS window. It uses sealed `ViewSpec` types, a stack-based page model,
and feature coordinators that return widgets synchronously.

---

## 1. ViewSpec — The Top-Level Sealed Class

`ViewSpec` has one variant per feature (or system surface):

```dart
@freezed
abstract class ViewSpec with _$ViewSpec {
  const factory ViewSpec.messages(MessagesSpec spec) = _ViewMessages;
  const factory ViewSpec.chats(ChatsSpec spec) = _ViewChats;
  const factory ViewSpec.contacts(ContactsSpec spec) = _ViewContacts;
  const factory ViewSpec.import(ImportSpec spec) = _ViewImport;
  const factory ViewSpec.settings(SettingsSpec spec) = _ViewSettings;
  const factory ViewSpec.workbench(WorkbenchSpec spec) = _ViewWorkbench;
}
```

Each variant wraps a **feature-specific spec** that only the feature interprets.

**Location:** `lib/essentials/navigation/domain/entities/view_spec.dart`

### Feature spec examples

**MessagesSpec** (7 variants):
`forChat`, `forContact`, `globalTimeline`, `globalTimelineV2`, `forHandle`,
`handleLens`, `forChatInDateRange`

**Location:** `lib/features/messages/domain/spec_classes/messages_view_spec.dart`
(re-exported via `lib/essentials/navigation/feature_level_providers.dart`)

Other feature specs (`ChatsSpec`, `ContactsSpec`, `ImportSpec`, `SettingsSpec`,
`WorkbenchSpec`) are in `lib/essentials/navigation/domain/entities/features/`.

---

## 2. Panel Stack — Page Model

Each panel maintains a **stack of pages**, supporting push/pop/tab behavior:

```dart
class PanelPage {
  final String id;        // Unique page ID (auto-generated)
  final ViewSpec spec;    // What this page displays
  final String title;     // Page title (for tabs)
  final bool isClosable;  // Whether user can close this page
}

class PanelStack {
  final List<PanelPage> pages;
  final int activeIndex;  // Which page is currently visible
}
```

`PanelStack` is immutable with methods: `replaceWithSingle()`, `push()`,
`activate()`, `pop()`, `removeAt()`.

**Location:** `lib/essentials/navigation/domain/entities/panel_stack.dart`

---

## 3. PanelsViewState — State Management

The `PanelsViewState` provider manages panel stacks per `SidebarMode`:

```dart
@riverpod
class PanelsViewState extends _$PanelsViewState {
  @override
  Map<WindowPanel, PanelStack> build(SidebarMode mode) {
    return {WindowPanel.center: const PanelStack.empty()};
  }
}
```

### Key methods

| Method | Purpose |
|---|---|
| `show(panel, spec)` | Replace the panel with a single non-closable page |
| `push(panel, spec)` | Push a new closable page onto the stack |
| `activate(panel, index)` | Switch to a specific page in the stack |
| `pop(panel)` | Remove the top page (if closable) |
| `closeAt(panel, index)` | Close a specific page (if closable) |
| `clear(panel)` | Empty the panel |

### Triggering navigation

From anywhere in the app:

```dart
ref.read(panelsViewStateProvider(SidebarMode.messages).notifier).show(
  panel: WindowPanel.center,
  spec: const ViewSpec.messages(MessagesSpec.globalTimelineV2()),
);
```

**Location:** `lib/essentials/navigation/application/panels_view_state_provider.dart`

---

## 4. PanelCoordinator — App-Level Dispatch

The `PanelCoordinator` maps `ViewSpec` to feature coordinators:

```dart
@riverpod
class PanelCoordinator extends _$PanelCoordinator {
  Widget buildForSpec(ViewSpec spec) {
    return spec.when(
      messages: (messagesSpec) => ref
          .read(messages_feature.viewSpecCoordinatorProvider.notifier)
          .buildForSpec(messagesSpec),
      contacts: (contactsSpec) => ref
          .read(contacts_feature.viewSpecCoordinatorProvider.notifier)
          .buildForSpec(contactsSpec),
      chats: (chatsSpec) => ChatsSidebarView(spec: chatsSpec),
      import: _buildImportPanel,
      settings: (_) => _buildEmptyPanelPlaceholder(WindowPanel.center),
      workbench: (_) => const WorkbenchPanelView(),
    );
  }
}
```

The coordinator also wraps the widget in a `PanelStackSurface` that handles
page tabs and active page rendering.

**Location:** `lib/essentials/navigation/application/panel_coordinator_provider.dart`

### Feature import pattern

Same as the cassette system — features are imported via barrel with aliases:

```dart
import '.../features/messages/feature_level_providers.dart' as messages_feature;
import '.../features/contacts/feature_level_providers.dart' as contacts_feature;
```

---

## 5. Panel Widget Providers — Reactive Layer

Two providers bridge state changes to UI:

```dart
@riverpod
Widget centerPanelWidget(Ref ref, SidebarMode mode) {
  final stack = ref.watch(
    panelsViewStateProvider(mode).select(
      (stacks) => stacks[WindowPanel.center] ?? const PanelStack.empty(),
    ),
  );
  return ref
      .read(panelCoordinatorProvider(mode).notifier)
      .buildPanelSurface(WindowPanel.center, stack);
}

@riverpod
Widget leftPanelWidget(Ref ref, SidebarMode mode) {
  // Watches cassetteWidgetCoordinatorProvider — sidebar cassette system
  // Uses stale-while-revalidate pattern
}
```

The UI shell (`MacosWindow`) consumes these providers:

```dart
child: ref.watch(centerPanelWidgetProvider(mode)),
sidebar: ref.watch(leftPanelWidgetProvider(mode)),
```

**Location:** `lib/essentials/navigation/application/panel_widget_providers.dart`

---

## 6. Feature-Level View Spec Handling

When `PanelCoordinator` calls a feature's `buildForSpec()`, the feature follows
the standard 4-folder pattern (see [52](../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/)):

```
feature/application/view_spec/
  coordinators/view_spec_coordinator.dart    ← pattern-matches feature spec
  resolvers/                                 ← logic + widget construction
  resolver_tools/                            ← shared helpers/providers
  widget_builders/                           ← thin, delegates to presentation/view/
```

### Key differences from cassette spec handling

| Aspect | Cassette | View spec |
|---|---|---|
| Returns | `Future<SidebarCassetteCardViewModel>` | `Widget` (sync) |
| Resolvers | `@riverpod` Notifier classes | Plain Dart classes |
| Widget builders | `ConsumerWidget` (reactive, self-contained) | Thin — delegate to `presentation/view/` |
| Chrome | App-level wraps in card widgets | Feature owns full rendering |
| App-level role | Wraps VM in chrome, manages stack composition | Slots widget into panel surface |

### Why sync, not async?

View spec widgets own their own loading states internally. A messages timeline
view, for example, uses `ref.watch()` inside the widget to reactively load data.
There's no need for the coordinator to await anything — the widget handles it.

---

## 7. Navigation Barrel

`lib/essentials/navigation/feature_level_providers.dart` exports:

```dart
export '../../features/messages/domain/spec_classes/messages_view_spec.dart';
export './application/panels_view_state_provider.dart';
```

This allows consumers to trigger navigation without importing feature internals
or navigation implementation details.

---

## 8. Constants

```dart
enum WindowPanel { center, right }    // Which panel
enum SidebarMode { messages, settings }  // Which app mode
```

**Locations:**
- `lib/essentials/navigation/domain/navigation_constants.dart`
- `lib/essentials/navigation/domain/sidebar_mode.dart`

---

## Complete Data Flow

```
User action
    │
    ▼
ref.read(panelsViewStateProvider(mode).notifier).show(
  panel: WindowPanel.center,
  spec: ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
)
    │
    ▼
PanelsViewState updates Map<WindowPanel, PanelStack>
    │
    ▼
centerPanelWidgetProvider watches state change
    │
    ▼
PanelCoordinator.buildPanelSurface(center, stack)
    │  reads active page from stack
    │  calls buildForSpec(page.spec)
    │
    ├──→ spec.when(messages: ...) → messages_feature.viewSpecCoordinatorProvider
    │       │  pattern-matches MessagesSpec.forContact
    │       │  calls MessagesForContactResolver.resolve(contactId: 42)
    │       │     → MessagesForContactBuilder → MessagesForContactView
    │       ▼
    │    Widget (sync)
    │
    ▼
PanelStackSurface renders widget in panel
```

---

## Adding a New ViewSpec Variant

1. Add a variant to the feature's spec class (e.g., `MessagesSpec.newThing(...)`)
2. Add a resolver in `view_spec/resolvers/`
3. Add a widget builder in `view_spec/widget_builders/`
4. Add a case to the feature's `ViewSpecCoordinator.buildForSpec()`
5. No changes needed at the app level — `PanelCoordinator` already routes to the feature

## Adding a New Feature to the Panel System

1. Define a feature spec class (e.g., `SearchSpec`)
2. Add `ViewSpec.search(SearchSpec spec)` variant
3. Create `view_spec/` folder in the feature's application layer
4. Create `ViewSpecCoordinator.buildForSpec()` in the feature
5. Add the routing case in `PanelCoordinator.buildForSpec()`
6. Export the coordinator from `feature_level_providers.dart`
