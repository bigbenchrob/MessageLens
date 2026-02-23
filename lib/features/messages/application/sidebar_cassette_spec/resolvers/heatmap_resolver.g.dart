// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$heatmapResolverHash() => r'148125d74a76d73c6bee3fcd5b34cb81b4bea111';

/// Resolves a messages heatmap cassette.
///
/// This resolver produces a [SidebarCassetteCardViewModel] for the calendar
/// heatmap cassette. It decides title/subtitle based on whether the heatmap
/// is contact-scoped or global, then delegates rendering to
/// [MessagesHeatmapWidget].
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Does NOT construct widgets itself (delegates to widget builder)
///
/// Copied from [HeatmapResolver].
@ProviderFor(HeatmapResolver)
final heatmapResolverProvider =
    AutoDisposeNotifierProvider<HeatmapResolver, void>.internal(
      HeatmapResolver.new,
      name: r'heatmapResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$heatmapResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HeatmapResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
