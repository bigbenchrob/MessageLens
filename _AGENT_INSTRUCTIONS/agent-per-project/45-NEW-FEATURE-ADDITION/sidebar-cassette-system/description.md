
# Sidebar cassette rack architecture and next steps

This document summarizes the state of the sidebar **cassette rack** implementation and outlines the remaining steps to finish the feature.  It assumes familiarity with Flutter, Riverpod and Freezed but should be useful for anyone taking over the codebase.

## Overview

The sidebar is built as a **cassette rack** – a stack of immutable data objects called **cassette specs**.  Each spec describes one slice of UI in the sidebar and records any view‑specific state.  Specs are defined as Freezed unions and live in the `essentials/sidebar/domain/entities` folder.  There are two feature‑level specs so far:

* `SidebarUtilityCassetteSpec` – controls the top chat menu and other sidebar utilities.
* `ContactsCassetteSpec` – handles contact pickers (flat menu or more elaborate picker).

Each feature can extend this pattern by adding its own spec type (e.g. `MessagesCassetteSpec` for messages).  Specs are wrapped in the top‑level `CassetteSpec` union.  The wrapper only matters when dispatching which feature should build the UI; once inside a feature, you work directly with the nested spec.

### Cassette rack state

`CassetteRackState` is a value object holding an ordered list of `CassetteSpec`s.  The **rack provider** is a class‑based Riverpod notifier (`CassetteRackStateNotifier`) that exposes methods to mutate the stack:

* `setRack(List<CassetteSpec>)` – replace the entire stack.
* `pushCassette(CassetteSpec)` – append a spec to the bottom of the stack.
* `updateSpecAndChild(oldSpec, newSpec)` – replace an existing spec with an updated spec and append its child (see below).
* `findLatestContactId()` – helper used by deeper cassettes to fetch the most recently selected contact ID from the stack.

There is **no external provider** for state like selected menu index or chosen contact.  All view state lives on the spec itself (e.g. `SidebarUtilityCassetteSpec.topChatMenu(chosenMenuIndex: 0)`).  When the user interacts with a cassette, the widget constructs a new spec with updated state and calls `updateSpecAndChild()`.  This simplifies the code and avoids a “messy collection of providers.”

### SideBarCassetteCard

Every cassette widget is wrapped in a reusable card widget to give it a consistent macOS look.  The `SideBarCassetteCard` uses `MacosDynamicColor.resolve(MacosColors.controlColor, context)` for its background and `MacosDynamicColor.resolve(MacosColors.quaternaryLabelColor, context)` for its border.  Using macOS colours rather than the Material colour scheme keeps the design subtle and platform‑appropriatehttps://pub.dev/documentation/macos_ui/latest/macos_ui/MacosColors-class.html#:~:text=The%20accent%20color%20selected%20by,The%20surface%20of%20a%20controlhttps://pub.dev/documentation/macos_ui/latest/macos_ui/MacosColors-class.html#:~:text=The%20text%20of%20a%20label,label%20such%20as%20watermark%20text.

## Top chat menu cassette

The top chat menu is the only implemented cassette at this point.  Its spec variant is `SidebarUtilityCassetteSpec.topChatMenu(chosenMenuIndex)`.  The corresponding builder reads the `chosenMenuIndex` directly from the spec and renders a `DropdownButton<int>` with three options: “Contacts”, “Unmatched phone numbers and emails”, and “All messages.”  When the user changes the selection, the widget:

1. Creates a new spec by calling `spec.copyWith(chosenMenuIndex: newIndex)`.
2. Wraps both old and new specs in the `CassetteSpec.sidebarUtility` wrapper.
3. Calls `ref.read(cassetteRackStateProvider.notifier).updateSpecAndChild(oldWrapper, newWrapper)`.

The rack provider locates the index of `oldWrapper`, replaces it with `newWrapper`, truncates anything below it, and pushes the next spec as determined by the spec’s `childSpec()` method (see below).

## Coordinators

### Feature‑level coordinator

Every feature defines a coordinator that maps a spec to a widget.  For example, the `UtilityCassetteCoordinator` in `features/sidebar_utilities/feature_level_providers.dart` exposes a method:

```dart
Widget buildForSpec(SidebarUtilityCassetteSpec spec, WidgetRef ref) {
  return spec.when(
    topChatMenu: (chosenMenuIndex) {
      return TopChatMenu(spec: spec);
    },
    // add other sidebar utilities here
  );
}
```

The coordinator itself is a Riverpod provider so it can read other providers as needed.  Because the spec carries all its state, no extra providers are required.

### Cassette widget coordinator

`CassetteWidgetCoordinator` is the top‑level coordinator for the entire rack.  It reads the `CassetteRackState` and turns the list of specs into a list of widgets.  In its current form it simply pattern‑matches on each `CassetteSpec` and delegates to the appropriate feature‑level coordinator:

