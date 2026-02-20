import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/search/application/search_service.dart';
import '../../../../../essentials/search/feature_level_providers.dart';
import '../../../domain/value_objects/message_timeline_scope.dart';
import 'ordinal/message_timeline_ordinal_provider.dart';

part 'message_timeline_view_model_provider.g.dart';

/// Search mode for message queries.
///
/// Currently only used by global scope, but defined here for future expansion.
enum MessageSearchMode {
  /// All search terms must match.
  allTerms,

  /// Any search term can match.
  anyTerm,
}

/// Unified state for message timeline views.
///
/// Works across all scopes (global, contact, chat) with a common structure.
class MessageTimelineViewModelState {
  const MessageTimelineViewModelState({
    required this.scope,
    required this.searchController,
    required this.searchQuery,
    required this.debouncedQuery,
    required this.searchMode,
    required this.searchResultIds,
    required this.ordinal,
  });

  /// The scope this view model represents.
  final MessageTimelineScope scope;

  /// Controller for the search text field.
  final TextEditingController searchController;

  /// Current search query (tracks every keystroke).
  final String searchQuery;

  /// Debounced search query (triggers actual search).
  final String debouncedQuery;

  /// Search mode (all terms / any term). Currently global-only.
  final MessageSearchMode searchMode;

  /// Search result message IDs for virtual scrolling.
  final AsyncValue<List<int>> searchResultIds;

  /// Ordinal state for the message list.
  final AsyncValue<MessageTimelineOrdinalState> ordinal;

  /// Whether the view is in search mode.
  bool get isSearching => debouncedQuery.trim().isNotEmpty;

  /// Number of search results (for display).
  int get searchResultCount => searchResultIds.valueOrNull?.length ?? 0;
}

/// Unified view model provider for message timelines.
///
/// Manages search, debounce, and coordinates with the ordinal provider.
/// Works for all scopes (global, contact, chat).
@riverpod
class MessageTimelineViewModel extends _$MessageTimelineViewModel {
  TextEditingController? _searchController;
  Timer? _debounce;
  bool _listenerAttached = false;

  @override
  MessageTimelineViewModelState build({required MessageTimelineScope scope}) {
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

    // Watch the unified ordinal provider for this scope
    final ordinal = ref.watch(messageTimelineOrdinalProvider(scope: scope));

    return MessageTimelineViewModelState(
      scope: scope,
      searchController: _searchController!,
      searchQuery: '',
      debouncedQuery: '',
      searchMode: MessageSearchMode.allTerms,
      searchResultIds: const AsyncValue<List<int>>.data([]),
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
    state = MessageTimelineViewModelState(
      scope: state.scope,
      searchController: state.searchController,
      searchQuery: value,
      debouncedQuery: state.debouncedQuery,
      searchMode: state.searchMode,
      searchResultIds: state.searchResultIds,
      ordinal: state.ordinal,
    );
  }

  Future<void> _setDebouncedQuery(String value) async {
    final trimmed = value.trim();
    if (trimmed == state.debouncedQuery) {
      return;
    }

    state = MessageTimelineViewModelState(
      scope: state.scope,
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: trimmed,
      searchMode: state.searchMode,
      searchResultIds: state.searchResultIds,
      ordinal: state.ordinal,
    );

    if (trimmed.isEmpty) {
      state = MessageTimelineViewModelState(
        scope: state.scope,
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchMode: state.searchMode,
        searchResultIds: const AsyncValue<List<int>>.data([]),
        ordinal: state.ordinal,
      );
      return;
    }

    state = MessageTimelineViewModelState(
      scope: state.scope,
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: state.debouncedQuery,
      searchMode: state.searchMode,
      searchResultIds: const AsyncValue<List<int>>.loading(),
      ordinal: state.ordinal,
    );

    await _executeSearch(trimmed);
  }

  Future<void> _executeSearch(String query) async {
    try {
      final searchService = ref.read(searchServiceProvider);
      final mode = state.searchMode == MessageSearchMode.allTerms
          ? SearchMode.allTerms
          : SearchMode.anyTerm;

      // Execute scope-specific search - returns just IDs for fast response
      final resultIds = await _searchForScope(searchService, query, mode);

      // Check if the query is still relevant
      if (state.debouncedQuery != query) {
        return;
      }

      state = MessageTimelineViewModelState(
        scope: state.scope,
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchMode: state.searchMode,
        searchResultIds: AsyncValue<List<int>>.data(resultIds),
        ordinal: state.ordinal,
      );
    } catch (error, stackTrace) {
      if (state.debouncedQuery != query) {
        return;
      }
      state = MessageTimelineViewModelState(
        scope: state.scope,
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchMode: state.searchMode,
        searchResultIds: AsyncValue<List<int>>.error(error, stackTrace),
        ordinal: state.ordinal,
      );
    }
  }

  Future<List<int>> _searchForScope(
    SearchService searchService,
    String query,
    SearchMode mode,
  ) async {
    return switch (state.scope) {
      GlobalTimelineScope() => searchService.searchGlobalMessageIds(
        query: query,
        mode: mode,
      ),
      ContactTimelineScope(:final contactId) =>
        searchService.searchContactMessageIds(
          contactId: contactId,
          query: query,
        ),
      ChatTimelineScope(:final chatId) => searchService.searchChatMessageIds(
        chatId: chatId,
        query: query,
      ),
    };
  }

  /// Set the search mode (all terms / any term).
  ///
  /// Currently only meaningful for global scope.
  void setSearchMode(MessageSearchMode mode) {
    if (state.searchMode == mode) {
      return;
    }

    state = MessageTimelineViewModelState(
      scope: state.scope,
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: state.debouncedQuery,
      searchMode: mode,
      searchResultIds: state.searchResultIds,
      ordinal: state.ordinal,
    );

    if (state.debouncedQuery.isNotEmpty) {
      state = MessageTimelineViewModelState(
        scope: state.scope,
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchMode: state.searchMode,
        searchResultIds: const AsyncValue<List<int>>.loading(),
        ordinal: state.ordinal,
      );
      _executeSearch(state.debouncedQuery);
    }
  }

  /// Jump to the latest (most recent) message.
  Future<void> jumpToLatest() async {
    await ref
        .read(messageTimelineOrdinalProvider(scope: state.scope).notifier)
        .jumpToLatest();
  }

  /// Jump to a specific month in the timeline.
  ///
  /// Month key format: 'YYYY-MM' (e.g., '2023-06')
  Future<void> jumpToMonth(String monthKey) async {
    await ref
        .read(messageTimelineOrdinalProvider(scope: state.scope).notifier)
        .jumpToMonth(monthKey);
  }

  /// Jump to a specific date in the timeline.
  Future<void> jumpToDate(DateTime date) async {
    await ref
        .read(messageTimelineOrdinalProvider(scope: state.scope).notifier)
        .jumpToDate(date);
  }
}
