import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../feature_level_providers.dart';

part 'cassette_rack_state_provider.freezed.dart';
part 'cassette_rack_state_provider.g.dart';

/// A value object representing the current stack of cassettes in the sidebar.
///
/// It uses the `freezed` package to generate the immutable data class
/// implementation along with copyWith, equality, and debugging utilities.  A
/// convenience factory [CassetteRack.initial] is provided to generate the
/// tracer‑bullet default containing a single top chat menu cassette.
@freezed
abstract class CassetteRack with _$CassetteRack {
  /// Creates a new [CassetteRack] with the given list of [cassettes].  The
  /// default value is an empty list.  The list is immutable, as the
  /// generated copyWith will always create new lists when updating.
  const factory CassetteRack({
    @Default(<CassetteSpec>[]) List<CassetteSpec> cassettes,
  }) = _CassetteRack;

  /// Private constructor used by the `freezed` mixin.  Required to be able
  /// to add custom methods to the class.
  const CassetteRack._();

  /// Returns a fresh [CassetteRack] containing a single top chat menu
  /// cassette.  This is the initial tracer‑bullet state used by
  /// [CassetteRackState.build].
  factory CassetteRack.initial() {
    return CassetteRack(
      cassettes: List<CassetteSpec>.unmodifiable([
        const CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        ),
      ]),
    );
  }
}

/// A Riverpod notifier managing the current [CassetteRack].
///
/// This class follows the class‑based provider syntax described in the
/// Riverpod documentation.  It exposes methods to mutate the rack in
/// response to user interactions (pushing new cassettes, updating existing
/// ones, truncating the stack, etc.).  Because the notifier’s state is
/// immutable, each mutation produces a new [CassetteRack] instance.
@riverpod
class CassetteRackState extends _$CassetteRackState {
  @override
  CassetteRack build() {
    // Start with the default tracer‑bullet rack: a single top chat menu.
    return CassetteRack.initial();
  }

  /// Reset to the simple single top‑menu tracer bullet state.
  void resetToInitial() {
    state = CassetteRack.initial();
  }

  /// Replace the entire rack at once.
  void setRack(List<CassetteSpec> newCassettes) {
    state = CassetteRack(
      cassettes: List<CassetteSpec>.unmodifiable(newCassettes),
    );
  }

  /// Push a new cassette onto the bottom of the stack (i.e. add after the
  /// existing ones).  This corresponds to adding a deeper level to the
  /// sidebar’s hierarchy when the user drills down into a feature.
  void pushCassette(CassetteSpec spec) {
    state = state.copyWith(cassettes: [...state.cassettes, spec]);
  }

  /// Replace the cassette at [index], without modifying the rest of the stack.
  ///
  /// Useful when a user interaction changes a cassette’s spec but downstream
  /// cassettes remain valid (for example, selecting a different menu item
  /// within the top chat menu).  If the index is out of bounds, this is a
  /// no‑op.
  void updateCassetteAt(
    int index,
    CassetteSpec Function(CassetteSpec current) update,
  ) {
    if (index < 0 || index >= state.cassettes.length) {
      return;
    }
    final updated = [...state.cassettes];
    updated[index] = update(updated[index]);
    state = state.copyWith(cassettes: updated);
  }

  /// Truncate the stack so that only cassettes up to [indexInclusive] remain.
  ///
  /// When a cassette changes in a way that invalidates downstream cassettes,
  /// call this after [updateCassetteAt] to remove all deeper levels.  If the
  /// index is negative, the entire rack is cleared.  If the index is beyond
  /// the end of the stack, nothing happens.
  void truncateAfter(int indexInclusive) {
    if (state.cassettes.isEmpty) {
      return;
    }
    if (indexInclusive < 0) {
      state = state.copyWith(cassettes: const []);
      return;
    }
    if (indexInclusive >= state.cassettes.length) {
      return;
    }
    state = state.copyWith(
      cassettes: state.cassettes.sublist(0, indexInclusive + 1),
    );
  }

  /// Convenience for just updating the top chat menu cassette.  The
  /// [chosenMenuIndex] parameter determines which option is selected; if null
  /// it defaults to whatever the factory uses by default.  This is used by
  /// UI interactions in the tracer‑bullet phase.
  void setTopChatMenu({int? chosenMenuIndex}) {
    final topMenu = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.topChatMenu(
        chosenMenuIndex:
            chosenMenuIndex ??
            const SidebarUtilityCassetteSpec.topChatMenu().chosenMenuIndex,
      ),
    );
    if (state.cassettes.isEmpty) {
      state = state.copyWith(cassettes: [topMenu]);
    } else {
      final rest = state.cassettes.skip(1).toList();
      state = state.copyWith(cassettes: [topMenu, ...rest]);
    }
  }

  /// Update a cassette at its current position by matching the old spec,
  /// and optionally append a child cassette based on the new spec.  This
  /// method takes both the old and new specs so that the caller doesn’t
  /// need to know the index of the cassette in the stack.  If the old
  /// spec isn’t found, no action is taken.
  void updateSpecAndChild(CassetteSpec oldSpec, CassetteSpec newSpec) {
    final index = state.cassettes.indexOf(oldSpec);
    if (index < 0) {
      return;
    }
    // Replace the spec at the found index.
    final updatedList = [...state.cassettes];
    updatedList[index] = newSpec;
    // Determine a child spec based on the new spec.  If the new spec is
    // a top chat menu, we look at the selected menu index to decide what
    // comes next.  Currently only the Contacts menu (index 0) pushes a
    // new cassette.  Other selections clear deeper cassettes.
    CassetteSpec? childSpec;
    newSpec.when(
      sidebarUtility: (sidebarSpec) {
        sidebarSpec.when(
          topChatMenu: (chosenMenuIndex) {
            if (chosenMenuIndex == 0) {
              // If “Contacts” is selected, push a contacts cassette.
              childSpec = const CassetteSpec.contacts(
                ContactsCassetteSpec.contactPicker(),
              );
            } else {
              // For other menu entries, no child spec is defined yet.
              childSpec = null;
            }
          },
        );
      },
      contacts: (_) {
        // A contacts cassette currently has no child.
        childSpec = null;
      },
    );
    // Update the state: keep cassettes only up to and including the
    // updated index, then append the child spec if it exists.
    final truncated = updatedList.sublist(0, index + 1);
    if (childSpec != null) {
      state = state.copyWith(
        cassettes: List<CassetteSpec>.unmodifiable([...truncated, childSpec]),
      );
    } else {
      state = state.copyWith(
        cassettes: List<CassetteSpec>.unmodifiable(truncated),
      );
    }
  }

  /// Find the most recently selected contact ID in the cassette stack.
  ///
  /// This method scans the cassettes from the last (deepest) to the first,
  /// looking for a [CassetteSpec.contacts] variant.  Once found, it
  /// examines the underlying [ContactsCassetteSpec] and returns the
  /// `chosenContactId`, regardless of whether the spec is a
  /// [ContactsCassetteSpec.contactsFlatMenu] or
  /// [ContactsCassetteSpec.contactPicker].  If no contact has been
  /// selected yet, it returns null.
  int? findLatestContactId() {
    for (final spec in state.cassettes.reversed) {
      final result = spec.when(
        sidebarUtility: (_) => null,
        contacts: (contactsSpec) {
          return contactsSpec.when(
            contactsFlatMenu: (chosenContactId) => chosenContactId,
            contactPicker: (chosenContactId) => chosenContactId,
          );
        },
      );
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
