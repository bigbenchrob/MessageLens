---
tier: project
scope: cassette-architecture
owner: agent-per-project
last_reviewed: 2025-12-23
source_of_truth: doc
links:
  - ./README.md
  - ./00-cassette-choice-flow-and-responsibilities.md
  - ../60-NAVIGATION/navigation-overview.md
tests: []
---

# Cassette System Architecture: Design Philosophy & Evolution

## The Problem with the Old ViewSpec Sidebar Approach

Previously, the sidebar was part of the ViewSpec navigation system, where a window panel would be assigned to a feature (e.g., "chats") and that feature would be responsible for rendering **everything** in that panel.

**This created chaos:**
- **Cross-feature coupling**: The chats feature had to ask contacts for a contact list, then build its own chats list below
- **Blurred boundaries**: Chats feature was building controls like "Show all/favourited contacts" - UI that logically belongs to contacts
- **Disorganization**: Widgets could end up anywhere in the codebase. Even the author can't predict where the enhanced contacts picker lives without searching through all feature folders.

### Example of the Old Problem

When the goal was to build a list of chats by a particular contact:
1. Sidebar assigned to chats feature via ViewSpec
2. Chats feature requests contact list from contacts feature
3. Chats feature builds contact picker UI (not its domain!)
4. Chats feature builds controls: "Show all/favourited contacts" (not its domain!)
5. Chats feature finally builds its own chats list

Result: Feature boundaries completely dissolved. No clear ownership. Maintenance nightmare.

## The Cassette System Solution

The cassette system brings **strict organizational boundaries** through a **vertical stack of independent, feature-scoped widgets**.

### Core Principles

#### 1. Each Cassette Owns Its Domain Completely

A contacts cassette only knows about contacts. A messages cassette only knows about messages. A handles cassette only knows about handles.

**No cross-feature knowledge** - Cassettes don't call other features' APIs or build other features' UI.

#### 2. Cascading Through Specs, Not Cross-Feature Knowledge

Each cassette spec declares what cassette spec (if any) should follow it. The cascade is **state-dependent**:

```dart
// When no contact selected:
ContactsCassetteSpec.contactChooser(chosenContactId: null)
  → childSpec() returns null
  → No cassette follows

// After user selects contact:
ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42)
  → childSpec() returns MessagesCassetteSpec.heatMap(contactId: 42)
  → Heatmap appears below hero badge
```

The cascade logic lives in `cassette_spec.dart` extensions, not in individual features.

#### 3. State-Driven Cascade Updates

When user takes action (e.g., selects a contact), the cassette widget calls its view model:

```dart
// In ContactsFlatMenuCassette:
ref.read(cassetteViewModelProvider.notifier).updateContactSelection(
  currentSpec: ContactsCassetteSpec.contactChooser(),
  nextContactId: 42,
);

// View model tells CassetteRackState:
"Replace ContactsCassetteSpec.contactChooser() 
 with ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42)"
```

**CassetteRackState automatically resolves the cascade:**
1. Removes old spec and everything below it
2. Adds new spec: `ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42)`
3. Calls `childSpec()` → gets `MessagesCassetteSpec.heatMap(contactId: 42)`
4. Adds heatmap cassette
5. Continues until `childSpec()` returns null

Result: Entire sidebar updates atomically with no manual coordination.

#### 4. Instant Feature Discoverability

Looking at the cassette stack immediately shows which feature owns which UI section:

```
CassetteSpec.sidebarUtility(topChatMenu)  → sidebar_utilities feature
CassetteSpec.contacts(contactHeroSummary) → contacts feature
CassetteSpec.messages(heatMap)            → messages feature
```

No more hunting through the codebase. Feature ownership is self-documenting.

### Key Benefits

- **Flexibility**: Easily add new flows without disturbing existing ones
  - Debugging tool: Theme Playground (presentation cassette)
  - Upcoming: Preferences drill-down navigation (broad categories → refined choices → specific settings)

- **Composability**: Stack adapts automatically based on user choices
  - Top menu choice determines first cassette
  - Each cassette's state determines what follows
  - No manual stack management required

- **Maintainability**: Feature boundaries are crystal clear
  - Contacts feature owns all contact UI
  - Messages feature owns all message UI
  - No shared responsibility confusion

- **Scalability**: Can build complex multi-level navigation
  - Preferences: Category → Subcategory → Setting detail
  - Each level is an independent cassette
  - Add/remove levels without affecting others

### Current Implementation Examples

**Contact Selection Flow:**
```
TopChatMenu (sidebar utility)
  → "Contacts" selected
  → ContactChooser appears
  → User selects contact #42
  → ContactHeroSummary(42) replaces chooser
  → MessageHeatmap(42) appears below automatically
```

**Stray Handles Flow:**
```
TopChatMenu (sidebar utility)
  → "Stray Phone Numbers" selected
  → HandlesList appears
  → (No further cascade - handles don't declare children yet)
```

**Debug Flow:**
```
TopChatMenu (sidebar utility)
  → "Theme Playground" selected
  → ThemePlayground appears (presentation cassette)
  → (No cascade - it's a leaf node)
```

## Relationship to Center Panel Navigation

### Current State

**Left Sidebar**: ✅ Fully functional cassette system
- Manages its own vertical stack
- Updates via CassetteRackState
- Features coordinate through childSpec() declarations

**Center Panel**: ⚠️ Uses separate ViewSpec navigation system
- Manages PanelStack per WindowPanel
- Updates via PanelsViewState
- **Not yet connected to cassette user actions**

### The Integration Point

Cassettes can update **two independent systems** in response to user actions:

1. **Update sidebar cascade** (already implemented):
   ```dart
   cassetteViewModelProvider.updateContactSelection(...)
   → Updates CassetteRackState
   → Sidebar reflects new state
   ```

2. **Trigger center panel navigation** (needs implementation):
   ```dart
   panelsViewStateProvider.show(
     panel: WindowPanel.center,
     spec: ViewSpec.messages(MessagesSpec.forContact(...)),
   )
   → Center panel displays relevant content
   ```

Both actions can happen in the same view model method. The cassette system owns sidebar layout; the ViewSpec system owns center panel content.

## Design Philosophy Summary

The cassette system embodies:

- **Domain isolation**: Each feature knows only its own domain
- **Declarative cascading**: Specs declare relationships, not imperative code
- **Single responsibility**: Cassettes render; specs define structure; state providers coordinate
- **Zero coupling**: Features never import each other (only their spec types)
- **Self-documenting**: Stack structure reveals feature ownership instantly

This architecture scales from simple flows (theme playground) to complex navigation trees (upcoming preferences drill-down) without increasing cognitive load or coupling between features.
