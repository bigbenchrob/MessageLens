import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/cassette_rack_state.dart';
import '../domain/entities/cassette_spec.dart';
import '../domain/entities/features/sidebar_widget_cassette_spec.dart';

part 'cassette_rack_state_provider.g.dart';

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
    return CassetteRack.initialTopChatMenu();
  }

  /// Reset to the simple single top‑menu tracer bullet state.
  void resetToInitial() {
    state = CassetteRack.initialTopChatMenu();
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
    final topMenu = CassetteSpec.sidebarWidget(
      SidebarWidgetCassetteSpec.topChatMenu(
        chosenMenuIndex:
            chosenMenuIndex ??
            const SidebarWidgetCassetteSpec.topChatMenu().chosenMenuIndex,
      ),
    );
    if (state.cassettes.isEmpty) {
      state = state.copyWith(cassettes: [topMenu]);
    } else {
      final rest = state.cassettes.skip(1).toList();
      state = state.copyWith(cassettes: [topMenu, ...rest]);
    }
  }
}
