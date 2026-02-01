import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../navigation/domain/sidebar_mode.dart';
import '../feature_level_providers.dart';

part 'cassette_rack_state_provider.freezed.dart';
part 'cassette_rack_state_provider.g.dart';

List<CassetteSpec> _cascadeFromSpec(CassetteSpec root) {
  final chain = <CassetteSpec>[root];
  var next = root.childSpec();
  while (next != null) {
    chain.add(next);
    next = next.childSpec();
  }
  return List<CassetteSpec>.unmodifiable(chain);
}

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
    const topMenu = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.topChatMenu(),
    );
    return CassetteRack(cassettes: _cascadeFromSpec(topMenu));
  }

  /// Returns a fresh [CassetteRack] containing a single settings menu
  /// cassette.
  factory CassetteRack.settingsInitial() {
    const settingsMenu = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.settingsMenu(),
    );
    return CassetteRack(cassettes: _cascadeFromSpec(settingsMenu));
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
  CassetteRack build(SidebarMode mode) {
    switch (mode) {
      case SidebarMode.messages:
        return CassetteRack.initial();
      case SidebarMode.settings:
        return CassetteRack.settingsInitial();
    }
  }

  /// Reset to the simple single top‑menu tracer bullet state.
  void resetToInitial() {
    switch (mode) {
      case SidebarMode.messages:
        state = CassetteRack.initial();
      case SidebarMode.settings:
        state = CassetteRack.settingsInitial();
    }
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
    state = state.copyWith(
      cassettes: [...state.cassettes, ..._cascadeFromSpec(spec)],
    );
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
  // void setTopChatMenu({TopChatMenuChoice chosenTopMenuChoice}) {
  //   final topMenu = const CassetteSpec.sidebarUtility(
  //     SidebarUtilityCassetteSpec.topChatMenu(
  //       selectedChoice:
  //           selectedChoice ??
  //           SidebarUtilityCassetteSpec.topChatMenu().chosenMenuIndex,
  //     ),
  //   );
  //   state = state.copyWith(cassettes: _cascadeFromSpec(topMenu));
  // }

  /// Update a cassette at its current position by matching the old spec,
  /// and optionally append a child cassette based on the new spec.  This
  /// method takes both the old and new specs so that the caller doesn’t
  /// need to know the index of the cassette in the stack.  If the old
  /// spec isn’t found, no action is taken.
  ///
  /// **Deprecated**: Prefer [replaceAtIndexAndCascade] which avoids requiring
  /// widgets to hold specs in state. This method will be removed once all
  /// callers are migrated.
  void updateSpecAndChild(CassetteSpec oldSpec, CassetteSpec newSpec) {
    final index = state.cassettes.indexOf(oldSpec);
    if (index < 0) {
      return;
    }
    final preserved = state.cassettes.take(index).toList(growable: false);
    final cascaded = _cascadeFromSpec(newSpec);
    state = state.copyWith(
      cassettes: List<CassetteSpec>.unmodifiable([...preserved, ...cascaded]),
    );
  }

  /// Replace the cassette at [index] with [newSpec] and re-cascade children.
  ///
  /// This is the preferred method for widgets to update their cassette spec
  /// in response to user interaction. The widget receives its [index] from
  /// the resolver (which received it from the coordinator), constructs the
  /// new spec locally, and calls this method.
  ///
  /// This approach avoids requiring widgets to hold the old spec in state,
  /// which would violate the cross-surface spec system rules.
  ///
  /// If the index is out of bounds, this is a no-op.
  void replaceAtIndexAndCascade(int index, CassetteSpec newSpec) {
    if (index < 0 || index >= state.cassettes.length) {
      return;
    }
    final preserved = state.cassettes.take(index).toList(growable: false);
    final cascaded = _cascadeFromSpec(newSpec);
    state = state.copyWith(
      cassettes: List<CassetteSpec>.unmodifiable([...preserved, ...cascaded]),
    );
  }

  /// Find the most recently selected contact ID in the cassette stack.
  ///
  /// This method scans the cassettes from the last (deepest) to the first,
  /// looking for a [CassetteSpec.contacts] variant.  Once found, it
  /// examines the underlying [ContactsCassetteSpec] and returns the
  /// `chosenContactId`, regardless of whether the spec is a
  /// [ContactsCassetteSpec.contactsFlatMenu],
  /// [ContactsCassetteSpec.contactsEnhancedPicker], or
  /// [ContactsCassetteSpec.contactHeroSummary]. If no contact has been
  /// selected yet, it returns null.
  int? findLatestContactId() {
    for (final spec in state.cassettes.reversed) {
      final result = spec.when(
        sidebarUtility: (_) => null,
        presentation: (_) => null,
        contacts: (contactsSpec) {
          return contactsSpec.when(
            contactChooser: (chosenContactId) => chosenContactId,
            contactHeroSummary: (chosenContactId) => chosenContactId,
          );
        },
        contactsSettings: (_) => null,
        contactsInfo: (_) => null,
        handles: (_) => null,
        handlesInfo: (_) => null,
        messages: (_) => null,
      );
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
