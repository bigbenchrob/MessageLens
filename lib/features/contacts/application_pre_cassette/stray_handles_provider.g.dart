// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stray_handles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strayHandlesHash() => r'5371e05ac1902d6b895782cd248dbfd306b4e2aa';

/// Returns all handles that are truly "stray": no participant link in the
/// working DB AND no linked override (participant or virtual participant) in
/// the overlay DB.
///
/// Handles with an overlay row that has only `reviewed_at` set (both
/// participant IDs null) are still included — they are reviewed but unlinked.
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
