# Navigation System - ViewSpec Architecture (September 2025)

## Overview
The navigation system has been completely redesigned around **sealed classes** and **reactive Riverpod providers** for type-safe, predictable navigation. This is a clean, bottom-up architecture that eliminates complex routing logic in favor of declarative view specifications.

## Core Architecture

### 1. Sealed Class Foundation
Navigation is driven by **strongly-typed sealed classes** that provide compile-time guarantees:

```dart
// Main navigation specification
@freezed
abstract class ViewSpec with _$ViewSpec {
  const factory ViewSpec.messages(MessagesSpec spec) = _ViewMessages;
  // Future: ViewSpec.chats(ChatsSpec spec), ViewSpec.contacts(ContactsSpec spec)
}

// Messages feature specification  
@freezed
class MessagesSpec with _$MessagesSpec {
  const factory MessagesSpec.forChat({required int chatId}) = _MessagesForChat;
  const factory MessagesSpec.forContact({required String contactId}) = _MessagesForContact;
  const factory MessagesSpec.recent({required int limit}) = _RecentMessages;
}
```

### 2. Panel State Management
Simple Map-based state tracks what should be displayed in each panel:

```dart
@riverpod
class PanelsViewState extends _$PanelsViewState {
  @override
  Map<WindowPanel, ViewSpec?> build() => {
    WindowPanel.left: null,
    WindowPanel.center: null, 
    WindowPanel.right: null,
  };

  void show({required WindowPanel panel, required ViewSpec spec}) {
    state = {...state, panel: spec};
  }
}
```

### 3. Bottom-Up Widget Resolution
The system uses a chain of providers that automatically resolve ViewSpecs to widgets:

```
ViewSpec → Feature Coordinators → Widget Builders → UI Components
```

## Implementation Layers

### Layer 1: Widget Builders (Leaf Level)
Pure widget builders that take parameters and return UI:

```dart
// lib/features/messages/application/use_cases/messages_for_chat_view_builder_provider.dart
@riverpod
Widget messagesForChatViewBuilder(Ref ref, int chatId) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    child: Text('Messages for Chat ID: $chatId'),
  );
}
```

### Layer 2: Feature Coordinators  
Map feature-specific specs to appropriate widget builders:

```dart
// lib/features/messages/feature_level_providers.dart
@riverpod
class MessagesCoordinator extends _$MessagesCoordinator {
  @override
  void build() {}

  Widget buildForSpec(MessagesSpec spec) {
    return spec.when(
      forChat: (chatId) => ref.read(messagesForChatViewBuilderProvider(chatId)),
      forContact: (contactId) => _buildContactMessagesPlaceholder(contactId),
      recent: (limit) => _buildRecentMessagesPlaceholder(limit),
    );
  }
}
```

### Layer 3: Panel Coordination
Maps ViewSpecs to feature coordinators:

```dart  
// lib/essentials/navigation/presentation/view_model/panel_coordinator_provider.dart
@riverpod
class PanelCoordinator extends _$PanelCoordinator {
  @override
  void build() {}

  Widget buildPanelWidget(WindowPanel panel) {
    final panelViewState = ref.watch(panelsViewStateProvider);
    final viewSpec = panelViewState[panel];

    if (viewSpec == null) {
      return _buildEmptyPanelPlaceholder(panel);
    }

    return viewSpec.when(
      messages: (messagesSpec) => ref
          .read(messagesCoordinatorProvider.notifier)
          .buildForSpec(messagesSpec),
    );
  }
}
```

### Layer 4: Panel Widget Providers
Reactive providers that trigger rebuilds when state changes:

```dart
// lib/essentials/navigation/presentation/view_model/panel_widget_providers.dart
@riverpod
Widget centerPanelWidget(Ref ref) {
  ref.watch(panelsViewStateProvider); // React to state changes
  return ref
      .read(panelCoordinatorProvider.notifier)
      .buildPanelWidget(WindowPanel.center);
}
```

### Layer 5: UI Integration
macOS UI components consume the reactive providers:

```dart
// lib/essentials/navigation/presentation/view/macos_app_shell.dart
MacosWindow(
  sidebar: Sidebar(
    builder: (context, scrollController) {
      return ref.watch(leftPanelWidgetProvider);  // Left panel
    },
  ),
  endSidebar: Sidebar(
    builder: (context, scrollController) {
      return ref.watch(rightPanelWidgetProvider); // Right panel  
    },
  ),
  child: MacosScaffold(
    children: [
      ContentArea(
        builder: (context, scrollController) {
          return ref.watch(centerPanelWidgetProvider); // Center panel
        },
      ),
    ],
  ),
)
```

