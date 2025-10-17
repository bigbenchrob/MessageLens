// panel_switcher.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/features/chats_spec.dart';
import '../domain/entities/panel_stack.dart';
import '../domain/entities/view_spec.dart';
import '../domain/navigation_constants.dart';

part 'panels_view_state_provider.g.dart';

@riverpod
class PanelsViewState extends _$PanelsViewState {
  int _pageIdSeed = 0;

  /// Map from WindowPanel -> stack of pages to render.
  @override
  Map<WindowPanel, PanelStack> build() {
    return {
      WindowPanel.left: PanelStack(
        pages: <PanelPage>[
          _createPage(
            spec: const ViewSpec.chats(ChatsSpec.recent(limit: 5)),
            title: 'Chats',
            isClosable: false,
          ),
        ],
      ),
      WindowPanel.center: const PanelStack.empty(),
      WindowPanel.right: const PanelStack.empty(),
    };
  }

  void show({required WindowPanel panel, required ViewSpec spec}) {
    final page = _createPage(
      spec: spec,
      title: _defaultTitleFor(spec),
      isClosable: false,
    );
    state = {
      ...state,
      panel: PanelStack(pages: <PanelPage>[page]),
    };
  }

  void push({
    required WindowPanel panel,
    required ViewSpec spec,
    String? title,
    bool isClosable = true,
  }) {
    final current = state[panel] ?? const PanelStack.empty();
    final page = _createPage(
      spec: spec,
      title: title ?? _defaultTitleFor(spec),
      isClosable: isClosable,
    );
    state = {...state, panel: current.push(page)};
  }

  void activate({required WindowPanel panel, required int index}) {
    final current = state[panel];
    if (current == null) {
      return;
    }
    state = {...state, panel: current.activate(index)};
  }

  void pop(WindowPanel panel) {
    final current = state[panel];
    if (current == null || current.pages.isEmpty) {
      return;
    }
    final lastPage = current.pages.last;
    if (current.pages.length == 1 && !lastPage.isClosable) {
      return;
    }
    state = {...state, panel: current.pop()};
  }

  void closeAt({required WindowPanel panel, required int index}) {
    final current = state[panel];
    if (current == null || current.pages.isEmpty) {
      return;
    }
    final page = current.pages[index];
    if (!page.isClosable) {
      return;
    }
    state = {...state, panel: current.removeAt(index)};
  }

  PanelPage _createPage({
    required ViewSpec spec,
    required String title,
    required bool isClosable,
  }) {
    final id = 'panel-page-${_pageIdSeed++}';
    return PanelPage(id: id, spec: spec, title: title, isClosable: isClosable);
  }

  String _defaultTitleFor(ViewSpec spec) {
    return spec.map(
      messages: (_) => 'Messages',
      chats: (_) => 'Chats',
      contacts: (_) => 'Contacts',
      import: (_) => 'Import',
      settings: (_) => 'Settings',
      workbench: (_) => 'Workbench',
    );
  }
}

// /// Convenience family to watch a single panel.
// @riverpod
// ViewSpec? panelViewFor(PanelViewForRef ref, WindowPanel panel) {
//   return ref.watch(panelViewsNotifierProvider)[panel];
// }
