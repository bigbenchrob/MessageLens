// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stray_handles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strayHandlesHash() => r'd198b606bee289aa82b8f46e7acccaa6c59b1db6';

/// Returns all handles that are truly "stray": no participant link in the
/// working DB AND no linked override (participant or virtual participant) in
/// the overlay DB.
///
/// Handles with an overlay row that has only `reviewed_at` set (both
/// participant IDs null) are still included — they are reviewed but unlinked.
///
/// **Excludes dismissed handles** — those are only visible in the Dismissed
/// escape hatch view via [dismissedHandlesProvider].
///
/// Sorted by total message count descending (most messages first).
///
/// Copied from [strayHandles].
@ProviderFor(strayHandles)
final strayHandlesProvider =
    AutoDisposeFutureProvider<List<StrayHandleSummary>>.internal(
      strayHandles,
      name: r'strayHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$strayHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StrayHandlesRef =
    AutoDisposeFutureProviderRef<List<StrayHandleSummary>>;
String _$spamCandidateHandlesHash() =>
    r'f11874bcb1c15f4dab78cc276dd096a43f025558';

/// Returns only stray handles that match junk-like heuristics (junkScore >= 3).
///
/// Used for the "Spam / One-off" blitz-dismiss mode. Sorted by junk score
/// descending (most likely junk first).
///
/// Copied from [spamCandidateHandles].
@ProviderFor(spamCandidateHandles)
final spamCandidateHandlesProvider =
    AutoDisposeFutureProvider<List<StrayHandleSummary>>.internal(
      spamCandidateHandles,
      name: r'spamCandidateHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$spamCandidateHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SpamCandidateHandlesRef =
    AutoDisposeFutureProviderRef<List<StrayHandleSummary>>;
String _$dismissedHandlesHash() => r'9d636e75f470fe305fab1faa8803e5974403a8a7';

/// Returns only dismissed handles for the escape hatch view.
///
/// Note: This returns metadata about dismissed handles by looking them up
/// in the working database using their normalized values.
///
/// Copied from [dismissedHandles].
@ProviderFor(dismissedHandles)
final dismissedHandlesProvider =
    AutoDisposeFutureProvider<List<StrayHandleSummary>>.internal(
      dismissedHandles,
      name: r'dismissedHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dismissedHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DismissedHandlesRef =
    AutoDisposeFutureProviderRef<List<StrayHandleSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
