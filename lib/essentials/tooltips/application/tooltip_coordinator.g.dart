// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tooltip_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tooltipCoordinatorHash() =>
    r'f86a33c82490eab409004c59108481108e0bbe7f';

/// TooltipCoordinator - Routes tooltip specs to feature coordinators
///
/// This is the essentials-level entry point for tooltip resolution.
/// It pattern-matches on [TooltipSpec] variants and delegates to the
/// appropriate feature-level coordinator.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Coordinators:
/// - Receive specs
/// - Pattern-match on variants
/// - Route to owning feature's coordinator
/// - Return resolved content
///
/// The coordinator MUST NOT:
/// - Perform IO
/// - Construct widgets
/// - Interpret spec semantics (that's the resolver's job)
///
/// Copied from [TooltipCoordinator].
@ProviderFor(TooltipCoordinator)
final tooltipCoordinatorProvider =
    AutoDisposeNotifierProvider<TooltipCoordinator, void>.internal(
      TooltipCoordinator.new,
      name: r'tooltipCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tooltipCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TooltipCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
