---
---
tier: project
scope: navigation
owner: agent-per-project
last_reviewed: 2025-01-30
source_of_truth: This file
links:
  - ../00-PROJECT/02-architecture-overview.md
  - ../../agent-instructions-shared/20-flutter/widgets.md
  - ../../agent-instructions-shared/00-global/riverpod-rules.md
tests: []
---

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
│   └── panels_view_state_provider.dart       # State management
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
