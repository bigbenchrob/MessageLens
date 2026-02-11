import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/view_spec/resolver_tools/global_message_timeline_provider.dart';

part 'global_timeline_controller.g.dart';

const int _globalTimelineDefaultPageSize = 100;

class GlobalTimelineState {
  const GlobalTimelineState({
    required this.items,
    required this.totalCount,
    required this.hasMoreBefore,
    required this.hasMoreAfter,
    this.isLoadingBefore = false,
    this.isLoadingAfter = false,
  });

  const GlobalTimelineState.empty()
    : items = const [],
      totalCount = 0,
      hasMoreBefore = false,
      hasMoreAfter = false,
      isLoadingBefore = false,
      isLoadingAfter = false;

  factory GlobalTimelineState.fromPage(GlobalMessageTimelinePage page) {
    if (page.totalCount == 0) {
      return const GlobalTimelineState.empty();
    }
    return GlobalTimelineState(
      items: page.items,
      totalCount: page.totalCount,
      hasMoreBefore: page.hasMoreBefore,
      hasMoreAfter: page.hasMoreAfter,
    );
  }

  final List<GlobalMessageTimelineItem> items;
  final int totalCount;
  final bool hasMoreBefore;
  final bool hasMoreAfter;
  final bool isLoadingBefore;
  final bool isLoadingAfter;

  bool get isEmpty => items.isEmpty;

  GlobalTimelineState copyWith({
    List<GlobalMessageTimelineItem>? items,
    int? totalCount,
    bool? hasMoreBefore,
    bool? hasMoreAfter,
    bool? isLoadingBefore,
    bool? isLoadingAfter,
  }) {
    return GlobalTimelineState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      hasMoreBefore: hasMoreBefore ?? this.hasMoreBefore,
      hasMoreAfter: hasMoreAfter ?? this.hasMoreAfter,
      isLoadingBefore: isLoadingBefore ?? this.isLoadingBefore,
      isLoadingAfter: isLoadingAfter ?? this.isLoadingAfter,
    );
  }
}

@riverpod
class GlobalTimelineController extends _$GlobalTimelineController {
  late int _pageSize;
  int? _initialStartAfter;
  int? _initialEndBefore;

  @override
  Future<GlobalTimelineState> build({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
    int pageSize = _globalTimelineDefaultPageSize,
  }) async {
    if (startAfterOrdinal != null && endBeforeOrdinal != null) {
      throw ArgumentError(
        'startAfterOrdinal and endBeforeOrdinal cannot both be provided.',
      );
    }

    _pageSize = pageSize;
    _initialStartAfter = startAfterOrdinal;
    _initialEndBefore = endBeforeOrdinal;

    final page = await _fetchPage(
      startAfterOrdinal: startAfterOrdinal,
      endBeforeOrdinal: endBeforeOrdinal,
    );

    return GlobalTimelineState.fromPage(page);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final page = await _fetchPage(
        startAfterOrdinal: _initialStartAfter,
        endBeforeOrdinal: _initialEndBefore,
      );
      return GlobalTimelineState.fromPage(page);
    });
  }

  Future<void> jumpToNewest() async {
    final current = state.valueOrNull;
    if (current == null) {
      await refresh();
      return;
    }
    await _replaceWithPageFrom(endBeforeOrdinal: current.totalCount);
  }

  Future<void> jumpToOldest() async {
    await refresh();
  }

  Future<bool> jumpToDate(DateTime date) async {
    final ordinal = await ref.read(
      globalTimelineOrdinalForDateProvider(date).future,
    );
    if (ordinal == null) {
      return false;
    }

    final totalCount = state.valueOrNull?.totalCount;
    if (totalCount != null && totalCount > 0) {
      final tailThreshold = totalCount - (_pageSize ~/ 2);
      if (ordinal >= tailThreshold) {
        await _replaceWithPageFrom(endBeforeOrdinal: totalCount);
        return true;
      }
    }

    final startCandidate = ordinal - (_pageSize ~/ 2);
    final startAfterOrdinal = startCandidate <= 0 ? null : startCandidate - 1;

    await _replaceWithPageFrom(startAfterOrdinal: startAfterOrdinal);
    return true;
  }

  Future<void> loadMoreAfter() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMoreAfter || current.isLoadingAfter) {
      return;
    }

    state = AsyncValue.data(current.copyWith(isLoadingAfter: true));

    try {
      if (current.items.isEmpty) {
        await refresh();
        return;
      }

      final page = await _fetchPage(
        startAfterOrdinal: current.items.last.ordinal,
      );

      final nextItems = _mergeAfter(current.items, page.items);

      state = AsyncValue.data(
        current.copyWith(
          items: nextItems,
          totalCount: page.totalCount,
          hasMoreAfter: page.hasMoreAfter,
          hasMoreBefore: current.hasMoreBefore || page.hasMoreBefore,
          isLoadingAfter: false,
        ),
      );
    } catch (err, stackTrace) {
      state = AsyncValue.error(err, stackTrace);
    }
  }

  Future<void> loadMoreBefore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMoreBefore || current.isLoadingBefore) {
      return;
    }

    state = AsyncValue.data(current.copyWith(isLoadingBefore: true));

    try {
      if (current.items.isEmpty) {
        await refresh();
        return;
      }

      final page = await _fetchPage(
        endBeforeOrdinal: current.items.first.ordinal,
      );

      final nextItems = _mergeBefore(current.items, page.items);

      state = AsyncValue.data(
        current.copyWith(
          items: nextItems,
          totalCount: page.totalCount,
          hasMoreBefore: page.hasMoreBefore,
          hasMoreAfter: current.hasMoreAfter || page.hasMoreAfter,
          isLoadingBefore: false,
        ),
      );
    } catch (err, stackTrace) {
      state = AsyncValue.error(err, stackTrace);
    }
  }

  Future<GlobalMessageTimelinePage> _fetchPage({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
  }) {
    return ref.read(
      globalMessageTimelineProvider(
        startAfterOrdinal: startAfterOrdinal,
        endBeforeOrdinal: endBeforeOrdinal,
        pageSize: _pageSize,
      ).future,
    );
  }

  Future<void> _replaceWithPageFrom({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final page = await _fetchPage(
        startAfterOrdinal: startAfterOrdinal,
        endBeforeOrdinal: endBeforeOrdinal,
      );
      return GlobalTimelineState.fromPage(page);
    });
  }

  List<GlobalMessageTimelineItem> _mergeAfter(
    List<GlobalMessageTimelineItem> current,
    List<GlobalMessageTimelineItem> additions,
  ) {
    if (additions.isEmpty) {
      return current;
    }
    final existingOrdinals = current.map((e) => e.ordinal).toSet();
    final filtered = additions
        .where((item) => !existingOrdinals.contains(item.ordinal))
        .toList(growable: false);
    if (filtered.isEmpty) {
      return current;
    }
    return [...current, ...filtered];
  }

  List<GlobalMessageTimelineItem> _mergeBefore(
    List<GlobalMessageTimelineItem> current,
    List<GlobalMessageTimelineItem> additions,
  ) {
    if (additions.isEmpty) {
      return current;
    }
    final existingOrdinals = current.map((e) => e.ordinal).toSet();
    final filtered = additions
        .where((item) => !existingOrdinals.contains(item.ordinal))
        .toList(growable: false);
    if (filtered.isEmpty) {
      return current;
    }
    return [...filtered, ...current];
  }
}
