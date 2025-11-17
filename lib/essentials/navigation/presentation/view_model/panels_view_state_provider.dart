import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/features/contacts_list_spec.dart';
import '../../domain/entities/features/sidebar_spec.dart';
import '../../domain/entities/panel_stack.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/navigation_constants.dart';

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
            spec: const ViewSpec.sidebar(
              SidebarSpec.contacts(listMode: ContactsListSpec.all()),
            ),
            title: 'Contacts',
            isClosable: false,
          ),
        ],
      ),
      WindowPanel.center: const PanelStack.empty(),
      WindowPanel.right: const PanelStack.empty(),
    };
  }

  // Show a new panel stack with a single page, replacing any existing stack.
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

  // Push a new page onto the stack for the specified panel.
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

  // Activate a page at the specified index for the given panel.
  void activate({required WindowPanel panel, required int index}) {
    final current = state[panel];
    if (current == null) {
      return;
    }
    state = {...state, panel: current.activate(index)};
  }

  // Pop the top page off the stack for the specified panel.
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

  // Close the page at the specified index for the given panel.
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

  // Clear the panel, setting it to empty.
  void clear({required WindowPanel panel}) {
    state = {...state, panel: const PanelStack.empty()};
  }

  /// Create a new panel page with the given specifications.
  PanelPage _createPage({
    required ViewSpec spec,
    required String title,
    required bool isClosable,
  }) {
    final id = 'panel-page-${_pageIdSeed++}';
    return PanelPage(id: id, spec: spec, title: title, isClosable: isClosable);
  }

  /// Get a default title for a given view spec.
  String _defaultTitleFor(ViewSpec spec) {
    return spec.map(
      messages: (_) => 'Messages',
      chats: (_) => 'Chats',
      contacts: (_) => 'Contacts',
      import: (_) => 'Import',
      settings: (_) => 'Settings',
      workbench: (_) => 'Workbench',
      sidebar: (_) => 'Sidebar',
    );
  }
}
