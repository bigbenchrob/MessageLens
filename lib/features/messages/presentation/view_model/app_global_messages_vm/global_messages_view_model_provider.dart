import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/search/application/search_service.dart';
import '../../../infrastructure/data_sources/global_message_index_data_source.dart';
import '../shared/hydration/messages_for_handle_provider.dart';
import 'jump/global_messages_ordinal_provider.dart';
import 'search/global_message_search_provider.dart';

part 'global_messages_view_model_provider.g.dart';

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
  final AsyncValue<List<MessageListItem>> searchResults;

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
      searchResults: const AsyncValue<List<MessageListItem>>.data(
        <MessageListItem>[],
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
        searchResults: const AsyncValue<List<MessageListItem>>.data(
          <MessageListItem>[],
        ),
        ordinal: state.ordinal,
      );
      return;
    }

    state = GlobalMessagesViewModelState(
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: state.debouncedQuery,
      searchMode: state.searchMode,
      filters: state.filters,
      searchResults: const AsyncValue<List<MessageListItem>>.loading(),
      ordinal: state.ordinal,
    );

    try {
      // We don't await here to avoid blocking the UI thread, but we do want to
      // capture the future to update state when it completes.
      // However, since we are in a void method, we can't await.
      // But wait, this method is void. We should probably make it async or use .then().
      // Actually, the pattern in ContactMessagesViewModel is async.
      // Let's change this method to async.
      _executeSearch(trimmed);
    } catch (error, stackTrace) {
      state = GlobalMessagesViewModelState(
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchMode: state.searchMode,
        filters: state.filters,
        searchResults: AsyncValue<List<MessageListItem>>.error(
          error,
          stackTrace,
        ),
        ordinal: state.ordinal,
      );
    }
  }

  Future<void> _executeSearch(String query) async {
    try {
      final mode = state.searchMode == GlobalMessagesSearchMode.allTerms
          ? SearchMode.allTerms
          : SearchMode.anyTerm;

      final results = await ref.read(
        globalMessageSearchResultsProvider(query: query, mode: mode).future,
      );

      // Check if the query is still relevant
      if (state.debouncedQuery != query) {
        return;
      }

      state = GlobalMessagesViewModelState(
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchMode: state.searchMode,
        filters: state.filters,
        searchResults: AsyncValue<List<MessageListItem>>.data(results),
        ordinal: state.ordinal,
      );
    } catch (error, stackTrace) {
      if (state.debouncedQuery != query) {
        return;
      }
      state = GlobalMessagesViewModelState(
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchMode: state.searchMode,
        filters: state.filters,
        searchResults: AsyncValue<List<MessageListItem>>.error(
          error,
          stackTrace,
        ),
        ordinal: state.ordinal,
      );
    }
  }

  void setSearchMode(GlobalMessagesSearchMode mode) {
    if (state.searchMode == mode) {
      return;
    }

    state = GlobalMessagesViewModelState(
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: state.debouncedQuery,
      searchMode: mode,
      filters: state.filters,
      searchResults: state.searchResults,
      ordinal: state.ordinal,
    );

    if (state.debouncedQuery.isNotEmpty) {
      state = GlobalMessagesViewModelState(
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchMode: state.searchMode,
        filters: state.filters,
        searchResults: const AsyncValue<List<MessageListItem>>.loading(),
        ordinal: state.ordinal,
      );
      _executeSearch(state.debouncedQuery);
    }
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

  Future<void> jumpToMonth(DateTime date) async {
    debugPrint('🔍 GlobalMessagesVM.jumpToMonth called with date: $date');
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final dataSource = GlobalMessageIndexDataSource(db);
    final ordinal = await dataSource.firstOrdinalOnOrAfter(date);

    debugPrint('🔍 Found ordinal: $ordinal for date: $date');

    if (ordinal != null) {
      debugPrint('🔍 Attempting to scroll to ordinal: $ordinal');
      await ref.read(globalMessagesOrdinalProvider.notifier).scrollTo(ordinal);
      debugPrint('🔍 Scroll to ordinal complete');
    } else {
      debugPrint('⚠️ No ordinal found for date: $date');
    }
  }
}
