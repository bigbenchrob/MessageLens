# Rationalize Message Views — Status

## ✅ COMPLETE

**Merged to main**: February 11, 2026  
**Branch**: `Ftr.msgview`  
**Commit**: `ca77d5c`

---

## Summary

Consolidated duplicate message timeline views into a unified infrastructure using the Strategy Pattern.

### Before
- `GlobalMessagesView` and `MessagesForContactView` were ~95% identical
- Separate ordinal providers, hydration providers, view models, and search providers for each scope
- Code duplication made changes error-prone

### After
- Single `MessagesTimelineView` widget handles all scopes
- `MessageTimelineScope` sealed class with variants: `global()`, `contact(contactId)`, `chat(chatId)`
- Strategy pattern (`OrdinalStrategy`) delegates scope-specific queries to appropriate data sources
- Unified providers parameterized by scope

---

## Files Created

**Domain:**
- `lib/features/messages/domain/value_objects/message_timeline_scope.dart`
- `lib/features/messages/domain/message_timeline_scope_extensions.dart`

**Application (Strategies):**
- `lib/features/messages/application/strategies/ordinal_strategy.dart`
- `lib/features/messages/application/strategies/global_ordinal_strategy.dart`
- `lib/features/messages/application/strategies/contact_ordinal_strategy.dart`
- `lib/features/messages/application/strategies/chat_ordinal_strategy.dart`

**Presentation (View Model):**
- `lib/features/messages/presentation/view_model/timeline/ordinal/message_timeline_ordinal_provider.dart`
- `lib/features/messages/presentation/view_model/timeline/ordinal/current_visible_month_provider.dart`
- `lib/features/messages/presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart`
- `lib/features/messages/presentation/view_model/timeline/message_timeline_view_model_provider.dart`

**Presentation (View):**
- `lib/features/messages/presentation/view/messages_timeline_view.dart`

---

## Files Deleted

- `lib/features/messages/presentation/view/global_messages_view.dart`
- `lib/features/messages/presentation/view/messages_for_contact_view.dart`
- `lib/features/messages/presentation/view_model/global_messages/` (entire folder)
- `lib/features/messages/presentation/view_model/contact_messages/` (entire folder)

---

## Files Modified

- `lib/features/messages/application/sidebar_cassette_spec/widget_builders/global_timeline_builder.dart`
- `lib/features/messages/application/sidebar_cassette_spec/widget_builders/messages_for_contact_builder.dart`
- `lib/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget.dart`

---

## Usage

```dart
// Global timeline
MessagesTimelineView(
  scope: const MessageTimelineScope.global(),
  scrollToDate: optionalDate,
)

// Contact timeline
MessagesTimelineView(
  scope: MessageTimelineScope.contact(contactId: 42),
)

// Chat timeline (future)
MessagesTimelineView(
  scope: MessageTimelineScope.chat(chatId: 123),
)
```

---

## Architecture

```
MessageTimelineScope (sealed class)
    ├── GlobalTimelineScope
    ├── ContactTimelineScope
    └── ChatTimelineScope
            │
            ▼
    OrdinalStrategy (interface)
    ├── GlobalOrdinalStrategy
    ├── ContactOrdinalStrategy
    └── ChatOrdinalStrategy
            │
            ▼
    MessageTimelineOrdinalProvider (family by scope)
    MessageByTimelineOrdinalProvider (family by scope + ordinal)
    MessageTimelineViewModelProvider (family by scope)
            │
            ▼
    MessagesTimelineView (unified widget)
```