## Usage Patterns

### Triggering Navigation
From anywhere in the app, simply call:

```dart
ref.read(panelsViewStateProvider.notifier).show(
  panel: WindowPanel.center,
  spec: const ViewSpec.messages(
    MessagesSpec.forChat(chatId: 42),
  ),
);
```

### Adding New Features
1. **Create feature spec**: Add new sealed class (e.g., `ChatsSpec`)
2. **Extend ViewSpec**: Add `ViewSpec.chats(ChatsSpec spec)` variant
3. **Create coordinator**: Implement `ChatsCoordinator.buildForSpec()`
4. **Wire into panel coordinator**: Add `chats:` case to `viewSpec.when()`
5. **Create widget builders**: Implement specific UI components

## Key Benefits

### ✅ **Type Safety**
- Compile-time guarantees prevent invalid navigation states
- Pattern matching ensures all cases are handled
- No string-based routing or magic constants

### ✅ **Predictable Data Flow**  
- Unidirectional data flow: State → Providers → UI
- Clear separation of concerns at each layer
- Easy to trace from user action to UI update

### ✅ **Reactive Updates**
- Automatic UI rebuilds when navigation state changes
- No manual widget management or complex routing logic  
- Leverages Riverpod's reactivity system

### ✅ **Scalable Architecture**
- Easy to add new features without touching existing code
- Clear patterns for widget builders and coordinators
- Bottom-up composition prevents tight coupling

### ✅ **Testable Components**
- Each layer can be tested in isolation
- Pure widget builders are easy to test
- State management separated from UI logic

## File Organization

```
lib/essentials/navigation/
├── domain/
│   ├── entities/
│   │   ├── view_spec.dart                    # Main ViewSpec sealed class
│   │   └── features/
│   │       └── messages_spec.dart            # MessagesSpec sealed class
│   └── navigation_constants.dart             # WindowPanel enum
├── application/
│   └── presentation/
│       └── view_model/
│           └── panels_view_state_provider.dart       # State management
└── presentation/
    ├── view_model/
    │   ├── panel_coordinator_provider.dart    # ViewSpec → Widget coordination
    │   └── panel_widget_providers.dart        # Reactive panel providers
    └── view/
        └── macos_app_shell.dart               # UI integration

lib/features/messages/
├── application/use_cases/
│   └── messages_for_chat_view_builder_provider.dart  # Widget builders
└── feature_level_providers.dart                      # MessagesCoordinator
```

## Migration Notes

### From Legacy System
The previous NavigationOrchestrator/BusinessFeature system has been completely replaced. The new system is:
- **Simpler**: Fewer concepts and components
- **More predictable**: Clear data flow from state to UI
- **Type-safe**: Compile-time guarantees via sealed classes
- **More maintainable**: Each layer has single responsibility

### Key Differences
- **No more string-based routing**: Everything is strongly typed
- **No more complex orchestrators**: Simple state + reactive providers  
- **No more feature interfaces**: Direct coordinator pattern
- **No more context maps**: All data is in the ViewSpec types

This architecture provides the foundation for a robust, maintainable navigation system that scales elegantly as the application grows.
}

@freezed
class NavigationEvent with _$NavigationEvent {
  const factory NavigationEvent.entitySelected({
    required BusinessFeature feature,
    required String entityType,
    required String entityId,
    @Default({}) Map<String, dynamic> extraContext,
    BusinessFeature? targetBusinessFeature, // NEW: Explicit target feature hint
    PanelSlot? targetPanel,                 // NEW: Explicit target panel hint
  }) = _EntitySelected;
  
  const factory NavigationEvent.configurePanel({
    required PanelSlot slot,
    required PanelConfiguration configuration,
  }) = _ConfigurePanel;
  
  const factory NavigationEvent.applyLayout({
    required PanelConfiguration? left,
    required PanelConfiguration? main,
    required PanelConfiguration? right,
  }) = _ApplyLayout;
}
```

`PanelSlot` is a simple enum: `left, main, right`.

## State & Orchestration

```dart
@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    /// Panel configurations (what's displayed where)
    PanelConfiguration? leftPanel,
    PanelConfiguration? mainPanel,
    PanelConfiguration? rightPanel,
    
    /// Latest navigation event (for feature decision making)
    NavigationEvent? latestEvent,
    
    /// Event-specific actionable data (explicit for easy feature access)
    BusinessFeature? targetBusinessFeature,
    @Default('') String entityType,
    @Default('') String entityId,
    @Default(<String, dynamic>{}) Map<String, dynamic> extraContext,
    
    /// @deprecated Use explicit fields instead
    @Deprecated('Use explicit event fields instead of generic globalContext')
    @Default(<String, dynamic>{}) Map<String, dynamic> globalContext,
  }) = _NavigationState;
}

