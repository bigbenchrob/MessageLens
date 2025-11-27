import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../navigation/domain/entities/features/sidebar_root_spec.dart';
import '../domain/entities/sidebar_element_spec.dart';
import '../domain/entities/sidebar_layout_state.dart';
import '../domain/sidebar_constants.dart';

part 'sidebar_layout_provider.g.dart';

@riverpod
class SidebarLayout extends _$SidebarLayout {
  @override
  SidebarLayoutState build(SidebarRootSpec root) {
    return SidebarLayoutState(root: root, elements: _initialElementsFor(root));
  }

  void replaceTailFrom(String id, List<SidebarElementSpec> newTail) {
    final idx = state.elements.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final head = state.elements.take(idx + 1).toList();
    state = state.copyWith(elements: [...head, ...newTail]);
  }

  void clearTailFrom(String id) {
    replaceTailFrom(id, const []);
  }

  List<SidebarElementSpec> _initialElementsFor(SidebarRootSpec root) =>
      root.map(
        contacts: (_) => [
          SidebarElementSpec(
            id: 'top-menu',
            kind: SidebarElementKind.topMenu,
            payload: const TopMenuPayload(),
          ),
          SidebarElementSpec(
            id: 'contacts-picker',
            kind: SidebarElementKind.contactsPicker,
            payload: const ContactsPickerPayload(),
          ),
        ],
        unmatched: (_) => [
          SidebarElementSpec(
            id: 'top-menu',
            kind: SidebarElementKind.topMenu,
            payload: const TopMenuPayload(),
          ),
          SidebarElementSpec(
            id: 'unmatched-type',
            kind: SidebarElementKind.unmatchedTypeFilter,
            payload: const UnmatchedTypeFilterPayload(),
          ),
          SidebarElementSpec(
            id: 'unmatched-subfilter',
            kind: SidebarElementKind.unmatchedSubFilter,
            payload: const UnmatchedSubFilterPayload(),
          ),
          SidebarElementSpec(
            id: 'unmatched-list',
            kind: SidebarElementKind.unmatchedChatList,
            payload: const UnmatchedChatListPayload(),
          ),
        ],
        allMessages: (_) => [
          // etc.
        ],
      );
}
