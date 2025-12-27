// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_visible_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentVisibleMonthHash() =>
    r'eac73caf8261661133e61efd717c97a336c912b8';

/// Tracks the currently visible month based on scroll position
/// Returns monthKey in format "YYYY-MM" (e.g., "2025-12")
///
/// Copied from [currentVisibleMonth].
@ProviderFor(currentVisibleMonth)
final currentVisibleMonthProvider = AutoDisposeStreamProvider<String?>.internal(
  currentVisibleMonth,
  name: r'currentVisibleMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentVisibleMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentVisibleMonthRef = AutoDisposeStreamProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