@riverpod
class NavigationOrchestrator extends _$NavigationOrchestrator {
  @override
  NavigationState build() => const NavigationState(
    mainPanel: PanelConfiguration(
      responsibleFeature: BusinessFeature.messages,
  featureDisplayCode: FeatureDisplayCode.welcome,
    ),
  );

  void handle(NavigationEvent event) { 
    // Translates events into state updates with explicit field population
    // - entitySelected: populates targetBusinessFeature, entityType, entityId, extraContext
    // - configurePanel/applyLayout: clears explicit fields (not entity-driven)
    // All events logged via MessageLogger service
  }
}
```

## Logging
Navigation events are logged through the centralized MessageLogger service (`essentials/logging`), keeping navigation state clean and separated from logging concerns. Each navigation event is logged with structured context including feature IDs, entity types, and panel targets.

## Panel Widget Providers
Each panel has a provider that:
1. Watches `navigationOrchestratorProvider` for state changes
2. Grabs the `PanelConfiguration` for its slot
3. Resolves a feature via the registry  
4. Maps `FeatureDisplayCode` to display type (temporary bridge)
5. Calls `feature.buildWidget()` with the configuration

## Feature Decision Making Patterns

### NEW: Explicit Event Field Checks (Recommended)
```dart
// Features can easily check if they're the target of navigation events
@riverpod
class MessagesFeatureProvider extends _$MessagesFeatureProvider {
  @override
  String build() {
    ref.listen<NavigationState>(
      navigationOrchestratorProvider,
      (previous, next) {
        // Crystal clear decision making:
        if (next.targetBusinessFeature == BusinessFeature.messages &&
            next.entityType == 'chat' &&
            next.entityId.isNotEmpty) {
          // THAT'S ME! Load messages for this chat
          loadMessagesForChat(next.entityId);
        }
      },
    );
    return '';
  }
}
```

### OLD: Global Context Pattern (Deprecated)
```dart
// Deprecated pattern - avoid in new code
final context = state.globalContext;
if (context['chatId']?.toString().isNotEmpty == true) {
  // Unclear intent, hard to maintain
}
```

## Dispatching Navigation Events

### Entity Selection (Recommended Pattern)
```dart
// ChatsViewModel following HOLY RULE - signals intent, doesn't command
Future<void> selectChat(int chatId) async {
  final orchestrator = ref.read(navigationOrchestratorProvider.notifier);
  orchestrator.handle(
    NavigationEvent.entitySelected(
      feature: BusinessFeature.chats,           // Who initiated
      entityType: 'chat',                       // What was selected
      entityId: chatId.toString(),              // Which one
      extraContext: {},                         // Additional data
      targetBusinessFeature: BusinessFeature.messages,  // Who should respond
      targetPanel: PanelSlot.main,              // Where to show it
    ),
  );
}
```

### Direct Panel Configuration
```dart
// Direct panel configuration for layout changes
orchestrator.handle(
  NavigationEvent.configurePanel(
    slot: PanelSlot.main,
    configuration: PanelConfiguration(
      responsibleFeature: BusinessFeature.messages,
      featureDisplayCode: FeatureDisplayCode.welcome,
    ),
  ),
);
```
## Adding a New Feature
1. Add enum case to `BusinessFeature` in `navigation_constants.dart`.
2. Add relevant `FeatureDisplayCode` enum cases.
3. Implement `FeatureInterface` for the new feature.
4. Register it in `featureRegistry`.
5. Features should watch NavigationState and check explicit fields:
   - `targetBusinessFeature` - Is this for me?
   - `entityType` - What kind of selection?
   - `entityId` - Which specific item?
6. Dispatch `NavigationEvent.entitySelected` with target hints for cross-feature coordination.

## Design Principles
- **Immutable state and events** → predictable navigation changes.
- **Strong typing** for feature & view selection → avoids string drift.
- **Single orchestration point** → easy logging & debugging via MessageLogger.
- **Feature autonomy** → each feature renders its own displays.
- **Explicit intent signaling** → targetBusinessFeature/entityType fields provide clear "THAT'S ME!" signals.
- **Separation of concerns** → navigation state carries no logging, uses MessageLogger service.

## Migration Notes
- **COMPLETED**: Removed `navigation_old` folder and string-based IDs.
- **COMPLETED**: Consolidated panel configuration into one Freezed model file.
- **COMPLETED**: Replaced ad-hoc helper methods with explicit `NavigationEvent`s.
- **COMPLETED**: Added explicit event fields to NavigationState for intuitive feature decision-making.
- **COMPLETED**: Deprecated globalContext in favor of strongly-typed fields.
- **COMPLETED**: Integrated MessageLogger for all navigation logging.
- **IN PROGRESS**: Temporary legacy display name mapping remains until all features adopt enum-based rendering directly.

## Future Enhancements
- Persist/restore last layout with serialized `PanelConfiguration`s.
- Add analytics hook in `handle()` logging event transitions (enhanced with MessageLogger).
- Introduce `NavigationEvent.stackPush/stackPop` if hierarchical flows emerge.
- Remove legacy display string mapping when all features consume `FeatureDisplayCode` enums directly.
- Consider adding validation for targetBusinessFeature/targetPanel combinations.
- Explore typed context maps instead of `Map<String, dynamic>` for extraContext.

## Explicit Event Fields: Key Benefits

### 1. Intuitive Feature Decision Making
Features can now easily determine if a navigation event is intended for them:
```dart
// Crystal clear intent checking
if (state.targetBusinessFeature == BusinessFeature.messages) {
  // This event is definitely for the messages feature
}
```

### 2. Strongly Typed Access to Event Data
No more digging through generic maps:
```dart
// Before (deprecated):
final chatId = state.globalContext['chatId']?.toString() ?? '';

