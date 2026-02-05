# Tooltips System

A cross-surface tooltips system following the same coordinator/resolver/widget-builder pattern as the sidebar cassette system.

## Overview

The tooltips system provides hover-triggered contextual help throughout the application. It uses the same spec-routing architecture established in the cross-surface spec system, allowing each feature to define and resolve its own tooltip content.

## Architecture

```
TooltipWrapper (essentials)
    │
    ▼ passes TooltipSpec
TooltipCoordinator (essentials)
    │ pattern-matches spec
    ▼
Feature Coordinators
    │
    └─► contacts: ContactsTooltipCoordinator
            │
            └─► editDisplayName: "Edit display name"
```

## Key Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `TooltipSpec` | `essentials/tooltips/domain/entities/` | Sealed class routing to features |
| `TooltipCoordinator` | `essentials/tooltips/application/` | Routes specs to feature coordinators |
| `TooltipWrapper` | `essentials/tooltips/presentation/` | Flutter `Tooltip`-based wrapper widget |
| `TooltipConfig` | `essentials/tooltips/domain/` | Configurable delays (default 500ms) |

## Usage

### Basic Usage

Wrap any widget with `TooltipWrapper`:

```dart
import 'package:remember_this_text/essentials/tooltips/feature_level_providers.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_tooltip_spec.dart';

TooltipWrapper(
  spec: TooltipSpec.contacts(ContactsTooltipSpec.editDisplayName()),
  child: Icon(CupertinoIcons.pencil),
)
```

### Adding Tooltips to a New Feature

To add tooltips to another feature (e.g., `handles`):

**Step 1: Create the tooltip spec**

```dart
// lib/features/handles/domain/spec_classes/handles_tooltip_spec.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'handles_tooltip_spec.freezed.dart';

@freezed
abstract class HandlesTooltipSpec with _$HandlesTooltipSpec {
  const factory HandlesTooltipSpec.linkToContact() = _LinkToContact;
  const factory HandlesTooltipSpec.unlinkHandle() = _UnlinkHandle;
}
```

**Step 2: Create the coordinator**

```dart
// lib/features/handles/application/tooltips_spec/coordinators/handles_tooltip_coordinator.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/spec_classes/handles_tooltip_spec.dart';

part 'handles_tooltip_coordinator.g.dart';

@riverpod
class HandlesTooltipCoordinator extends _$HandlesTooltipCoordinator {
  @override
  void build() {}

  String resolve(HandlesTooltipSpec spec) {
    return spec.map(
      linkToContact: (_) => 'Link this handle to a contact',
      unlinkHandle: (_) => 'Remove handle from contact',
    );
  }
}
```

**Step 3: Add variant to TooltipSpec**

```dart
// lib/essentials/tooltips/domain/entities/tooltip_spec.dart
@freezed
abstract class TooltipSpec with _$TooltipSpec {
  const factory TooltipSpec.contacts(ContactsTooltipSpec spec) = _Contacts;
  const factory TooltipSpec.handles(HandlesTooltipSpec spec) = _Handles;  // Add this
}
```

**Step 4: Route in TooltipCoordinator**

```dart
// lib/essentials/tooltips/application/tooltip_coordinator.dart
String resolve(TooltipSpec spec) {
  return spec.map(
    contacts: (c) => ref.read(contactsTooltipCoordinatorProvider.notifier).resolve(c.spec),
    handles: (h) => ref.read(handlesTooltipCoordinatorProvider.notifier).resolve(h.spec),
  );
}
```

**Step 5: Use in UI**

```dart
TooltipWrapper(
  spec: TooltipSpec.handles(HandlesTooltipSpec.linkToContact()),
  child: Icon(CupertinoIcons.link),
)
```

## Configuration

Default settings in `TooltipConfig`:

| Setting | Default | Description |
|---------|---------|-------------|
| `waitDuration` | 500ms | Delay before tooltip appears |
| `showDuration` | 1500ms | How long tooltip stays visible |
| `preferBelow` | false | Prefer above target (auto-positions below if no room) |

## Current Features

### Contacts Feature

| Spec Variant | Tooltip Text |
|--------------|--------------|
| `editDisplayName` | "Edit display name" |

Used on the pencil icon in the contact hero card.

## Design Notes

- Uses Flutter's built-in `Tooltip` widget for simplicity
- Follows cross-surface spec system patterns
- Feature-owned text content (each feature defines its own strings)
- Animation support can be added later if needed

## File Locations

```
lib/
├── essentials/tooltips/
│   ├── application/
│   │   └── tooltip_coordinator.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── tooltip_spec.dart
│   │   └── tooltip_config.dart
│   ├── presentation/
│   │   └── tooltip_wrapper.dart
│   └── feature_level_providers.dart
│
└── features/contacts/
    ├── application/tooltips_spec/
    │   └── coordinators/
    │       └── contacts_tooltip_coordinator.dart
    └── domain/spec_classes/
        └── contacts_tooltip_spec.dart
```

## Planning Documents

Development planning artifacts are in:
`_AGENT_INSTRUCTIONS/agent-per-project/30-NEW-FEATURE-ADDITION/tooltips/`
