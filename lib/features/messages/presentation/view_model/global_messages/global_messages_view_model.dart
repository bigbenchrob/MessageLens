import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../messages_for_chat_provider.dart';
import 'jump/global_messages_ordinal_provider.dart';

part 'global_messages_view_model.g.dart';

class GlobalMessagesFilters {
  const GlobalMessagesFilters({
    required this.correspondentsScope,
    required this.sortOrder,
  });

  const GlobalMessagesFilters.defaults()
    : correspondentsScope = GlobalMessagesCorrespondentsScope.all,
      sortOrder = GlobalMessagesSortOrder.date;

  final GlobalMessagesCorrespondentsScope correspondentsScope;
  final GlobalMessagesSortOrder sortOrder;

  GlobalMessagesFilters copyWith({
    GlobalMessagesCorrespondentsScope? correspondentsScope,
    GlobalMessagesSortOrder? sortOrder,
  }) {
    return GlobalMessagesFilters(
      correspondentsScope: correspondentsScope ?? this.correspondentsScope,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

enum GlobalMessagesCorrespondentsScope { all, knownContacts, unknownSenders }

enum GlobalMessagesSortOrder { date, dateReversed }

enum GlobalMessagesSearchMode { allTerms, anyTerm }

class GlobalMessagesViewModelState {
  const GlobalMessagesViewModelState({
    required this.searchController,
    required this.searchQuery,
    required this.debouncedQuery,
    required this.searchMode,
    required this.filters,
    required this.searchResults,
    required this.ordinal,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final String debouncedQuery;
  final GlobalMessagesSearchMode searchMode;
  final GlobalMessagesFilters filters;

  // Placeholder shape for now: we’ll swap to a global-specific search row model.
  final AsyncValue<List<ChatMessageListItem>> searchResults;

  // Used for browse-mode skeleton + hydration.
  final AsyncValue<GlobalMessagesOrdinalState> ordinal;

  bool get isSearching => debouncedQuery.trim().isNotEmpty;
}

@riverpod
class GlobalMessagesViewModel extends _$GlobalMessagesViewModel {
  TextEditingController? _searchController;
  Timer? _debounce;
  bool _listenerAttached = false;

  @override
  GlobalMessagesViewModelState build() {
    _searchController ??= TextEditingController();

    ref.onDispose(() {
      _debounce?.cancel();
      if (_listenerAttached) {
        _searchController?.removeListener(_onSearchControllerChanged);
        _listenerAttached = false;
      }
      _searchController?.dispose();
      _searchController = null;
    });

    if (!_listenerAttached) {
      _searchController!.addListener(_onSearchControllerChanged);
      _listenerAttached = true;
    }

    final ordinal = ref.watch(globalMessagesOrdinalProvider);

    return GlobalMessagesViewModelState(
      searchController: _searchController!,
      searchQuery: '',
      debouncedQuery: '',
      searchMode: GlobalMessagesSearchMode.allTerms,
      filters: const GlobalMessagesFilters.defaults(),
      searchResults: const AsyncValue<List<ChatMessageListItem>>.data(
        <ChatMessageListItem>[],
      ),
      ordinal: ordinal,
    );
  }

  void _onSearchControllerChanged() {
    final controller = _searchController;
    if (controller == null) {
      return;
    }

    _setSearchQuery(controller.text);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final controller = _searchController;
      if (controller == null) {
        return;
      }
      _setDebouncedQuery(controller.text);
    });
  }

  void _setSearchQuery(String value) {
    state = GlobalMessagesViewModelState(
      searchController: state.searchController,
      searchQuery: value,
      debouncedQuery: state.debouncedQuery,
      searchMode: state.searchMode,
      filters: state.filters,
      searchResults: state.searchResults,
      ordinal: state.ordinal,
    );
  }

  void _setDebouncedQuery(String value) {
    final trimmed = value.trim();
    if (trimmed == state.debouncedQuery) {
      return;
    }

    state = GlobalMessagesViewModelState(
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: trimmed,
      searchMode: state.searchMode,
      filters: state.filters,
      searchResults: state.searchResults,
      ordinal: state.ordinal,
    );

    if (trimmed.isEmpty) {
      state = GlobalMessagesViewModelState(
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchMode: state.searchMode,
        filters: state.filters,
        searchResults: const AsyncValue<List<ChatMessageListItem>>.data(
          <ChatMessageListItem>[],
        ),
        ordinal: state.ordinal,
      );
    }

    // TODO(Ftr.global): wire real global search providers + helpers.
  }

  void setSearchMode(GlobalMessagesSearchMode mode) {
    state = GlobalMessagesViewModelState(
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: state.debouncedQuery,
      searchMode: mode,
      filters: state.filters,
      searchResults: state.searchResults,
      ordinal: state.ordinal,
    );

    // TODO(Ftr.global): re-run search if needed.
  }

  void setFilters(GlobalMessagesFilters filters) {
    state = GlobalMessagesViewModelState(
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: state.debouncedQuery,
      searchMode: state.searchMode,
      filters: filters,
      searchResults: state.searchResults,
      ordinal: state.ordinal,
    );

    // TODO(Ftr.global): when filters affect browse/search, re-run queries here.
  }

  Future<void> jumpToLatest() async {
    await ref.read(globalMessagesOrdinalProvider.notifier).jumpToLatest();
  }
}