// After (current):
final chatId = state.entityId; // Direct, typed access
```

### 3. Self-Documenting Code
The navigation state clearly shows what data is available:
- `latestEvent` - The full navigation event that caused this state
- `targetBusinessFeature` - Which feature should respond
- `entityType` - What kind of entity was selected
- `entityId` - The specific entity identifier
- `extraContext` - Additional context specific to the event

### 4. Better Testing and Debugging
Test assertions become much clearer:
```dart
expect(state.targetBusinessFeature, equals(BusinessFeature.messages));
expect(state.entityType, equals('chat'));
expect(state.entityId, equals('123'));
```

### 5. Future-Proof Architecture
New fields can be added to NavigationState without breaking existing generic context parsing logic.

## Architecture Patterns

### Architecture (ASCII)
```
+--------------------+        +------------------+
|  User Interaction  |        |  Feature Widgets |
| (Clicks, Selects)  |        | (Messages,etc.)  |
+----------+---------+        +---------+--------+
           |                             ^
           v                             |
+----------+---------+        +---------+--------+
| View Models /      |        | FeatureInterface |
| Action Providers    |        | Implementations |
| (ChatsViewModel)    |        +---------+--------+
+----------+---------+                  ^
           | NavigationEvent            |
           | (with target hints)        |
           v                            |
+----------+-------------+  updates  +--+-------------------+
| NavigationOrchestrator |---------> | NavigationState      |
| handle(event)          |           | + explicit fields:   |
| + MessageLogger        |           | - targetBusinessFeature
+----------+-------------+           | - entityType         |
           |                         | - entityId           |
           | watches                 | - extraContext       |
           v                         | - latestEvent        |
+----------+-------------+           +-----------+----------+
| Panel Widget Providers |                       ^
| left / main / right    |                       |
| (check explicit fields)|<----------------------+
+------------------------+
```

### Navigation Event Flow
```
1. User clicks chat in ChatsFeature
2. ChatsViewModel.selectChat() called
3. Dispatches NavigationEvent.entitySelected(
     feature: BusinessFeature.chats,
     entityType: 'chat',
     entityId: '123',
     targetBusinessFeature: BusinessFeature.messages,
     targetPanel: PanelSlot.main
   )
4. NavigationOrchestrator.handle() processes event:
   - Logs event via MessageLogger
   - Updates NavigationState with explicit fields
   - Configures target panel if hints provided
5. Panel providers watch NavigationState
6. MessagesFeature checks: state.targetBusinessFeature == BusinessFeature.messages
7. MessagesFeature loads messages for state.entityId
```

### SVG Diagram
Stored at: `ui_renders/navigation_system.svg`

To regenerate, update the SVG asset manually or create a script if automation is desired.

---
This reflects the authoritative navigation system with explicit event fields enhancement (September 2025).
