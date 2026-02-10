import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../shared/hydration/messages_for_handle_provider.dart';
import 'hydration/message_by_contact_ordinal_provider.dart';
import 'jump/contact_messages_ordinal_provider.dart';
import 'search/contact_message_search_provider.dart';

export 'hydration/message_by_contact_ordinal_provider.dart';
export 'jump/contact_messages_ordinal_provider.dart';

part 'contact_messages_view_model_provider.g.dart';

/// Entrypoint facade for the "Messages for Contact" display pipeline.
///
/// This file exists to make the mental model obvious:
/// - Ordinal list + jump helpers: [contactMessagesOrdinalProvider]
/// - Per-row hydration: [messageByContactOrdinalProvider]
///
/// The view should generally depend on this file (and UI widgets), not on a
/// scattered set of providers.

class ContactMessagesViewModelState {
  const ContactMessagesViewModelState({
    required this.contactId,
    required this.searchController,
    required this.searchQuery,
    required this.debouncedQuery,
    required this.searchResults,
    required this.ordinal,
  });

  final int contactId;
  final TextEditingController searchController;
  final String searchQuery;
  final String debouncedQuery;
  final AsyncValue<List<MessageListItem>> searchResults;
  final AsyncValue<ContactMessagesOrdinalState> ordinal;

  bool get isSearching => debouncedQuery.trim().isNotEmpty;
}

@riverpod
class ContactMessagesViewModel extends _$ContactMessagesViewModel {
  TextEditingController? _searchController;
  Timer? _debounce;
  bool _listenerAttached = false;

  @override
  ContactMessagesViewModelState build({required int contactId}) {
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

    // If build() re-runs, avoid double-attaching the listener.
    if (!_listenerAttached) {
      _searchController!.addListener(_onSearchControllerChanged);
      _listenerAttached = true;
    }

    // Cancel any pending debounce when rebuilding with new dependencies.
    _debounce?.cancel();

    final ordinal = ref.watch(
      contactMessagesOrdinalProvider(contactId: contactId),
    );
    const debouncedQuery = '';
    const searchResults = AsyncValue<List<MessageListItem>>.data(
      <MessageListItem>[],
    );

    return ContactMessagesViewModelState(
      contactId: contactId,
      searchController: _searchController!,
      searchQuery: '',
      debouncedQuery: debouncedQuery,
      searchResults: searchResults,
      ordinal: ordinal,
    );
  }

  void _onSearchControllerChanged() {
    final controller = _searchController;
    if (controller == null) {
      return;
    }

    setSearchQuery(controller.text);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final controller = _searchController;
      if (controller == null) {
        return;
      }
      setDebouncedQuery(controller.text);
    });
  }

  void setSearchQuery(String value) {
    state = ContactMessagesViewModelState(
      contactId: state.contactId,
      searchController: state.searchController,
      searchQuery: value,
      debouncedQuery: state.debouncedQuery,
      searchResults: state.searchResults,
      ordinal: state.ordinal,
    );
  }

  Future<void> setDebouncedQuery(String value) async {
    final trimmed = value.trim();
    if (trimmed == state.debouncedQuery) {
      return;
    }

    state = ContactMessagesViewModelState(
      contactId: state.contactId,
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: trimmed,
      searchResults: state.searchResults,
      ordinal: state.ordinal,
    );

    if (trimmed.isEmpty) {
      state = ContactMessagesViewModelState(
        contactId: state.contactId,
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchResults: const AsyncValue<List<MessageListItem>>.data(
          <MessageListItem>[],
        ),
        ordinal: state.ordinal,
      );
      return;
    }

    state = ContactMessagesViewModelState(
      contactId: state.contactId,
      searchController: state.searchController,
      searchQuery: state.searchQuery,
      debouncedQuery: state.debouncedQuery,
      searchResults: const AsyncValue<List<MessageListItem>>.loading(),
      ordinal: state.ordinal,
    );

    try {
      final results = await ref.read(
        contactMessageSearchResultsProvider(
          contactId: state.contactId,
          query: trimmed,
        ).future,
      );

      state = ContactMessagesViewModelState(
        contactId: state.contactId,
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchResults: AsyncValue<List<MessageListItem>>.data(results),
        ordinal: state.ordinal,
      );
    } catch (error, stackTrace) {
      state = ContactMessagesViewModelState(
        contactId: state.contactId,
        searchController: state.searchController,
        searchQuery: state.searchQuery,
        debouncedQuery: state.debouncedQuery,
        searchResults: AsyncValue<List<MessageListItem>>.error(
          error,
          stackTrace,
        ),
        ordinal: state.ordinal,
      );
    }
  }

  Future<void> jumpToMonthKey(String monthKey) async {
    await ref
        .read(
          contactMessagesOrdinalProvider(contactId: state.contactId).notifier,
        )
        .jumpToMonth(monthKey);
  }

  Future<void> jumpToMonthForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month);
    final monthKey =
        '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}';
    await jumpToMonthKey(monthKey);
  }

  Future<void> jumpToLatest() async {
    await ref
        .read(
          contactMessagesOrdinalProvider(contactId: state.contactId).notifier,
        )
        .jumpToLatest();
  }
}