```dart
@riverpod
class CassetteWidgetCoordinator extends _$CassetteWidgetCoordinator {
  @override
  List<Widget> build() {
    final rack = ref.watch(cassetteRackStateProvider).cassettes;
    final widgets = <Widget>[];
    for (final spec in rack) {
      final childWidget = spec.when(
        sidebarUtility: (sidebarSpec) =>
            sidebar_utilities.utilityCassetteCoordinatorProvider
                .buildForSpec(sidebarSpec, ref),
        contacts: (contactsSpec) =>
            contacts_feature.contactsCassetteCoordinatorProvider
                .buildForSpec(contactsSpec, ref),
        // add other feature cases here
      );
      widgets.add(SideBarCassetteCard(child: childWidget));
    }
    return widgets;
  }
}
```

Currently it stops after rendering the specs in the rack.  The next step is to have it continue building child specs on the fly until none remain (see *Remaining work*).

### Panel widget provider

`panel_widget_providers.dart` defines a `leftPanelWidget` that watches the cassette widget coordinator and arranges the returned list of widgets in a `Column`.  This causes the entire sidebar to rebuild whenever the cassette rack changes.

## Remaining work

The high‑level logic of the rack is in place, but the **cassette widget coordinator** still needs to support dynamic child generation.  The steps to complete are:

1. **Add a `childSpec()` extension on each spec.**  Each feature spec should implement a method (via extension) that returns the appropriate next spec based on its own state.  For example:

   ```dart
   extension SidebarUtilityCassetteSpecX on SidebarUtilityCassetteSpec {
     CassetteSpec? childSpec() {
       return when(
         topChatMenu: (index) {
           switch (index) {
             case 0:
               // user chose Contacts → next cassette is a flat menu
               return CassetteSpec.contacts(
                 ContactsCassetteSpec.flatMenu(chosenContactId: null),
               );
             case 1:
               // unmatched phone numbers and emails → child spec might be a messages cassette
               return CassetteSpec.sidebarUtility(
                 SidebarUtilityCassetteSpec.unmatchedHandles(),
               );
             case 2:
             default:
               // all messages → no further cassettes until user opens a chat
               return null;
           }
         },
         // handle other variants here
       );
     }
   }
   ```

   The spec should return `null` when there is no next cassette.

2. **Update `CassetteRackStateNotifier.updateSpecAndChild()`.**  This method should:

   * Find the index of `oldSpec` in `state.cassettes`.
   * Replace it with `newSpec`.
   * Truncate the stack below this index.
   * Call `newSpec.childSpec()` and, if it returns a non‑null spec, push it onto the stack.

   This ensures that when a cassette changes state it regenerates any cassettes below it.

3. **Iteratively build children in the widget coordinator.**  The `CassetteWidgetCoordinator` should no longer stop after building the existing stack.  Instead, after rendering the last spec in the rack, it should look at that spec’s `childSpec()`.  If `childSpec()` returns a spec, it should build a widget for it (using the appropriate feature coordinator) and append it to the list.  Then it should repeat the process until `childSpec()` returns `null`.  This will create a continuous chain of widgets without needing explicit calls from the widgets themselves.

4. **Implement coordinators for other features.**  You will need to add feature‑level coordinators for contacts, messages and any other cassette types.  These coordinators should pattern‑match on their own specs and build appropriate widgets.  They can also call `ref.read(cassetteRackStateProvider.notifier).findLatestContactId()` when they need context from earlier cassettes.

5. **Remove unused providers.**  The older `SidebarMenuChoice` provider is no longer needed.  Ensure it is deleted to avoid confusion.

6. **Adhere to macOS aesthetics.**  Continue using `MacosDynamicColor` and `MacosColors` for colours.  Avoid using Material theme colours for the sidebarhttps://pub.dev/documentation/macos_ui/latest/macos_ui/MacosColors-class.html#:~:text=The%20accent%20color%20selected%20by,The%20surface%20of%20a%20control.  Use `SideBarCassetteCard` to wrap every cassette widget.

## File structure summary

The project is organised into logical domains:

```
lib/
  essentials/
    sidebar/
      application/
        cassette_rack_state_provider.dart     # holds the cassette rack state
        cassette_widget_coordinator.dart      # maps specs to widgets
        cassette_widget_coordinator.g.dart
      domain/
        entities/
          cassette_spec.dart                  # top‑level union of all specs
          features/
            sidebar_utility_cassette_spec.dart# spec for sidebar utilities
            contacts_cassette_spec.dart       # spec for contacts
      presentation/
        cassettes/
          top_chat_menu.dart                 # top chat menu widget
          sidebar_cassette_card.dart          # generic card for cassettes
  features/
    sidebar_utilities/
      feature_level_providers.dart            # UtilityCassetteCoordinator
    contacts/
      feature_level_providers.dart            # Contacts coordinator (to be added)
  panel_widget_providers.dart                 # leftPanelWidget and other panels
```

## Conclusion

The cassette rack architecture provides a modular and scalable way to build a complex sidebar.  Each cassette is responsible for its own state and for determining what comes next.  The rack provider orchestrates the stack and exposes helpers for querying earlier cassettes.  The widget coordinator then composes the UI by delegating to feature‑specific coordinators and wrapping the results in a consistent card.

By following the remaining steps – implementing `childSpec()` methods, updating the rack notifier, and enhancing the widget coordinator – the sidebar will dynamically adapt to user interactions without requiring global state or complex plumbing.